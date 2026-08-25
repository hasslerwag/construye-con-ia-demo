-- Datos de ejemplo para el esquema de biblioteca.
-- Las PK son GENERATED ALWAYS AS IDENTITY, asi que nunca insertamos ids a mano:
-- las relaciones se resuelven con subconsultas sobre columnas naturales.

-- ---------------------------------------------------------------- usuarios
INSERT INTO usuario (nombre, apellido, direccion) VALUES
    ('Laura',    'Gutierrez', 'Cra 7 # 45-12, Bogota'),
    ('Andres',   'Molina',    'Cl 10 Sur # 22-40, Medellin'),
    ('Valentina','Rojas',     'Av 4N # 18-33, Cali'),
    ('Sebastian','Cardenas',  'Cra 53 # 72-19, Barranquilla'),
    ('Camila',   'Ortiz',     'Cl 8 # 3-55, Cartagena'),
    ('Mateo',    'Herrera',   NULL),
    ('Isabella', 'Nunez',     'Cra 15 # 100-24, Bogota'),
    ('Daniel',   'Vargas',    'Cl 34 # 6-70, Bucaramanga');

-- ------------------------------------------------------------- ubicaciones
INSERT INTO ubicacion (nombre, ciudad, departamento, pais) VALUES
    ('Sede Principal',        'Bogota',       'Cundinamarca', 'Colombia'),
    ('Sucursal Chapinero',    'Bogota',       'Cundinamarca', 'Colombia'),
    ('Biblioteca El Poblado', 'Medellin',     'Antioquia',    'Colombia'),
    ('Sala San Antonio',      'Cali',         'Valle del Cauca', 'Colombia'),
    ('Deposito Norte',        'Barranquilla', 'Atlantico',    'Colombia'),
    ('Sala Centro Historico', 'Cartagena',    'Bolivar',      'Colombia'),
    ('Anexo Cabecera',        'Bucaramanga',  'Santander',    'Colombia'),
    ('Bodega Central',        'Bogota',       'Cundinamarca', 'Colombia');

-- ------------------------------------------------------------------ libros
-- usuario_id se resuelve por (nombre, apellido) del duenio.
INSERT INTO libro (nombre, precio, nn_paginas, usuario_id)
SELECT v.nombre, v.precio, v.nn_paginas, u.id
FROM (VALUES
    ('Cien anos de soledad',        89000.00, 471, 'Laura',     'Gutierrez'),
    ('El amor en los tiempos del colera', 76500.00, 464, 'Laura', 'Gutierrez'),
    ('La voragine',                 45000.00, 320, 'Laura',     'Gutierrez'),
    ('Rayuela',                     92000.00, 736, 'Andres',    'Molina'),
    ('Ficciones',                   58000.00, 203, 'Andres',    'Molina'),
    ('Pedro Paramo',                39900.00, 128, 'Andres',    'Molina'),
    ('La casa de los espiritus',    81000.00, 448, 'Valentina', 'Rojas'),
    ('Conversacion en La Catedral', 105000.00, 601, 'Valentina','Rojas'),
    ('El tunel',                    34500.00, 144, 'Valentina', 'Rojas'),
    ('Delirio',                     52000.00, 296, 'Sebastian', 'Cardenas'),
    ('El ruido de las cosas al caer', 61000.00, 259, 'Sebastian','Cardenas'),
    ('La hojarasca',                41000.00, 137, 'Camila',    'Ortiz'),
    ('Los detectives salvajes',     98000.00, 609, 'Camila',    'Ortiz'),
    ('Estructuras de datos',        135000.00, 512, 'Mateo',    'Herrera'),
    ('Introduccion a SQL',          120000.00, 384, 'Mateo',    'Herrera'),
    ('Diseno de bases de datos',    148500.00, 640, 'Mateo',    'Herrera'),
    ('El olvido que seremos',       67000.00, 274, 'Isabella',  'Nunez'),
    ('Angosta',                     55000.00, 352, 'Isabella',  'Nunez'),
    ('Satanas',                     48000.00, 224, 'Daniel',    'Vargas'),
    ('Poesia completa',             72000.00, NULL, 'Daniel',   'Vargas')
) AS v(nombre, precio, nn_paginas, u_nombre, u_apellido)
JOIN usuario u ON u.nombre = v.u_nombre AND u.apellido = v.u_apellido;

-- ------------------------------------------------------- libro <-> ubicacion
-- Relacion N:N: un mismo titulo puede estar en varias sedes.
INSERT INTO libro_ubicacion (libro_codigo, ubicacion_id)
SELECT l.codigo, ub.id
FROM (VALUES
    ('Cien anos de soledad',        'Sede Principal'),
    ('Cien anos de soledad',        'Biblioteca El Poblado'),
    ('Cien anos de soledad',        'Bodega Central'),
    ('El amor en los tiempos del colera', 'Sede Principal'),
    ('El amor en los tiempos del colera', 'Sala Centro Historico'),
    ('La voragine',                 'Sucursal Chapinero'),
    ('Rayuela',                     'Sucursal Chapinero'),
    ('Rayuela',                     'Sala San Antonio'),
    ('Ficciones',                   'Biblioteca El Poblado'),
    ('Ficciones',                   'Sede Principal'),
    ('Pedro Paramo',                'Sala San Antonio'),
    ('La casa de los espiritus',    'Sala San Antonio'),
    ('La casa de los espiritus',    'Anexo Cabecera'),
    ('Conversacion en La Catedral', 'Sede Principal'),
    ('El tunel',                    'Deposito Norte'),
    ('Delirio',                     'Deposito Norte'),
    ('Delirio',                     'Sede Principal'),
    ('El ruido de las cosas al caer', 'Sucursal Chapinero'),
    ('El ruido de las cosas al caer', 'Biblioteca El Poblado'),
    ('La hojarasca',                'Sala Centro Historico'),
    ('Los detectives salvajes',     'Sala Centro Historico'),
    ('Los detectives salvajes',     'Bodega Central'),
    ('Estructuras de datos',        'Sede Principal'),
    ('Estructuras de datos',        'Anexo Cabecera'),
    ('Introduccion a SQL',          'Sede Principal'),
    ('Introduccion a SQL',          'Sucursal Chapinero'),
    ('Introduccion a SQL',          'Biblioteca El Poblado'),
    ('Diseno de bases de datos',    'Bodega Central'),
    ('El olvido que seremos',       'Biblioteca El Poblado'),
    ('El olvido que seremos',       'Sede Principal'),
    ('Angosta',                     'Biblioteca El Poblado'),
    ('Satanas',                     'Anexo Cabecera'),
    ('Poesia completa',             'Anexo Cabecera'),
    ('Poesia completa',             'Bodega Central')
) AS v(libro_nombre, ubicacion_nombre)
JOIN libro     l  ON l.nombre  = v.libro_nombre
JOIN ubicacion ub ON ub.nombre = v.ubicacion_nombre;
