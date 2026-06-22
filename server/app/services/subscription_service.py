import json
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

_play_service = None


def _play_api_configured() -> bool:
    return bool(settings.google_play_credentials_json)


def _get_play_service():
    global _play_service
    if _play_service is not None:
        return _play_service

    from google.oauth2.service_account import Credentials
    from googleapiclient.discovery import build

    creds_raw = settings.google_play_credentials_json
    creds_dict = json.loads(creds_raw)
    credentials = Credentials.from_service_account_info(
        creds_dict,
        scopes=["https://www.googleapis.com/auth/androidpublisher"],
    )
    _play_service = build(
        "androidpublisher", "v3", credentials=credentials,
        cache_discovery=False,
    )
    return _play_service


def _verify_with_google(product_id: str, purchase_token: str) -> dict:
    """Call Google Play Developer API to verify a subscription purchase."""
    service = _get_play_service()
    package = settings.google_play_package

    result = (
        service.purchases()
        .subscriptions()
        .get(
            packageName=package,
            subscriptionId=product_id,
            token=purchase_token,
        )
        .execute()
    )

    payment_state = result.get("paymentState")
    cancel_reason = result.get("cancelReason")
    expiry_ms = int(result.get("expiryTimeMillis", 0))
    expiry_dt = (
        datetime.fromtimestamp(expiry_ms / 1000, tz=timezone.utc)
        if expiry_ms
        else None
    )

    # paymentState: 0=pending, 1=received, 2=free_trial, 3=deferred
    # cancelReason: 0=user, 1=system, 2=replaced, 3=developer
    is_active = (
        payment_state in (1, 2)
        and (expiry_dt is None or expiry_dt > datetime.now(timezone.utc))
    )

    return {
        "is_active": is_active,
        "expiry": expiry_dt,
        "payment_state": payment_state,
        "cancel_reason": cancel_reason,
        "raw_expiry_ms": expiry_ms,
    }


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

    try:
        gp = _verify_with_google(product_id, purchase_token)
    except Exception:
        logger.exception(
            "Google Play API error for product=%s user=%s",
            product_id, user_id,
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
            "error": "verification_failed",
            "message": "Could not reach Google Play. Purchase stored for retry.",
        }

    if gp["is_active"]:
        activate_subscription(
            user_id=user_id,
            product_id=product_id,
            purchase_token=purchase_token,
            expires_at=gp["expiry"],
        )
        logger.info(
            "Purchase verified: user=%s product=%s tier=%s expires=%s",
            user_id, product_id, tier.value, gp["expiry"],
        )
        return {
            "valid": True,
            "tier": tier.value,
            "expires_at": gp["expiry"].isoformat() if gp["expiry"] else None,
        }

    _store_subscription(
        user_id=user_id,
        product_id=product_id,
        purchase_token=purchase_token,
        status="expired",
        tier=tier,
        expires_at=gp["expiry"],
    )
    logger.info(
        "Purchase not active: user=%s product=%s payment_state=%s cancel=%s",
        user_id, product_id, gp["payment_state"], gp["cancel_reason"],
    )
    return {
        "valid": False,
        "error": "purchase_not_active",
        "message": "Subscription is not active or has expired.",
    }


async def verify_purchase_by_token(
    purchase_token: str, product_id: str,
) -> dict:
    """Verify a subscription by token only (for RTDN handler).
    Returns the Google Play result without modifying any user state."""
    if not _play_api_configured():
        return {"error": "verification_unavailable"}

    try:
        return _verify_with_google(product_id, purchase_token)
    except Exception:
        logger.exception("Google Play API error during RTDN verification")
        return {"error": "verification_failed"}


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
