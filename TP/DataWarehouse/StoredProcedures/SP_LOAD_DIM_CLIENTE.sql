USE TDC_DW;
GO

CREATE OR ALTER PROCEDURE SP_LOAD_DIM_CLIENTE
AS
BEGIN
    -- Limpieza STG_REGIONS
    UPDATE STG_TDC.dbo.STG_REGIONS SET CITY = 'St. Louis' WHERE CITY = 'St. Loius';

    -- Limpieza STG_CUSTOMERS
    UPDATE STG_TDC.dbo.STG_CUSTOMERS SET BIRTH_DATE = NULL  WHERE CUSTOMER_ID = '2036';
    UPDATE STG_TDC.dbo.STG_CUSTOMERS SET BIRTH_DATE = '11/03/1968' WHERE CUSTOMER_ID = '2132';
    UPDATE STG_TDC.dbo.STG_CUSTOMERS SET BIRTH_DATE = '10/05/1964' WHERE CUSTOMER_ID = '2158';
    UPDATE STG_TDC.dbo.STG_CUSTOMERS SET BIRTH_DATE = '11/11/1969' WHERE CUSTOMER_ID = '1018';
    UPDATE STG_TDC.dbo.STG_CUSTOMERS SET BIRTH_DATE = '12/17/1953' WHERE CUSTOMER_ID = '1197';
    UPDATE STG_TDC.dbo.STG_CUSTOMERS SET ZIPCODE = '0' + ZIPCODE WHERE LEN(ZIPCODE) = 4;

    DELETE FROM DIM_CLIENTE;
    DBCC CHECKIDENT ('DIM_CLIENTE', RESEED, 0);

    -- Registro desconocido
    SET IDENTITY_INSERT DIM_CLIENTE ON;
    INSERT INTO DIM_CLIENTE (id_cliente, cod_sist_origen, id_cliente_origen, nombre_cliente, fecha_nacimiento, tipo_cliente, zipcode, ciudad, estado, region)
    VALUES (-1, 'N/A', '-1', 'Desconocido', NULL, 'N/A', 'N/A', 'N/A', 'N/A', 'N/A');
    SET IDENTITY_INSERT DIM_CLIENTE OFF;

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