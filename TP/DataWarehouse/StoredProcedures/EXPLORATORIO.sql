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
--Exploracion datos Tabla fecha
--##################################

select * from STG_BILLING

select * from STG_HISTORY_SALES
select min(date), max(date) from STG_BILLING
select min(date), max(date) from STG_HISTORY_SALES

select * from STG_HOLIDAYS

--##################################
--Exploracion datos Tabla billing
--##################################

SELECT * FROM STG_TDC.dbo.STG_billing;

SELECT 
    SUM(CASE WHEN BILLING_ID IS NULL THEN 1 ELSE 0 END) AS nulos_billing_id,
    SUM(CASE WHEN REGION IS NULL THEN 1 ELSE 0 END) AS nulos_region,
    SUM(CASE WHEN BRANCH_ID IS NULL THEN 1 ELSE 0 END) AS nulos_branch_id,
    SUM(CASE WHEN DATE IS NULL THEN 1 ELSE 0 END) AS nulos_date,
    SUM(CASE WHEN CUSTOMER_ID IS NULL THEN 1 ELSE 0 END) AS nulos_customer_id,
    SUM(CASE WHEN EMPLOYEE_ID IS NULL THEN 1 ELSE 0 END) AS nulos_employee_id
FROM STG_TDC.dbo.STG_BILLING;


SELECT DISTINCT REGION FROM STG_TDC.dbo.STG_BILLING;
SELECT DISTINCT REGION FROM STG_TDC.dbo.STG_HISTORY_SALES;
SELECT COUNT(*) FROM STG_TDC.dbo.STG_HISTORY_SALES WHERE REGION IS NULL;

UPDATE STG_TDC.dbo.STG_BILLING SET REGION = 'Central' WHERE REGION = 'North';

SELECT DISTINCT REGION FROM STG_TDC.dbo.STG_BILLING;

SELECT COUNT(*) FROM STG_TDC.dbo.STG_BILLING WHERE ISDATE(DATE) = 0;

--##################################
--Exploracion datos Tabla billing_detail
--##################################

SELECT * FROM STG_TDC.dbo.STG_BILLING_DETAIL;

SELECT 
    SUM(CASE WHEN BILLING_ID IS NULL THEN 1 ELSE 0 END) AS nulos_billing_id,
    SUM(CASE WHEN PRODUCT_ID IS NULL THEN 1 ELSE 0 END) AS nulos_product_id,
    SUM(CASE WHEN QUANTITY IS NULL THEN 1 ELSE 0 END) AS nulos_quantity
FROM STG_TDC.dbo.STG_BILLING_DETAIL;

--Detectamos que los product_id no coinciden en productos/billing_detail
SELECT DISTINCT bd.PRODUCT_ID
FROM STG_TDC.dbo.STG_BILLING_DETAIL bd
LEFT JOIN STG_TDC.dbo.STG_PRODUCTS p ON bd.PRODUCT_ID = p.PRODUCT_ID
WHERE p.PRODUCT_ID IS NULL;

SELECT DISTINCT LEN(PRODUCT_ID), MIN(PRODUCT_ID), MAX(PRODUCT_ID)
FROM STG_TDC.dbo.STG_BILLING_DETAIL
GROUP BY LEN(PRODUCT_ID);

UPDATE STG_TDC.dbo.STG_BILLING_DETAIL 
SET PRODUCT_ID = '0' + PRODUCT_ID 
WHERE LEN(PRODUCT_ID) = 1;

--##################################
--Exploracion datos Tabla prices
--##################################
select * from STG_PRICES
--Corregimos id que les falta cero al inicio
UPDATE STG_TDC.dbo.STG_PRICES 
SET PRODUCT_ID = '0' + PRODUCT_ID 
WHERE LEN(PRODUCT_ID) = 1;

--redondeamos valores a dos decimales
UPDATE STG_TDC.dbo.STG_PRICES 
SET PRICE = CAST(ROUND(CAST(PRICE AS FLOAT), 2) AS VARCHAR(50));

SELECT * FROM STG_PRICES

--##################################
--Exploracion datos Tabla discounts
--##################################

SELECT * FROM STG_TDC.dbo.STG_DISCOUNTS;

