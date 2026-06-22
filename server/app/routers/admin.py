import base64
import json
import logging

from fastapi import APIRouter, Header, HTTPException

from app.config import settings
from app.models.entitlements import Tier
from app.models.schemas import (
    RtdnNotification,
    UsageMeta,
    UserTierRequest,
    UserTierResponse,
)
from app.services.subscription_service import (
    PRODUCT_TIER_MAP,
    activate_subscription,
    expire_subscription,
    verify_purchase_by_token,
)
from app.services.usage_service import (
    ensure_user,
    get_usage_meta,
    set_user_tier,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/admin", tags=["Admin"])

_MODULES = ["job_fit", "profile_boost", "cover_letter"]

# RTDN notification types that mean the subscription is active
_ACTIVE_TYPES = {1, 2, 4, 6, 7}
# Types that mean the subscription is no longer active
_INACTIVE_TYPES = {3, 5, 12, 13, 20}


def _check_admin(secret: str) -> None:
    if not settings.admin_secret:
        raise HTTPException(
            status_code=403,
            detail="Admin access not configured",
        )
    if secret != settings.admin_secret:
        raise HTTPException(
            status_code=403, detail="Invalid admin secret",
        )


@router.post("/set-tier", response_model=UserTierResponse)
async def admin_set_tier(
    body: UserTierRequest,
    x_admin_secret: str = Header(default=""),
    x_user_id: str = Header(default="anonymous"),
) -> UserTierResponse:
    _check_admin(x_admin_secret)

    user_id = x_user_id
    ensure_user(user_id)
    new_tier = Tier(body.tier)
    set_user_tier(user_id, new_tier)

    usage = {
        m: UsageMeta(**get_usage_meta(user_id, m))
        for m in _MODULES
    }
    return UserTierResponse(
        tier=new_tier.value, usage=usage,
    )


@router.post("/rtdn")
async def handle_rtdn(
    body: RtdnNotification,
    x_rtdn_secret: str = Header(default=""),
) -> dict:
    if settings.rtdn_secret:
        if x_rtdn_secret != settings.rtdn_secret:
            raise HTTPException(
                status_code=403,
                detail="Invalid RTDN secret",
            )

    message = body.message
    data_b64 = message.get("data", "")
    if not data_b64:
        logger.warning("RTDN: empty data field")
        return {"status": "ignored", "reason": "empty_data"}

    try:
        raw = base64.b64decode(data_b64)
        payload = json.loads(raw)
    except Exception:
        logger.exception("RTDN: failed to decode payload")
        raise HTTPException(
            status_code=400, detail="Invalid payload",
        )

    sub_info = payload.get("subscriptionNotification", {})
    notification_type = sub_info.get("notificationType")
    purchase_token = sub_info.get("purchaseToken", "")
    subscription_id = sub_info.get("subscriptionId", "")

    logger.info(
        "RTDN received: type=%s product=%s token=%s...",
        notification_type,
        subscription_id,
        purchase_token[:20] if purchase_token else "",
    )

    if not purchase_token or not subscription_id:
        return {"status": "ignored", "reason": "missing_fields"}

    if subscription_id not in PRODUCT_TIER_MAP:
        logger.warning("RTDN: unknown product %s", subscription_id)
        return {"status": "ignored", "reason": "unknown_product"}

    gp = await verify_purchase_by_token(purchase_token, subscription_id)

    if "error" in gp:
        logger.warning("RTDN: verification failed: %s", gp["error"])
        return {
            "status": "received",
            "notification_type": notification_type,
            "verification": gp["error"],
        }

    from app.db import Subscription, get_session
    session = get_session()
    try:
        sub = session.query(Subscription).filter(
            Subscription.purchase_token == purchase_token,
        ).first()
        user_id = sub.user_id if sub else None
    finally:
        session.close()

    if not user_id:
        logger.warning(
            "RTDN: no user found for token %s...",
            purchase_token[:20],
        )
        return {
            "status": "received",
            "notification_type": notification_type,
            "action": "no_user_found",
        }

    if gp["is_active"]:
        tier = activate_subscription(
            user_id=user_id,
            product_id=subscription_id,
            purchase_token=purchase_token,
            expires_at=gp["expiry"],
        )
        action = f"activated_{tier.value}"
    else:
        expire_subscription(user_id, purchase_token)
        action = "expired"

    logger.info(
        "RTDN processed: user=%s action=%s type=%s",
        user_id, action, notification_type,
    )
    return {
        "status": "processed",
        "notification_type": notification_type,
        "subscription_id": subscription_id,
        "action": action,
    }
