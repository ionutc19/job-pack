import logging
from datetime import datetime

from app.config import settings
from app.db import get_conn
from app.models.entitlements import Tier

logger = logging.getLogger(__name__)

PRODUCT_TIER_MAP: dict[str, Tier] = {
    "jobcoach_premium_monthly": Tier.PREMIUM,
    "jobcoach_pro_monthly": Tier.PRO,
}


def _play_api_configured() -> bool:
    return bool(settings.google_play_credentials_json)


async def verify_purchase(
    user_id: str,
    product_id: str,
    purchase_token: str,
) -> dict:
    tier = PRODUCT_TIER_MAP.get(product_id)
    if not tier:
        return {
            "valid": False,
            "error": "unknown_product",
        }

    if not _play_api_configured():
        logger.warning(
            "Google Play credentials not configured; "
            "storing purchase as pending verification",
        )
        _store_subscription(
            user_id=user_id,
            product_id=product_id,
            purchase_token=purchase_token,
            status="pending_verification",
            tier=tier,
        )
        return {
            "valid": False,
            "error": "verification_unavailable",
            "message": (
                "Play credentials not configured. "
                "Purchase stored for later verification."
            ),
        }

    # TODO: Call Google Play Developer API to verify
    # subscription_response = await _call_play_api(
    #     package_name=settings.google_play_package,
    #     subscription_id=product_id,
    #     token=purchase_token,
    # )
    # For now, log and store as pending:
    logger.info(
        "Would verify purchase: product=%s token=%s...",
        product_id, purchase_token[:20],
    )

    _store_subscription(
        user_id=user_id,
        product_id=product_id,
        purchase_token=purchase_token,
        status="pending_verification",
        tier=tier,
    )

    return {
        "valid": False,
        "error": "verification_not_implemented",
        "message": (
            "Play API verification scaffolded but "
            "not yet active. Purchase stored."
        ),
    }


def _store_subscription(
    user_id: str,
    product_id: str,
    purchase_token: str,
    status: str,
    tier: Tier,
    expires_at: str | None = None,
) -> None:
    conn = get_conn()
    existing = conn.execute(
        "SELECT id FROM subscriptions "
        "WHERE user_id = ? AND product_id = ? "
        "AND purchase_token = ?",
        (user_id, product_id, purchase_token),
    ).fetchone()

    now = datetime.utcnow().isoformat()

    if existing:
        conn.execute(
            "UPDATE subscriptions SET status = ?, "
            "expires_at = ?, updated_at = ? WHERE id = ?",
            (status, expires_at, now, existing["id"]),
        )
    else:
        conn.execute(
            "INSERT INTO subscriptions "
            "(user_id, product_id, purchase_token, "
            "status, tier, started_at, expires_at) "
            "VALUES (?, ?, ?, ?, ?, ?, ?)",
            (
                user_id, product_id, purchase_token,
                status, tier.value, now, expires_at,
            ),
        )
    conn.commit()


def activate_subscription(
    user_id: str,
    product_id: str,
    purchase_token: str,
    expires_at: str | None = None,
) -> Tier:
    tier = PRODUCT_TIER_MAP.get(product_id, Tier.FREE)

    _store_subscription(
        user_id=user_id,
        product_id=product_id,
        purchase_token=purchase_token,
        status="active",
        tier=tier,
        expires_at=expires_at,
    )

    conn = get_conn()
    conn.execute(
        "UPDATE users SET tier = ?, "
        "updated_at = datetime('now') WHERE user_id = ?",
        (tier.value, user_id),
    )
    conn.commit()

    logger.info(
        "Subscription activated: user=%s tier=%s product=%s",
        user_id, tier.value, product_id,
    )
    return tier


def expire_subscription(
    user_id: str, purchase_token: str,
) -> None:
    conn = get_conn()
    conn.execute(
        "UPDATE subscriptions SET status = 'expired', "
        "updated_at = datetime('now') "
        "WHERE user_id = ? AND purchase_token = ?",
        (user_id, purchase_token),
    )

    active = conn.execute(
        "SELECT id FROM subscriptions "
        "WHERE user_id = ? AND status = 'active'",
        (user_id,),
    ).fetchone()

    if not active:
        conn.execute(
            "UPDATE users SET tier = 'free', "
            "updated_at = datetime('now') WHERE user_id = ?",
            (user_id,),
        )

    conn.commit()
    logger.info(
        "Subscription expired: user=%s token=%s...",
        user_id, purchase_token[:20] if purchase_token else "",
    )


def get_active_subscription(user_id: str) -> dict | None:
    conn = get_conn()
    row = conn.execute(
        "SELECT product_id, status, tier, "
        "started_at, expires_at "
        "FROM subscriptions WHERE user_id = ? "
        "AND status = 'active' "
        "ORDER BY created_at DESC LIMIT 1",
        (user_id,),
    ).fetchone()
    if not row:
        return None
    return dict(row)
