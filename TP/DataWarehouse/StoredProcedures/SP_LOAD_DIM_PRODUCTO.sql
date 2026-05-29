use TDC_DW;
GO

CREATE OR ALTER PROCEDURE SP_LOAD_DIM_PRODUCTO
AS
BEGIN
    DELETE FROM DIM_PRODUCTO;
    DBCC CHECKIDENT ('DIM_PRODUCTO', RESEED, 0);

    INSERT INTO DIM_PRODUCTO (id_rubro, id_presentacion, cod_sist_origen, id_producto_origen, nombre_producto, es_diet)
    SELECT
        r.id_rubro,
        p2.id_presentacion,
        'FLAT_FILE'         AS cod_sist_origen,
        p.PRODUCT_ID        AS id_producto_origen,
        p.DETAIL            AS nombre_producto,
        CASE WHEN p.DETAIL LIKE '%Diet%' THEN 1 ELSE 0 END AS es_diet
    FROM STG_TDC.dbo.STG_PRODUCTS p
    JOIN DIM_RUBRO r ON r.nombre_rubro = 
        CASE 
            WHEN p.DETAIL LIKE '%Beer%'         THEN 'Beer'
            WHEN p.DETAIL LIKE '%Cola%'         THEN 'Cola'
            WHEN p.DETAIL LIKE '%Soda%'         THEN 'Soda'
            WHEN p.DETAIL LIKE '%juice%'        THEN 'Juice'
            WHEN p.DETAIL LIKE '%energy drink%' THEN 'Energy drink'
        END
    JOIN DIM_PRESENTACION p2 ON p2.volumen = 
        CASE p.PACKAGE
            WHEN '1 Liter'     THEN 1000
            WHEN '2 Liter'     THEN 2000
            WHEN '330 cm3 can' THEN 330
            WHEN '500 cm3 can' THEN 500
            WHEN '670 cm3'     THEN 670
        END
        AND p2.tipo_envase =
        CASE p.PACKAGE
            WHEN '330 cm3 can' THEN 'lata'
            WHEN '500 cm3 can' THEN 'lata'
            ELSE 'botella'
        END;
END;
GO
