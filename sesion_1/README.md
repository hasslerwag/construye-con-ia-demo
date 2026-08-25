# Sesión 1 — Base de datos de biblioteca (PostgreSQL)

La base arranca **vacía** a propósito: en clase se crean las tablas y se cargan los
datos ejecutando los scripts desde el editor SQL de DBeaver.

## 1. Levantar la base (antes de la clase)

```bash
cd sesion_1
docker compose up -d
```

## 2. Conectar DBeaver

`Database` → `New Database Connection` → **PostgreSQL**

| Campo    | Valor        |
|----------|--------------|
| Host     | `localhost`  |
| Puerto   | `5433`       |
| Database | `biblioteca` |
| Usuario  | `demo`       |
| Password | `demo123`    |

> El puerto es 5433 (no 5432) para no chocar con otros Postgres locales.
> Credenciales de demo: esta base es desechable, no usarla fuera de la clase.

La primera vez DBeaver ofrece descargar el driver de PostgreSQL — acepta.
Al conectar no verás tablas todavía: eso es lo correcto.

## 3. Correr los scripts en clase

`SQL Editor` → `Open SQL script` → abre `schema.sql`, y después `seed.sql`.

**Ejecuta con `Alt+X`** (`Execute script`), no con `Ctrl+Enter`.

| Atajo       | Qué hace                                        |
|-------------|-------------------------------------------------|
| `Ctrl+Enter`| Ejecuta **solo** la sentencia bajo el cursor     |
| `Alt+X`     | Ejecuta **todo** el archivo, sentencia por sentencia |

Es el error más común: se ejecuta `Ctrl+Enter`, se crea una sola tabla, y el
`seed.sql` falla después con "relation does not exist".

Orden obligatorio: **`schema.sql` primero**, `seed.sql` después — el seed hace
`JOIN` contra las tablas que crea el schema.

### Qué debe quedar

| Tabla             | Filas |
|-------------------|-------|
| `usuario`         | 8     |
| `libro`           | 20    |
| `ubicacion`       | 8     |
| `libro_ubicacion` | 34    |

```sql
SELECT 'usuario' AS tabla, count(*) FROM usuario
UNION ALL SELECT 'libro', count(*) FROM libro
UNION ALL SELECT 'ubicacion', count(*) FROM ubicacion
UNION ALL SELECT 'libro_ubicacion', count(*) FROM libro_ubicacion
ORDER BY 1;
```

## 4. Si algo sale mal en vivo

Los scripts **no** son idempotentes: correr `schema.sql` dos veces da
`relation "usuario" already exists`, y `seed.sql` dos veces duplica filas.

Para volver a cero sin salir de DBeaver, ejecuta esto y vuelve al paso 3:

```sql
DROP TABLE IF EXISTS libro_ubicacion, libro, ubicacion, usuario CASCADE;
```

Para volver a cero desde la terminal (borra el volumen entero):

```bash
docker compose down -v && docker compose up -d
```

## Nota sobre el DML

Las llaves primarias son `GENERATED ALWAYS AS IDENTITY`, así que no se pueden
insertar ids a mano. Por eso `seed.sql` resuelve las llaves foráneas con
`INSERT ... SELECT ... JOIN` sobre un `VALUES`, buscando por columnas naturales
(nombre del usuario, nombre de la ubicación) en vez de ids hardcodeados.
