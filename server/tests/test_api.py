import pytest
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health():
    response = client.get("/api/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "version" in data


def test_job_fit_analyze():
    response = client.post(
        "/api/job-fit/analyze",
        json={
            "cv_text": "Experienced python developer with django and flask expertise",
            "job_description": "Looking for a python developer with react and docker experience",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert 0 <= data["match_score"] <= 100
    assert "summary" in data
    assert isinstance(data["missing_keywords"], list)


def test_job_fit_validation():
    response = client.post(
        "/api/job-fit/analyze",
        json={"cv_text": "short", "job_description": "short"},
    )
    assert response.status_code == 422


def test_profile_boost():
    response = client.post(
        "/api/profile-boost/generate",
        json={
            "headline": "Software Engineer",
            "about": "I build web applications.",
            "experience": "5 years at a tech startup.",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["improved_headline"]
    assert data["improved_about"]
    assert isinstance(data["tips"], list)


def test_apply_letter():
    response = client.post(
        "/api/apply-letter/generate",
        json={
            "cv_text": "Python developer with 5 years experience in django and rest APIs",
            "job_description": "We need a python backend engineer with django experience",
            "tone": "professional",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "Dear Hiring Manager" in data["cover_letter"]


def test_apply_letter_invalid_tone():
    response = client.post(
        "/api/apply-letter/generate",
        json={
            "cv_text": "Python developer with experience",
            "job_description": "Looking for a developer",
            "tone": "angry",
        },
    )
    assert response.status_code == 422


def test_feedback_no_github_token():
    response = client.post(
        "/api/feedback",
        json={
            "category": "bug",
            "title": "App crashes on startup",
            "description": "The app crashes every time I open the job fit screen on Android 14.",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is False
    assert "not configured" in data["message"]


@pytest.mark.parametrize("category", ["bug", "feature", "feedback"])
def test_feedback_categories(category: str):
    response = client.post(
        "/api/feedback",
        json={
            "category": category,
            "title": f"Test {category} report",
            "description": "This is a test feedback submission for validation.",
        },
    )
    assert response.status_code == 200
