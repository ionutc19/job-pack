from app.models.schemas import (
    ApplyLetterRequest,
    ApplyLetterResponse,
    BulletSuggestion,
    JobFitRequest,
    JobFitResponse,
    KeywordGap,
    ProfileBoostRequest,
    ProfileBoostResponse,
)


def _extract_keywords(text: str) -> set[str]:
    common_tech = {
        "python", "java", "javascript", "typescript", "react", "angular",
        "vue", "node", "django", "flask", "fastapi", "sql", "nosql",
        "aws", "azure", "gcp", "docker", "kubernetes", "ci/cd", "git",
        "agile", "scrum", "rest", "graphql", "machine learning", "ai",
        "data analysis", "project management", "leadership", "communication",
    }
    words = set(text.lower().split())
    return words & common_tech


def analyze_job_fit(request: JobFitRequest) -> JobFitResponse:
    """Rule-based mock: compare CV keywords against job description."""
    cv_keywords = _extract_keywords(request.cv_text)
    jd_keywords = _extract_keywords(request.job_description)

    if not jd_keywords:
        match_score = 50
    else:
        overlap = cv_keywords & jd_keywords
        match_score = min(int((len(overlap) / len(jd_keywords)) * 100), 100)

    missing = jd_keywords - cv_keywords
    missing_keywords = [
        KeywordGap(keyword=kw, importance="high") for kw in sorted(missing)[:5]
    ]

    bullet_suggestions = []
    if missing:
        sample = sorted(missing)[0]
        bullet_suggestions.append(
            BulletSuggestion(
                original="Worked on various projects",
                improved=(
                    f"Led cross-functional projects leveraging {sample} "
                    "to deliver measurable outcomes"
                ),
            )
        )

    return JobFitResponse(
        match_score=match_score,
        summary=(
            f"Your CV matches {match_score}% of the job requirements. "
            f"Found {len(cv_keywords & jd_keywords)} matching keywords "
            f"out of {len(jd_keywords)} required."
        ),
        missing_keywords=missing_keywords,
        bullet_suggestions=bullet_suggestions,
    )


def generate_profile_boost(request: ProfileBoostRequest) -> ProfileBoostResponse:
    """Rule-based mock for LinkedIn profile improvements."""
    headline = request.headline or "Professional"
    about = request.about or "Experienced professional."
    experience = request.experience or "Various roles."

    return ProfileBoostResponse(
        improved_headline=f"{headline} | Driving Results & Innovation",
        improved_about=(
            f"{about}\n\n"
            "I bring a track record of delivering impactful solutions and collaborating "
            "with cross-functional teams to achieve ambitious goals."
        ),
        improved_experience=(
            f"{experience}\n\n"
            "Key achievements:\n"
            "- Delivered projects on time and within budget\n"
            "- Collaborated with stakeholders to define and execute strategic initiatives"
        ),
        tips=[
            "Add quantifiable metrics to your experience (e.g., 'increased revenue by 20%')",
            "Include relevant industry keywords for better discoverability",
            "Keep your headline under 120 characters and lead with your strongest skill",
        ],
    )


def generate_cover_letter(request: ApplyLetterRequest) -> ApplyLetterResponse:
    """Rule-based mock cover letter generation."""
    cv_keywords = _extract_keywords(request.cv_text)
    jd_keywords = _extract_keywords(request.job_description)
    shared = sorted(cv_keywords & jd_keywords)
    skills_phrase = ", ".join(shared[:3]) if shared else "my relevant skills"

    tone_openers = {
        "professional": "I am writing to express my strong interest in",
        "casual": "I'm excited to apply for",
        "enthusiastic": "I am thrilled at the opportunity to apply for",
    }
    opener = tone_openers.get(request.tone, tone_openers["professional"])

    return ApplyLetterResponse(
        cover_letter=(
            f"Dear Hiring Manager,\n\n"
            f"{opener} this position. With experience in {skills_phrase}, "
            f"I am confident in my ability to contribute meaningfully to your team.\n\n"
            f"Throughout my career, I have developed strong expertise that aligns well "
            f"with the requirements outlined in the job description. I am particularly "
            f"drawn to this role because it offers the opportunity to apply my skills "
            f"in a challenging and rewarding environment.\n\n"
            f"I look forward to discussing how my background and enthusiasm can benefit "
            f"your organization.\n\n"
            f"Best regards"
        )
    )
