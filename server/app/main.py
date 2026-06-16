from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import apply_letter, feedback, health, job_fit, profile_boost

app = FastAPI(
    title="Job Pack API",
    description=(
        "Backend for the Job Pack mobile app — "
        "job fit analysis, profile boost, and cover letter generation."
    ),
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(job_fit.router)
app.include_router(profile_boost.router)
app.include_router(apply_letter.router)
app.include_router(feedback.router)
