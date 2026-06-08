USE TDC_DW;
GO

CREATE OR ALTER PROCEDURE SP_LOAD_FCT_VENTAS
AS
BEGIN

    -- ============================================================
    -- PASO 1: LIMPIEZA STAGING
    -- ============================================================
    UPDATE STG_TDC.dbo.STG_BILLING SET REGION = 'Central' WHERE REGION = 'North';
    UPDATE STG_TDC.dbo.STG_BILLING_DETAIL SET PRODUCT_ID = '0' + PRODUCT_ID WHERE LEN(PRODUCT_ID) = 1;
    UPDATE STG_TDC.dbo.STG_PRICES SET PRICE = CAST(ROUND(CAST(PRICE AS FLOAT), 2) AS VARCHAR(50));
    UPDATE STG_TDC.dbo.STG_HISTORY_SALES SET PRODUCT_ID = '0' + PRODUCT_ID WHERE LEN(PRODUCT_ID) = 1;

    DELETE FROM TDC_DW.dbo.FCT_VENTAS;
    DBCC CHECKIDENT ('TDC_DW.dbo.FCT_VENTAS', RESEED, 0);

    -- ============================================================
    -- PASO 2: PRECIOS VIGENTES (HISTORY SALES)
    -- ============================================================
    IF OBJECT_ID('tempdb..#precios') IS NOT NULL DROP TABLE #precios;

    SELECT 
        h.ID,
        h.PRODUCT_ID,
        h.DATE,
        COALESCE(
            (SELECT TOP 1 CAST(p.PRICE AS MONEY)
             FROM STG_TDC.dbo.STG_PRICES p
             WHERE p.PRODUCT_ID = h.PRODUCT_ID
             AND CAST(p.DATE AS DATE) <= CAST(h.DATE AS DATE)
             ORDER BY CAST(p.DATE AS DATE) DESC),
            (SELECT TOP 1 CAST(p.PRICE AS MONEY)
             FROM STG_TDC.dbo.STG_PRICES p
             WHERE p.PRODUCT_ID = h.PRODUCT_ID
             ORDER BY CAST(p.DATE AS DATE) ASC)
        ) AS precio_unitario
    INTO #precios
    FROM STG_TDC.dbo.STG_HISTORY_SALES h;

    -- ============================================================
    -- PASO 3: MONTOS TOTALES POR FACTURA (HISTORY SALES)
    -- ============================================================
    IF OBJECT_ID('tempdb..#montos_factura') IS NOT NULL DROP TABLE #montos_factura;

    SELECT 
        h.BILLING_ID,
        SUM(CAST(h.QUANTITY AS INT) * pr.precio_unitario) AS monto_total_factura
    INTO #montos_factura
    FROM STG_TDC.dbo.STG_HISTORY_SALES h
    JOIN #precios pr ON pr.ID = h.ID
    GROUP BY h.BILLING_ID;

    -- ============================================================
    -- PASO 4: DESCUENTOS (HISTORY SALES)
    -- ============================================================
    IF OBJECT_ID('tempdb..#descuentos') IS NOT NULL DROP TABLE #descuentos;

    SELECT 
        mf.BILLING_ID,
        MAX(CAST(d.PERCENTAGE AS DECIMAL(5,2))) AS porcentaje_descuento
    INTO #descuentos
    FROM #montos_factura mf
    JOIN STG_TDC.dbo.STG_HISTORY_SALES h ON h.BILLING_ID = mf.BILLING_ID
    JOIN STG_TDC.dbo.STG_DISCOUNTS d 
        ON mf.monto_total_factura >= CAST(d.TOTAL_BILLING AS MONEY)
        AND CAST(h.DATE AS DATE) >= CAST(d.FROM_DATE AS DATE)
        AND (d.UNTIL_DATE IS NULL OR CAST(h.DATE AS DATE) <= CAST(d.UNTIL_DATE AS DATE))
    GROUP BY mf.BILLING_ID;

    -- ============================================================
    -- PASO 5: INSERT FCT_VENTAS - VENTAS HISTORICAS
    -- ============================================================
    INSERT INTO TDC_DW.dbo.FCT_VENTAS (fecha_nro, id_cliente, id_producto, id_empleado, region_venta, cod_sist_origen, factura, cantidad, volumen_total, precio_unitario_usd, precio_bruto_usd, descuento, monto_total_usd, edad_cliente, edad_empleado, grupo_etario, antiguedad_empleado)
    SELECT
        ISNULL(CAST(FORMAT(CAST(h.DATE AS DATE), 'yyyyMMdd') AS INT), -1),
        ISNULL(dc.id_cliente, -1),
        dp.id_producto,
        ISNULL(de.id_empleado, -1),
        h.REGION,
        'SQL_SERVER',
        h.BILLING_ID,
        CAST(h.QUANTITY AS INT),
        CAST(h.QUANTITY AS INT) * dp2.volumen,
        pr.precio_unitario,
        CAST(h.QUANTITY AS INT) * pr.precio_unitario,
        CAST(h.QUANTITY AS INT) * pr.precio_unitario * ISNULL(d.porcentaje_descuento, 0) / 100,
        CAST(h.QUANTITY AS INT) * pr.precio_unitario - CAST(h.QUANTITY AS INT) * pr.precio_unitario * ISNULL(d.porcentaje_descuento, 0) / 100,
        DATEDIFF(YEAR, dc.fecha_nacimiento, CAST(h.DATE AS DATE)),
        DATEDIFF(YEAR, de.fecha_nacimiento, CAST(h.DATE AS DATE)),
        CASE
            WHEN DATEDIFF(YEAR, dc.fecha_nacimiento, CAST(h.DATE AS DATE)) BETWEEN 0  AND 12 THEN 1
            WHEN DATEDIFF(YEAR, dc.fecha_nacimiento, CAST(h.DATE AS DATE)) BETWEEN 13 AND 19 THEN 2
            WHEN DATEDIFF(YEAR, dc.fecha_nacimiento, CAST(h.DATE AS DATE)) BETWEEN 20 AND 39 THEN 3
            WHEN DATEDIFF(YEAR, dc.fecha_nacimiento, CAST(h.DATE AS DATE)) BETWEEN 40 AND 50 THEN 4
            WHEN DATEDIFF(YEAR, dc.fecha_nacimiento, CAST(h.DATE AS DATE)) BETWEEN 51 AND 65 THEN 5
            ELSE 6
        END,
        DATEDIFF(YEAR, de.fecha_ingreso, CAST(h.DATE AS DATE))
    FROM STG_TDC.dbo.STG_HISTORY_SALES h
    JOIN #precios pr ON pr.ID = h.ID
    LEFT JOIN #descuentos d ON d.BILLING_ID = h.BILLING_ID
    LEFT JOIN TDC_DW.dbo.DIM_CLIENTE dc ON dc.id_cliente_origen = h.CUSTOMER_ID AND dc.id_cliente <> -1
    LEFT JOIN TDC_DW.dbo.DIM_EMPLEADO de ON de.id_empleado_origen = h.EMPLOYEE_ID AND de.id_empleado <> -1
    JOIN TDC_DW.dbo.DIM_PRODUCTO dp ON dp.id_producto_origen = h.PRODUCT_ID
    JOIN TDC_DW.dbo.DIM_PRESENTACION dp2 ON dp2.id_presentacion = dp.id_presentacion;


