-- ============================================================
-- DATA WAREHOUSE - THE DRINKING COMPANY (TDC)
-- Script de creación de tablas en SQL Server
-- ============================================================
DROP DATABASE IF EXISTS TDC_DW;
GO

CREATE DATABASE TDC_DW;
GO

USE TDC_DW;
GO

-- ============================================================
-- DIMENSIONES
-- ============================================================

-- DIM_FECHA
CREATE TABLE DIM_FECHA (
    fecha_nro       INT             NOT NULL,
    dia             INT             NOT NULL,
    dia_sem_nro     INT             NOT NULL,
    dia_sem_nomb    VARCHAR(20)     NOT NULL,
    mes             INT             NOT NULL,
    mes_nombre      VARCHAR(20)     NOT NULL,
    trimestre       INT             NOT NULL,
    semestre        INT             NOT NULL,
    anio            INT             NOT NULL,
    feriado         BIT             NOT NULL DEFAULT 0,
    CONSTRAINT PK_DIM_FECHA PRIMARY KEY (fecha_nro)
);
GO

-- DIM_CLIENTE
-- La geografía del cliente está desnormalizada.
-- DIM_GEOGRAFIA es una dimensión separada usada solo para el punto de venta.
CREATE TABLE DIM_CLIENTE (
    id_cliente          INT             NOT NULL    IDENTITY(1,1),
    cod_sist_origen     VARCHAR(50)     NOT NULL,
    id_cliente_origen   VARCHAR(50)     NOT NULL,
    nombre_cliente      VARCHAR(200)    NOT NULL,
    fecha_nacimiento    DATE            NULL,
    tipo_cliente        VARCHAR(50)     NOT NULL,
    zipcode             VARCHAR(20)     NOT NULL,
    ciudad              VARCHAR(100)    NOT NULL,
    estado              VARCHAR(100)    NOT NULL,
    region              VARCHAR(100)    NOT NULL,
    CONSTRAINT PK_DIM_CLIENTE PRIMARY KEY (id_cliente)
);
GO

-- DIM_RUBRO
CREATE TABLE DIM_RUBRO (
    id_rubro        INT             NOT NULL    IDENTITY(1,1),
    nombre_rubro    VARCHAR(100)    NOT NULL,
    CONSTRAINT PK_DIM_RUBRO PRIMARY KEY (id_rubro)
);
GO

-- DIM_PRESENTACION
CREATE TABLE DIM_PRESENTACION (
    id_presentacion INT             NOT NULL    IDENTITY(1,1),
    volumen         INT   NULL,       -- volumen cm3
	medida			VARCHAR(20)		NULL,	-- cm3
    tipo_envase     VARCHAR(50)     NULL,
	presentacion_original VARCHAR(100) NULL,
    CONSTRAINT PK_DIM_PRESENTACION PRIMARY KEY (id_presentacion)
);
GO

-- DIM_PRODUCTO
CREATE TABLE DIM_PRODUCTO (
    id_producto         INT             NOT NULL    IDENTITY(1,1),
    id_rubro            INT             NOT NULL,
    id_presentacion     INT             NOT NULL,
    cod_sist_origen     VARCHAR(50)     NOT NULL,
    id_producto_origen  VARCHAR(50)     NOT NULL,
    nombre_producto     VARCHAR(200)    NOT NULL,
    es_diet             BIT             NOT NULL DEFAULT 0,
    CONSTRAINT PK_DIM_PRODUCTO PRIMARY KEY (id_producto),
    CONSTRAINT FK_PRODUCTO_RUBRO        FOREIGN KEY (id_rubro)        REFERENCES DIM_RUBRO(id_rubro),
    CONSTRAINT FK_PRODUCTO_PRESENTACION FOREIGN KEY (id_presentacion) REFERENCES DIM_PRESENTACION(id_presentacion)
);
GO

