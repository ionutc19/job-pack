import os

os.environ["DATABASE_URL"] = "sqlite:///test_data/test.db"

from app.db import init_db  # noqa: E402


def pytest_configure(config):
    init_db()
