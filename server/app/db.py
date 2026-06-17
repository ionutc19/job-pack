import logging

from sqlalchemy import (
    Column,
    DateTime,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    create_engine,
    func,
)
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from app.config import settings

logger = logging.getLogger(__name__)


class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "users"

    user_id = Column(String(128), primary_key=True)
    device_id = Column(String(128), nullable=True)
    tier = Column(String(20), nullable=False, server_default="free")
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=False, server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        Index("idx_users_device", "device_id"),
    )


class Subscription(Base):
    __tablename__ = "subscriptions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(
        String(128), ForeignKey("users.user_id"), nullable=False,
    )
    product_id = Column(String(100), nullable=False)
    purchase_token = Column(Text, nullable=True)
    status = Column(String(30), nullable=False, server_default="pending")
    tier = Column(String(20), nullable=False)
    started_at = Column(DateTime, nullable=True)
    expires_at = Column(DateTime, nullable=True)
    renewed_at = Column(DateTime, nullable=True)
    canceled_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=False, server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        Index("idx_subs_user", "user_id"),
        Index("idx_subs_token", "purchase_token"),
    )


class UsageEvent(Base):
    __tablename__ = "usage_events"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(
        String(128), ForeignKey("users.user_id"), nullable=False,
    )
    module = Column(String(50), nullable=False)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    ts = Column(Float, nullable=False)

    __table_args__ = (
        Index("idx_usage_user_module", "user_id", "module", "ts"),
        Index("idx_usage_user_ts", "user_id", "ts"),
    )


_engine = None
_SessionLocal = None


def get_engine():
    global _engine
    if _engine is None:
        url = settings.database_url
        connect_args = {}
        if url.startswith("sqlite"):
            connect_args["check_same_thread"] = False
        _engine = create_engine(url, pool_pre_ping=True, connect_args=connect_args)
    return _engine


def get_session_factory():
    global _SessionLocal
    if _SessionLocal is None:
        _SessionLocal = sessionmaker(bind=get_engine(), expire_on_commit=False)
    return _SessionLocal


def get_session() -> Session:
    return get_session_factory()()


def init_db() -> None:
    engine = get_engine()
    Base.metadata.create_all(bind=engine)
    url = settings.database_url
    safe_url = url.split("@")[-1] if "@" in url else url
    logger.info("Database initialized: %s", safe_url)


def dispose_engine() -> None:
    global _engine, _SessionLocal
    if _engine is not None:
        _engine.dispose()
        _engine = None
        _SessionLocal = None


def reset_engine() -> None:
    """Re-create the engine from current settings. Used by tests."""
    dispose_engine()
    get_engine()
    get_session_factory()