-- DIM_EMPLEADO
CREATE TABLE DIM_EMPLEADO (
    id_empleado         INT             NOT NULL    IDENTITY(1,1),
    cod_sist_origen     VARCHAR(50)     NOT NULL,
	id_empleado_origen VARCHAR(50) NOT NULL,
    nombre_empleado     VARCHAR(200)    NOT NULL,
    genero              VARCHAR(20)     NULL,
    categoria           VARCHAR(100)    NULL,
    fecha_ingreso       DATE            NOT NULL,
    fecha_nacimiento    DATE            NULL,
    nivel_educativo     VARCHAR(100)    NULL,
    antiguedad          INT             NULL,
    CONSTRAINT PK_DIM_EMPLEADO PRIMARY KEY (id_empleado)
);
GO

-- DIM_COTIZACION
CREATE TABLE DIM_COTIZACION (
    id_cotizacion       INT             NOT NULL    IDENTITY(1,1),
    fecha_nro_desde     INT             NOT NULL,
    fecha_nro_hasta     INT             NOT NULL,
    moneda              VARCHAR(10)     NOT NULL,
    cotizacion          MONEY           NOT NULL,   -- es un valor monetario
    CONSTRAINT PK_DIM_COTIZACION PRIMARY KEY (id_cotizacion),
    CONSTRAINT FK_COTIZACION_FECHA_DESDE FOREIGN KEY (fecha_nro_desde) REFERENCES DIM_FECHA(fecha_nro),
    CONSTRAINT FK_COTIZACION_FECHA_HASTA FOREIGN KEY (fecha_nro_hasta) REFERENCES DIM_FECHA(fecha_nro)
);
GO

-- ============================================================
-- TABLAS DE HECHOS
-- ============================================================

-- FCT_VENTAS
CREATE TABLE FCT_VENTAS (
    id_venta            INT             NOT NULL    IDENTITY(1,1),
    fecha_nro           INT             NOT NULL,
    id_cliente          INT             NOT NULL,
    id_producto         INT             NOT NULL,
    id_empleado         INT             NOT NULL,
    region_venta        VARCHAR(50)	    NULL,
    cod_sist_origen     VARCHAR(50)     NOT NULL,
    factura             VARCHAR(50)     NOT NULL,
    cantidad            INT             NOT NULL,
    volumen_total       INT			    NULL,       -- volume cm3
    precio_unitario_usd MONEY           NULL,
    precio_bruto_usd    MONEY           NULL,
    descuento           MONEY           NULL,
    monto_total_usd     MONEY           NULL,
    edad_cliente        INT             NULL,
    edad_empleado       INT             NULL,
    grupo_etario        INT             NULL,
    antiguedad_empleado INT             NULL,
    CONSTRAINT PK_FCT_VENTAS PRIMARY KEY (id_venta),
    CONSTRAINT FK_VENTAS_FECHA    FOREIGN KEY (fecha_nro)    REFERENCES DIM_FECHA(fecha_nro),
    CONSTRAINT FK_VENTAS_CLIENTE  FOREIGN KEY (id_cliente)   REFERENCES DIM_CLIENTE(id_cliente),
    CONSTRAINT FK_VENTAS_PRODUCTO FOREIGN KEY (id_producto)  REFERENCES DIM_PRODUCTO(id_producto),
    CONSTRAINT FK_VENTAS_EMPLEADO FOREIGN KEY (id_empleado)  REFERENCES DIM_EMPLEADO(id_empleado),
);
GO

-- FCT_STOCK
-- Granularidad: una fila por producto por fecha (periodic snapshot).
-- Sin cod_sist_origen: el stock proviene de una única fuente.
CREATE TABLE FCT_STOCK (
    id_stock        INT             NOT NULL    IDENTITY(1,1),
    fecha_nro       INT             NOT NULL,
    id_producto     INT             NOT NULL,
    cantidad        INT             NOT NULL,
    CONSTRAINT PK_FCT_STOCK PRIMARY KEY (id_stock),
    CONSTRAINT FK_STOCK_FECHA    FOREIGN KEY (fecha_nro)   REFERENCES DIM_FECHA(fecha_nro),
    CONSTRAINT FK_STOCK_PRODUCTO FOREIGN KEY (id_producto) REFERENCES DIM_PRODUCTO(id_producto),
    CONSTRAINT UQ_STOCK_FECHA_PRODUCTO UNIQUE (fecha_nro, id_producto)
);
GO