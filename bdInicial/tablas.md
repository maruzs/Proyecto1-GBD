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
