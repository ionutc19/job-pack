from pydantic import BaseModel, Field


class UsageMeta(BaseModel):
    tier: str = "free"
    used: int = 0
    remaining: int = 5
    period_seconds: int = 2592000
    show_upgrade: bool = True


class JobFitRequest(BaseModel):
    cv_text: str = Field(
        ..., min_length=10, description="CV/resume content",
    )
    job_description: str = Field(
        ..., min_length=10, description="Job posting text",
    )
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
    usage: UsageMeta | None = None


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
    usage: UsageMeta | None = None


class ApplyLetterRequest(BaseModel):
    cv_text: str = Field(..., min_length=10)
    job_description: str = Field(..., min_length=10)
    tone: str = Field(
        default="professional",
        pattern="^(professional|casual|enthusiastic)$",
    )
    language: str = Field(default="en", pattern="^(en|ro)$")


class ApplyLetterResponse(BaseModel):
    cover_letter: str
    usage: UsageMeta | None = None


class FeedbackRequest(BaseModel):
    category: str = Field(
        ..., pattern="^(bug|feature|feedback)$",
    )
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


class UserTierRequest(BaseModel):
    tier: str = Field(pattern="^(free|premium|pro)$")


class UserTierResponse(BaseModel):
    tier: str
    usage: dict[str, UsageMeta]
    subscription: dict | None = None


class VerifyPurchaseRequest(BaseModel):
    product_id: str = Field(
        ...,
        pattern=(
            "^(jobcoach_premium_monthly"
            "|jobcoach_pro_monthly)$"
        ),
    )
    purchase_token: str = Field(..., min_length=1)


class VerifyPurchaseResponse(BaseModel):
    valid: bool
    tier: str = "free"
    error: str = ""
    message: str = ""


class RtdnNotification(BaseModel):
    message: dict
    subscription: str = ""
