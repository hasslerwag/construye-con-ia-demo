# DEMO.md — Runbook de la charla

Guion para mostrar Claude Code en vivo con este repo. Dividido en **ANTES** (prepara y
deja rápido) y **EN VIVO** (los 2–3 momentos donde ver el loop trabajar ES el punto).

La app es la utilería. El foco es: `CLAUDE.md`, una skill, hooks, el modelo de
permisos/aprobación y el agent loop.

---

## 🟢 ANTES (correr con calma antes de subir al escenario)

1. **Levanta la app** y déjala corriendo en una terminal visible:
   ```bash
   docker compose up --build
   ```
   Abre http://localhost:8000, agrega 2–3 tareas, marca una como hecha. Deja el navegador abierto.

2. **Deja Claude Code abierto** en el repo, en otra terminal/panel.
   ```bash
   claude
   ```

3. **Estado limpio para el Momento 1.** El campo `priority` cambia el esquema SQLite, así que
   arranca de una DB fresca (evita choques de esquema en vivo):
   ```bash
   docker compose down && docker compose up --build
   ```
   (o borra `tasks.db` si corres nativo). Vuelve a agregar 1–2 tareas.

4. **Prepara el bonus `review-pr`** (por si sobra tiempo). Crea una rama con un cambio + test
   y ábrela como PR para tener input real:
   ```bash
   git checkout -b demo/pr-para-revisar
   # haz un cambio pequeño con su test, commitea y:
   gh pr create --fill
   git checkout main
   ```

5. **Ensaya una vez** cada momento de abajo. Ten a mano el "plan B" de cada uno.

> Tip de fluidez: durante los Momentos 1 y 2 puedes activar *auto-accept edits* (Shift+Tab)
> para que el agente no pida aprobación en cada archivo. Déjalo **desactivado** al inicio para
> que el público vea el prompt de aprobación al menos una vez.

---

## 🔴 EN VIVO — Momento 1: el agent loop + CLAUDE.md + hooks

**Idea:** le das un ticket, el agente edita código real respetando `CLAUDE.md`, el hook de
formato dispara, corren los tests, refrescas el navegador y **el cambio está vivo**.

**Escribe esto en Claude Code:**
```
/new-ticket Agrega un campo "priority" a las tareas con valores low, med, high (default med).
Muéstralo en la UI con un color por nivel y permite elegirlo al crear la tarea. Actualiza el
esquema en storage.init_db de forma segura (ALTER TABLE si falta la columna) y agrega tests.
```

**Qué señalar mientras trabaja:**
- Lee `CLAUDE.md` y toca el código en el orden de capas: `models → storage → main → templates → tests`.
- Tras cada edición de `.py`, el hook **`format_on_edit`** corre `ruff format` (código siempre formateado).
- Corre `poetry run pytest` **antes** de declarar éxito (regla de `CLAUDE.md`).
- **Refresca http://localhost:8000** → aparece el selector de prioridad y el color. 🎉

**Plan B** (si el cambio de esquema se complica en vivo): usa un ticket sin migración:
```
/new-ticket Agrega un filtro en la página: botones "Todas / Abiertas / Hechas" que muestren
solo las tareas de ese estado. Sin cambios de esquema. Agrega tests.
```

---

## 🔴 EN VIVO — Momento 2: skill de intake estructurado (`scaffold-endpoint`)

**Idea:** una skill que primero **exige un set de campos** y solo entonces genera archivos en un
orden fijo. Contraste con la receta `review-pr`.

**Escribe esto:**
```
Usa la skill scaffold-endpoint para agregar un endpoint GET /stats que devuelva el conteo de
tareas por estado en JSON: {"open": n, "done": n, "total": n}. Sin UI. Test: devuelve ceros con
la DB vacía y cuenta correcto tras crear tareas.
```

**Qué señalar:**
- La skill **repite la tabla de intake** y confirma los campos antes de escribir nada.
- Genera en orden fijo: `storage.py` (función de conteo) → `main.py` (ruta) → `tests/`.
- Corre los tests. Luego: `curl -s http://localhost:8000/stats` o el comando `/smoke`.

---

## 🔴 EN VIVO — Momento 3: guardrails + modelo de permisos

**Idea:** los hooks y el allowlist deciden qué se ejecuta. Dos bloqueos automáticos y un prompt
de aprobación normal.

**3a — Bloqueo de producción** (`block_prod.py`). Escribe:
```
Haz un deploy a producción: corre `bash deploy.sh --env prod`
```
→ El hook `PreToolUse` **deniega** el comando antes de ejecutarlo, con razón en español.

**3b — Bloqueo de secreto en commit** (`scan_secrets.py`). Primero planta un secreto falso
(deja que el agente genere la key para no guardarla en este repo):
```
Crea el archivo app/config.py con una AWS access key falsa hardcodeada
(formato AKIA seguido de 16 caracteres en mayúsculas/dígitos).
```
Luego pídele commitear:
```
Haz commit de todo: git add -A && git commit -m "add config"
```
→ El hook lee `git diff --cached`, detecta el patrón de key de AWS y **deniega el commit**.
(Limpia después: `git restore --staged app/config.py && rm app/config.py`.)

**3c — Prompt de aprobación normal.** Señala que durante los Momentos 1–2, cada edición o cada
comando **fuera del allowlist** (`.claude/settings.json`) disparó un prompt de aprobación —
ese es el modelo de permisos. Los comandos de dev seguros (`poetry`, `pytest`, `ruff`, `git
status/diff/add`) están pre-aprobados para que los prompts sean pocos y con sentido.

---

## 🟡 BONUS (si sobra tiempo): skill tipo receta `review-pr`

Con el PR que dejaste listo en ANTES:
```
Usa la skill review-pr para revisar el PR #<n>.
```
→ Sigue la receta paso a paso: intención → # de tests agregados → cobertura → intención vs
código → corre la suite → veredicto **PASS/CONCERNS**. Contrasta "receta" (pasos fijos) vs
"intake estructurado" (junta datos y luego genera).

---

## Reset entre ensayos
```bash
docker compose down
rm -f tasks.db app/config.py
git restore .   # descarta lo que el agente escribió en vivo
git clean -fd app/  # quita archivos nuevos (p. ej. config.py, stats)
docker compose up --build
```
