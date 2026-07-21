# construye-con-ia-demo

Task tracker mínimo (FastAPI + htmx + SQLite) que sirve de **utilería** para una charla de
una hora sobre LLMs, Claude y **Claude Code**. La app es el pretexto; lo interesante vive en
`.claude/` (CLAUDE.md, skills, hooks, comandos) y en [`DEMO.md`](./DEMO.md).

## Requisitos
- **Docker** (camino recomendado), o
- **Python 3.11–3.12 + Poetry** para correr en modo nativo.

## Correr con Docker (recomendado)
```bash
docker compose up --build
```
Abre http://localhost:8000. El código de `app/` está montado como volumen, así que al
editar un archivo `uvicorn --reload` recarga solo — refresca el navegador y ves el cambio.

## Correr nativo con Poetry
```bash
poetry install
poetry run uvicorn app.main:app --reload
```
> Nota: en Python 3.13+ algunas dependencias aún no traen wheels; usa 3.11–3.12 (por ejemplo
> con `pyenv`) o el camino de Docker.

## Tests
```bash
poetry run pytest --cov=app --cov-report=term-missing
```

## Qué mirar (mapa del repo)
| Ruta | Qué demuestra |
|------|----------------|
| `CLAUDE.md` | Convenciones que el agente respeta (Poetry, capas, tests, docstrings). |
| `.claude/skills/review-pr/` | Skill tipo **receta**: revisa un PR paso a paso. |
| `.claude/skills/scaffold-endpoint/` | Skill tipo **intake estructurado**: junta campos, luego genera. |
| `.claude/hooks/` | `block_prod`, `scan_secrets` (PreToolUse) y `format_on_edit` (PostToolUse). |
| `.claude/commands/` | `/new-ticket`, `/run-tests`, `/smoke`. |
| `.claude/settings.json` | Cableado de hooks + allowlist de permisos. |
| `app/` | La app (rutas delgadas, lógica de datos en `storage.py`). |

## Estructura
```
app/            FastAPI + plantillas + estático
tests/          pytest (fixture client -> DB temporal)
.claude/        skills, hooks, comandos, settings
docs/           spec de diseño
DEMO.md         runbook de la charla (antes / en vivo)
```
