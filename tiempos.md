# NOTAS

En muchos messages sale "10 rows affected" o "12 rows affected" pero EXPLAIN ANALYZE da los datos reales

# Ejecucion de `ScriptCreacionBDProyectoGBD.sql`

## Messages

NOTICE: table "ventas" does not exist, skipping
NOTICE: table "compras" does not exist, skipping
NOTICE: table "almacenes" does not exist, skipping
NOTICE: table "cigarrillos" does not exist, skipping
NOTICE: table "estancos" does not exist, skipping
NOTICE: table "fabricantes" does not exist, skipping
INSERT 0 3223037

Query returned successfully in 4 min 16 secs.

# Ejecucion de `consultas.sql` sin optimizacion

## CONSULTA 1: VENTAS POR ESTANCO Y DETALLES DEL CIGARRILLO DESDE EL 01/01/2025 AL 30/05/2025

EXPLAIN ANALYZE
SELECT v.nif_estanco, v.fecha_venta, v.c_vendida, c.marca, c.clase, c.precio_venta
FROM Ventas v, Cigarrillos c
WHERE v.marca = c.marca AND v.filtro = c.filtro AND v.color = c.color AND v.clase = c.clase AND v.mentol = c.mentol AND v.fecha_venta BETWEEN '2025-01-01' AND '2025-06-30';

### Messages

Successfully run. Total query runtime: 604 msec.
10 rows affected.

### Data Output

"Hash Join (cost=24.25..94216.85 rows=533537 width=55) (actual time=0.773..577.353 rows=534282 loops=1)"
" Hash Cond: (((v.marca)::text = (c.marca)::text) AND (v.filtro = c.filtro) AND ((v.color)::text = (c.color)::text) AND ((v.clase)::text = (c.clase)::text) AND (v.mentol = c.mentol))"
" -> Seq Scan on ventas v (cost=0.00..87189.12 rows=533537 width=57) (actual time=0.569..367.549 rows=534282 loops=1)"
" Filter: ((fecha_venta >= '2025-01-01'::date) AND (fecha_venta <= '2025-06-30'::date))"
" Rows Removed by Filter: 2688755"
" -> Hash (cost=13.00..13.00 rows=500 width=45) (actual time=0.191..0.192 rows=500 loops=1)"
" Buckets: 1024 Batches: 1 Memory Usage: 47kB"
" -> Seq Scan on cigarrillos c (cost=0.00..13.00 rows=500 width=45) (actual time=0.010..0.076 rows=500 loops=1)"
"Planning Time: 0.329 ms"
"Execution Time: 589.984 ms"

## CONSULTA 2: COMPRAS POR ESTANCO Y DETALLES DEL CIGARRILLO

EXPLAIN ANALYZE
SELECT co.nif_estanco, co.fecha_compra, co.c_comprada, c.marca, f.nombre_fabricante, f.pais
FROM Compras co, Cigarrillos c, Fabricantes f
WHERE co.marca = c.marca AND co.filtro = c.filtro AND co.color = c.color AND co.clase = c.clase AND co.mentol = c.mentol
AND c.nombre_fabricante = f.nombre_fabricante
AND f.nombre_fabricante = 'Fabricante_1_1';

### Messages

Successfully run. Total query runtime: 423 msec.
16 rows affected.

### Data Output

