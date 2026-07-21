# Design — `construye-con-ia-demo`

**Date:** 2026-07-20
**Purpose:** A small, real, generic dev tool that serves as a *prop* for a 1-hour talk on
LLMs, Claude, and Claude Code (mixed audience: half engineers, half business). The app is
deliberately boring; the **Claude Code artifacts are the star**.

## The app (prop)

A tiny **task tracker**:

- **Stack:** Python + Poetry, FastAPI, Jinja2 templates, htmx, SQLite.
- **Why these:** single Docker container, `uvicorn --reload` gives instant hot-reload, SQLite
  persists across reloads so state survives when the agent edits code live. No JS build step.
- **Run:** primary path is `docker compose up` → `http://localhost:8000`. Secondary: native
  Poetry (`poetry install && poetry run uvicorn app.main:app --reload`) on Python 3.11–3.12.
- **Endpoints (initial):** `GET /` (list), `POST /tasks` (create), `POST /tasks/{id}/toggle`.
- Tooling: **pytest** (+coverage), **ruff** (format + lint).

The initial app intentionally has **no `priority` field and no `/stats` endpoint** — those are
added *live* during the talk.

## Teaching artifacts

### CLAUDE.md (Spanish)
Poetry-only; folder layout; a pytest test for every new behavior; run `pytest` before claiming
done; **no vacuous docstrings** (document *why*, not the signature); ruff formatting; small
conventional commits.

### Skills (two archetypes)
- **`review-pr` — RECIPE:** fixed sequence: identify intent → count added tests → check coverage
  → match intent to code → run suite → PASS/CONCERNS verdict.
- **`scaffold-endpoint` — STRUCTURED-INTAKE:** collect a required field set (resource, method,
  path, request/response fields, needs-UI?, test cases); refuse to generate until complete; then
  write files in a fixed order (models → storage → main → templates → tests → verify).

### Hooks (three)
- **`block_prod.py`** — `PreToolUse(Bash)`: deny commands referencing prod targets.
- **`scan_secrets.py`** — `PreToolUse(Bash)`, only on `git commit`: scan `git diff --cached` for
  secret shapes; deny on match.
- **`format_on_edit.py`** — `PostToolUse(Edit|Write)`: `ruff format` (+ `--fix`) the touched `.py`.

Wired in `.claude/settings.json`, which also carries a **permission allowlist** for safe dev
Bash commands so live approval prompts are rare and meaningful.

### Slash commands
`/new-ticket <desc>`, `/run-tests`, `/smoke`.

## DEMO.md runbook

- **RUN BEFOREHAND:** clone, `docker compose up`, verify localhost, pre-create a feature branch +
  PR for `review-pr`, dry-run each live moment.
- **RUN LIVE (3 moments):**
  1. Agent loop + CLAUDE.md + hooks — ticket: add `priority` field; refresh browser to see it.
  2. Structured-intake skill — `scaffold-endpoint` adds `/stats`.
  3. Guardrails + permission model — `deploy prod` denied; planted secret commit denied; normal
     command hits approval prompt.

## Out of scope (YAGNI)
Auth, users, pagination, real DB migrations, CI. It's a prop.
