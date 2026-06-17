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
from app.services.usage_service import (
    ensure_user,
    get_usage_meta,
    set_user_tier,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/admin", tags=["Admin"])

_MODULES = ["job_fit", "profile_boost", "cover_letter"]


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

    notification_type = payload.get(
        "subscriptionNotification", {},
    ).get("notificationType")
    sub_info = payload.get("subscriptionNotification", {})
    purchase_token = sub_info.get("purchaseToken", "")
    subscription_id = sub_info.get("subscriptionId", "")

    logger.info(
        "RTDN received: type=%s product=%s token=%s...",
        notification_type,
        subscription_id,
        purchase_token[:20] if purchase_token else "",
    )

    # Notification types:
    # 1=RECOVERED, 2=RENEWED, 3=CANCELED, 4=PURCHASED,
    # 5=ON_HOLD, 6=IN_GRACE_PERIOD, 7=RESTARTED,
    # 9=DEFERRED, 10=PAUSED, 11=PAUSE_SCHEDULE_CHANGED,
    # 12=REVOKED, 13=EXPIRED, 20=PENDING_PURCHASE_CANCELED

    # TODO: Once Google Play credentials are configured,
    # call the Play Developer API here to get the
    # authoritative subscription state, then call
    # activate_subscription() or expire_subscription()
    # accordingly. Do NOT trust the RTDN payload alone.

    return {
        "status": "received",
        "notification_type": notification_type,
        "subscription_id": subscription_id,
    }
