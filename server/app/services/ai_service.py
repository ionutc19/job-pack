import json
import logging

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

logger = logging.getLogger(__name__)

_IMPORTANCE = {
    "en": {"high": "high", "medium": "medium", "low": "low"},
    "ro": {"high": "ridicat", "medium": "mediu", "low": "scăzut"},
}


def _extract_keywords(text: str) -> set[str]:
    common_tech = {
        "python", "java", "javascript", "typescript", "react",
        "angular", "vue", "node", "django", "flask", "fastapi",
        "sql", "nosql", "aws", "azure", "gcp", "docker",
        "kubernetes", "ci/cd", "git", "agile", "scrum", "rest",
        "graphql", "machine learning", "ai", "data analysis",
        "project management", "leadership", "communication",
    }
    words = set(text.lower().split())
    return words & common_tech


def _ai_configured() -> bool:
    return bool(settings.ai_api_key and settings.ai_base_url)


async def _call_ai(prompt: str) -> str:
    if not _ai_configured():
        return ""

    headers = {
        "Authorization": f"Bearer {settings.ai_api_key}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": settings.ai_model,
        "input": [{"role": "user", "content": prompt}],
        "temperature": 0.7,
    }

    async with httpx.AsyncClient(
        timeout=settings.ai_timeout_seconds,
    ) as client:
        response = await client.post(
            f"{settings.ai_base_url}/responses",
            json=payload,
            headers=headers,
        )
        response.raise_for_status()
        data = response.json()
        for item in data.get("output", []):
            if item.get("type") == "message":
                for block in item.get("content", []):
                    if block.get("type") == "output_text":
                        return block["text"]
        return ""


def _parse_json(text: str) -> dict | None:
    cleaned = text.strip()
    if cleaned.startswith("```"):
        lines = cleaned.split("\n")
        lines = lines[1:]
        if lines and lines[-1].strip() == "```":
            lines = lines[:-1]
        cleaned = "\n".join(lines)
    try:
        return json.loads(cleaned)
    except (json.JSONDecodeError, ValueError):
        logger.warning("Failed to parse AI JSON response")
        return None


# -- Fallback (rule-based) functions --

def _fallback_job_fit(request: JobFitRequest) -> JobFitResponse:
    lang = request.language
    imp = _IMPORTANCE.get(lang, _IMPORTANCE["en"])

    cv_keywords = _extract_keywords(request.cv_text)
    jd_keywords = _extract_keywords(request.job_description)

    if not jd_keywords:
        match_score = 50
    else:
        overlap = cv_keywords & jd_keywords
        match_score = min(
            int((len(overlap) / len(jd_keywords)) * 100), 100,
        )

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
                    f"Am condus proiecte cross-funcționale "
                    f"folosind {sample} pentru a livra "
                    f"rezultate măsurabile"
                ),
            ))
        else:
            bullet_suggestions.append(BulletSuggestion(
                original="Worked on various projects",
                improved=(
                    f"Led cross-functional projects leveraging "
                    f"{sample} to deliver measurable outcomes"
                ),
            ))

    n_overlap = len(cv_keywords & jd_keywords)
    n_required = len(jd_keywords)
    if lang == "ro":
        summary = (
            f"CV-ul tău se potrivește în proporție de "
            f"{match_score}% cu cerințele jobului. "
            f"S-au găsit {n_overlap} cuvinte cheie "
            f"comune din {n_required} necesare."
        )
    else:
        summary = (
            f"Your CV matches {match_score}% of the job "
            f"requirements. Found {n_overlap} matching "
            f"keywords out of {n_required} required."
        )

    return JobFitResponse(
        match_score=match_score,
        summary=summary,
        missing_keywords=missing_keywords,
        bullet_suggestions=bullet_suggestions,
    )


