USE TDC_DW;
GO

CREATE OR ALTER PROCEDURE SP_LOAD_DIM_GEOGRAFIA
AS
BEGIN
    DELETE FROM DIM_GEOGRAFIA;
    DBCC CHECKIDENT ('DIM_GEOGRAFIA', RESEED, 0);

    INSERT INTO DIM_GEOGRAFIA (region, estado, ciudad, zipcode)
    SELECT
        REGION      AS region,
        STATE       AS estado,
        CITY        AS ciudad,
        ZIPCODE     AS zipcode
    FROM STG_TDC.dbo.STG_REGIONS;
END;
GO

