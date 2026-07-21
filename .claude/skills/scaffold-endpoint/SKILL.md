---
name: scaffold-endpoint
description: Use when adding a new HTTP endpoint to the task tracker. Structured intake — collect a required field set first, refuse to generate until it is complete, then create files in a fixed order.
---

# scaffold-endpoint (structured intake)

This is a STRUCTURED-INTAKE skill: you must collect a complete field set BEFORE writing
any code, then generate files in a FIXED order.

## Step 1 — Intake (required before any file is written)
Collect ALL of the following. If any field is missing, ask for it and STOP. Never generate
code with `TODO`/placeholder values.

| Field | Example |
|-------|---------|
| `resource` (noun) | `stats` |
| `method` | `GET` |
| `path` | `/stats` |
| `request fields` (name:type) | none, or `title:str` |
| `response shape` | `{"open": int, "done": int}` |
| `needs UI?` (yes/no) | no |
| `test cases` (at least one) | "returns zeros for an empty db" |

Echo the completed table back and get a "yes" before proceeding.

## Step 2 — Generate files IN THIS ORDER
Follow CLAUDE.md conventions. Generate strictly in this sequence:

1. `app/models.py` — add or adjust any dataclass / type needed.
2. `app/storage.py` — add the data-access function(s). Keep logic here, not in the route.
3. `app/main.py` — add the route; it calls `storage` and returns the response/template.
4. `app/templates/` — ONLY if `needs UI? = yes`. Add/extend the template and wire htmx.
5. `tests/` — add a test per declared test case.

## Step 3 — Verify
- Run `poetry run pytest`.
- Report: files created/changed, tests added, and pass/fail.

The order is not optional: storage and models must exist before the route imports them.
