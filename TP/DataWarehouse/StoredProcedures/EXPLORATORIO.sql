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

SELECT PRODUCT_ID FROM STG_TDC.dbo.STG_PRODUCTS ORDER BY PRODUCT_ID;
SELECT DISTINCT PRODUCT_ID FROM STG_TDC.dbo.STG_BILLING_DETAIL ORDER BY PRODUCT_ID;
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

select datediff(year, cast(employment_date as date), getdate()) as antiguedad
from STG_EMPLOYEES

--##################################
--Exploracion datos Tabla regions
--##################################

select * from STG_REGIONS


SELECT 
    SUM(CASE WHEN REGION IS NULL THEN 1 ELSE 0 END) AS nulos_region,
    SUM(CASE WHEN STATE IS NULL THEN 1 ELSE 0 END) AS nulos_state,
    SUM(CASE WHEN CITY IS NULL THEN 1 ELSE 0 END) AS nulos_city,
    SUM(CASE WHEN ZIPCODE IS NULL THEN 1 ELSE 0 END) AS nulos_zipcode
FROM STG_TDC.dbo.STG_REGIONS;

select zipcode, count(*)
from STG_REGIONS
group by zipcode
having count(*) > 1

update STG_TDC.dbo.STG_REGIONS
set city = 'St. Louis'
where city = 'St. Loius'

SELECT DISTINCT CITY FROM STG_TDC.dbo.STG_REGIONS WHERE CITY LIKE '%Louis%';

--##################################
--Exploracion datos Tabla CUSTOMERS
--##################################

SELECT count(*) FROM STG_CUSTOMERS

SELECT 
    SUM(CASE WHEN CUSTOMER_ID IS NULL THEN 1 ELSE 0 END) AS nulos_id,
    SUM(CASE WHEN FULL_NAME IS NULL THEN 1 ELSE 0 END) AS nulos_nombre,
    SUM(CASE WHEN BIRTH_DATE IS NULL THEN 1 ELSE 0 END) AS nulos_fecha_nac,
    SUM(CASE WHEN CITY IS NULL THEN 1 ELSE 0 END) AS nulos_city,
    SUM(CASE WHEN STATE IS NULL THEN 1 ELSE 0 END) AS nulos_state,
    SUM(CASE WHEN ZIPCODE IS NULL THEN 1 ELSE 0 END) AS nulos_zipcode,
    SUM(CASE WHEN TIPO_CLIENTE IS NULL THEN 1 ELSE 0 END) AS nulos_tipo
FROM STG_TDC.dbo.STG_CUSTOMERS;

select customer_id, count(*)
from STG_CUSTOMERS
group by CUSTOMER_ID
having count(*) > 1;

select customer_id, full_name, birth_date, city, state, zipcode, tipo_cliente
from STG_CUSTOMERS
where isdate(birth_date) = 0

--se encontraron 5 fechas erroneas 44/45/1943, 11j/03/1968, 10/50/1964, 11/11/1969, 12/17*/1953
-- todas se corrigen excepto 44/45/1943 que queda en null
update STG_CUSTOMERS set BIRTH_DATE = null where CUSTOMER_ID = '2036';

update STG_CUSTOMERS set BIRTH_DATE = '11/03/1968' where CUSTOMER_ID = '2132';

update STG_CUSTOMERS set BIRTH_DATE = '10/05/1964' where CUSTOMER_ID = '2158';

update STG_CUSTOMERS set BIRTH_DATE = '11/11/1969' where CUSTOMER_ID = '1018';

update STG_CUSTOMERS set BIRTH_DATE = '12/17/1953' where CUSTOMER_ID = '1197';

SELECT DISTINCT c.ZIPCODE, c.CITY, c.STATE
FROM STG_TDC.dbo.STG_CUSTOMERS c
LEFT JOIN STG_TDC.dbo.STG_REGIONS r ON c.ZIPCODE = r.ZIPCODE
WHERE r.ZIPCODE IS NULL
ORDER BY c.STATE, c.CITY;

SELECT DISTINCT CITY, STATE, ZIPCODE
FROM STG_TDC.dbo.STG_REGIONS
WHERE CITY IN ('Boston', 'Portsmouth', 'Manchester', 'Andover')
ORDER BY CITY;

UPDATE STG_TDC.dbo.STG_CUSTOMERS
SET ZIPCODE = '0' + ZIPCODE
WHERE LEN(ZIPCODE) = 4;

--##################################
--Exploracion datos Tabla CUSTOMERS
--##################################