USE TDC_DW;
GO

CREATE OR ALTER PROCEDURE SP_LOAD_DIM_EMPLEADO
AS
BEGIN
    DELETE FROM DIM_EMPLEADO;
    DBCC CHECKIDENT ('DIM_EMPLEADO', RESEED, 0);

    INSERT INTO DIM_EMPLEADO (cod_sist_origen, id_empleado_origen, nombre_empleado, genero, categoria, fecha_ingreso, fecha_nacimiento, nivel_educativo, antiguedad)
    SELECT
        'EXCEL'                             AS cod_sist_origen,
        EMPLOYEE_ID                         AS id_empleado_origen,
        FULL_NAME                           AS nombre_empleado,
        GENDER                              AS genero,
        CATEGORY                            AS categoria,
        CAST(EMPLOYMENT_DATE AS DATE)       AS fecha_ingreso,
        CAST(BIRTH_DATE AS DATE)            AS fecha_nacimiento,
        EDUCATION_LEVEL                     AS nivel_educativo,
        DATEDIFF(YEAR, CAST(EMPLOYMENT_DATE AS DATE), GETDATE()) AS antiguedad
    FROM STG_TDC.dbo.STG_EMPLOYEES;
END;
GO

exec SP_LOAD_DIM_EMPLEADO
select * from DIM_EMPLEADO