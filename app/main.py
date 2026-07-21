"""FastAPI app for the demo task tracker.

The app is intentionally small: it exists so we can hand Claude Code a ticket, watch it
edit real code under CLAUDE.md conventions and hooks, and see the change live in the
browser. Routes stay thin — data access lives in ``storage``.
"""

from __future__ import annotations

from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI, Form, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from app import storage

BASE_DIR = Path(__file__).parent


@asynccontextmanager
async def lifespan(app: FastAPI):
    storage.init_db()
    yield


app = FastAPI(title="Task Tracker — Construye con IA", lifespan=lifespan)
templates = Jinja2Templates(directory=str(BASE_DIR / "templates"))
app.mount("/static", StaticFiles(directory=str(BASE_DIR / "static")), name="static")


@app.get("/", response_class=HTMLResponse)
def index(request: Request):
    return templates.TemplateResponse(request, "tasks.html", {"tasks": storage.list_tasks()})


@app.post("/tasks", response_class=HTMLResponse)
def create_task(request: Request, title: str = Form(...)):
    storage.add_task(title.strip())
    return templates.TemplateResponse(request, "_task_list.html", {"tasks": storage.list_tasks()})


@app.post("/tasks/{task_id}/toggle", response_class=HTMLResponse)
def toggle(request: Request, task_id: int):
    storage.toggle_task(task_id)
    return templates.TemplateResponse(request, "_task_list.html", {"tasks": storage.list_tasks()})
