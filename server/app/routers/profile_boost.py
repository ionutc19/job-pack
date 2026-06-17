from fastapi import APIRouter

from app.models.schemas import ProfileBoostRequest, ProfileBoostResponse
from app.services.ai_service import generate_profile_boost

router = APIRouter(prefix="/api/profile-boost", tags=["Profile Boost"])


@router.post("/generate", response_model=ProfileBoostResponse)
async def generate(request: ProfileBoostRequest) -> ProfileBoostResponse:
    return await generate_profile_boost(request)
