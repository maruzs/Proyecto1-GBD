--PUNTO 2: CONSULTAS SIN JOIN DE LOS DATOS DE FABRICANTES Y CIGARRILLOS
--CONSULTA 1: VENTAS POR ESTANCO Y DETALLES DEL CIGARRILLO DESDE EL 01/01/2025 AL 30/05/2025

SELECT v.nif_estanco, v.fecha_venta, v.c_vendida, c.marca, c.clase, c.precio_venta 
FROM Ventas v, Cigarrillos c 
WHERE v.marca = c.marca AND v.filtro = c.filtro AND v.color = c.color AND v.clase = c.clase AND v.mentol = c.mentol AND v.fecha_venta BETWEEN '2025-01-01' AND '2025-06-30'; 

--EXPLAIN ANALYZE: EXECUTION TIME=0.089ms -- [PROBAR MARIANO]
--CONSULTA 2: COMPRAS INDICANDO A LOS FABRICANTES
EXPLAIN ANALYZE
SELECT co.nif_estanco, co.fecha_compra, co.c_comprada, c.marca, f.nombre_fabricante, f.pais 
FROM Compras co, Cigarrillos c, Fabricantes f 
WHERE co.marca = c.marca AND co.filtro = c.filtro AND co.color = c.color AND co.clase = c.clase AND co.mentol = c.mentol 
AND c.nombre_fabricante = f.nombre_fabricante 
AND f.nombre_fabricante = 'Fabricante_1_1'; -- Cambiado para que coincida con tus datos masivos
--EXPLAIN ANALYZE: EXECUTION TIME=0.104ms -- [PROBAR MARIANO]

-- PUNTO 3: METODOS DE OPTIMIZACION

-- Se seleccionaron índices de tipo B-Tree (Balanced Tree), ya que son la estructura ideal en PostgreSQL para optimizar consultas que involucran operadores de igualdad (=), como ocurre al cruzar nuestras claves foráneas compuestas entre Ventas y Cigarrillos. Además, el B-Tree es altamente eficiente para consultas de rangos (<>), lo cual es fundamental para acelerar las búsquedas por fecha
-- CREACIÓN DE ÍNDICES:
-- Índice 1 para los rangos de fechas:
CREATE INDEX idx_ventas_fecha ON Ventas(fecha_venta);
CREATE INDEX idx_compras_fecha ON Compras(fecha_compra);

-- Índice 2, para buscar por fabricantes de cigarros más rápido:
CREATE INDEX idx_cigarrillos_fabricante ON Cigarrillos(nombre_fabricante);


-- Índice 3: para acelerar el cruce de Ventas y Cigarrillos (compuesto)
CREATE INDEX idx_ventas_fk_cigarrillos ON Ventas(marca, filtro, color, clase, mentol);
CREATE INDEX idx_compras_fk_cigarrillos ON Compras(marca, filtro, color, clase, mentol);

-- PUNTO 4: PROBAR NUEVAMENTE LOS TIEMPOS DE RESPUESTA
--EXPLAIN ANALYZE DE CONSULTA 1: EXECUTION TIME= 0.061ms (VS 0.089ms) -- [PROBAR MARIANO]
--EXPLAIN ANALYZE DE CONSULTA 2: EXECUTION TIME= 0.135ms (VS 0.104ms) -- (SE TARDA MÁS POR USAR UN DATASET PEQUEÑO [SOBRECOSTO INNECESARIO])

-- PUNTO 5: APLICAR OPTIMIZACIONES CON JOIN Y HEURÍSTICAS
-- CONSULTA 1: VENTAS POR ESTANCO Y DETALLES DEL CIGARRILLO DESDE EL 01/01/2025 AL 30/05/2025
-- HEURISTICA APLICADA: Se aplica el "Traslado de selección", filtrando la tabla Ventas por el rango de fechas antes de realizar el acoplamiento con JOIN, con la tabla Cigarrillos.
-- CONSULTA SQL OPTIMIZADA:
EXPLAIN ANALYZE
SELECT v.nif_estanco, v.fecha_venta, v.c_vendida, c.marca, c.clase, c.precio_venta
FROM (
    -- Heurística: Filtramos Ventas antes del JOIN
    SELECT * FROM Ventas 
    WHERE fecha_venta BETWEEN '2025-01-01' AND '2025-06-30'
) v
INNER JOIN Cigarrillos c 
    ON v.marca = c.marca 
    AND v.filtro = c.filtro 
    AND v.color = c.color 
    AND v.clase = c.clase 
    AND v.mentol = c.mentol;

-- EXPLAIN ANALYZE: EXECUTION TIME= 0.091ms (VS 0.061ms) -- [TESTEAR CON DATASET COMPLETO - MARIANO]

-- CONSULTA 2: COMPRAS INDICANDO A LOS FABRICANTES
-- HEURÍSTICA APLICADA: Aquí aplicamos selección temprana en dos ramas: filtramos las Compras (si hubiera criterio de fecha) y los Fabricantes por nombre antes de realizar los JOINs. 
-- CONSULTA SQL OPTIMIZADA:
EXPLAIN ANALYZE
SELECT co.nif_estanco, co.fecha_compra, co.c_comprada, c.marca, f.nombre_fabricante, f.pais
FROM (
    -- Heurística: Filtrar fabricante específico en la base
    SELECT nombre_fabricante, pais 
    FROM Fabricantes 
    WHERE nombre_fabricante = 'BAT Chile'
) f
INNER JOIN Cigarrillos c 
    ON f.nombre_fabricante = c.nombre_fabricante
INNER JOIN Compras co
    ON c.marca = co.marca 
    AND c.filtro = co.filtro 
    AND c.color = co.color 
    AND c.clase = co.clase 
    AND co.mentol = c.mentol;

-- EXPLAIN ANALYZE DE CONSULTA 2: EXECUTION TIME= 0.136ms (VS 0.135ms) -- [TESTEAR CON DATASET COMPLETO - MARIANO]

-- ÁRBOLES DE CONSULTAS:
-- SIMBOLOGÍA:
-- π (Proyección): Indica las columnas que se muestran en el SELECT
-- σ (Selección): Representa los filtros aplicados mediante el WHERE
-- × (Producto cartesiano): El cruce total sin condiciones que ocurre en las consultas ineficientes
-- ⨝ (JOIN): Unión mediante condiciones específicas
