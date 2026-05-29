USE TDC_DW;
GO

CREATE OR ALTER PROCEDURE SP_LOAD_DIM_CLIENTE
AS
BEGIN
    DELETE FROM DIM_CLIENTE;
    DBCC CHECKIDENT ('DIM_CLIENTE', RESEED, 0);

    INSERT INTO DIM_CLIENTE (cod_sist_origen, id_cliente_origen, nombre_cliente, fecha_nacimiento, tipo_cliente, zipcode, ciudad, estado, region)
    SELECT
        'XML'                       AS cod_sist_origen,
        c.CUSTOMER_ID               AS id_cliente_origen,
        c.FULL_NAME                 AS nombre_cliente,
        CAST(c.BIRTH_DATE AS DATE)  AS fecha_nacimiento,
        c.TIPO_CLIENTE              AS tipo_cliente,
        c.ZIPCODE                   AS zipcode,
        c.CITY                      AS ciudad,
        c.STATE                     AS estado,
        r.REGION                    AS region
    FROM STG_TDC.dbo.STG_CUSTOMERS c
    JOIN STG_TDC.dbo.STG_REGIONS r ON c.ZIPCODE = r.ZIPCODE;
END;
GO