"Nested Loop (cost=1014.62..80097.76 rows=64794 width=477) (actual time=12.358..393.770 rows=216000 loops=1)"
" -> Index Scan using fabricantes_pkey on fabricantes f (cost=0.14..8.16 rows=1 width=436) (actual time=0.031..0.034 rows=1 loops=1)"
" Index Cond: ((nombre_fabricante)::text = 'Fabricante_1_1'::text)"
" -> Gather (cost=1014.48..79441.66 rows=64794 width=56) (actual time=12.324..375.152 rows=216000 loops=1)"
" Workers Planned: 2"
" Workers Launched: 2"
" -> Hash Join (cost=14.47..71962.26 rows=26998 width=56) (actual time=0.589..335.384 rows=72000 loops=3)"
" Hash Cond: (((co.marca)::text = (c.marca)::text) AND (co.filtro = c.filtro) AND ((co.color)::text = (c.color)::text) AND ((co.clase)::text = (c.clase)::text) AND (co.mentol = c.mentol))"
" -> Parallel Seq Scan on compras co (cost=0.00..54228.71 rows=1349871 width=57) (actual time=0.176..93.252 rows=1080000 loops=3)"
" -> Hash (cost=14.25..14.25 rows=10 width=54) (actual time=0.244..0.244 rows=10 loops=3)"
" Buckets: 1024 Batches: 1 Memory Usage: 9kB"
" -> Seq Scan on cigarrillos c (cost=0.00..14.25 rows=10 width=54) (actual time=0.149..0.233 rows=10 loops=3)"
" Filter: ((nombre_fabricante)::text = 'Fabricante_1_1'::text)"
" Rows Removed by Filter: 490"
"Planning Time: 0.471 ms"
"Execution Time: 399.166 ms"

# Ejecucion de `consultas.sql` con optimizaciones

Se seleccionaron índices de tipo B-Tree (Balanced Tree), ya que son la estructura ideal en PostgreSQL para optimizar consultas que involucran operadores de igualdad (=), como ocurre al cruzar nuestras claves foráneas compuestas entre Ventas y Cigarrillos. Además, el B-Tree es altamente eficiente para consultas de rangos (<>), lo cual es fundamental para acelerar las búsquedas por fecha

## Creacion de Indices

- Índice 1 para los rangos de fechas:
  CREATE INDEX idx_ventas_fecha ON Ventas(fecha_venta);
  CREATE INDEX idx_compras_fecha ON Compras(fecha_compra);
  --> Query returned successfully in 2 secs 533 msec.

- Índice 2, para buscar por fabricantes de cigarros más rápido:
  CREATE INDEX idx_cigarrillos_fabricante ON Cigarrillos(nombre_fabricante);
  --> Query returned successfully in 27 msec.
- Índice 3: para acelerar el cruce de Ventas y Cigarrillos (compuesto)
  CREATE INDEX idx_ventas_fk_cigarrillos ON Ventas(marca, filtro, color, clase, mentol);
  CREATE INDEX idx_compras_fk_cigarrillos ON Compras(marca, filtro, color, clase, mentol);
  --> Query returned successfully in 6 secs 471 msec.

## CONSULTA 1: VENTAS POR ESTANCO Y DETALLES DEL CIGARRILLO DESDE EL 01/01/2025 AL 30/05/2025

EXPLAIN ANALYZE
SELECT v.nif_estanco, v.fecha_venta, v.c_vendida, c.marca, c.clase, c.precio_venta
FROM Ventas v, Cigarrillos c
WHERE v.marca = c.marca AND v.filtro = c.filtro AND v.color = c.color AND v.clase = c.clase AND v.mentol = c.mentol AND v.fecha_venta BETWEEN '2025-01-01' AND '2025-06-30';

### Messages

Successfully run. Total query runtime: 375 msec.
12 rows affected.

### Data Output

"Hash Join (cost=7342.05..61199.26 rows=533597 width=55) (actual time=13.387..339.799 rows=534282 loops=1)"
" Hash Cond: (((v.marca)::text = (c.marca)::text) AND (v.filtro = c.filtro) AND ((v.color)::text = (c.color)::text) AND ((v.clase)::text = (c.clase)::text) AND (v.mentol = c.mentol))"
" -> Bitmap Heap Scan on ventas v (cost=7317.80..54170.75 rows=533597 width=57) (actual time=13.175..87.522 rows=534282 loops=1)"
" Recheck Cond: ((fecha_venta >= '2025-01-01'::date) AND (fecha_venta <= '2025-06-30'::date))"
" Heap Blocks: exact=7414"
" -> Bitmap Index Scan on idx_ventas_fecha (cost=0.00..7184.40 rows=533597 width=0) (actual time=12.370..12.370 rows=534282 loops=1)"
" Index Cond: ((fecha_venta >= '2025-01-01'::date) AND (fecha_venta <= '2025-06-30'::date))"
" -> Hash (cost=13.00..13.00 rows=500 width=45) (actual time=0.196..0.197 rows=500 loops=1)"
" Buckets: 1024 Batches: 1 Memory Usage: 47kB"
" -> Seq Scan on cigarrillos c (cost=0.00..13.00 rows=500 width=45) (actual time=0.011..0.073 rows=500 loops=1)"
"Planning Time: 2.153 ms"
"Execution Time: 352.820 ms"

