---
description: Implement a ticket end-to-end following CLAUDE.md conventions, with tests.
---

Implementa este ticket en la app de task tracker:

$ARGUMENTS

Reglas:
- Sigue CLAUDE.md: Poetry, la estructura de carpetas, un test de pytest por cada
  comportamiento nuevo, y nada de docstrings vacíos.
- Haz el cambio más pequeño que satisfaga el ticket.
- Cuando aplique, toca el código en este orden: models → storage → main (ruta) → templates → tests.
- Al terminar, corre `poetry run pytest` y reporta el resultado. Luego dime que
  refresque http://localhost:8000.
