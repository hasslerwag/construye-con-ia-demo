"""Tests for the task tracker endpoints."""


def test_index_starts_empty(client):
    resp = client.get("/")
    assert resp.status_code == 200
    assert "No hay tareas" in resp.text


def test_create_task_shows_in_list(client):
    resp = client.post("/tasks", data={"title": "Comprar café"})
    assert resp.status_code == 200
    assert "Comprar café" in resp.text


def test_toggle_marks_task_done(client):
    client.post("/tasks", data={"title": "Escribir la charla"})
    # The first created task has id 1.
    resp = client.post("/tasks/1/toggle")
    assert resp.status_code == 200
    assert "done" in resp.text


def test_toggle_is_reversible(client):
    client.post("/tasks", data={"title": "Preparar demo"})
    client.post("/tasks/1/toggle")  # -> done
    resp = client.post("/tasks/1/toggle")  # -> open again
    assert resp.status_code == 200
    # Back to open: the checkmark button should not be in its done state.
    assert "task open" in resp.text
