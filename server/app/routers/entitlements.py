from fastapi import APIRouter, Header

from app.models.entitlements import Tier
from app.models.schemas import (
    UsageMeta,
    UserTierRequest,
    UserTierResponse,
)
from app.services.usage_service import (
    get_usage_meta,
    get_user_tier,
    set_user_tier,
)

router = APIRouter(
    prefix="/api/entitlements", tags=["Entitlements"],
)

_MODULES = ["job_fit", "profile_boost", "cover_letter"]


@router.get("/me", response_model=UserTierResponse)
async def get_my_tier(
    x_device_id: str = Header(default="anonymous"),
) -> UserTierResponse:
    user_id = x_device_id
    tier = get_user_tier(user_id)
    usage = {
        m: UsageMeta(**get_usage_meta(user_id, m))
        for m in _MODULES
    }
    return UserTierResponse(tier=tier.value, usage=usage)


@router.post("/tier", response_model=UserTierResponse)
async def update_tier(
    body: UserTierRequest,
    x_device_id: str = Header(default="anonymous"),
) -> UserTierResponse:
    user_id = x_device_id
    new_tier = Tier(body.tier)
    set_user_tier(user_id, new_tier)
    usage = {
        m: UsageMeta(**get_usage_meta(user_id, m))
        for m in _MODULES
    }
    return UserTierResponse(tier=new_tier.value, usage=usage)
