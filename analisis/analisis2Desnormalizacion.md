# Puntos de friccion a desnormalizar

# Consultas criticas
1. Consultas de Compras y Ventas por Almacén 
El enunciado exige mostrar la información de compras (mayoristas) y ventas (al detalle) asociada a cada almacén y estanco.
Lo que debe incluir: Debes mostrar los datos referentes a las características de los cigarrillos (marca, filtro, color, clase, mentol, nicotina, alquitrán) y los datos del fabricante (nombre y país).
Problema en el modelo original: Esta consulta es lenta porque requiere unir Ventas/Compras con Almacenes, luego con Cigarrillos y finalmente con Fabricantes.
Meta: Crear una tabla desnormalizada donde, al consultar por una venta o compra, el nombre del fabricante y el país ya estén en la misma fila.

2. Consultas bajo "Cualquier tipo de Agrupación"
El enunciado menciona que los procesos de consulta más usuales se realizarán bajo cualquier tipo de agrupación sobre los tabacos vendidos.
* Ejemplos de agrupaciones críticas:
    * Ventas totales por Provincia o Localidad.
    * Ventas por Clase (Normal, Light, SuperLight, UltraLight).
    * Ventas por Fabricante o País de origen.
Meta: Asegurarte de que tu tabla desnormalizada incluya las columnas provincia_estanco, localidad_estanco y pais del fabricante para que estas agrupaciones (GROUP BY) no necesiten JOIN.

3. Consultas de Consumo Diario
El Supuesto 11 indica que tanto para compras como para ventas solo interesa conocer el total de ellas, de cada tipo de cigarrillo, realizadas por día.
Meta: Podrías crear una tabla desnormalizada de Ventas Diarias que ya tenga los datos sumados. Esto facilitará enormemente el análisis de los 3 años de información que pide el proyecto.

#