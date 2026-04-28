-- ==============================================================================
-- 0. LIMPIEZA PREVIA (RERUNEABLE)
-- ==============================================================================
DROP TABLE IF EXISTS Ventas CASCADE;
DROP TABLE IF EXISTS Compras CASCADE;
DROP TABLE IF EXISTS Almacenes CASCADE;
DROP TABLE IF EXISTS Cigarrillos CASCADE;
DROP TABLE IF EXISTS Estancos CASCADE;
DROP TABLE IF EXISTS Fabricantes CASCADE;

-- ==============================================================================
-- 1. DDL: CREACIÓN DE ESTRUCTURAS FÍSICAS
-- ==============================================================================
CREATE TABLE Fabricantes (
    nombre_fabricante VARCHAR(100) PRIMARY KEY,
    pais VARCHAR(100) NOT NULL
);

CREATE TABLE Estancos (
    nif_estanco VARCHAR(20) PRIMARY KEY,
    num_expendeduria INT NOT NULL,
    cp_estanco VARCHAR(15),
    nombre_estanco VARCHAR(100) NOT NULL,
    direccion_estanco VARCHAR(255),
    localidad_estanco VARCHAR(100) NOT NULL,
    provincia_estanco VARCHAR(100) NOT NULL
);

CREATE TABLE Cigarrillos (
    marca VARCHAR(100),
    filtro BOOLEAN,
    color VARCHAR(50),
    clase VARCHAR(50),
    mentol BOOLEAN,
    nicotina DECIMAL(5,2),
    alquitran DECIMAL(5,2),
    nombre_fabricante VARCHAR(100) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    precio_costo DECIMAL(10,2) NOT NULL,
    carton INT NOT NULL,
    embalaje INT NOT NULL,
    PRIMARY KEY (marca, filtro, color, clase, mentol),
    FOREIGN KEY (nombre_fabricante) REFERENCES Fabricantes(nombre_fabricante)
);

CREATE TABLE Almacenes (
    nif_estanco VARCHAR(20),
    marca VARCHAR(100),
    filtro BOOLEAN,
    color VARCHAR(50),
    clase VARCHAR(50),
    mentol BOOLEAN,
    unidades INT NOT NULL DEFAULT 0,
    PRIMARY KEY (nif_estanco, marca, filtro, color, clase, mentol),
    FOREIGN KEY (nif_estanco) REFERENCES Estancos(nif_estanco),
    FOREIGN KEY (marca, filtro, color, clase, mentol) REFERENCES Cigarrillos(marca, filtro, color, clase, mentol)
);

CREATE TABLE Compras (
    nif_estanco VARCHAR(20),
    marca VARCHAR(100),
    filtro BOOLEAN,
    color VARCHAR(50),
    clase VARCHAR(50),
    mentol BOOLEAN,
    fecha_compra DATE,
    c_comprada INT NOT NULL,
    precio_compra DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (nif_estanco, marca, filtro, color, clase, mentol, fecha_compra),
    FOREIGN KEY (nif_estanco) REFERENCES Estancos(nif_estanco),
    FOREIGN KEY (marca, filtro, color, clase, mentol) REFERENCES Cigarrillos(marca, filtro, color, clase, mentol)
);

CREATE TABLE Ventas (
    nif_estanco VARCHAR(20),
    marca VARCHAR(100),
    filtro BOOLEAN,
    color VARCHAR(50),
    clase VARCHAR(50),
    mentol BOOLEAN,
    fecha_venta DATE,
    c_vendida INT NOT NULL, 
    precio_venta DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (nif_estanco, marca, filtro, color, clase, mentol, fecha_venta),
    FOREIGN KEY (nif_estanco) REFERENCES Estancos(nif_estanco),
    FOREIGN KEY (marca, filtro, color, clase, mentol) REFERENCES Cigarrillos(marca, filtro, color, clase, mentol)
);

-- ==============================================================================
-- 2. DML: POBLAMIENTO MASIVO (Con ON CONFLICT para mayor seguridad)
-- ==============================================================================

-- 2.1 Carga de Fabricantes (5 países, 10 fabricantes por país = 50 registros)
INSERT INTO Fabricantes (nombre_fabricante, pais)
SELECT 
    'Fabricante_' || p || '_' || f,
    'Pais_' || p
FROM generate_series(1, 5) p, generate_series(1, 10) f
ON CONFLICT DO NOTHING;

