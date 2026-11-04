USE Ventas_Tech_DB;
GO
-- ===== DATOS DE EJEMPLO ADICIONALES =====
-- Clientes y productos sin ventas, agregados solo para poder probar las consultas 2 y 3.
-- Se ejecuta una sola vez: si los datos ya existen, no se vuelven a insertar.
IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = 6)
    INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
      (6, 'Julián Díaz', 'julian@mail.com', 'La Plata', '2024-03-12'),
      (7, 'Sofía Paz',   'sofia@mail.com',  'Salta',    '2024-03-14');

IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto = 7)
    INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
      (7, 'Webcam Full HD',    2, 65.00, 25, 1),
      (8, 'Parlante Portátil', 3, 80.00, 30, 1);

-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: tener cada venta con nombres en lugar de IDs, lista para Power BI.
SELECT
    v.fecha_venta,
    v.id_cliente,
    c.nombre AS cliente,
    c.ciudad,
    p.nombre_producto AS producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;
-- Hallazgo: La vista tiene 10 ventas, cada una con su cliente, producto, categoría y ciudad, y en total suman 6444.
-- Esa tabla es la base lista para Power BI.

-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: detectar clientes registrados que nunca compraron, para que CRM los contacte.
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
-- Hallazgo: 2 de 7 clientes registrados nunca compraron; los 2 se registraron en marzo del 2024.
-- CRM puede contactarlos con una oferta de bienvenida para concretar su primera compra.

-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: identificar artículos del catálogo sin movimiento, para el área de producto.
SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos AS p
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
-- Hallazgo: 2 de 8 productos del catálogo no tienen ventas registradas.
-- Pueden revisar precio, visibilidad o stock, para identificar por qué esos dos artículos no se mueven.

-- Consulta 4: Consolidado por período (UNION ALL)
-- Propósito: ver cuánto se facturó en cada mitad de marzo.
SELECT
    periodo,
    SUM(total) AS total_periodo
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Primera mitad de marzo' AS periodo
    FROM ventas
    WHERE fecha_venta BETWEEN '2024-03-01' AND '2024-03-10'
    UNION ALL
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Segunda mitad de marzo' AS periodo
    FROM ventas
    WHERE fecha_venta BETWEEN '2024-03-11' AND '2024-03-31'
) AS consolidado
GROUP BY periodo
ORDER BY periodo;
-- Hallazgo: la facturación fue de 3620.00 en la primera mitad y de 2824.00 en la segunda. 
-- Esto indica que se generó un 21.99% menos de ingresos que en la primera.
-- Las dos mitades tienen 5 ventas cada una, así que la caída no viene de vender
-- menos veces, sino de ventas de menor valor.