# Job Coach

A mobile-first Android app for job seekers. Analyze job fit, boost your LinkedIn profile, and generate personalized cover letters — powered by AI, with full English and Romanian support.

## Features

- **Job Fit Analysis** — Paste your CV and a job description to get a match score, missing keywords, and bullet point improvements
- **Profile Boost** — Improve your LinkedIn headline, About section, and experience descriptions
- **Cover Letter** — Generate a concise, personalized cover letter based on your CV and the target job
- **Bilingual** — Full English and Romanian UI and backend responses
- **Feedback System** — In-app bug reports and feature requests that create GitHub Issues automatically

## Architecture

```
job-pack/
├── mobile/                  # Flutter app (Android-first)
│   ├── lib/
│   │   ├── config/          # App config, theme
│   │   ├── l10n/            # Localization (EN/RO) + language provider
│   │   ├── models/          # Data models
│   │   ├── screens/         # UI screens (7 screens)
│   │   ├── services/        # API + mock service layer
│   │   └── widgets/         # Reusable components
│   └── test/                # Widget tests
├── server/                  # FastAPI backend
│   ├── app/
│   │   ├── models/          # Pydantic schemas (language-aware)
│   │   ├── routers/         # API route handlers
│   │   └── services/        # Business logic (AI, GitHub)
│   ├── tests/               # API tests
│   └── startup.sh           # Azure App Service startup script
└── .github/workflows/       # CI pipelines
```

**Service layer**: The mobile app uses a service locator that switches between mock and real backend via the `USE_MOCKS` compile-time flag. When `AI_API_KEY` is configured, the backend sends requests to the configured AI provider (Azure OpenAI, OpenAI, or any compatible endpoint) via the `/responses` API. If AI is not configured or the call fails, all endpoints fall back to safe rule-based responses.

**Localization**: The app stores the selected language in SharedPreferences and passes it to the backend as a `language` field. The backend generates all response text in the requested language.

## Local Setup

### Prerequisites

