#!/bin/bash
set -e
# Azure App Service startup script
# Set as: az webapp config set --startup-file "startup.sh"

echo "Running Alembic migrations..."
alembic upgrade head
echo "Migrations complete."

exec gunicorn app.main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000 \
  --timeout 120
