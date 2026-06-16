import httpx

from app.config import settings
from app.models.schemas import FeedbackRequest, FeedbackResponse


async def create_github_issue(request: FeedbackRequest) -> FeedbackResponse:
    """Create a GitHub issue from user feedback."""
    if not settings.github_token:
        return FeedbackResponse(
            success=False,
            message="GitHub integration not configured. Feedback received but issue not created.",
        )

    label_map = {
        "bug": ["bug"],
        "feature": ["enhancement"],
        "feedback": ["feedback"],
    }

    body = f"**Category:** {request.category}\n\n{request.description}"
    if request.email:
        body += f"\n\n**Submitted by:** {request.email}"

    url = f"https://api.github.com/repos/{settings.github_repo_owner}/{settings.github_repo_name}/issues"
    headers = {
        "Authorization": f"Bearer {settings.github_token}",
        "Accept": "application/vnd.github+json",
    }
    payload = {
        "title": f"[{request.category.upper()}] {request.title}",
        "body": body,
        "labels": label_map.get(request.category, []),
    }

    try:
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.post(url, json=payload, headers=headers)
            response.raise_for_status()
            issue_data = response.json()
            return FeedbackResponse(
                success=True,
                message="Thank you! Your feedback has been submitted.",
                issue_url=issue_data.get("html_url", ""),
            )
    except httpx.HTTPError:
        return FeedbackResponse(
            success=False,
            message=(
                "Failed to create GitHub issue. "
                "Your feedback was received but could not be tracked."
            ),
        )