--##################################
--Exploracion datos Tabla history_sales
--##################################

select * from stg_history_sales

SELECT 
    SUM(CASE WHEN ID IS NULL THEN 1 ELSE 0 END) AS nulos_id,
    SUM(CASE WHEN BILLING_ID IS NULL THEN 1 ELSE 0 END) AS nulos_billing_id,
    SUM(CASE WHEN DATE IS NULL THEN 1 ELSE 0 END) AS nulos_date,
    SUM(CASE WHEN CUSTOMER_ID IS NULL THEN 1 ELSE 0 END) AS nulos_customer_id,
    SUM(CASE WHEN EMPLOYEE_ID IS NULL THEN 1 ELSE 0 END) AS nulos_employee_id,
    SUM(CASE WHEN PRODUCT_ID IS NULL THEN 1 ELSE 0 END) AS nulos_product_id,
    SUM(CASE WHEN QUANTITY IS NULL THEN 1 ELSE 0 END) AS nulos_quantity,
    SUM(CASE WHEN REGION IS NULL THEN 1 ELSE 0 END) AS nulos_region
FROM STG_TDC.dbo.STG_HISTORY_SALES;

SELECT * FROM STG_TDC.dbo.STG_HISTORY_SALES
WHERE DATE IS NULL OR CUSTOMER_ID IS NULL OR EMPLOYEE_ID IS NULL OR REGION IS NULL;

SELECT DISTINCT LEN(PRODUCT_ID), MIN(PRODUCT_ID), MAX(PRODUCT_ID)
FROM STG_TDC.dbo.STG_HISTORY_SALES
GROUP BY LEN(PRODUCT_ID);

UPDATE STG_TDC.dbo.STG_HISTORY_SALES
SET PRODUCT_ID = '0' + PRODUCT_ID
WHERE LEN(PRODUCT_ID) = 1;

select distinct h.customer_id
from STG_HISTORY_SALES h
left join STG_CUSTOMERS c on h.CUSTOMER_ID = c.CUSTOMER_ID
where c.CUSTOMER_ID is null
and h.customer_id is not null

SELECT DISTINCT h.EMPLOYEE_ID
FROM STG_TDC.dbo.STG_HISTORY_SALES h
LEFT JOIN STG_TDC.dbo.STG_EMPLOYEES e ON h.EMPLOYEE_ID = e.EMPLOYEE_ID
WHERE e.EMPLOYEE_ID IS NULL
AND h.EMPLOYEE_ID IS NOT NULL;

--Detectamos un id_empleado que no existe
select * from STG_HISTORY_SALES where EMPLOYEE_ID = '536871149'

SELECT DISTINCT h.PRODUCT_ID
FROM STG_TDC.dbo.STG_HISTORY_SALES h
LEFT JOIN STG_TDC.dbo.STG_PRODUCTS p ON h.PRODUCT_ID = p.PRODUCT_ID
WHERE p.PRODUCT_ID IS NULL
AND h.PRODUCT_ID IS NOT NULL;

select * from STG_BILLING

select * from STG_BILLING_detail

select * from STG_HISTORY_SALES

select * from STG_PRICES

SELECT COUNT(DISTINCT bd.BILLING_ID)
FROM STG_TDC.dbo.STG_BILLING_DETAIL bd
LEFT JOIN STG_TDC.dbo.STG_BILLING b ON bd.BILLING_ID = b.BILLING_ID
WHERE b.BILLING_ID IS NULL;

--Hay detalles de venta sin billing_id correspondiente
SELECT COUNT(*)
FROM STG_TDC.dbo.STG_BILLING_DETAIL bd
LEFT JOIN STG_TDC.dbo.STG_BILLING b ON bd.BILLING_ID = b.BILLING_ID
WHERE b.BILLING_ID IS NULL;

SELECT MIN(bd.BILLING_ID), MAX(bd.BILLING_ID)
FROM STG_TDC.dbo.STG_BILLING_DETAIL bd
LEFT JOIN STG_TDC.dbo.STG_BILLING b ON bd.BILLING_ID = b.BILLING_ID
WHERE b.BILLING_ID IS NULL;

