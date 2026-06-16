import httpx

from app.config import settings
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

_IMPORTANCE = {"en": {"high": "high", "medium": "medium", "low": "low"},
               "ro": {"high": "ridicat", "medium": "mediu", "low": "scăzut"}}


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
    lang = request.language
    imp = _IMPORTANCE.get(lang, _IMPORTANCE["en"])

    cv_keywords = _extract_keywords(request.cv_text)
    jd_keywords = _extract_keywords(request.job_description)

    if not jd_keywords:
        match_score = 50
    else:
        overlap = cv_keywords & jd_keywords
        match_score = min(int((len(overlap) / len(jd_keywords)) * 100), 100)

    missing = jd_keywords - cv_keywords
    missing_keywords = [
        KeywordGap(keyword=kw, importance=imp["high"])
        for kw in sorted(missing)[:5]
    ]

    bullet_suggestions = []
    if missing:
        sample = sorted(missing)[0]
        if lang == "ro":
            bullet_suggestions.append(BulletSuggestion(
                original="Am lucrat pe diverse proiecte",
                improved=(
                    f"Am condus proiecte cross-funcționale folosind {sample} "
                    "pentru a livra rezultate măsurabile"
                ),
            ))
        else:
            bullet_suggestions.append(BulletSuggestion(
                original="Worked on various projects",
                improved=(
                    f"Led cross-functional projects leveraging {sample} "
                    "to deliver measurable outcomes"
                ),
            ))

    n_overlap = len(cv_keywords & jd_keywords)
    n_required = len(jd_keywords)
    if lang == "ro":
        summary = (
            f"CV-ul tău se potrivește în proporție de {match_score}% cu cerințele jobului. "
            f"S-au găsit {n_overlap} cuvinte cheie comune din {n_required} necesare."
        )
    else:
        summary = (
            f"Your CV matches {match_score}% of the job requirements. "
            f"Found {n_overlap} matching keywords out of {n_required} required."
        )

    return JobFitResponse(
        match_score=match_score,
        summary=summary,
        missing_keywords=missing_keywords,
        bullet_suggestions=bullet_suggestions,
    )


def generate_profile_boost(request: ProfileBoostRequest) -> ProfileBoostResponse:
    lang = request.language
    headline = request.headline or ("Profesionist" if lang == "ro" else "Professional")
    about = request.about or (
        "Profesionist cu experiență." if lang == "ro" else "Experienced professional."
    )
    experience = request.experience or ("Diverse roluri." if lang == "ro" else "Various roles.")

    if lang == "ro":
        return ProfileBoostResponse(
            improved_headline=f"{headline} | Rezultate & Inovație",
            improved_about=(
                f"{about}\n\n"
                "Aduc un parcurs dovedit de livrare a soluțiilor de impact și "
                "colaborare cu echipe cross-funcționale pentru atingerea obiectivelor ambițioase."
            ),
            improved_experience=(
                f"{experience}\n\n"
                "Realizări cheie:\n"
                "- Am livrat proiecte la timp și în buget\n"
                "- Am colaborat cu stakeholderii pentru definirea și execuția "
                "inițiativelor strategice"
            ),
            tips=[
                "Adaugă metrici cuantificabile la experiență (ex: 'am crescut veniturile cu 20%')",
                "Include cuvinte cheie relevante din industrie pentru o mai bună vizibilitate",
                "Păstrează titlul sub 120 de caractere și pune în față "
                "cea mai puternică competență",
            ],
        )

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
    lang = request.language
    cv_keywords = _extract_keywords(request.cv_text)
    jd_keywords = _extract_keywords(request.job_description)
    shared = sorted(cv_keywords & jd_keywords)

    if lang == "ro":
        skills_phrase = ", ".join(shared[:3]) if shared else "competențele mele relevante"
        tone_openers = {
            "professional": "Vă scriu pentru a-mi exprima interesul puternic pentru",
            "casual": "Sunt entuziasmat să aplic pentru",
            "enthusiastic": "Sunt încântat de oportunitatea de a aplica pentru",
        }
        opener = tone_openers.get(request.tone, tone_openers["professional"])
        return ApplyLetterResponse(
            cover_letter=(
                f"Stimate Angajator,\n\n"
                f"{opener} această poziție. Cu experiență în {skills_phrase}, "
                f"sunt încrezător în capacitatea mea de a contribui semnificativ "
                f"echipei dumneavoastră.\n\n"
                f"De-a lungul carierei mele, am dezvoltat expertiză solidă care se "
                f"aliniază cu cerințele din descrierea postului. Sunt atras în mod "
                f"deosebit de acest rol pentru că oferă oportunitatea de a-mi aplica "
                f"competențele într-un mediu provocator și plin de satisfacții.\n\n"
                f"Aștept cu interes să discutăm cum experiența și entuziasmul meu "
                f"pot aduce valoare organizației dumneavoastră.\n\n"
                f"Cu respect"
            )
        )

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


async def call_ai_provider(prompt: str) -> str:
    """Call the configured AI provider. Falls back to a placeholder if not configured."""
    if not settings.ai_api_key:
        return ""

    headers = {
        "Authorization": f"Bearer {settings.ai_api_key}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": settings.ai_model,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.7,
    }

    async with httpx.AsyncClient(timeout=settings.ai_timeout_seconds) as client:
        response = await client.post(
            f"{settings.ai_base_url}/chat/completions",
            json=payload,
            headers=headers,
        )
        response.raise_for_status()
        data = response.json()
        return data["choices"][0]["message"]["content"]
