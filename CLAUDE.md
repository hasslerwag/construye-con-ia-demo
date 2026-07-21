# CLAUDE.md — Convenciones del proyecto

Este repo es un **task tracker mínimo** que sirve de utilería para una charla sobre
Claude Code. La app es simple a propósito; respeta estas convenciones al modificarla.

## Stack y herramientas
- **Python 3.11** gestionado con **Poetry**. Nunca uses `pip install` directo; agrega
  dependencias con `poetry add` (y `poetry add --group dev` para herramientas de dev).
- **FastAPI** + **Jinja2** + **htmx** para el front, **SQLite** para persistencia.
- **pytest** para tests, **ruff** para formato y lint.

## Estructura de carpetas
```
app/
  main.py         # rutas FastAPI (delgadas: solo orquestan)
  models.py       # tipos de dominio (dataclasses)
  storage.py      # acceso a datos SQLite (aquí vive la lógica de datos)
  templates/      # plantillas Jinja2 (_task_list.html es el parcial que htmx intercambia)
  static/         # css + htmx vendorizado
tests/            # un test por comportamiento
.claude/          # skills, hooks y comandos (el "show" de la charla)
```
Regla de capas: **las rutas no llevan lógica de datos**. Si necesitas leer/escribir,
agrega una función en `storage.py` y llámala desde `main.py`.

## Tests
- Todo comportamiento nuevo (ruta, rama de lógica) necesita **al menos un test** en `tests/`.
- Corre `poetry run pytest` **antes** de decir que algo está listo. No declares éxito sin
  ver la salida en verde.
- Los tests usan la fixture `client` (`tests/conftest.py`), que apunta a una DB temporal.

## Estilo
- Formato y lint con **ruff**: `ruff format` y `ruff check --fix` (un hook lo corre solo
  tras cada edición).
- **Nada de docstrings vacíos.** No escribas `"""Create task."""` sobre `def create_task`.
  Un docstring debe explicar el *porqué*, un caso borde o una decisión no obvia — o no
  ir. Lo mismo con los comentarios.
- Cambios pequeños y enfocados. Commits en estilo convencional (`feat:`, `fix:`, `test:`…).

## Seguridad (aplicada por hooks)
- Ningún comando debe apuntar a **producción** (`block_prod.py` lo bloquea).
- Nunca commitees secretos; `scan_secrets.py` revisa el stage antes de cada commit.
  Usa variables de entorno / `.env` (ya en `.gitignore`).

## Cómo correr la app
- Docker (recomendado): `docker compose up` → http://localhost:8000
- Nativo (Python 3.11–3.12): `poetry install && poetry run uvicorn app.main:app --reload`
