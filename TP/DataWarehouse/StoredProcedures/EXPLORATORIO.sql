use STG_TDC

select * from STG_PRODUCTS

select distinct detail from stg_products order by detail

select distinct package from stg_products order by package

SELECT DISTINCT PACKAGE
FROM STG_TDC.dbo.STG_PRODUCTS
WHERE PACKAGE NOT IN ('1 Liter', '2 Liter', '330 cm3 can', '500 cm3 can', '670 cm3');

SELECT DISTINCT PACKAGE, LEN(PACKAGE), DATALENGTH(PACKAGE)
FROM STG_TDC.dbo.STG_PRODUCTS;

SELECT DISTINCT PACKAGE, DATALENGTH(PACKAGE)
FROM STG_TDC.dbo.STG_PRODUCTS
WHERE PACKAGE LIKE '%Liter%';

SELECT DISTINCT PACKAGE,
    CASE PACKAGE
        WHEN '1 Liter' THEN 1000
        WHEN '2 Liter' THEN 2000
        WHEN '330 cm3 can' THEN 330
        WHEN '500 cm3 can' THEN 500
        WHEN '670 cm3' THEN 670
    END AS volumen
FROM STG_TDC.dbo.STG_PRODUCTS;