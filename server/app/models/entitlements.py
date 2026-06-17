from enum import Enum

from pydantic import BaseModel


class Tier(str, Enum):
    FREE = "free"
    PREMIUM = "premium"
    PRO = "pro"


class TierLimits(BaseModel):
    max_per_period: int
    period_seconds: int
    burst_max: int = 0
    burst_window_seconds: int = 0
    max_input_chars: int = 0


TIER_LIMITS: dict[Tier, dict[str, TierLimits]] = {
    Tier.FREE: {
        "job_fit": TierLimits(
            max_per_period=5, period_seconds=30 * 24 * 3600,
        ),
        "profile_boost": TierLimits(
            max_per_period=5, period_seconds=30 * 24 * 3600,
        ),
        "cover_letter": TierLimits(
            max_per_period=5, period_seconds=30 * 24 * 3600,
        ),
    },
    Tier.PREMIUM: {
        "job_fit": TierLimits(
            max_per_period=20, period_seconds=24 * 3600,
        ),
        "profile_boost": TierLimits(
            max_per_period=20, period_seconds=24 * 3600,
        ),
        "cover_letter": TierLimits(
            max_per_period=20, period_seconds=24 * 3600,
        ),
    },
    Tier.PRO: {
        "job_fit": TierLimits(
            max_per_period=100,
            period_seconds=24 * 3600,
            burst_max=10,
            burst_window_seconds=600,
            max_input_chars=15000,
        ),
        "profile_boost": TierLimits(
            max_per_period=100,
            period_seconds=24 * 3600,
            burst_max=10,
            burst_window_seconds=600,
            max_input_chars=15000,
        ),
        "cover_letter": TierLimits(
            max_per_period=100,
            period_seconds=24 * 3600,
            burst_max=10,
            burst_window_seconds=600,
            max_input_chars=15000,
        ),
    },
}

TIER_PRICES = {
    Tier.FREE: 0.0,
    Tier.PREMIUM: 3.99,
    Tier.PRO: 9.99,
}