def _fallback_profile_boost(
    request: ProfileBoostRequest,
) -> ProfileBoostResponse:
    lang = request.language
    headline = request.headline or (
        "Profesionist" if lang == "ro" else "Professional"
    )
    about = request.about or (
        "Profesionist cu experiență."
        if lang == "ro"
        else "Experienced professional."
    )
    experience = request.experience or (
        "Diverse roluri." if lang == "ro" else "Various roles."
    )

    if lang == "ro":
        return ProfileBoostResponse(
            improved_headline=(
                f"{headline} | Rezultate & Inovație"
            ),
            improved_about=(
                f"{about}\n\nAduc un parcurs dovedit de "
                f"livrare a soluțiilor de impact și colaborare "
                f"cu echipe cross-funcționale pentru atingerea "
                f"obiectivelor ambițioase."
            ),
            improved_experience=(
                f"{experience}\n\nRealizări cheie:\n"
                f"- Am livrat proiecte la timp și în buget\n"
                f"- Am colaborat cu stakeholderii pentru "
                f"definirea și execuția inițiativelor strategice"
            ),
            tips=[
                "Adaugă metrici cuantificabile la experiență",
                "Include cuvinte cheie relevante din industrie",
                "Păstrează titlul sub 120 de caractere",
            ],
        )

    return ProfileBoostResponse(
        improved_headline=(
            f"{headline} | Driving Results & Innovation"
        ),
        improved_about=(
            f"{about}\n\nI bring a track record of delivering "
            f"impactful solutions and collaborating with "
            f"cross-functional teams to achieve ambitious goals."
        ),
        improved_experience=(
            f"{experience}\n\nKey achievements:\n"
            f"- Delivered projects on time and within budget\n"
            f"- Collaborated with stakeholders to define and "
            f"execute strategic initiatives"
        ),
        tips=[
            "Add quantifiable metrics to your experience",
            "Include relevant industry keywords",
            "Keep your headline under 120 characters",
        ],
    )


def _fallback_cover_letter(
    request: ApplyLetterRequest,
) -> ApplyLetterResponse:
    lang = request.language
    cv_keywords = _extract_keywords(request.cv_text)
    jd_keywords = _extract_keywords(request.job_description)
    shared = sorted(cv_keywords & jd_keywords)

    if lang == "ro":
        skills = (
            ", ".join(shared[:3])
            if shared
            else "competențele mele relevante"
        )
        tone_openers = {
            "professional": (
                "Vă scriu pentru a-mi exprima "
                "interesul puternic pentru"
            ),
            "casual": "Sunt entuziasmat să aplic pentru",
            "enthusiastic": (
                "Sunt încântat de oportunitatea "
                "de a aplica pentru"
            ),
        }
        opener = tone_openers.get(
            request.tone, tone_openers["professional"],
        )
        return ApplyLetterResponse(
            cover_letter=(
                f"Stimate Angajator,\n\n"
                f"{opener} această poziție. Cu experiență "
                f"în {skills}, sunt încrezător în capacitatea "
                f"mea de a contribui semnificativ echipei "
                f"dumneavoastră.\n\n"
                f"De-a lungul carierei mele, am dezvoltat "
                f"expertiză solidă care se aliniază cu "
                f"cerințele din descrierea postului. Sunt "
                f"atras în mod deosebit de acest rol pentru "
                f"că oferă oportunitatea de a-mi aplica "
                f"competențele într-un mediu provocator și "
                f"plin de satisfacții.\n\n"
                f"Aștept cu interes să discutăm cum "
                f"experiența și entuziasmul meu pot aduce "
                f"valoare organizației dumneavoastră.\n\n"
                f"Cu respect"
            ),
        )

    skills = (
        ", ".join(shared[:3])
        if shared
        else "my relevant skills"
    )
    tone_openers = {
        "professional": (
            "I am writing to express my strong interest in"
        ),
        "casual": "I'm excited to apply for",
        "enthusiastic": (
            "I am thrilled at the opportunity to apply for"
        ),
    }
    opener = tone_openers.get(
        request.tone, tone_openers["professional"],
    )

    return ApplyLetterResponse(
        cover_letter=(
            f"Dear Hiring Manager,\n\n"
            f"{opener} this position. With experience in "
            f"{skills}, I am confident in my ability to "
            f"contribute meaningfully to your team.\n\n"
            f"Throughout my career, I have developed strong "
            f"expertise that aligns well with the requirements "
            f"outlined in the job description. I am "
            f"particularly drawn to this role because it "
            f"offers the opportunity to apply my skills in a "
            f"challenging and rewarding environment.\n\n"
            f"I look forward to discussing how my background "
            f"and enthusiasm can benefit your organization.\n\n"
            f"Best regards"
        ),
    )


# -- AI-powered functions --

_LANG_INSTRUCTION = {
    "en": "Respond entirely in English.",
    "ro": "Răspunde complet în limba română.",
}