## CONSULTA 2: COMPRAS POR ESTANCO Y DETALLES DEL CIGARRILLO

EXPLAIN ANALYZE
SELECT co.nif_estanco, co.fecha_compra, co.c_comprada, c.marca, f.nombre_fabricante, f.pais
FROM Compras co, Cigarrillos c, Fabricantes f
WHERE co.marca = c.marca AND co.filtro = c.filtro AND co.color = c.color AND co.clase = c.clase AND co.mentol = c.mentol
AND c.nombre_fabricante = f.nombre_fabricante
AND f.nombre_fabricante = 'Fabricante_1_1';

### Messages

Successfully run. Total query runtime: 75 msec.
12 rows affected.

### Data Output

"Nested Loop (cost=0.85..44232.10 rows=64800 width=477) (actual time=0.072..47.340 rows=216000 loops=1)"
" -> Nested Loop (cost=0.42..77.17 rows=10 width=475) (actual time=0.015..0.207 rows=10 loops=1)"
" -> Index Scan using cigarrillos_pkey on cigarrillos c (cost=0.27..68.88 rows=10 width=54) (actual time=0.007..0.190 rows=10 loops=1)"
" Filter: ((nombre_fabricante)::text = 'Fabricante_1_1'::text)"
" Rows Removed by Filter: 490"
" -> Materialize (cost=0.14..8.17 rows=1 width=436) (actual time=0.001..0.001 rows=1 loops=10)"
" -> Index Scan using fabricantes_pkey on fabricantes f (cost=0.14..8.16 rows=1 width=436) (actual time=0.006..0.007 rows=1 loops=1)"
" Index Cond: ((nombre_fabricante)::text = 'Fabricante_1_1'::text)"
" -> Index Scan using idx_compras_fk_cigarrillos on compras co (cost=0.43..4381.74 rows=3375 width=57) (actual time=0.009..2.148 rows=21600 loops=10)"
" Index Cond: (((marca)::text = (c.marca)::text) AND (filtro = c.filtro) AND ((color)::text = (c.color)::text) AND ((clase)::text = (c.clase)::text) AND (mentol = c.mentol))"
"Planning Time: 0.343 ms"
"Execution Time: 52.440 ms"

# Ejecucion de `consultas.sql` con optimizaciones con JOIN y Heurísticas

## CONSULTA 1: VENTAS POR ESTANCO Y DETALLES DEL CIGARRILLO DESDE EL 01/01/2025 AL 30/05/2025

-- HEURISTICA APLICADA: Se aplica el "Traslado de selección", filtrando la tabla Ventas por el rango de fechas antes de realizar el acoplamiento con JOIN, con la tabla Cigarrillos.
-- PUNTO 5: CONSULTA 1 OPTIMIZADA
EXPLAIN ANALYZE
SELECT v.nif_estanco, v.fecha_venta, v.c_vendida, c.marca, c.clase, c.precio_venta
FROM (
-- Heuristica: Filtramos Ventas antes del JOIN
SELECT \* FROM Ventas
WHERE fecha_venta BETWEEN '2025-01-01' AND '2025-06-30'
) v
INNER JOIN Cigarrillos c
ON v.marca = c.marca
AND v.filtro = c.filtro
AND v.color = c.color
AND v.clase = c.clase
AND v.mentol = c.mentol;

### Messages

Successfully run. Total query runtime: 341 msec.
12 rows affected.

### Data Output

