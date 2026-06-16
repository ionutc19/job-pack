from fastapi import APIRouter

from app.models.schemas import JobFitRequest, JobFitResponse
from app.services.ai_service import analyze_job_fit

router = APIRouter(prefix="/api/job-fit", tags=["Job Fit"])


@router.post("/analyze", response_model=JobFitResponse)
async def analyze(request: JobFitRequest) -> JobFitResponse:
    return analyze_job_fit(request)