SELECT TOP 10
    h.ID,
    h.PRODUCT_ID,
    h.DATE,
    (SELECT TOP 1 CAST(p.PRICE AS MONEY)
     FROM STG_TDC.dbo.STG_PRICES p
     WHERE p.PRODUCT_ID = h.PRODUCT_ID
     AND CAST(p.DATE AS DATE) <= CAST(h.DATE AS DATE)
     ORDER BY CAST(p.DATE AS DATE) DESC) AS precio_unitario
FROM STG_TDC.dbo.STG_HISTORY_SALES h;

SELECT 
    SUM(CASE WHEN h.DATE IS NULL THEN 1 ELSE 0 END) AS sin_fecha,
    SUM(CASE WHEN h.DATE IS NOT NULL THEN 1 ELSE 0 END) AS con_fecha
FROM STG_TDC.dbo.STG_HISTORY_SALES h
LEFT JOIN STG_TDC.dbo.STG_PRICES p 
    ON p.PRODUCT_ID = h.PRODUCT_ID
    AND CAST(p.DATE AS DATE) = (
        SELECT MAX(CAST(p2.DATE AS DATE))
        FROM STG_TDC.dbo.STG_PRICES p2
        WHERE p2.PRODUCT_ID = h.PRODUCT_ID
        AND CAST(p2.DATE AS DATE) <= CAST(h.DATE AS DATE)
    )
WHERE p.PRICE IS NULL;

SELECT COUNT(*) FROM STG_TDC.dbo.STG_HISTORY_SALES 
WHERE CAST(DATE AS DATE) < '2006-02-01'
AND DATE IS NOT NULL;

SELECT MIN(CAST(DATE AS DATE)), MAX(CAST(DATE AS DATE))
FROM STG_TDC.dbo.STG_HISTORY_SALES
WHERE CAST(DATE AS DATE) < '2006-02-01'
AND DATE IS NOT NULL;

--para las 32070 filas sin fecha vamos a usar el precio mas cercano a la fecha 
SELECT TOP 100
    h.ID,
    h.PRODUCT_ID,
    h.DATE,
    COALESCE(
        (SELECT TOP 1 CAST(p.PRICE AS MONEY)
         FROM STG_TDC.dbo.STG_PRICES p
         WHERE p.PRODUCT_ID = h.PRODUCT_ID
         AND CAST(p.DATE AS DATE) <= CAST(h.DATE AS DATE)
         ORDER BY CAST(p.DATE AS DATE) DESC),
        (SELECT TOP 1 CAST(p.PRICE AS MONEY)
         FROM STG_TDC.dbo.STG_PRICES p
         WHERE p.PRODUCT_ID = h.PRODUCT_ID
         ORDER BY CAST(p.DATE AS DATE) ASC)
    ) AS precio_unitario
FROM STG_TDC.dbo.STG_HISTORY_SALES h
WHERE CAST(DATE AS DATE) < '2006-02-01';

-- ============================================================
    -- PASO 6: PRECIOS VIGENTES (BILLING)
    -- ============================================================
    IF OBJECT_ID('tempdb..#precios_billing') IS NOT NULL DROP TABLE #precios_billing;

    SELECT 
        bd.BILLING_ID,
        bd.PRODUCT_ID,
        b.DATE,
        CAST(bd.QUANTITY AS INT) AS cantidad,
        COALESCE(
            (SELECT TOP 1 CAST(p.PRICE AS MONEY)
             FROM STG_TDC.dbo.STG_PRICES p
             WHERE p.PRODUCT_ID = bd.PRODUCT_ID
             AND CAST(p.DATE AS DATE) <= CAST(b.DATE AS DATE)
             ORDER BY CAST(p.DATE AS DATE) DESC),
            (SELECT TOP 1 CAST(p.PRICE AS MONEY)
             FROM STG_TDC.dbo.STG_PRICES p
             WHERE p.PRODUCT_ID = bd.PRODUCT_ID
             ORDER BY CAST(p.DATE AS DATE) ASC)
        ) AS precio_unitario
    INTO #precios_billing
    FROM STG_TDC.dbo.STG_BILLING_DETAIL bd
    LEFT JOIN STG_TDC.dbo.STG_BILLING b ON bd.BILLING_ID = b.BILLING_ID;