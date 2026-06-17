"""initial_schema

Revision ID: d9c684ae5b3a
Revises:
Create Date: 2026-06-17 20:04:26.289027

"""
from typing import Sequence, Union

import sqlalchemy as sa

from alembic import op

revision: str = 'd9c684ae5b3a'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        'users',
        sa.Column('user_id', sa.String(length=128), nullable=False),
        sa.Column('device_id', sa.String(length=128), nullable=True),
        sa.Column(
            'tier', sa.String(length=20),
            server_default='free', nullable=False,
        ),
        sa.Column(
            'created_at', sa.DateTime(),
            server_default=sa.text('(CURRENT_TIMESTAMP)'), nullable=False,
        ),
        sa.Column(
            'updated_at', sa.DateTime(),
            server_default=sa.text('(CURRENT_TIMESTAMP)'), nullable=False,
        ),
        sa.PrimaryKeyConstraint('user_id'),
    )
    op.create_index('idx_users_device', 'users', ['device_id'], unique=False)
    op.create_table(
        'subscriptions',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('user_id', sa.String(length=128), nullable=False),
        sa.Column('product_id', sa.String(length=100), nullable=False),
        sa.Column('purchase_token', sa.Text(), nullable=True),
        sa.Column(
            'status', sa.String(length=30),
            server_default='pending', nullable=False,
        ),
        sa.Column('tier', sa.String(length=20), nullable=False),
        sa.Column('started_at', sa.DateTime(), nullable=True),
        sa.Column('expires_at', sa.DateTime(), nullable=True),
        sa.Column('renewed_at', sa.DateTime(), nullable=True),
        sa.Column('canceled_at', sa.DateTime(), nullable=True),
        sa.Column(
            'created_at', sa.DateTime(),
            server_default=sa.text('(CURRENT_TIMESTAMP)'), nullable=False,
        ),
        sa.Column(
            'updated_at', sa.DateTime(),
            server_default=sa.text('(CURRENT_TIMESTAMP)'), nullable=False,
        ),
        sa.ForeignKeyConstraint(['user_id'], ['users.user_id']),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index('idx_subs_token', 'subscriptions', ['purchase_token'], unique=False)
    op.create_index('idx_subs_user', 'subscriptions', ['user_id'], unique=False)
    op.create_table(
        'usage_events',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('user_id', sa.String(length=128), nullable=False),
        sa.Column('module', sa.String(length=50), nullable=False),
        sa.Column(
            'created_at', sa.DateTime(),
            server_default=sa.text('(CURRENT_TIMESTAMP)'), nullable=False,
        ),
        sa.Column('ts', sa.Float(), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.user_id']),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index(
        'idx_usage_user_module', 'usage_events',
        ['user_id', 'module', 'ts'], unique=False,
    )
    op.create_index(
        'idx_usage_user_ts', 'usage_events',
        ['user_id', 'ts'], unique=False,
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index('idx_usage_user_ts', table_name='usage_events')
    op.drop_index('idx_usage_user_module', table_name='usage_events')
    op.drop_table('usage_events')
    op.drop_index('idx_subs_user', table_name='subscriptions')
    op.drop_index('idx_subs_token', table_name='subscriptions')
    op.drop_table('subscriptions')
    op.drop_index('idx_users_device', table_name='users')
    op.drop_table('users')
