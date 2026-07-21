---
description: Smoke-test the running app on localhost:8000.
---

Verifica que la app esté arriba:
- `curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/` debe imprimir `200`.
- `curl -s http://localhost:8000/ | head -20`.

Reporta si la página renderiza y si lista las tareas.
