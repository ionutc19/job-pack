import time

from app.db import get_conn
from app.models.entitlements import (
    TIER_LIMITS,
    Tier,
)


def ensure_user(user_id: str, device_id: str = "") -> None:
    conn = get_conn()
    conn.execute(
        "INSERT OR IGNORE INTO users (user_id, device_id) "
        "VALUES (?, ?)",
        (user_id, device_id),
    )
    if device_id:
        conn.execute(
            "UPDATE users SET device_id = ?, "
            "updated_at = datetime('now') "
            "WHERE user_id = ? AND (device_id IS NULL "
            "OR device_id = '' OR device_id != ?)",
            (device_id, user_id, device_id),
        )
    conn.commit()


def get_user_tier(user_id: str) -> Tier:
    conn = get_conn()
    row = conn.execute(
        "SELECT tier FROM users WHERE user_id = ?",
        (user_id,),
    ).fetchone()
    if not row:
        return Tier.FREE
    try:
        return Tier(row["tier"])
    except ValueError:
        return Tier.FREE


def set_user_tier(user_id: str, tier: Tier) -> None:
    conn = get_conn()
    conn.execute(
        "UPDATE users SET tier = ?, "
        "updated_at = datetime('now') WHERE user_id = ?",
        (tier.value, user_id),
    )
    conn.commit()


def _count_in_window(
    user_id: str, module: str, window_seconds: int,
) -> int:
    cutoff = time.time() - window_seconds
    conn = get_conn()
    row = conn.execute(
        "SELECT COUNT(*) as cnt FROM usage_events "
        "WHERE user_id = ? AND module = ? AND ts > ?",
        (user_id, module, cutoff),
    ).fetchone()
    return row["cnt"] if row else 0


def _count_all_modules_in_window(
    user_id: str, window_seconds: int,
) -> int:
    cutoff = time.time() - window_seconds
    conn = get_conn()
    row = conn.execute(
        "SELECT COUNT(*) as cnt FROM usage_events "
        "WHERE user_id = ? AND ts > ?",
        (user_id, cutoff),
    ).fetchone()
    return row["cnt"] if row else 0


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
    conn = get_conn()
    conn.execute(
        "INSERT INTO usage_events (user_id, module, ts) "
        "VALUES (?, ?, ?)",
        (user_id, module, time.time()),
    )
    conn.commit()


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
    conn = get_conn()
    cursor = conn.execute(
        "DELETE FROM usage_events WHERE ts < ?",
        (cutoff,),
    )
    conn.commit()
    return cursor.rowcount
