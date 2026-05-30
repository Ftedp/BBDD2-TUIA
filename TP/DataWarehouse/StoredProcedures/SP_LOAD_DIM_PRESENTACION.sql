use TDC_DW;
go

CREATE OR ALTER PROCEDURE SP_LOAD_DIM_PRESENTACION
AS
BEGIN
    DELETE FROM DIM_PRESENTACION;
    DBCC CHECKIDENT ('DIM_PRESENTACION', RESEED, 0);
    INSERT INTO DIM_PRESENTACION (volumen, medida, tipo_envase, presentacion_original)
    SELECT DISTINCT 
        CASE PACKAGE
            WHEN '1 Liter'      THEN 1000
            WHEN '2 Liter'      THEN 2000
            WHEN '330 cm3 can'  THEN 330
            WHEN '500 cm3 can'  THEN 500
            WHEN '670 cm3'      THEN 670
        END AS volumen,
        'cm3' AS medida,
        CASE PACKAGE
            WHEN '330 cm3 can'  THEN 'lata'
            WHEN '500 cm3 can'  THEN 'lata'
            ELSE                     'botella'
        END AS tipo_envase,
        PACKAGE AS presentacion_original
    FROM STG_TDC.dbo.STG_PRODUCTS;
END;
GO

