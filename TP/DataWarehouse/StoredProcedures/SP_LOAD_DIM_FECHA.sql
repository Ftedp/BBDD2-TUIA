USE TDC_DW;
GO

CREATE OR ALTER PROCEDURE SP_LOAD_DIM_FECHA
AS
BEGIN
    DELETE FROM DIM_FECHA;

    -- Registro desconocido
    INSERT INTO DIM_FECHA (fecha_nro, dia, dia_sem_nro, dia_sem_nomb, mes, mes_nombre, trimestre, semestre, anio, feriado)
    VALUES (-1, -1, -1, 'Desconocido', -1, 'Desconocido', -1, -1, -1, 0);

    DECLARE @fecha DATE = '2006-01-01';
    DECLARE @fecha_fin DATE = '2009-12-31';

    WHILE @fecha <= @fecha_fin
    BEGIN
        INSERT INTO DIM_FECHA (fecha_nro, dia, dia_sem_nro, dia_sem_nomb, mes, mes_nombre, trimestre, semestre, anio, feriado)
        VALUES (
            CAST(FORMAT(@fecha, 'yyyyMMdd') AS INT),
            DAY(@fecha),
            DATEPART(WEEKDAY, @fecha),
            DATENAME(WEEKDAY, @fecha),
            MONTH(@fecha),
            DATENAME(MONTH, @fecha),
            DATEPART(QUARTER, @fecha),
            CASE WHEN MONTH(@fecha) <= 6 THEN 1 ELSE 2 END,
            YEAR(@fecha),
            0
        );
        SET @fecha = DATEADD(DAY, 1, @fecha);
    END;

    UPDATE DIM_FECHA
    SET feriado = 1
    WHERE EXISTS (
        SELECT 1 
        FROM STG_TDC.dbo.STG_HOLIDAYS h
        WHERE DAY(CAST(h.DATE AS DATE)) = DIM_FECHA.dia
        AND MONTH(CAST(h.DATE AS DATE)) = DIM_FECHA.mes
    );
END;
GO

