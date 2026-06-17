import os

os.environ["DATABASE_URL"] = "sqlite:///test_data/test.db"

from app.db import init_db, reset_engine  # noqa: E402


def pytest_configure(config):
    reset_engine()
    init_db()
