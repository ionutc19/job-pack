import logging
import sqlite3
import threading
from pathlib import Path

from app.config import settings

logger = logging.getLogger(__name__)

_local = threading.local()


def _db_path() -> str:
    return settings.database_url.replace("sqlite:///", "")


def _get_conn() -> sqlite3.Connection:
    if not hasattr(_local, "conn") or _local.conn is None:
        path = _db_path()
        Path(path).parent.mkdir(parents=True, exist_ok=True)
        _local.conn = sqlite3.connect(path)
        _local.conn.row_factory = sqlite3.Row
        _local.conn.execute("PRAGMA journal_mode=WAL")
        _local.conn.execute("PRAGMA foreign_keys=ON")
    return _local.conn


def get_conn() -> sqlite3.Connection:
    return _get_conn()


def init_db() -> None:
    conn = _get_conn()
    conn.executescript(_SCHEMA)
    conn.commit()
    logger.info("Database initialized at %s", _db_path())


_SCHEMA = """
CREATE TABLE IF NOT EXISTS users (
    user_id       TEXT PRIMARY KEY,
    device_id     TEXT,
    tier          TEXT NOT NULL DEFAULT 'free',
    created_at    TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_users_device
    ON users(device_id);

CREATE TABLE IF NOT EXISTS subscriptions (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         TEXT NOT NULL REFERENCES users(user_id),
    product_id      TEXT NOT NULL,
    purchase_token  TEXT,
    status          TEXT NOT NULL DEFAULT 'pending',
    tier            TEXT NOT NULL,
    started_at      TEXT,
    expires_at      TEXT,
    renewed_at      TEXT,
    canceled_at     TEXT,
    created_at      TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_subs_user
    ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subs_token
    ON subscriptions(purchase_token);

CREATE TABLE IF NOT EXISTS usage_events (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     TEXT NOT NULL REFERENCES users(user_id),
    module      TEXT NOT NULL,
    created_at  TEXT NOT NULL DEFAULT (datetime('now')),
    ts          REAL NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_usage_user_module
    ON usage_events(user_id, module, ts);
CREATE INDEX IF NOT EXISTS idx_usage_user_ts
    ON usage_events(user_id, ts);
"""
