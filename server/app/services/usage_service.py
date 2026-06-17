import time
from collections import defaultdict

from app.models.entitlements import (
    TIER_LIMITS,
    Tier,
)


class _UserUsage:
    def __init__(self) -> None:
        self.timestamps: list[float] = []

    def count_in_window(self, window_seconds: int) -> int:
        cutoff = time.time() - window_seconds
        self.timestamps = [
            t for t in self.timestamps if t > cutoff
        ]
        return len(self.timestamps)

    def record(self) -> None:
        self.timestamps.append(time.time())


_usage: dict[str, dict[str, _UserUsage]] = defaultdict(
    lambda: defaultdict(_UserUsage),
)

_user_tiers: dict[str, Tier] = {}


def get_user_tier(user_id: str) -> Tier:
    return _user_tiers.get(user_id, Tier.FREE)


def set_user_tier(user_id: str, tier: Tier) -> None:
    _user_tiers[user_id] = tier


def check_usage(
    user_id: str, module: str,
) -> tuple[bool, str, int]:
    tier = get_user_tier(user_id)
    limits = TIER_LIMITS[tier].get(module)
    if not limits:
        return True, "", 0

    user_module = _usage[user_id][module]
    used = user_module.count_in_window(limits.period_seconds)

    if used >= limits.max_per_period:
        remaining = 0
        return False, "period_limit", remaining

    if tier == Tier.PRO and limits.burst_max > 0:
        all_modules = _usage[user_id]
        total_day = sum(
            m.count_in_window(limits.period_seconds)
            for m in all_modules.values()
        )
        if total_day >= limits.max_per_period:
            return False, "daily_total_limit", 0

        burst_total = sum(
            m.count_in_window(limits.burst_window_seconds)
            for m in all_modules.values()
        )
        if burst_total >= limits.burst_max:
            return False, "burst_limit", 0

    remaining = limits.max_per_period - used
    return True, "", remaining


def record_usage(user_id: str, module: str) -> None:
    _usage[user_id][module].record()


def get_usage_meta(
    user_id: str, module: str,
) -> dict:
    tier = get_user_tier(user_id)
    limits = TIER_LIMITS[tier].get(module)
    if not limits:
        return _build_meta(tier, 0, 0, 0)

    user_module = _usage[user_id][module]
    used = user_module.count_in_window(limits.period_seconds)
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
        "show_upgrade": tier == Tier.FREE,
    }


def check_input_length(
    tier: Tier, module: str, input_chars: int,
) -> bool:
    limits = TIER_LIMITS[tier].get(module)
    if not limits or limits.max_input_chars == 0:
        return True
    return input_chars <= limits.max_input_chars
