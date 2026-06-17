from fastapi import APIRouter, Header, HTTPException

from app.models.schemas import (
    ProfileBoostRequest,
    ProfileBoostResponse,
    UsageMeta,
)
from app.services.ai_service import generate_profile_boost
from app.services.usage_service import (
    check_input_length,
    check_usage,
    get_usage_meta,
    get_user_tier,
    record_usage,
)

router = APIRouter(
    prefix="/api/profile-boost", tags=["Profile Boost"],
)

MODULE = "profile_boost"


@router.post("/generate", response_model=ProfileBoostResponse)
async def generate(
    request: ProfileBoostRequest,
    x_device_id: str = Header(default="anonymous"),
) -> ProfileBoostResponse:
    user_id = x_device_id
    tier = get_user_tier(user_id)

    input_len = (
        len(request.headline)
        + len(request.about)
        + len(request.experience)
    )
    if not check_input_length(tier, MODULE, input_len):
        raise HTTPException(
            status_code=413,
            detail="Input too long for your plan",
        )

    allowed, reason, _remaining = check_usage(user_id, MODULE)
    if not allowed:
        meta = get_usage_meta(user_id, MODULE)
        raise HTTPException(
            status_code=429,
            detail={
                "message": "Usage limit reached",
                "reason": reason,
                "usage": meta,
            },
        )

    result = await generate_profile_boost(request)
    record_usage(user_id, MODULE)
    result.usage = UsageMeta(**get_usage_meta(user_id, MODULE))
    return result
