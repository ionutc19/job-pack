#!/bin/sh
set -eu

cd /home/site/wwwroot

echo "[startup] Running database migrations..."
python -m alembic upgrade head || echo "[startup] Alembic migration failed, continuing startup"

echo "[startup] Starting FastAPI with Gunicorn + UvicornWorker..."
exec gunicorn -w 2 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:8000 app.main:app
