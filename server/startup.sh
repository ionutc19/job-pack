#!/bin/bash
# Azure App Service startup script
# Set as: az webapp config set --startup-file "startup.sh"

# Run database migrations before starting the server
alembic upgrade head

gunicorn app.main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000 \
  --timeout 120