- **Flutter** 3.22+ ([install](https://docs.flutter.dev/get-started/install)) — tested with 3.44
- **Python** 3.11+ ([install](https://www.python.org/downloads/)) — tested with 3.11 and 3.14
- **Android Studio** or an Android emulator

### Environment Variables

```bash
cp server/.env.example server/.env
```

| Variable | Description | Required |
|----------|-------------|----------|
| `AI_PROVIDER` | Provider name (`openai`, `azure_openai`, etc.) | No (rule-based fallback) |
| `AI_BASE_URL` | AI API base URL (e.g. `https://your-resource.services.ai.azure.com/openai/v1`) | No |
| `AI_API_KEY` | AI API key — enables AI when set | No |
| `AI_MODEL` | Model identifier (e.g. `gpt-5.4-mini`) | No |
| `AI_TIMEOUT_SECONDS` | Request timeout in seconds | No (default: 30) |
| `GITHUB_TOKEN` | GitHub PAT for creating issues | Yes (for feedback) |
| `GITHUB_REPO_OWNER` | GitHub repo owner | No (default: ionutc19) |
| `GITHUB_REPO_NAME` | GitHub repo name | No (default: job-pack) |
| `DATABASE_URL` | SQLite path (e.g. `sqlite:///data/jobcoach.db`) | No (default: `sqlite:///data/jobcoach.db`) |
| `ADMIN_SECRET` | Secret for admin/debug endpoints | No (admin endpoints disabled without it) |
| `GOOGLE_PLAY_PACKAGE` | Android package name | No (default: `com.ionutc19.jobcoach`) |
| `GOOGLE_PLAY_CREDENTIALS_JSON` | Google Play service account JSON path | No (purchase verification disabled without it) |
| `RTDN_SECRET` | Shared secret for RTDN webhook | No |

## Running the Backend

### Local development

```bash
cd server
python -m venv .venv
source .venv/bin/activate    # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

The API will be at `http://localhost:8000`. Interactive docs at `http://localhost:8000/docs`.

### Production (local or VM)

```bash
cd server
pip install -r requirements.txt
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

### Running Backend Tests

```bash
cd server
pip install -r requirements-dev.txt
pytest -v
ruff check .
```

## Running the Mobile App

### With mock services (no backend needed)

```bash
cd mobile
flutter pub get
flutter run
```

### With real backend

Start the backend first (`uvicorn app.main:app --reload` in the `server/` directory), then:

```bash
cd mobile
flutter run --dart-define=USE_MOCKS=false
```

The app defaults to `http://10.0.2.2:8000`, which is the Android emulator's alias for `localhost` on your host machine. To override:

```bash
flutter run --dart-define=USE_MOCKS=false --dart-define=BASE_URL=http://your-server:8000
```

## Building Android APK Locally

```bash
cd mobile
flutter build apk --release
```

The APK will be at `mobile/build/app/outputs/flutter-apk/app-release.apk`.

## Building Android AAB for Google Play

```bash
cd mobile
flutter build appbundle --release
```

The AAB will be at `mobile/build/app/outputs/bundle/release/app-release.aab`.

> Before publishing, configure signing in `mobile/android/app/build.gradle.kts` with your upload keystore.

## Deployment

### Azure App Service (Linux)

1. Create a Python 3.11 Linux App Service
2. Set environment variables in App Service Configuration (all from `.env.example`)
3. Deploy the `server/` directory (via GitHub Actions, ZIP deploy, or local Git)
4. Set the startup command:
   ```
   startup.sh
   ```
   Or directly:
   ```
   gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
   ```
5. The app will be available at `https://your-app.azurewebsites.net`

**For Azure-hosted AI models** (OpenAI-compatible `/responses` API), set:
```
AI_PROVIDER=azure_openai
AI_BASE_URL=https://your-resource.services.ai.azure.com/openai/v1
AI_API_KEY=your-azure-api-key
AI_MODEL=gpt-5.4-mini
AI_TIMEOUT_SECONDS=60
```

The backend calls `{AI_BASE_URL}/responses` and parses the response. If the AI call fails or returns unparseable output, all endpoints gracefully fall back to rule-based responses — the app never crashes due to AI unavailability.

### Single Linux VM

1. Install Python 3.11+ on the server
2. Clone the repo and install:
   ```bash
   cd server && python -m venv .venv && source .venv/bin/activate
   pip install -r requirements.txt
   ```
3. Create `.env` with production values
4. Run: `./startup.sh`
5. Put behind nginx as a reverse proxy with HTTPS (Let's Encrypt)
6. Use systemd to manage the service

For the mobile app, build the APK/AAB locally and distribute via Google Play or direct APK install.

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/health` | Health check |
| POST | `/api/job-fit/analyze` | Analyze CV vs job description (accepts `language`: en/ro) |
| POST | `/api/profile-boost/generate` | Generate LinkedIn improvements (accepts `language`: en/ro) |
| POST | `/api/apply-letter/generate` | Generate cover letter (accepts `language`: en/ro) |
| POST | `/api/feedback` | Submit feedback (creates GitHub Issue) |
| GET | `/api/entitlements/me` | Get current tier and usage for user |
| POST | `/api/entitlements/verify-purchase` | Submit a Google Play purchase for verification |
| POST | `/api/admin/set-tier` | Admin-only: override user tier (requires `X-Admin-Secret`) |
| POST | `/api/admin/rtdn` | RTDN webhook endpoint for Google Play notifications |

All content endpoints (`job-fit`, `profile-boost`, `apply-letter`) accept `X-User-Id` and `X-Device-Id` headers for identity. Responses include `usage` metadata (tier, used, remaining, period).

## Entitlements & Persistence

Entitlements, usage counters, and subscription data are stored in a SQLite database (`data/jobcoach.db` by default). The schema is designed to be PostgreSQL-compatible for production migration. The database is auto-created on first startup.

**Privacy**: CV text, job descriptions, and generated results are NOT stored in the database. Only user identity, tier, subscription metadata, and usage event timestamps are persisted.

**User identity**: The mobile app generates a stable UUID on first launch and sends it as `X-User-Id` on all requests. `X-Device-Id` is a secondary anti-abuse signal. There is no account/login system yet.

**Tier management**: The public `POST /api/entitlements/tier` endpoint has been removed. Tier changes happen through:
- Purchase verification (`POST /api/entitlements/verify-purchase`)
- RTDN webhook processing (`POST /api/admin/rtdn`)
- Admin override (`POST /api/admin/set-tier`, requires `ADMIN_SECRET`)

**Google Play integration**: The subscription service is scaffolded for `jobcoach_premium_monthly` and `jobcoach_pro_monthly` product IDs. Purchase verification and RTDN handling require `GOOGLE_PLAY_CREDENTIALS_JSON` to be configured with a service account that has access to the Google Play Developer API.

## Troubleshooting

### Android emulator can't reach the backend

The Android emulator runs in its own network. `localhost` inside the emulator points to the emulator itself, not your dev machine. Use `10.0.2.2` instead — this is the emulator's alias for your host machine's loopback. The app already defaults to `http://10.0.2.2:8000`. If you're running on a physical device, use your machine's local IP (e.g. `192.168.x.x`).

### OneDrive file locking during Flutter/Gradle builds

If your project is inside a OneDrive-synced folder, you may see errors like `Unable to delete directory` during builds. OneDrive locks files while syncing, which conflicts with Gradle's clean tasks. Workarounds:

1. **Pause OneDrive sync** before building (right-click tray icon → Pause syncing)
2. Run `flutter clean` before `flutter run` if you hit stale lock errors
3. **Long-term fix**: move the repo to a folder outside OneDrive sync (e.g. `C:\dev\job-pack`)

### Python dependency build errors on Windows

If `pip install` tries to compile `pydantic-core` from source (requires Rust/MSVC), your pydantic version is too old for your Python version. The project uses version ranges (`pydantic>=2.13`) so `pip install -r requirements.txt` should resolve to a version with pre-built wheels. If you still hit issues:

1. Make sure pip is up to date: `python -m pip install --upgrade pip`
2. Upgrade pydantic explicitly: `pip install --upgrade pydantic pydantic-core`
3. If using Python 3.14, ensure all deps are at their latest compatible versions

## Known Next Steps

- [x] Integrate real AI provider via Azure OpenAI `/responses` API
- [x] Persistent entitlements + usage tracking (SQLite)
- [x] Stable user identity (UUID-based)
- [x] Subscription-ready architecture (Google Play product IDs, verification, RTDN)
- [ ] Configure Google Play service account and activate purchase verification
- [ ] Integrate Google Play Billing Library in Flutter app
- [ ] Add AdMob SDK for free tier
- [ ] Add PDF text extraction for CV uploads
- [ ] Migrate SQLite to PostgreSQL for production
- [ ] Add dark theme support
- [ ] Add local storage for saving past analyses
- [ ] Add share functionality for cover letters
- [ ] Set up Android signing for Play Store release
- [ ] Add Dockerfile for backend containerization
- [ ] Add error tracking (Sentry or similar)
- [ ] Add analytics events
