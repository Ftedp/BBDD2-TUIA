-- ============================================================
-- STAGING - THE DRINKING COMPANY (TDC)
-- Script de creación de base de datos y tablas de staging
-- Sin FKs, sin restricciones, todo VARCHAR (datos sucios)
-- ============================================================

DROP DATABASE IF EXISTS STG_TDC;
GO

CREATE DATABASE STG_TDC;
GO

USE STG_TDC;
GO

-- ============================================================
-- TABLAS DE STAGING
-- ============================================================

-- Fuente: archivo de empleados
CREATE TABLE STG_EMPLOYEES (
    EMPLOYEE_ID         VARCHAR(50),
    FULL_NAME           VARCHAR(200),
    GENDER              VARCHAR(50),
    CATEGORY            VARCHAR(100),
    EMPLOYMENT_DATE     VARCHAR(50),
    BIRTH_DATE          VARCHAR(50),
    EDUCATION_LEVEL     VARCHAR(100)
);
GO

-- Fuente: archivo de feriados
CREATE TABLE STG_HOLIDAYS (
    DATE                VARCHAR(50),
    HOLIDAY             VARCHAR(200)
);
GO

-- Fuente: archivo de clientes
-- TIPO_CLIENTE agregado manualmente: R (retail) o W (wholesale)
CREATE TABLE STG_CUSTOMERS (
    CUSTOMER_ID         VARCHAR(50),
    FULL_NAME           VARCHAR(200),
    BIRTH_DATE          VARCHAR(50),
    CITY                VARCHAR(100),
    STATE               VARCHAR(100),
    ZIPCODE             VARCHAR(20),
    TIPO_CLIENTE        VARCHAR(10)
);
GO

-- Fuente: archivo de regiones/geografía
CREATE TABLE STG_REGIONS (
    REGION              VARCHAR(100),
    STATE               VARCHAR(100),
    CITY                VARCHAR(100),
    ZIPCODE             VARCHAR(20)
);
GO

-- Fuente: archivo de productos
CREATE TABLE STG_PRODUCTS (
    PRODUCT_ID          VARCHAR(50),
    DETAIL              VARCHAR(200),
    PACKAGE             VARCHAR(100)
);
GO

-- Fuente: archivo de stock
CREATE TABLE STG_STOCK (
    PRODUCT_ID          VARCHAR(50),
    DATE                VARCHAR(100),
    VARIATION           VARCHAR(50)
);
GO

-- Fuente: sistema de facturación (cabecera)
CREATE TABLE STG_BILLING (
    BILLING_ID          VARCHAR(50),
    REGION              VARCHAR(100),
    BRANCH_ID           VARCHAR(50),
    DATE                VARCHAR(50),
    CUSTOMER_ID         VARCHAR(50),
    EMPLOYEE_ID         VARCHAR(50)
);
GO

-- Fuente: sistema de facturación (detalle)
CREATE TABLE STG_BILLING_DETAIL (
    BILLING_ID          VARCHAR(50),
    PRODUCT_ID          VARCHAR(50),
    QUANTITY            VARCHAR(50)
);
GO

-- Fuente: archivo de precios
CREATE TABLE STG_PRICES (
    PRODUCT_ID          VARCHAR(50),
    DATE                VARCHAR(50),
    PRICE               VARCHAR(50)
);
GO

-- Fuente: archivo de descuentos
CREATE TABLE STG_DISCOUNTS (
    DISCOUNT_ID         VARCHAR(50),
    FROM_DATE           VARCHAR(50),
    UNTIL_DATE          VARCHAR(50),
    TOTAL_BILLING       VARCHAR(50),
    PERCENTAGE          VARCHAR(50)
);
GO

-- Fuente: ventas históricas
CREATE TABLE STG_HISTORY_SALES (
    ID                  VARCHAR(50),
    BILLING_ID          VARCHAR(50),
    DATE                VARCHAR(50),
    CUSTOMER_ID         VARCHAR(50),
    EMPLOYEE_ID         VARCHAR(50),
    PRODUCT_ID          VARCHAR(50),
    QUANTITY            VARCHAR(50),
    REGION		VARCHAR(100)
);
GO