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


