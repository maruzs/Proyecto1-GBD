# Pre-Desnormalizacion
Actualmente para saber que fabricante vendio algo hay que saltar de Ventas a Cigarrillos y luego a fabricantes

Fabricante vendio algo? => ventas -> cigarrillos -> fabricantes 

## Analisis modelo relacional

### Relaciones clave identificadas
Un fabricante puede producir multiples tipos de cigarrillos pero cada tipo pertenece a un solo fabricante

Fabricante '1' --- '0..*' Cigarrillos
Cigarrillos tiene PK compuesta de 5 atributos (`marca`,`filtro`,`color`,`clase`,`mentol`) y se propaga como FK a `Almacenes`, `Compras` y `Ventas`
Estancos centraliza las operaciones de inventario `(Almacenes)`, abastecimiento `(Compras)` y transacciones al detalle `(Ventas)`

### Consultas lentas
El modelo actual debe recorrer multiples tablas y realizar comparaciones entre miles de registros, y con el volumen solicitado, las operaciones se vuelven extremadamente costosas en tiempo de procesamiento.
#### Ejemplo:
* **Reporte de ventas totales por pais del fabricante:** Esta consulta es lenta ya que pais no esta en la tabla de ventas
* Camino de navegacion: Para cada fila en `Ventas` hay que buscar `Cigarrillos` (coincidiendo sus 5 atributos de la PK), Una vez encontrado cigarrillo hay que buscar nombre_fabricante y buscarlo en `Fabricantes` para finalmente tener el pais
```sql
SELECT 
    f.pais, 
    SUM(v.c_vendida * v.precio_venta) AS total_ventas
FROM Ventas v
JOIN Cigarrillos c ON 
    v.marca = c.marca AND 
    v.filtro = c.filtro AND 
    v.color = c.color AND 
    v.clase = c.clase AND 
    v.mentol = c.mentol
JOIN Fabricantes f ON c.nombre_fabricante = f.nombre_fabricante
GROUP BY f.pais;
```
# Desnormalizacion
Consiste en optimizar bases de datos introduciendo redundancia (controlada) para aumentar la velocidad de las consultas
## Ventajas
* Rendimiento -> Reduce tiempo de respuestas para sistemas con consultas de lectura son frecuentes y complejas
* Reducir uso de JOINs -> Datos necesarios en una sola tabla, evitando la necesidad de cruce entre masivos archivos
* Balance de costos -> Equilibrio entre costo de consultas (disminuye) y costo de actualizaciones (aumenta por la redundancia)

## Tecnicas de desnormalizacion
1. Combinar relaciones 1:1 -> Si dos tablas se consultan juntas casi siempre, se unen. 
    * Ejemplo: Unir  `Cliente` con `Entrevista`.
    * Post-Condicion: Aparicion de valores nulos si un cliente no tiene entrevista.

2. Duplicar atributos no clave (1:N) -> Copiar campo de tabla padre en tabla hijo para evitar JOIN.
    * Ejemplo: Incluir el `Nombre del Dueño` directamente en la tabla `Propiedad`.
    * Riesgo: Si el dueño cambia de nombre, debes actualizarlo en todos los registros de sus propiedades para mantener la consistencia.

3. Tablas de busqueda (Lookup Tables) -> Reemplazar atributos de texto largo por codigos numericos que apunten a una tabla de referencia
    * Beneficio: Ahorra mucho espacio en disco al no repetir cadenas de texto largas en millones de filas.

4. Grupos repetitivos: -> Un atributo multivaluado pero limite maximo pequeno y conocido se puede convertir en columnas fijas.
    * Ejemplo: En lugar de una tabla separada de teléfonos, crear los campos Telefono1, Telefono2 y Telefono3 en la tabla principal.

### Ventajas -> Desventajas
Reducir numero de tablas y JOINs -> Actualizaciones mas lentas (Modificar datos en varios lugares).
Acelerar generacion de reportes y dashboards -> Riesgo de inconsistencia y desfase entre tablas.
Pre-calculo de datos derivados -> Mas uso de espacio en disco debido a la redundancia.

## Cuando aplicarla
1. Rendimiento actual no es satisfactorio,
2. Baja tasa de actualizacion de los datos.
3. Muy alta tasa de consultas.

Para mantener la integridad en esquemas desnormalizados se integran triggers que repliquen los cambios de un dato duplicado en todas sus ubicaciones.

