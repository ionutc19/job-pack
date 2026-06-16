from pydantic import BaseModel, Field


class JobFitRequest(BaseModel):
    cv_text: str = Field(..., min_length=10, description="CV/resume content")
    job_description: str = Field(..., min_length=10, description="Job posting text")
    language: str = Field(default="en", pattern="^(en|ro)$")


class KeywordGap(BaseModel):
    keyword: str
    importance: str = Field(description="high, medium, or low")


class BulletSuggestion(BaseModel):
    original: str
    improved: str


class JobFitResponse(BaseModel):
    match_score: int = Field(ge=0, le=100)
    summary: str
    missing_keywords: list[KeywordGap]
    bullet_suggestions: list[BulletSuggestion]


class ProfileBoostRequest(BaseModel):
    headline: str = ""
    about: str = ""
    experience: str = ""
    language: str = Field(default="en", pattern="^(en|ro)$")


class ProfileBoostResponse(BaseModel):
    improved_headline: str
    improved_about: str
    improved_experience: str
    tips: list[str]


class ApplyLetterRequest(BaseModel):
    cv_text: str = Field(..., min_length=10)
    job_description: str = Field(..., min_length=10)
    tone: str = Field(default="professional", pattern="^(professional|casual|enthusiastic)$")
    language: str = Field(default="en", pattern="^(en|ro)$")


class ApplyLetterResponse(BaseModel):
    cover_letter: str


class FeedbackRequest(BaseModel):
    category: str = Field(..., pattern="^(bug|feature|feedback)$")
    title: str = Field(..., min_length=3, max_length=200)
    description: str = Field(..., min_length=10)
    email: str = ""


class FeedbackResponse(BaseModel):
    success: bool
    message: str
    issue_url: str = ""


class HealthResponse(BaseModel):
    status: str
    version: str
