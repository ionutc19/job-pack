# Job Coach

An AI-powered career toolkit for Android. Analyze job fit, boost your LinkedIn profile, and generate personalized cover letters — with full English and Romanian support.

[Privacy Policy](https://ionutc19.github.io/job-pack/privacy-policy.html) · [Terms of Service](https://ionutc19.github.io/job-pack/terms-of-service.html)

## Features

- **Job Fit Analysis** — Compare your CV against a job description to get a match score, missing keywords, and improvement suggestions
- **Profile Boost** — Get AI-powered improvements for your LinkedIn headline, about section, and experience
- **Cover Letter Generator** — Create personalized cover letters tailored to any job posting
- **Document Upload** — Upload PDF, DOCX, or TXT files for text extraction (privacy-first: files are processed in memory only, never stored)
- **Bilingual** — Full English and Romanian UI and AI-generated responses
- **Subscription Plans** — Free (with ads), Premium, and Pro tiers via Google Play Billing
- **Privacy-First** — No persistent storage of CV text, job descriptions, or generated results

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3.44+ (Android) |
| Backend | FastAPI (Python 3.11+) |
| AI | Azure OpenAI (with rule-based fallback) |
| Database | PostgreSQL (via SQLAlchemy + Alembic) |
| Ads | Google AdMob |
| Billing | Google Play Billing (in_app_purchase) |
| Hosting | Microsoft Azure App Service |

## Project Structure

```
job-pack/
├── mobile/          # Flutter Android app
│   ├── lib/
│   │   ├── config/  # App config, ad config, theme
│   │   ├── l10n/    # Localization (EN/RO)
│   │   ├── screens/ # UI screens
│   │   ├── services/# API, billing, identity services
│   │   └── widgets/ # Reusable components
│   └── android/     # Android platform config
├── server/          # FastAPI backend
│   ├── app/
│   │   ├── routers/ # API endpoints
│   │   └── services/# AI, billing, file extraction
│   └── tests/       # API tests
├── docs/            # GitHub Pages (Privacy Policy, ToS)
└── branding/        # Logo and icon assets
```

## Getting Started

### Prerequisites

- **Flutter** 3.22+ ([install](https://docs.flutter.dev/get-started/install))
- **Python** 3.11+ ([install](https://www.python.org/downloads/))
- **Android Studio** or an Android emulator/device

### Backend

```bash
cd server
python -m venv .venv
source .venv/bin/activate    # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env         # Configure environment variables
uvicorn app.main:app --reload
```

The API runs at `http://localhost:8000` with interactive docs at `/docs`.

#### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `AI_API_KEY` | AI provider API key | No (falls back to rule-based responses) |
| `AI_BASE_URL` | AI API base URL | No |
| `AI_MODEL` | Model identifier | No |
| `GITHUB_TOKEN` | GitHub PAT for feedback → issues | No |

### Mobile App

**With mock services (no backend needed):**
```bash
cd mobile
flutter pub get
flutter run
```

**With real backend:**
```bash
cd mobile
flutter run --dart-define=USE_MOCKS=false --dart-define=BASE_URL=http://10.0.2.2:8000
```

> `10.0.2.2` is the Android emulator's alias for your host machine's localhost.

### Building for Release

```bash
# APK
flutter build apk --release \
  --dart-define=USE_MOCKS=false \
  --dart-define=BASE_URL=https://your-backend-url.com

# AAB (for Google Play)
flutter build appbundle --release \
  --dart-define=USE_MOCKS=false \
  --dart-define=BASE_URL=https://your-backend-url.com
```

> Release signing requires `mobile/android/key.properties` (not committed to git).

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/health` | Health check |
| POST | `/api/job-fit/analyze` | Analyze CV vs job description |
| POST | `/api/profile-boost/generate` | Generate LinkedIn improvements |
| POST | `/api/apply-letter/generate` | Generate cover letter |
| POST | `/api/files/extract-text` | Extract text from PDF/DOCX/TXT |
| POST | `/api/feedback` | Submit feedback |
| GET | `/api/entitlements/me` | Get current tier and usage |
| POST | `/api/entitlements/verify-purchase` | Verify Google Play purchase |

All content endpoints accept `X-User-Id` and `X-Device-Id` headers. Responses include usage metadata (tier, used, remaining).

## Privacy

- CV text, job descriptions, and generated results are **never stored** in the database
- Uploaded files are processed in memory and discarded immediately
- Only user identity (UUID), subscription status, and usage counters are persisted
- No account registration required — a random UUID is generated on first launch

See the full [Privacy Policy](https://ionutc19.github.io/job-pack/privacy-policy.html).

## License

This project is licensed under the [MIT License](LICENSE).
