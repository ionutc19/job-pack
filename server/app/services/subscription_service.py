import logging
from datetime import datetime, timezone

from sqlalchemy import and_

from app.config import settings
from app.db import Subscription, User, get_session
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
    expires_at: datetime | None = None,
) -> None:
    session = get_session()
    try:
        existing = session.query(Subscription).filter(
            and_(
                Subscription.user_id == user_id,
                Subscription.product_id == product_id,
                Subscription.purchase_token == purchase_token,
            ),
        ).first()

        now = datetime.now(timezone.utc)

        if existing:
            existing.status = status
            existing.expires_at = expires_at
            existing.updated_at = now
        else:
            sub = Subscription(
                user_id=user_id,
                product_id=product_id,
                purchase_token=purchase_token,
                status=status,
                tier=tier.value,
                started_at=now,
                expires_at=expires_at,
            )
            session.add(sub)
        session.commit()
    finally:
        session.close()


def activate_subscription(
    user_id: str,
    product_id: str,
    purchase_token: str,
    expires_at: datetime | None = None,
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

    session = get_session()
    try:
        user = session.get(User, user_id)
        if user:
            user.tier = tier.value
            session.commit()
    finally:
        session.close()

    logger.info(
        "Subscription activated: user=%s tier=%s product=%s",
        user_id, tier.value, product_id,
    )
    return tier


def expire_subscription(
    user_id: str, purchase_token: str,
) -> None:
    session = get_session()
    try:
        now = datetime.now(timezone.utc)
        session.query(Subscription).filter(
            and_(
                Subscription.user_id == user_id,
                Subscription.purchase_token == purchase_token,
            ),
        ).update({"status": "expired", "updated_at": now})

        active = session.query(Subscription).filter(
            and_(
                Subscription.user_id == user_id,
                Subscription.status == "active",
            ),
        ).first()

        if not active:
            user = session.get(User, user_id)
            if user:
                user.tier = "free"

        session.commit()
    finally:
        session.close()

    logger.info(
        "Subscription expired: user=%s token=%s...",
        user_id, purchase_token[:20] if purchase_token else "",
    )


def get_active_subscription(user_id: str) -> dict | None:
    session = get_session()
    try:
        sub = session.query(Subscription).filter(
            and_(
                Subscription.user_id == user_id,
                Subscription.status == "active",
            ),
        ).order_by(Subscription.created_at.desc()).first()

        if not sub:
            return None
        return {
            "product_id": sub.product_id,
            "status": sub.status,
            "tier": sub.tier,
            "started_at": sub.started_at.isoformat() if sub.started_at else None,
            "expires_at": sub.expires_at.isoformat() if sub.expires_at else None,
        }
    finally:
        session.close()
