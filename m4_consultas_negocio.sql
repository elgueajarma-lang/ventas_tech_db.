USE Ventas_Tech_DB;
GO

-- Consulta 1: Resumen ejecutivo mensual
SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);

-- Consulta 2: Ranking de productos (Top 5 por facturación)
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- Consulta 3: Clientes recurrentes (más de un pedido)
SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- Consulta 4: Productos por encima / por debajo del promedio
WITH facturacion_por_producto AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM facturacion_por_producto)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS clasificacion
FROM facturacion_por_producto
ORDER BY total_facturado DESC;

-- ===== HALLAZGOS =====
-- 1. El producto 2 vendió 13 unidades (los demás, 3 o 4) pero facturó solo 364,
--    el 5,6% del total: vende mucho, pero barato, y aporta poco a los ingresos.

-- 2. No hay compradores de una sola vez, los cinco clientes compraron exactamente dos veces. 
-- El cliente 1 gastó 2640, el 41% del total, por lo que el gasto está concentrado en pocos clientes

-- 3. Solo dos de los seis productos superan el promedio de facturación, que es 1074. 
-- Los otros cuatro quedan muy por debajo, entre 360 y 390. Los productos 1 y 3 suman 4950, el 76,8% de la facturación.