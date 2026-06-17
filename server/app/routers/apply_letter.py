from fastapi import APIRouter

from app.models.schemas import ApplyLetterRequest, ApplyLetterResponse
from app.services.ai_service import generate_cover_letter

router = APIRouter(prefix="/api/apply-letter", tags=["Apply Letter"])


@router.post("/generate", response_model=ApplyLetterResponse)
async def generate(request: ApplyLetterRequest) -> ApplyLetterResponse:
    return await generate_cover_letter(request)
