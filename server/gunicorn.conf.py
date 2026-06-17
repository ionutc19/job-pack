import subprocess
import sys

bind = "0.0.0.0:8000"
workers = 2
worker_class = "uvicorn.workers.UvicornWorker"
timeout = 120


def on_starting(server):
    """Run Alembic migrations once before workers are forked."""
    server.log.info("Running database migrations...")
    result = subprocess.run(
        [sys.executable, "-m", "alembic", "upgrade", "head"],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        server.log.error("Migration failed:\n%s", result.stderr)
        sys.exit(1)
    server.log.info("Migrations complete.")
