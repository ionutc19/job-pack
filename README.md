# Job Pack

A mobile-first Android app for job seekers. Analyze job fit, boost your LinkedIn profile, and generate personalized cover letters — all powered by AI.

## Features

- **Job Fit Analysis** — Paste your CV and a job description to get a match score, missing keywords, and bullet point improvements
- **Profile Boost** — Improve your LinkedIn headline, About section, and experience descriptions
- **Apply Letter** — Generate a concise, personalized cover letter based on your CV and the target job
- **Feedback System** — In-app bug reports and feature requests that create GitHub Issues automatically

## Architecture

```
job-pack/
├── mobile/              # Flutter app (Android-first)
│   ├── lib/
│   │   ├── config/      # App config, theme
│   │   ├── models/      # Data models
│   │   ├── screens/     # UI screens
│   │   ├── services/    # API + mock service layer
│   │   └── widgets/     # Reusable components
│   └── test/            # Widget tests
├── server/              # FastAPI backend
│   ├── app/
│   │   ├── models/      # Pydantic schemas
│   │   ├── routers/     # API route handlers
│   │   └── services/    # Business logic (AI, GitHub)
│   └── tests/           # API tests
└── .github/workflows/   # CI pipelines
```

The mobile app uses a service locator pattern that switches between mock and real backend services via a compile-time flag (`USE_MOCKS`). The backend uses rule-based responses for now, with a placeholder for real AI provider integration.

## Local Setup

### Prerequisites

- **Flutter** 3.22+ ([install](https://docs.flutter.dev/get-started/install)) — tested with 3.44
- **Python** 3.11+ ([install](https://www.python.org/downloads/)) — tested with 3.11 and 3.14
- **Android Studio** or an Android emulator

### Environment Variables

Copy the example env file and fill in your values:

```bash
cp server/.env.example server/.env
```

| Variable | Description | Required |
|----------|-------------|----------|
| `AI_PROVIDER` | AI provider name (e.g. `openai`) | No (not used yet) |
| `AI_BASE_URL` | AI API base URL | No (not used yet) |
| `AI_API_KEY` | AI API key | No (not used yet) |
| `AI_MODEL` | Model identifier | No (not used yet) |
| `AI_TIMEOUT_SECONDS` | Request timeout | No (default: 30) |
| `GITHUB_TOKEN` | GitHub PAT for creating issues | Yes (for feedback) |
| `GITHUB_REPO_OWNER` | GitHub repo owner | No (default: ionutc19) |
| `GITHUB_REPO_NAME` | GitHub repo name | No (default: job-pack) |

## Running the Backend

```bash
cd server
python -m venv .venv
source .venv/bin/activate    # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

The API will be at `http://localhost:8000`. Interactive docs at `http://localhost:8000/docs`.

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

> Before publishing, you'll need to configure signing in `mobile/android/app/build.gradle.kts` with your upload keystore.

## Deployment (Single Linux VM)

A minimal deployment for the backend on a single Linux VM:

1. Install Python 3.11+ on the server
2. Clone the repo and set up the venv:
   ```bash
   cd server && python -m venv .venv && source .venv/bin/activate
   pip install -r requirements.txt
   ```
3. Create `.env` with production values
4. Run with gunicorn + uvicorn workers:
   ```bash
   pip install gunicorn
   gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
   ```
5. Put behind nginx as a reverse proxy with HTTPS (Let's Encrypt)
6. Use systemd to manage the service

For the mobile app, build the APK/AAB locally and distribute via Google Play or direct APK install.

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/health` | Health check |
| POST | `/api/job-fit/analyze` | Analyze CV vs job description |
| POST | `/api/profile-boost/generate` | Generate LinkedIn improvements |
| POST | `/api/apply-letter/generate` | Generate cover letter |
| POST | `/api/feedback` | Submit feedback (creates GitHub Issue) |

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

- [ ] Integrate real AI provider (OpenAI/Anthropic/etc.) via `ai_service.py`
- [ ] Add PDF text extraction for CV uploads
- [ ] Add authentication / rate limiting
- [ ] Add dark theme support
- [ ] Add local storage for saving past analyses
- [ ] Add share functionality for cover letters
- [ ] Set up Android signing for Play Store release
- [ ] Add Dockerfile for backend containerization
- [ ] Add error tracking (Sentry or similar)
- [ ] Add analytics events
