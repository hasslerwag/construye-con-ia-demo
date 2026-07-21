"""SQLite-backed storage for tasks.

Deliberately tiny — this app is a demo prop. The DB path is read at call time (not
import time) so tests can point it at a temp file via the ``TASKS_DB`` env var.
"""

from __future__ import annotations

import os
import sqlite3
from collections.abc import Iterator
from contextlib import contextmanager

from app.models import Task


def _db_path() -> str:
    return os.environ.get("TASKS_DB", "tasks.db")


@contextmanager
def _conn() -> Iterator[sqlite3.Connection]:
    conn = sqlite3.connect(_db_path())
    conn.row_factory = sqlite3.Row
    try:
        yield conn
        conn.commit()
    finally:
        conn.close()


def init_db() -> None:
    with _conn() as conn:
        conn.execute(
            "CREATE TABLE IF NOT EXISTS tasks ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title TEXT NOT NULL, "
            "status TEXT NOT NULL DEFAULT 'open')"
        )


def list_tasks() -> list[Task]:
    with _conn() as conn:
        rows = conn.execute("SELECT id, title, status FROM tasks ORDER BY id DESC").fetchall()
    return [Task(id=r["id"], title=r["title"], status=r["status"]) for r in rows]


def add_task(title: str) -> Task:
    with _conn() as conn:
        cur = conn.execute("INSERT INTO tasks (title, status) VALUES (?, 'open')", (title,))
        task_id = cur.lastrowid
    return Task(id=int(task_id), title=title, status="open")


def toggle_task(task_id: int) -> None:
    # Flip open<->done in a single statement so we never read-then-write a stale value.
    with _conn() as conn:
        conn.execute(
            "UPDATE tasks SET status = CASE status WHEN 'open' THEN 'done' ELSE 'open' END "
            "WHERE id = ?",
            (task_id,),
        )
