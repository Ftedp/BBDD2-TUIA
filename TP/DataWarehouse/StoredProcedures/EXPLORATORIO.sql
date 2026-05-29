--##################################
--Exploracion datos Tabla productos
--##################################

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

use TDC_DW

exec SP_LOAD_DIM_PRESENTACION;
select * from DIM_RUBRO
select * from DIM_PRESENTACION


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
--##################################
--Exploracion datos Tabla EMPLOYEES
--##################################

use STG_TDC

select * from STG_EMPLOYEES

SELECT 
    SUM(CASE WHEN EMPLOYEE_ID IS NULL THEN 1 ELSE 0 END) AS nulos_id,
    SUM(CASE WHEN FULL_NAME IS NULL THEN 1 ELSE 0 END) AS nulos_nombre,
    SUM(CASE WHEN GENDER IS NULL THEN 1 ELSE 0 END) AS nulos_genero,
    SUM(CASE WHEN CATEGORY IS NULL THEN 1 ELSE 0 END) AS nulos_categoria,
    SUM(CASE WHEN EMPLOYMENT_DATE IS NULL THEN 1 ELSE 0 END) AS nulos_fecha_ingreso,
    SUM(CASE WHEN BIRTH_DATE IS NULL THEN 1 ELSE 0 END) AS nulos_fecha_nac,
    SUM(CASE WHEN EDUCATION_LEVEL IS NULL THEN 1 ELSE 0 END) AS nulos_educacion
FROM STG_TDC.dbo.STG_EMPLOYEES;

select distinct gender from STG_EMPLOYEES

select distinct employment_date from STG_EMPLOYEES

select distinct birth_date from STG_EMPLOYEES

select full_name from STG_EMPLOYEES
where full_name like '%,%,%'  --Devuelve un nombre con error

select full_name from STG_EMPLOYEES where full_name like '%  %'

select employee_id, count(*)
from STG_EMPLOYEES
group by EMPLOYEE_ID
having count(*) > 1;

select full_name, employment_date, birth_date
from STG_EMPLOYEES
where isdate(employment_date) = 0 or isdate(birth_date) = 0