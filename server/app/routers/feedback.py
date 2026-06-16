from fastapi import APIRouter

from app.models.schemas import FeedbackRequest, FeedbackResponse
from app.services.github_service import create_github_issue

router = APIRouter(prefix="/api", tags=["Feedback"])


@router.post("/feedback", response_model=FeedbackResponse)
async def submit_feedback(request: FeedbackRequest) -> FeedbackResponse:
    return await create_github_issue(request)
