`Proyecto 1 Gestion Bases de Datos`
# INTEGRANTEs
Bruno Ganora
Maximiliano Paredes
Mariano Munoz

# ACCIONES A REALIZAR
1. Poblar la base de datos, manejar un volumen de datos que represente: 
    * 15 estancos por localidad, considerar 10 provincias con localidades entre [10 a 15] 
    * 10 fabricantes por país, considerar al menos 5 países. 
    * 10 tipos de Cigarrillos distintos por fabricante. 
    * Entre  10  a  30  almacenes  por  estanco,  considerando  que  el  almacén  responde  al  tipo  de  cigarrillo  que  maneja el estanco. 
    * Las compras deben reflejar tres años de información, con un promedio de dos compras mensuales por  almacén del estanco.  
    * Las ventas deben reflejar tres años de información, procurando la coherencia entre las compras que se  realizaron por almacén del estanco. 
2. Crear consultas (sin join) que reflejen la información de compras y ventas por almacén y estancos, indicando  los datos referentes a las características de los cigarrillos y los fabricantes. 
3. Establecer métodos de optimización, incluyendo los índices que correspondan y otras alternativas vistas en el  laboratorio 2. 
4. Repetir la ejecución de las consultas anteriores y evaluar los tiempos de respuesta. 
5. Optimizar las consultas anteriores utilizando JOIN y métodos heurísticos. Para dos de estos casos construir su  árbol de consulta y mostrar el paso a paso de la optimización generada. Una vez realizada las consultas evaluar  los tiempos de respuesta y compararlos con las situaciones anteriores. 
6. Proponer una nueva versión de la base de datos considerando la desnormalización de esta. Asegurarse que los  datos  contenidos  no  se  modifiquen,  de  esta  manera  mantener  la  integridad  da  la  información  pudiendo ejecutar “las mismas” consultas anteriores y así poder comparar nuevamente los tiempos de respuesta. 
    
* Obs1: Dejar registro del rendimiento del computador al momento de realizar las consultas, idealmente disponer del  equipo con el menor uso posible de otros programas de usuario. 
    
* Obs2:  Para  que  la  evaluación  y  comparación  sea  lo  más  objetiva  posible,  se  recomienda  utilizar  el  mismo  computador en cada fase que involucre obtención del rendimiento. 
    
* Obs3: Considerar que las compras son de forma mayorista y las ventas son al detalle. 
    
* Obs4: Podrá realizar modificaciones al modelo relacional, siempre y cuando estén debidamente justificadas, por lo  que en tal caso deberá ser consultado al profesor o al ayudante.

# ENUNCIADO PROBLEMA
Se desea mantener información sobre las ventas de tabaco que son realizadas por diferentes
expendedurías autorizadas. Es importa para el distribuidor conocer la información sobre las
expendedurías, los pedidos que realizan y las ventas de estas. Asimismo, es importante conocer datos
sobre las ventas detalladas para cada una de las clases de tabaco.
Los procesos de consulta más usuales que se realizarán harán referencia a las ventas y distribución
de tabacos y el consumo que se realiza, bajo cualquier tipo de agrupación, de los tabacos vendidos
por las expendedurías.

## SUPUESTOS DEL PROBLEMA

**Supuesto 1:** Los estancos son abastecidos con un número de cigarrillos diferentes que sólo depende de las órdenes de pedido y de la existencia de estos tipos. Por lo tanto, los estancos podrán vender cualquier tipo de cigarrillo de los que tengan existencias.

**Supuesto 2:** Los estancos tienen asignado un número de expendeduría que se puede repetir de una localidad a otra. Además, cada estanco tiene asignado un número de identificación fiscal que corresponde a la empresa como tal (o responsable de la misma), así como un nombre, el cual puede ser el del responsable o no, que también puede repetirse incluso en la misma localidad.

**Supuesto 3:** Los fabricantes de cigarrillos tienen su sede principal en un país, aunque en un mismo país se pueden encontrar sedes de varios fabricantes.

**Supuesto 4:** Cada fabricante puede fabricar un número variable de marcas de cigarrillos, si bien una marca de cigarrillos, independientemente de su tipo, sólo puede ser fabricada por un único fabricante.

**Supuesto 5:** Para cada marca de cigarrillos se fabrican distintos tipos de ellos, según la existencia o no de filtro, el color de la hoja de tabaco y la cantidad de nicótica y alquitrán existente en los mismos.

**Supuesto 6:** De una misma marca pueden existir cigarrillos con filtro y sin filtro.

**Supuesto 7:** De una misma marca pueden existir cigarrillos de hoja negra o rubia.

**Supuesto 8:** De una misma marca pueden existir cigarrillos con contenido de contaminantes (nicotina y alquitrán) catalogados, según el fabricante, en:** Light, SuperLight y UltraLight. Cuando un tipo no está catalogado en alguno de estos grupos (no ha tenido un tratamiento especial para eliminar parte de los contaminantes) se considera que es Normal. Los cigarrillos sin filtro son siempre catalogados en el tipo Normal.

**Supuesto 9:** De una misma marca de cigarrillos pueden existir cigarrillos mentolados o no mentolados. Los cigarrillos mentolados tienen siempre un contenido de contaminantes Normal.

**Supuesto 10:** No interesa conocer los clientes a los que se les venden los cigarrillos en los estancos.

**Supuesto 11:** Tanto para las compras como para las ventas sólo interesa conocer el total de ellas, de cada tipo de cigarrillos, realizadas por día.

**Supuesto 12:** Los estancos realizan las compras de cigarrillos por unidades de estos denominadas cartones. Un cartón está formado por un conjunto de cajetillas de cigarrillos, generalmente 10. Y una cajetilla de cigarrillos está formada por un conjunto de cigarrillos, generalmente 20.

## Modelo Relacional
Fabricantes (**nombre_fabricante**, país)
Estancos (**nif_estanco**, num_expendeduría, cp_estanco, nombre_estanco, dirección_estanco, localidad_estanco, provincia_estanco)
Cigarrillos (**marca, filtro, color, clase, mentol**, nicotina, alquitrán, nombre_fabricante, precio_venta, precio_costo,cartón, embalaje)
Almacenes (**nif_estanco, marca, filtro, color, clase, mentol**, unidades)
Compras (**nif_estanco, marca, filtro, color, clase, mentol**, fecha_compra, c_comprada, precio_compra)
Ventas (**nif_estanco, marca, filtro, color, clase, mentol**, fecha_venta, c_vendida, precio_venta)

## Diccionario del modelo:
**Estancos:** Puesto de venta del producto.
**nif_estanco:** número de identificación fiscal del puesto de venta.
**cp_estanco:** código postal del puesto de venta.
**cartón:** representa el número de cajetillas que entran en un cartón de tipo de cigarrillos determinado.
**embalaje:** representa el número de cigarrillos que se empaquetan en cada cajetilla.
**Almacenes:** representa el stock disponible de cada producto asociado a un punto de venta.

## Notas
* Lo que se muestra en subrayado corresponde a la clave primaria de la tabla, tener en cuenta que en varios casos la clave primaria está compuesta por más de un atributo.
* Lo que se muestra en negrita corresponde a claves foráneas de la tabla, tener en cuenta que esta clave también puede ser compuesta de más de un atributo.
* Lo que se muestra negrita y subrayado al mismo tiempo corresponde a clave primaria y foránea en forma simultánea.


