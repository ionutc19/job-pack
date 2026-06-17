#!/bin/sh
set -eu

cd /home/site/wwwroot

echo "[startup] Starting Gunicorn (config from gunicorn.conf.py)..."
exec gunicorn app.main:app
