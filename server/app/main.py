from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.db import dispose_engine, init_db
from app.routers import (
    admin,
    apply_letter,
    entitlements,
    feedback,
    health,
    job_fit,
    profile_boost,
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    yield
    dispose_engine()


app = FastAPI(
    title="Job Coach API",
    description=(
        "Backend for the Job Coach mobile app — "
        "job fit analysis, profile boost, "
        "and cover letter generation."
    ),
    version="0.3.0",
    lifespan=lifespan,
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
app.include_router(entitlements.router)
app.include_router(admin.router)