# Objetivo
Desnormalizar sin modificar los datos contenidos de manera que se pueda mantener la integridad de los datos

## Consultas que dan paso a la desnormalizacion

1. Reporte de Ventas por Geografía y Fabricante: Requiere unir Ventas, Estancos, Cigarrillos y Fabricantes para obtener el total de ventas por país o provincia.
2. Análisis de Rentabilidad por Producto: Requiere cruzar Ventas con Cigarrillos para calcular la diferencia entre precio_venta y precio_costo en cada transacción.

## Justificacion de la estructura y Proceso de carga

### Tabla de Hechos de Ventas (`Hechos_Ventas`):
Esta estructura "aplana" el modelo, almacenando en una sola tabla los datos descriptivos (estanco, ubicación, fabricante) junto con los datos transaccionales (precios, cantidades).
* Ventajas:
    * Elimina la necesidad de realizar JOIN en tiempo de consulta.
    * Optimiza la velocidad de lectura para reportes gerenciales.
    * Reduce la carga del procesador al evitar comparaciones de claves compuestas en cada reporte.
* Script de creacion y carga    
```SQL
-- 1. Creacion de la tabla desnormalizada
CREATE TABLE Hechos_Ventas (
    nif_estanco VARCHAR(20),
    nombre_estanco VARCHAR(100),
    localidad_estanco VARCHAR(100),
    provincia_estanco VARCHAR(100),
    marca VARCHAR(100),
    clase VARCHAR(50),
    nombre_fabricante VARCHAR(100),
    pais_fabricante VARCHAR(100),
    fecha_venta DATE,
    unidades_vendidas INT,
    precio_venta_unitario DECIMAL(10,2),
    precio_costo_unitario DECIMAL(10,2),
    utilidad_transaccion DECIMAL(10,2)
);

-- 2. Proceso de carga inicial (ETL interno)
INSERT INTO Hechos_Ventas
SELECT 
    e.nif_estanco, e.nombre_estanco, e.localidad_estanco, e.provincia_estanco,
    c.marca, c.clase,
    f.nombre_fabricante, f.pais,
    v.fecha_venta, v.c_vendida, v.precio_venta,
    c.precio_costo,
    (v.c_vendida * (v.precio_venta - c.precio_costo))
FROM Ventas v
JOIN Estancos e ON v.nif_estanco = e.nif_estanco
JOIN Cigarrillos c ON v.marca = c.marca AND v.filtro = c.filtro 
    AND v.color = c.color AND v.clase = c.clase AND v.mentol = c.mentol
JOIN Fabricantes f ON c.nombre_fabricante = f.nombre_fabricante;

-- 3. Verificacion de los datos cargados
SELECT * FROM Hechos_Ventas LIMIT 5;
```
#### Estrategias de consistencia
Debido a que la desnormalización duplica información, es vital mantener la consistencia. Se proponen las siguientes estrategias:
* **Triggers de Actualización:** Configurar disparadores que, ante un `INSERT` en la tabla `Ventas` original, inserten automáticamente la fila correspondiente en `Hechos_Ventas`.

* **Procedimientos Almacenados (Batch):** Realizar una actualización masiva nocturna (proceso ETL) para sincronizar ambas versiones de la base de datos si el sistema no requiere tiempo real.

* **Vistas Materializadas:** Usar `MATERIALIZED VIEW` en PostgreSQL para que el motor gestione la actualización de los datos desnormalizados de forma eficiente.

#### Comparacion de Consultas y analisis de tiempos
Consulta Original (Normalizada)
```SQL
SELECT f.pais, SUM(v.c_vendida * v.precio_venta) 
FROM Ventas v
JOIN Cigarrillos c ON v.marca = c.marca AND v.filtro = c.filtro -- mas condiciones...
JOIN Fabricantes f ON c.nombre_fabricante = f.nombre_fabricante
GROUP BY f.pais;
```
Nueva consulta (Desnormalizada)
```SQL
SELECT pais_fabricante, SUM(unidades_vendidas * precio_venta_unitario)
FROM Hechos_Ventas
GROUP BY pais_fabricante;
```

### Tabla Maestro de Inventario (Almacenes + Cigarrillos + Estancos):
* Propósito: Responder rápidamente "¿cuántas unidades de la marca X hay en la localidad Y?" sin unir tres tablas.
* Estructura: Una tabla Inventario_Global que incluya nif_estanco, nombre_estanco, localidad, marca, clase y unidades.