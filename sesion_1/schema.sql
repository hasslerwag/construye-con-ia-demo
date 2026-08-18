-- Esquema de biblioteca (PostgreSQL)
-- Derivado del ERD: Usuario 1:N Libro, Libro N:N Ubicacion

CREATE TABLE usuario (
    id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre    TEXT NOT NULL,
    apellido  TEXT NOT NULL,
    direccion TEXT
);

CREATE TABLE libro (
    codigo     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre     TEXT           NOT NULL,
    precio     NUMERIC(12, 2) NOT NULL,
    nn_paginas  INTEGER,
    -- FK del lado "N": cada libro pertenece a un usuario (1:N)
    usuario_id BIGINT         NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuario (id)
);

CREATE TABLE ubicacion (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre       TEXT NOT NULL,
    ciudad       TEXT,
    departamento TEXT,
    pais         TEXT
);

-- Tabla intermedia para la relacion N:N entre libro y ubicacion
CREATE TABLE libro_ubicacion (
    libro_codigo BIGINT NOT NULL,
    ubicacion_id BIGINT NOT NULL,
    PRIMARY KEY (libro_codigo, ubicacion_id),
    FOREIGN KEY (libro_codigo) REFERENCES libro (codigo) ON DELETE CASCADE,
    FOREIGN KEY (ubicacion_id) REFERENCES ubicacion (id) ON DELETE CASCADE
);