"Hash Join (cost=7342.05..61199.26 rows=533597 width=55) (actual time=11.428..303.794 rows=534282 loops=1)"
" Hash Cond: (((ventas.marca)::text = (c.marca)::text) AND (ventas.filtro = c.filtro) AND ((ventas.color)::text = (c.color)::text) AND ((ventas.clase)::text = (c.clase)::text) AND (ventas.mentol = c.mentol))"
" -> Bitmap Heap Scan on ventas (cost=7317.80..54170.75 rows=533597 width=57) (actual time=11.211..54.303 rows=534282 loops=1)"
" Recheck Cond: ((fecha_venta >= '2025-01-01'::date) AND (fecha_venta <= '2025-06-30'::date))"
" Heap Blocks: exact=7414"
" -> Bitmap Index Scan on idx_ventas_fecha (cost=0.00..7184.40 rows=533597 width=0) (actual time=10.468..10.468 rows=534282 loops=1)"
" Index Cond: ((fecha_venta >= '2025-01-01'::date) AND (fecha_venta <= '2025-06-30'::date))"
" -> Hash (cost=13.00..13.00 rows=500 width=45) (actual time=0.202..0.203 rows=500 loops=1)"
" Buckets: 1024 Batches: 1 Memory Usage: 47kB"
" -> Seq Scan on cigarrillos c (cost=0.00..13.00 rows=500 width=45) (actual time=0.012..0.076 rows=500 loops=1)"
"Planning Time: 0.370 ms"
"Execution Time: 316.416 ms"

## CONSULTA 2: COMPRAS POR ESTANCO Y DETALLES DEL CIGARRILLO

-- HEURÍSTICA APLICADA: Aquí aplicamos selección temprana en dos ramas: filtramos las Compras (si hubiera criterio de fecha) y los Fabricantes por nombre antes de realizar los JOINs.
EXPLAIN ANALYZE
SELECT co.nif_estanco, co.fecha_compra, co.c_comprada, c.marca, f.nombre_fabricante, f.pais
FROM (
-- Heuristica: Filtrar fabricante especifico antes de los JOINs
SELECT nombre_fabricante, pais
FROM Fabricantes
WHERE nombre_fabricante = 'Fabricante_1_1'
) f
INNER JOIN Cigarrillos c
ON f.nombre_fabricante = c.nombre_fabricante
INNER JOIN Compras co
ON c.marca = co.marca
AND c.filtro = co.filtro
AND c.color = co.color
AND c.clase = co.clase
AND co.mentol = c.mentol;

### Messages

Successfully run. Total query runtime: 66 msec.
12 rows affected.

### Data Output

"Nested Loop (cost=0.85..44232.10 rows=64800 width=477) (actual time=0.100..45.983 rows=216000 loops=1)"
" -> Nested Loop (cost=0.42..77.17 rows=10 width=475) (actual time=0.036..0.235 rows=10 loops=1)"
" -> Index Scan using cigarrillos_pkey on cigarrillos c (cost=0.27..68.88 rows=10 width=54) (actual time=0.018..0.206 rows=10 loops=1)"
" Filter: ((nombre_fabricante)::text = 'Fabricante_1_1'::text)"
" Rows Removed by Filter: 490"
" -> Materialize (cost=0.14..8.17 rows=1 width=436) (actual time=0.002..0.002 rows=1 loops=10)"
" -> Index Scan using fabricantes_pkey on fabricantes (cost=0.14..8.16 rows=1 width=436) (actual time=0.014..0.014 rows=1 loops=1)"
" Index Cond: ((nombre_fabricante)::text = 'Fabricante_1_1'::text)"
" -> Index Scan using idx_compras_fk_cigarrillos on compras co (cost=0.43..4381.74 rows=3375 width=57) (actual time=0.010..2.116 rows=21600 loops=10)"
" Index Cond: (((marca)::text = (c.marca)::text) AND (filtro = c.filtro) AND ((color)::text = (c.color)::text) AND ((clase)::text = (c.clase)::text) AND (mentol = c.mentol))"
"Planning Time: 0.425 ms"
"Execution Time: 51.046 ms"
