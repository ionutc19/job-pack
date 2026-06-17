#!/bin/sh
set -eu

cd /home/site/wwwroot

pip install -r requirements.txt --quiet

echo "[startup] Running database migrations..."
alembic upgrade head

echo "[startup] Starting FastAPI with Gunicorn + UvicornWorker..."
exec gunicorn -w 2 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:8000 app.main:app
