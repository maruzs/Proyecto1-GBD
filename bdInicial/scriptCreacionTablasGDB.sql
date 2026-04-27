-- 0. Limpieza previa para hacer el script reruneable
DROP TABLE IF EXISTS Ventas CASCADE;
DROP TABLE IF EXISTS Compras CASCADE;
DROP TABLE IF EXISTS Almacenes CASCADE;
DROP TABLE IF EXISTS Cigarrillos CASCADE;
DROP TABLE IF EXISTS Estancos CASCADE;
DROP TABLE IF EXISTS Fabricantes CASCADE;

-- Creación de tabla Fabricantes
CREATE TABLE Fabricantes (
    nombre_fabricante VARCHAR(100) PRIMARY KEY,
    pais VARCHAR(100) NOT NULL
);

-- Creación de tabla Estancos
CREATE TABLE Estancos (
    nif_estanco VARCHAR(20) PRIMARY KEY,
    num_expendeduria INT NOT NULL,
    cp_estanco VARCHAR(15),
    nombre_estanco VARCHAR(100) NOT NULL,
    direccion_estanco VARCHAR(255),
    localidad_estanco VARCHAR(100) NOT NULL,
    provincia_estanco VARCHAR(100) NOT NULL
);

-- Creación de tabla Cigarrillos
CREATE TABLE Cigarrillos (
    marca VARCHAR(100),
    filtro BOOLEAN,
    color VARCHAR(50),
    clase VARCHAR(50),       -- Ej: Normal, Light, SuperLight, UltraLight
    mentol BOOLEAN,
    nicotina DECIMAL(5,2),
    alquitran DECIMAL(5,2),
    nombre_fabricante VARCHAR(100) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    precio_costo DECIMAL(10,2) NOT NULL,
    carton INT NOT NULL,     -- Cajetillas por cartón (generalmente 10)
    embalaje INT NOT NULL,   -- Cigarrillos por cajetilla (generalmente 20)
    PRIMARY KEY (marca, filtro, color, clase, mentol),
    FOREIGN KEY (nombre_fabricante) REFERENCES Fabricantes(nombre_fabricante)
);

-- Creación de tabla Almacenes
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

-- Creación de tabla Compras (Mayoristas)
CREATE TABLE Compras (
    nif_estanco VARCHAR(20),
    marca VARCHAR(100),
    filtro BOOLEAN,
    color VARCHAR(50),
    clase VARCHAR(50),
    mentol BOOLEAN,
    fecha_compra DATE,
    c_comprada INT NOT NULL, -- Cantidad en cartones
    precio_compra DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (nif_estanco, marca, filtro, color, clase, mentol, fecha_compra),
    FOREIGN KEY (nif_estanco) REFERENCES Estancos(nif_estanco),
    FOREIGN KEY (marca, filtro, color, clase, mentol) REFERENCES Cigarrillos(marca, filtro, color, clase, mentol)
);

-- Creación de tabla Ventas (Al detalle)
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

-- 1. Insertar Fabricantes (Operadores principales en el mercado chileno)
INSERT INTO Fabricantes (nombre_fabricante, pais) VALUES
('Philip Morris Chile', 'Chile'),
('BAT Chile', 'Chile');

-- 2. Insertar Estancos (RUTs chilenos)
INSERT INTO Estancos (nif_estanco, num_expendeduria, cp_estanco, nombre_estanco, direccion_estanco, localidad_estanco, provincia_estanco) VALUES
('76123456-K', 101, '3460000', 'Estanco Centro Sur', '1 Sur 1120', 'Talca', 'Talca'),
('77987654-3', 102, '3340000', 'Tabaquería Alameda', 'Alameda Manso de Velasco 450', 'Curicó', 'Curicó');

-- 3. Insertar Cigarrillos (Marcas vendidas en Chile con precios en CLP por cajetilla)
-- Atributos: (marca, filtro, color, clase, mentol, nicotina, alquitran, nombre_fabricante, precio_venta, precio_costo, carton, embalaje)
INSERT INTO Cigarrillos VALUES
('Marlboro Red', true, 'Rubio', 'Normal', false, 0.8, 10.0, 'Philip Morris Chile', 5000.00, 3800.00, 10, 20),
('Pall Mall Click', true, 'Rubio', 'Normal', true, 0.6, 8.0, 'BAT Chile', 4500.00, 3200.00, 10, 20),
('Kent Core', true, 'Rubio', 'Light', false, 0.5, 6.0, 'BAT Chile', 4800.00, 3500.00, 10, 20),
('Belmont', true, 'Rubio', 'Normal', false, 0.7, 9.0, 'BAT Chile', 4600.00, 3300.00, 10, 20);

-- 4. Insertar Almacenes (Inventario inicial asociado a cada estanco)
INSERT INTO Almacenes (nif_estanco, marca, filtro, color, clase, mentol, unidades) VALUES
('76123456-K', 'Marlboro Red', true, 'Rubio', 'Normal', false, 150),
('76123456-K', 'Pall Mall Click', true, 'Rubio', 'Normal', true, 80),
('77987654-3', 'Kent Core', true, 'Rubio', 'Light', false, 200),
('77987654-3', 'Belmont', true, 'Rubio', 'Normal', false, 50);

-- 5. Insertar Compras (Transacciones mayoristas en cartones durante 1 año de prueba)
-- Se refleja el precio_compra asumiendo el costo por cajetilla multiplicado por las 10 unidades del cartón
INSERT INTO Compras (nif_estanco, marca, filtro, color, clase, mentol, fecha_compra, c_comprada, precio_compra) VALUES
('76123456-K', 'Marlboro Red', true, 'Rubio', 'Normal', false, '2025-01-15', 50, 38000.00),
('76123456-K', 'Marlboro Red', true, 'Rubio', 'Normal', false, '2025-06-20', 100, 38000.00),
('76123456-K', 'Pall Mall Click', true, 'Rubio', 'Normal', true, '2025-03-10', 40, 32000.00),
('77987654-3', 'Kent Core', true, 'Rubio', 'Light', false, '2025-02-05', 100, 35000.00),
('77987654-3', 'Kent Core', true, 'Rubio', 'Light', false, '2025-08-12', 100, 35000.00),
('77987654-3', 'Belmont', true, 'Rubio', 'Normal', false, '2025-04-22', 25, 33000.00);

-- 6. Insertar Ventas (Transacciones al detalle coherentes con el stock comprado)
INSERT INTO Ventas (nif_estanco, marca, filtro, color, clase, mentol, fecha_venta, c_vendida, precio_venta) VALUES
('76123456-K', 'Marlboro Red', true, 'Rubio', 'Normal', false, '2025-01-20', 10, 5000.00),
('76123456-K', 'Marlboro Red', true, 'Rubio', 'Normal', false, '2025-07-05', 25, 5000.00),
('76123456-K', 'Pall Mall Click', true, 'Rubio', 'Normal', true, '2025-03-15', 5, 4500.00),
('77987654-3', 'Kent Core', true, 'Rubio', 'Light', false, '2025-02-10', 30, 4800.00),
('77987654-3', 'Kent Core', true, 'Rubio', 'Light', false, '2025-09-01', 40, 4800.00),
('77987654-3', 'Belmont', true, 'Rubio', 'Normal', false, '2025-05-10', 10, 4600.00);