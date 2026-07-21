"""Shared test fixtures."""

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture()
def client(monkeypatch, tmp_path):
    # Point storage at a throwaway DB so tests never touch the real tasks.db.
    monkeypatch.setenv("TASKS_DB", str(tmp_path / "test.db"))
    with TestClient(app) as c:  # entering the context runs the lifespan -> init_db
        yield c