-- ============================================================
   -- PASO 6: PRECIOS VIGENTES (BILLING)
-- ============================================================

    IF OBJECT_ID('tempdb..#precios_billing') IS NOT NULL DROP TABLE #precios_billing;

    SELECT 
        bd.BILLING_ID,
        bd.PRODUCT_ID,
        b.DATE,
        CAST(bd.QUANTITY AS INT) AS cantidad,
        COALESCE(
            (SELECT TOP 1 CAST(p.PRICE AS MONEY)
             FROM STG_TDC.dbo.STG_PRICES p
             WHERE p.PRODUCT_ID = bd.PRODUCT_ID
             AND CAST(p.DATE AS DATE) <= CAST(b.DATE AS DATE)
             ORDER BY CAST(p.DATE AS DATE) DESC),
            (SELECT TOP 1 CAST(p.PRICE AS MONEY)
             FROM STG_TDC.dbo.STG_PRICES p
             WHERE p.PRODUCT_ID = bd.PRODUCT_ID
             ORDER BY CAST(p.DATE AS DATE) ASC)
        ) AS precio_unitario
    INTO #precios_billing
    FROM STG_TDC.dbo.STG_BILLING_DETAIL bd
    LEFT JOIN STG_TDC.dbo.STG_BILLING b ON bd.BILLING_ID = b.BILLING_ID;


-- ============================================================
    -- PASO 7: MONTOS TOTALES POR FACTURA (BILLING)
    -- ============================================================
    IF OBJECT_ID('tempdb..#montos_factura_billing') IS NOT NULL DROP TABLE #montos_factura_billing;

    SELECT 
        pb.BILLING_ID,
        SUM(pb.cantidad * pb.precio_unitario) AS monto_total_factura
    INTO #montos_factura_billing
    FROM #precios_billing pb
    GROUP BY pb.BILLING_ID;


-- ============================================================
    -- PASO 8: DESCUENTOS (BILLING)
