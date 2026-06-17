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


def test_job_fit_analyze_en():
    response = client.post(
        "/api/job-fit/analyze",
        json={
            "cv_text": "Experienced python developer with django and flask expertise",
            "job_description": "Looking for a python developer with react and docker experience",
            "language": "en",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert 0 <= data["match_score"] <= 100
    assert "summary" in data
    assert isinstance(data["missing_keywords"], list)


def test_job_fit_analyze_ro():
    response = client.post(
        "/api/job-fit/analyze",
        json={
            "cv_text": "Dezvoltator python experimentat cu experiență în django și flask",
            "job_description": "Căutăm un dezvoltator python cu experiență în react și docker",
            "language": "ro",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "CV-ul" in data["summary"]


def test_job_fit_default_language():
    response = client.post(
        "/api/job-fit/analyze",
        json={
            "cv_text": "Experienced python developer with django and flask expertise",
            "job_description": "Looking for a python developer with react and docker experience",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "Your CV" in data["summary"]


def test_job_fit_validation():
    response = client.post(
        "/api/job-fit/analyze",
        json={"cv_text": "short", "job_description": "short"},
    )
    assert response.status_code == 422


def test_profile_boost_en():
    response = client.post(
        "/api/profile-boost/generate",
        json={
            "headline": "Software Engineer",
            "about": "I build web applications.",
            "experience": "5 years at a tech startup.",
            "language": "en",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["improved_headline"]
    assert data["improved_about"]
    assert isinstance(data["tips"], list)


def test_profile_boost_ro():
    response = client.post(
        "/api/profile-boost/generate",
        json={
            "headline": "Inginer Software",
            "about": "Construiesc aplicații web.",
            "experience": "5 ani într-un startup tech.",
            "language": "ro",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "Rezultate" in data["improved_headline"]


def test_apply_letter_en():
    response = client.post(
        "/api/apply-letter/generate",
        json={
            "cv_text": "Python developer with 5 years experience in django and rest APIs",
            "job_description": "We need a python backend engineer with django experience",
            "tone": "professional",
            "language": "en",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "Dear Hiring Manager" in data["cover_letter"]


def test_apply_letter_ro():
    response = client.post(
        "/api/apply-letter/generate",
        json={
            "cv_text": "Dezvoltator Python cu 5 ani experiență în django și REST APIs",
            "job_description": "Avem nevoie de un inginer backend python cu experiență django",
            "tone": "professional",
            "language": "ro",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "Stimate Angajator" in data["cover_letter"]


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


def test_usage_meta_in_job_fit():
    response = client.post(
        "/api/job-fit/analyze",
        json={
            "cv_text": "Experienced python developer with django expertise",
            "job_description": "Looking for a python developer with react experience",
        },
        headers={"X-Device-Id": "test-usage-jf"},
    )
    assert response.status_code == 200
    data = response.json()
    assert "usage" in data
    assert data["usage"]["tier"] == "free"
    assert data["usage"]["remaining"] >= 0
    assert "show_upgrade" in data["usage"]


def test_entitlements_me():
    response = client.get(
        "/api/entitlements/me",
        headers={"X-Device-Id": "test-ent-me"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["tier"] == "free"
    assert "job_fit" in data["usage"]
    assert "profile_boost" in data["usage"]
    assert "cover_letter" in data["usage"]


def test_entitlements_upgrade():
    response = client.post(
        "/api/entitlements/tier",
        json={"tier": "premium"},
        headers={"X-Device-Id": "test-ent-upgrade"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["tier"] == "premium"

    response = client.get(
        "/api/entitlements/me",
        headers={"X-Device-Id": "test-ent-upgrade"},
    )
    assert response.json()["tier"] == "premium"


def test_free_tier_limit():
    device = "test-free-limit"
    for i in range(5):
        response = client.post(
            "/api/job-fit/analyze",
            json={
                "cv_text": "Experienced python developer with django expertise",
                "job_description": "Looking for a python developer with react",
            },
            headers={"X-Device-Id": device},
        )
        assert response.status_code == 200

    response = client.post(
        "/api/job-fit/analyze",
        json={
            "cv_text": "Experienced python developer with django expertise",
            "job_description": "Looking for a python developer with react",
        },
        headers={"X-Device-Id": device},
    )
    assert response.status_code == 429
