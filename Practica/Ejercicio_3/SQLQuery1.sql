-- ============================================
-- DATA WAREHOUSE - VENTAS Y GESTION
-- TUIA - Bases de Datos 2 - 2026
-- ============================================
CREATE DATABASE dw_ventas;

use dw_ventas;

--1. DIM_TIEMPO
CREATE TABLE DIM_TIEMPO (
	id_tiempo INT NOT NULL,
	fecha DATE NOT NULL,
	dia INT NOT NULL,
	mes INT NOT NULL,
	trimestre INT NOT NULL,
	semestre INT NOT NULL,
	anio INT NOT NULL,
	dia_semana VARCHAR(10) NOT NULL,
	CONSTRAINT PK_DIM_TIEMPO PRIMARY KEY (id_tiempo)
);

--2. DIM_GEOGRAFIA
CREATE TABLE DIM_GEOGRAFIA (
	id_geografia    INT             NOT NULL,
    nro_cliente     VARCHAR(20)     NOT NULL,
    direccion       VARCHAR(200)    NOT NULL,
    ciudad          VARCHAR(100)    NOT NULL,
    zona            VARCHAR(100)    NOT NULL,
    region          VARCHAR(100)    NOT NULL,
    fecha_desde     DATE            NOT NULL,
    fecha_hasta     DATE                    ,
    CONSTRAINT PK_DIM_GEOGRAFIA PRIMARY KEY (id_geografia)
);

-- 3. DIM_CLIENTE
CREATE TABLE DIM_CLIENTE (
    id_cliente      INT             NOT NULL,
    nro_cliente     VARCHAR(20)     NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    telefono        VARCHAR(20)             ,
    edad            INT                     ,
    sexo            CHAR(1)                 ,
    grupo_etario    VARCHAR(20)             ,
    id_geografia    INT             NOT NULL,
    CONSTRAINT PK_DIM_CLIENTE      PRIMARY KEY (id_cliente),
    CONSTRAINT FK_CLI_GEO          FOREIGN KEY (id_geografia) REFERENCES DIM_GEOGRAFIA(id_geografia)
);
 
-- 4. DIM_PRODUCTO
CREATE TABLE DIM_PRODUCTO (
    id_producto         INT             NOT NULL,
    codigo_producto     VARCHAR(20)     NOT NULL,
    nombre              VARCHAR(100)    NOT NULL,
    marca               VARCHAR(50)             ,
    categoria           VARCHAR(50)             ,
    sub_producto        VARCHAR(50)             ,
    descripcion         VARCHAR(200)            ,
    precio_lista        DECIMAL(10,2)           ,
    CONSTRAINT PK_DIM_PRODUCTO PRIMARY KEY (id_producto)
);

-- 5. DIM_VENDEDOR
CREATE TABLE DIM_VENDEDOR (
    id_vendedor         INT             NOT NULL,
    codigo_vendedor     VARCHAR(20)     NOT NULL,
    nombre              VARCHAR(100)    NOT NULL,
    sucursal            VARCHAR(100)            ,
    edad                INT                     ,
    sexo                CHAR(1)                 ,
    fecha_ingreso       DATE                    ,
    direccion           VARCHAR(200)            ,
    telefono            VARCHAR(20)             ,
    CONSTRAINT PK_DIM_VENDEDOR PRIMARY KEY (id_vendedor)
);
 
-- 6. FCT_VENTAS
CREATE TABLE FCT_VENTAS (
    id_venta            INT             NOT NULL,
    id_tiempo           INT             NOT NULL,
    id_cliente          INT             NOT NULL,
    id_geografia        INT             NOT NULL,
    id_producto         INT             NOT NULL,
    id_vendedor         INT             NOT NULL,
    cantidad_vendida    INT             NOT NULL,
    precio_unitario     DECIMAL(10,2)   NOT NULL,
    monto_total         DECIMAL(10,2)   NOT NULL,
    CONSTRAINT PK_FCT_VENTAS        PRIMARY KEY (id_venta),
    CONSTRAINT FK_VTA_TIEMPO        FOREIGN KEY (id_tiempo)     REFERENCES DIM_TIEMPO(id_tiempo),
    CONSTRAINT FK_VTA_CLIENTE       FOREIGN KEY (id_cliente)    REFERENCES DIM_CLIENTE(id_cliente),
    CONSTRAINT FK_VTA_GEOGRAFIA     FOREIGN KEY (id_geografia)  REFERENCES DIM_GEOGRAFIA(id_geografia),
    CONSTRAINT FK_VTA_PRODUCTO      FOREIGN KEY (id_producto)   REFERENCES DIM_PRODUCTO(id_producto),
    CONSTRAINT FK_VTA_VENDEDOR      FOREIGN KEY (id_vendedor)   REFERENCES DIM_VENDEDOR(id_vendedor)
);
 
-- 7. FCT_INVENTARIO
CREATE TABLE FCT_INVENTARIO (
    id_inventario       INT             NOT NULL,
    id_producto         INT             NOT NULL,
    id_tiempo           INT             NOT NULL,
    cantidad_stock      INT             NOT NULL,
    CONSTRAINT PK_FCT_INVENTARIO    PRIMARY KEY (id_inventario),
    CONSTRAINT FK_INV_PRODUCTO      FOREIGN KEY (id_producto)   REFERENCES DIM_PRODUCTO(id_producto),
    CONSTRAINT FK_INV_TIEMPO        FOREIGN KEY (id_tiempo)     REFERENCES DIM_TIEMPO(id_tiempo)
);