-- ============================================================

    IF OBJECT_ID('tempdb..#descuentos_billing') IS NOT NULL DROP TABLE #descuentos_billing;

    SELECT 
        mfb.BILLING_ID,
        MAX(CAST(d.PERCENTAGE AS DECIMAL(5,2))) AS porcentaje_descuento
    INTO #descuentos_billing
    FROM #montos_factura_billing mfb
    LEFT JOIN STG_TDC.dbo.STG_BILLING b ON b.BILLING_ID = mfb.BILLING_ID
    JOIN STG_TDC.dbo.STG_DISCOUNTS d 
        ON mfb.monto_total_factura >= CAST(d.TOTAL_BILLING AS MONEY)
        AND CAST(b.DATE AS DATE) >= CAST(d.FROM_DATE AS DATE)
        AND (d.UNTIL_DATE IS NULL OR CAST(b.DATE AS DATE) <= CAST(d.UNTIL_DATE AS DATE))
    GROUP BY mfb.BILLING_ID;


-- ============================================================
    -- PASO 9: INSERT FCT_VENTAS - VENTAS ACTUALES (MYSQL)
    -- ============================================================
    INSERT INTO TDC_DW.dbo.FCT_VENTAS (fecha_nro, id_cliente, id_producto, id_empleado, region_venta, cod_sist_origen, factura, cantidad, volumen_total, precio_unitario_usd, precio_bruto_usd, descuento, monto_total_usd, edad_cliente, edad_empleado, grupo_etario, antiguedad_empleado)
    SELECT
        ISNULL(CAST(FORMAT(CAST(b.DATE AS DATE), 'yyyyMMdd') AS INT), -1),
        ISNULL(dc.id_cliente, -1),
        dp.id_producto,
        ISNULL(de.id_empleado, -1),
        b.REGION,
        'MYSQL',
        bd.BILLING_ID,
        pb.cantidad,
        pb.cantidad * dp2.volumen,
        pb.precio_unitario,
        pb.cantidad * pb.precio_unitario,
        pb.cantidad * pb.precio_unitario * ISNULL(db_.porcentaje_descuento, 0) / 100,
        pb.cantidad * pb.precio_unitario - pb.cantidad * pb.precio_unitario * ISNULL(db_.porcentaje_descuento, 0) / 100,
        DATEDIFF(YEAR, dc.fecha_nacimiento, CAST(b.DATE AS DATE)),
        DATEDIFF(YEAR, de.fecha_nacimiento, CAST(b.DATE AS DATE)),
        CASE
            WHEN DATEDIFF(YEAR, dc.fecha_nacimiento, CAST(b.DATE AS DATE)) BETWEEN 0  AND 12 THEN 1
            WHEN DATEDIFF(YEAR, dc.fecha_nacimiento, CAST(b.DATE AS DATE)) BETWEEN 13 AND 19 THEN 2
            WHEN DATEDIFF(YEAR, dc.fecha_nacimiento, CAST(b.DATE AS DATE)) BETWEEN 20 AND 39 THEN 3
            WHEN DATEDIFF(YEAR, dc.fecha_nacimiento, CAST(b.DATE AS DATE)) BETWEEN 40 AND 50 THEN 4
            WHEN DATEDIFF(YEAR, dc.fecha_nacimiento, CAST(b.DATE AS DATE)) BETWEEN 51 AND 65 THEN 5
            ELSE 6
        END,
        DATEDIFF(YEAR, de.fecha_ingreso, CAST(b.DATE AS DATE))
    FROM STG_TDC.dbo.STG_BILLING_DETAIL bd
    JOIN #precios_billing pb ON pb.BILLING_ID = bd.BILLING_ID AND pb.PRODUCT_ID = bd.PRODUCT_ID
    LEFT JOIN STG_TDC.dbo.STG_BILLING b ON bd.BILLING_ID = b.BILLING_ID
    LEFT JOIN #descuentos_billing db_ ON db_.BILLING_ID = bd.BILLING_ID
    LEFT JOIN TDC_DW.dbo.DIM_CLIENTE dc ON dc.id_cliente_origen = b.CUSTOMER_ID AND dc.id_cliente <> -1
    LEFT JOIN TDC_DW.dbo.DIM_EMPLEADO de ON de.id_empleado_origen = b.EMPLOYEE_ID AND de.id_empleado <> -1
    JOIN TDC_DW.dbo.DIM_PRODUCTO dp ON dp.id_producto_origen = bd.PRODUCT_ID
    JOIN TDC_DW.dbo.DIM_PRESENTACION dp2 ON dp2.id_presentacion = dp.id_presentacion;

END;
GO