def _job_fit_prompt(request: JobFitRequest) -> str:
    lang_inst = _LANG_INSTRUCTION.get(
        request.language, _LANG_INSTRUCTION["en"],
    )
    return f"""{lang_inst}

Analyze how well this CV matches the job description.
Return ONLY valid JSON with this exact structure:
{{
  "match_score": <integer 0-100>,
  "summary": "<2-3 sentence summary>",
  "missing_keywords": [
    {{"keyword": "<skill>", "importance": "<high|medium|low>"}}
  ],
  "bullet_suggestions": [
    {{"original": "<weak bullet point from CV>", "improved": "<stronger version>"}}
  ]
}}

Provide up to 5 missing keywords and up to 3 bullet suggestions.

CV:
{request.cv_text}

Job Description:
{request.job_description}"""


def _profile_boost_prompt(request: ProfileBoostRequest) -> str:
    lang_inst = _LANG_INSTRUCTION.get(
        request.language, _LANG_INSTRUCTION["en"],
    )
    return f"""{lang_inst}

Improve this LinkedIn profile for maximum professional impact.
Return ONLY valid JSON with this exact structure:
{{
  "improved_headline": "<optimized headline, max 120 chars>",
  "improved_about": "<improved About section>",
  "improved_experience": "<improved Experience section>",
  "tips": ["<tip 1>", "<tip 2>", "<tip 3>"]
}}

Current Headline: {request.headline or "Not provided"}
Current About: {request.about or "Not provided"}
Current Experience: {request.experience or "Not provided"}"""


def _cover_letter_prompt(request: ApplyLetterRequest) -> str:
    lang_inst = _LANG_INSTRUCTION.get(
        request.language, _LANG_INSTRUCTION["en"],
    )
    tone_desc = {
        "professional": "formal and professional",
        "casual": "friendly and conversational",
        "enthusiastic": "energetic and passionate",
    }
    tone = tone_desc.get(request.tone, tone_desc["professional"])
    return f"""{lang_inst}

Write a cover letter with a {tone} tone.
Return ONLY valid JSON with this exact structure:
{{
  "cover_letter": "<the full cover letter text>"
}}

CV:
{request.cv_text}

Job Description:
{request.job_description}"""


# -- Public async API --

async def analyze_job_fit(
    request: JobFitRequest,
) -> JobFitResponse:
    if not _ai_configured():
        return _fallback_job_fit(request)

    try:
        raw = await _call_ai(_job_fit_prompt(request))
        data = _parse_json(raw)
        if not data or "match_score" not in data:
            logger.warning("AI job-fit response invalid, using fallback")
            return _fallback_job_fit(request)

        return JobFitResponse(
            match_score=max(0, min(100, int(data["match_score"]))),
            summary=data.get("summary", ""),
            missing_keywords=[
                KeywordGap(**kw)
                for kw in data.get("missing_keywords", [])
            ],
            bullet_suggestions=[
                BulletSuggestion(**bs)
                for bs in data.get("bullet_suggestions", [])
            ],
        )
    except Exception:
        logger.exception("AI job-fit call failed, using fallback")
        return _fallback_job_fit(request)


async def generate_profile_boost(
    request: ProfileBoostRequest,
) -> ProfileBoostResponse:
    if not _ai_configured():
        return _fallback_profile_boost(request)

    try:
        raw = await _call_ai(_profile_boost_prompt(request))
        data = _parse_json(raw)
        if not data or "improved_headline" not in data:
            logger.warning(
                "AI profile-boost response invalid, using fallback",
            )
            return _fallback_profile_boost(request)

        return ProfileBoostResponse(
            improved_headline=data["improved_headline"],
            improved_about=data.get("improved_about", ""),
            improved_experience=data.get("improved_experience", ""),
            tips=data.get("tips", []),
        )
    except Exception:
        logger.exception(
            "AI profile-boost call failed, using fallback",
        )
        return _fallback_profile_boost(request)


async def generate_cover_letter(
    request: ApplyLetterRequest,
) -> ApplyLetterResponse:
    if not _ai_configured():
        return _fallback_cover_letter(request)

    try:
        raw = await _call_ai(_cover_letter_prompt(request))
        data = _parse_json(raw)
        if not data or "cover_letter" not in data:
            logger.warning(
                "AI cover-letter response invalid, using fallback",
            )
            return _fallback_cover_letter(request)

        return ApplyLetterResponse(
            cover_letter=data["cover_letter"],
        )
    except Exception:
        logger.exception(
            "AI cover-letter call failed, using fallback",
        )
        return _fallback_cover_letter(request)