-- 2.2 Carga de Estancos (10 provincias, 10 localidades/provincia, 15 estancos/localidad = 1,500 registros)
INSERT INTO Estancos (nif_estanco, num_expendeduria, cp_estanco, nombre_estanco, direccion_estanco, localidad_estanco, provincia_estanco)
SELECT 
    'NIF_' || prov || '_' || loc || '_' || est AS nif_estanco,
    (prov * 1000) + (loc * 100) + est AS num_expendeduria,
    'CP_' || prov || loc AS cp_estanco,
    'Estanco_' || prov || '_' || loc || '_' || est AS nombre_estanco,
    'Calle Falsa ' || (random() * 1000)::INT AS direccion_estanco,
    'Localidad_' || loc AS localidad_estanco,
    'Provincia_' || prov AS provincia_estanco
FROM generate_series(1, 10) prov, 
     generate_series(1, 10) loc, 
     generate_series(1, 15) est
ON CONFLICT DO NOTHING;

-- 2.3 Carga de Cigarrillos (10 tipos por fabricante = 500 registros)
INSERT INTO Cigarrillos (marca, filtro, color, clase, mentol, nicotina, alquitran, nombre_fabricante, precio_venta, precio_costo, carton, embalaje)
SELECT 
    'Marca_' || f.nombre_fabricante || '_' || t AS marca,
    (random() > 0.5) AS filtro,
    CASE WHEN random() > 0.5 THEN 'Rubio' ELSE 'Negro' END AS color,
    (ARRAY['Normal', 'Light', 'SuperLight', 'UltraLight'])[ceil(random()*4)] AS clase,
    (random() > 0.8) AS mentol,
    (random() * 1.5 + 0.1)::DECIMAL(5,2) AS nicotina,
    (random() * 15.0 + 1.0)::DECIMAL(5,2) AS alquitran,
    f.nombre_fabricante,
    (random() * 3000 + 2000)::DECIMAL(10,2) AS precio_venta,
    (random() * 1500 + 1000)::DECIMAL(10,2) AS precio_costo,
    10 AS carton,
    20 AS embalaje
FROM Fabricantes f, generate_series(1, 10) t
ON CONFLICT DO NOTHING;

-- 2.4 Carga de Almacenes (Entre 10 y 30 tipos de cigarrillos por cada estanco)
INSERT INTO Almacenes (nif_estanco, marca, filtro, color, clase, mentol, unidades)
SELECT 
    e.nif_estanco,
    c.marca, c.filtro, c.color, c.clase, c.mentol,
    (random() * 500 + 50)::INT AS unidades 
FROM Estancos e
JOIN LATERAL (
    SELECT marca, filtro, color, clase, mentol 
    FROM Cigarrillos 
    ORDER BY random() 
    LIMIT (floor(random() * 21) + 10)::INT 
) c ON true
ON CONFLICT DO NOTHING;

-- 2.5 Carga de Compras (3 años, ~2 compras mensuales por almacén)
INSERT INTO Compras (nif_estanco, marca, filtro, color, clase, mentol, fecha_compra, c_comprada, precio_compra)
SELECT 
    a.nif_estanco, a.marca, a.filtro, a.color, a.clase, a.mentol,
    make_date(anio, mes, 
        CASE WHEN num_compra = 1 THEN (random() * 13 + 1)::INT 
             ELSE (random() * 13 + 15)::INT                    
        END
    ) AS fecha_compra,
    (random() * 100 + 10)::INT AS c_comprada,
    c.precio_costo * 10 AS precio_compra 
FROM Almacenes a
JOIN Cigarrillos c ON a.marca = c.marca AND a.filtro = c.filtro AND a.color = c.color AND a.clase = c.clase AND a.mentol = c.mentol
CROSS JOIN generate_series(2023, 2025) anio
CROSS JOIN generate_series(1, 12) mes
CROSS JOIN generate_series(1, 2) num_compra
ON CONFLICT DO NOTHING;

-- 2.6 Carga de Ventas (Coherente con las compras, 3 años)
INSERT INTO Ventas (nif_estanco, marca, filtro, color, clase, mentol, fecha_venta, c_vendida, precio_venta)
SELECT 
    comp.nif_estanco, comp.marca, comp.filtro, comp.color, comp.clase, comp.mentol,
    comp.fecha_compra + ((random() * 10 + 1)::INT) AS fecha_venta, 
    (comp.c_comprada * (random() * 0.8 + 0.1))::INT AS c_vendida,  
    c.precio_venta AS precio_venta
FROM Compras comp
JOIN Cigarrillos c ON comp.marca = c.marca AND comp.filtro = c.filtro AND comp.color = c.color AND comp.clase = c.clase AND comp.mentol = c.mentol
ON CONFLICT DO NOTHING;