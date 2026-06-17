import logging

from fastapi import APIRouter, Header

from app.models.schemas import (
    UsageMeta,
    UserTierResponse,
    VerifyPurchaseRequest,
    VerifyPurchaseResponse,
)
from app.services.subscription_service import (
    get_active_subscription,
    verify_purchase,
)
from app.services.usage_service import (
    ensure_user,
    get_usage_meta,
    get_user_tier,
)

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/entitlements", tags=["Entitlements"],
)

_MODULES = ["job_fit", "profile_boost", "cover_letter"]


def _resolve_user(
    x_user_id: str, x_device_id: str,
) -> str:
    user_id = x_user_id if x_user_id != "anonymous" else (
        x_device_id if x_device_id != "anonymous"
        else "anonymous"
    )
    ensure_user(user_id, x_device_id)
    return user_id


@router.get("/me", response_model=UserTierResponse)
async def get_my_tier(
    x_user_id: str = Header(default="anonymous"),
    x_device_id: str = Header(default="anonymous"),
) -> UserTierResponse:
    user_id = _resolve_user(x_user_id, x_device_id)
    tier = get_user_tier(user_id)
    usage = {
        m: UsageMeta(**get_usage_meta(user_id, m))
        for m in _MODULES
    }
    sub = get_active_subscription(user_id)
    return UserTierResponse(
        tier=tier.value, usage=usage, subscription=sub,
    )


@router.post(
    "/verify-purchase",
    response_model=VerifyPurchaseResponse,
)
async def verify_purchase_endpoint(
    body: VerifyPurchaseRequest,
    x_user_id: str = Header(default="anonymous"),
    x_device_id: str = Header(default="anonymous"),
) -> VerifyPurchaseResponse:
    user_id = _resolve_user(x_user_id, x_device_id)

    result = await verify_purchase(
        user_id=user_id,
        product_id=body.product_id,
        purchase_token=body.purchase_token,
    )

    tier = get_user_tier(user_id)
    return VerifyPurchaseResponse(
        valid=result.get("valid", False),
        tier=tier.value,
        error=result.get("error", ""),
        message=result.get("message", ""),
    )
