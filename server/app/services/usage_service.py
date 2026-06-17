import time

from sqlalchemy import func

from app.db import UsageEvent, User, get_session
from app.models.entitlements import (
    TIER_LIMITS,
    Tier,
)


def ensure_user(user_id: str, device_id: str = "") -> None:
    session = get_session()
    try:
        user = session.get(User, user_id)
        if user is None:
            user = User(user_id=user_id, device_id=device_id or None)
            session.add(user)
        elif device_id and user.device_id != device_id:
            user.device_id = device_id
        session.commit()
    finally:
        session.close()


def get_user_tier(user_id: str) -> Tier:
    session = get_session()
    try:
        user = session.get(User, user_id)
        if not user:
            return Tier.FREE
        try:
            return Tier(user.tier)
        except ValueError:
            return Tier.FREE
    finally:
        session.close()


def set_user_tier(user_id: str, tier: Tier) -> None:
    session = get_session()
    try:
        user = session.get(User, user_id)
        if user:
            user.tier = tier.value
            session.commit()
    finally:
        session.close()


def _count_in_window(
    user_id: str, module: str, window_seconds: int,
) -> int:
    cutoff = time.time() - window_seconds
    session = get_session()
    try:
        count = session.query(func.count(UsageEvent.id)).filter(
            UsageEvent.user_id == user_id,
            UsageEvent.module == module,
            UsageEvent.ts > cutoff,
        ).scalar()
        return count or 0
    finally:
        session.close()


def _count_all_modules_in_window(
    user_id: str, window_seconds: int,
) -> int:
    cutoff = time.time() - window_seconds
    session = get_session()
    try:
        count = session.query(func.count(UsageEvent.id)).filter(
            UsageEvent.user_id == user_id,
            UsageEvent.ts > cutoff,
        ).scalar()
        return count or 0
    finally:
        session.close()


def check_usage(
    user_id: str, module: str,
) -> tuple[bool, str, int]:
    tier = get_user_tier(user_id)
    limits = TIER_LIMITS[tier].get(module)
    if not limits:
        return True, "", 0

    used = _count_in_window(
        user_id, module, limits.period_seconds,
    )

    if used >= limits.max_per_period:
        return False, "period_limit", 0

    if tier == Tier.PRO and limits.burst_max > 0:
        total_day = _count_all_modules_in_window(
            user_id, limits.period_seconds,
        )
        if total_day >= limits.max_per_period:
            return False, "daily_total_limit", 0

        burst_total = _count_all_modules_in_window(
            user_id, limits.burst_window_seconds,
        )
        if burst_total >= limits.burst_max:
            return False, "burst_limit", 0

    remaining = limits.max_per_period - used
    return True, "", remaining


def record_usage(user_id: str, module: str) -> None:
    session = get_session()
    try:
        event = UsageEvent(user_id=user_id, module=module, ts=time.time())
        session.add(event)
        session.commit()
    finally:
        session.close()


def get_usage_meta(user_id: str, module: str) -> dict:
    tier = get_user_tier(user_id)
    limits = TIER_LIMITS[tier].get(module)
    if not limits:
        return _build_meta(tier, 0, 0, 0)

    used = _count_in_window(
        user_id, module, limits.period_seconds,
    )
    remaining = max(0, limits.max_per_period - used)

    return _build_meta(
        tier, used, remaining, limits.period_seconds,
    )


def _build_meta(
    tier: Tier,
    used: int,
    remaining: int,
    period_seconds: int,
) -> dict:
    return {
        "tier": tier.value,
        "used": used,
        "remaining": remaining,
        "period_seconds": period_seconds,
        "show_upgrade": tier in (Tier.FREE, Tier.PREMIUM),
    }


def check_input_length(
    tier: Tier, module: str, input_chars: int,
) -> bool:
    limits = TIER_LIMITS[tier].get(module)
    if not limits or limits.max_input_chars == 0:
        return True
    return input_chars <= limits.max_input_chars


def cleanup_old_events(days: int = 90) -> int:
    cutoff = time.time() - (days * 24 * 3600)
    session = get_session()
    try:
        count = session.query(UsageEvent).filter(
            UsageEvent.ts < cutoff,
        ).delete()
        session.commit()
        return count
    finally:
        session.close()
