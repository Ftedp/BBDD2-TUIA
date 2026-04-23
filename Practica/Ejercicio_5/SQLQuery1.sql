-- ============================================
-- DATA WAREHOUSE - CONCESIONARIO AUTOMOVILES
-- TUIA - Bases de Datos 2 - 2023
-- ============================================
CREATE DATABASE	Ventas_Consecionario;

Use Ventas_Consecionario;

-- ============================================
-- 1. DIM_MODO_PAGO
-- ============================================
CREATE TABLE DIM_MODO_PAGO (
	id_modo_pago INT NOT NULL,
	descripcion VARCHAR(50) NOT NULL,
	CONSTRAINT PK_DIM_MODO_PAGO PRIMARY KEY (id_modo_pago)
);
GO

-- ============================================
-- 2. DIM_SUCURSAL
-- Jerarquia: Sucursal -> Ciudad
-- ============================================
CREATE TABLE DIM_SUCURSAL (
	id_sucursal INT NOT NULL,
	nombre VARCHAR(100) NOT NULL,
	ciudad VARCHAR(100) NOT NULL,
	domicilio VARCHAR(100) NOT NULL,
	cuit VARCHAR(100) NOT NULL,
	CONSTRAINT PK_DIM_SUCURSAL PRIMARY KEY (id_sucursal)
);
GO

-- ============================================
-- 3. DIM_VENDEDOR
-- Jerarquia: Vendedor -> Sucursal
-- ============================================
CREATE TABLE DIM_VENDEDOR (
    id_vendedor     INT             NOT NULL,
    legajo          VARCHAR(20)     NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    cuit            VARCHAR(20)             ,
    domicilio       VARCHAR(200)            ,
    fecha_ingreso   DATE                    ,
    id_sucursal     INT             NOT NULL,
    CONSTRAINT PK_DIM_VENDEDOR  PRIMARY KEY (id_vendedor),
    CONSTRAINT FK_VEN_SUC       FOREIGN KEY (id_sucursal) REFERENCES DIM_SUCURSAL(id_sucursal)
);
GO

-- ============================================
-- 4. DIM_TIEMPO
-- Jerarquia: Dia -> Mes -> Trimestre -> Semestre -> Anio
-- Dimension de rol: compra y entrega
-- ============================================
CREATE TABLE DIM_TIEMPO (
    id_tiempo       INT             NOT NULL,
    fecha           DATE            NOT NULL,
    dia             INT             NOT NULL,
    mes             INT             NOT NULL,
    trimestre       INT             NOT NULL,
    semestre        INT             NOT NULL,
    anio            INT             NOT NULL,
    dia_semana      VARCHAR(10)     NOT NULL,
    es_feriado      BIT             NOT NULL DEFAULT 0,
    CONSTRAINT PK_DIM_TIEMPO PRIMARY KEY (id_tiempo)
);
GO
 
-- ============================================
-- 5. DIM_ACCESORIO
-- Incluye registro dummy 'Sin accesorio' (id=0)
-- ============================================
CREATE TABLE DIM_ACCESORIO (
    id_accesorio    INT             NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    descripcion     VARCHAR(200)            ,
    CONSTRAINT PK_DIM_ACCESORIO PRIMARY KEY (id_accesorio)
);
GO
 
-- Registro dummy para autos sin accesorios
INSERT INTO DIM_ACCESORIO (id_accesorio, nombre, descripcion)
VALUES (0, 'Sin accesorio', 'Auto vendido sin accesorios adicionales');
GO
 
-- ============================================
-- 6. DIM_AUTOMOVIL (conformada: usada por FCT_VENTAS y FCT_STOCK)
-- Jerarquia: Modelo -> Marca -> Tipo
-- ============================================
CREATE TABLE DIM_AUTOMOVIL (
    id_automovil    INT             NOT NULL,
    nro_chasis      VARCHAR(50)     NOT NULL,
    marca           VARCHAR(50)     NOT NULL,
    modelo          VARCHAR(50)     NOT NULL,
    tipo_vehiculo   VARCHAR(50)             ,
    color           VARCHAR(30)             ,
    potencia        VARCHAR(30)             ,
    cilindrada      VARCHAR(30)             ,
    precio_lista    DECIMAL(15,2)           ,
    CONSTRAINT PK_DIM_AUTOMOVIL PRIMARY KEY (id_automovil)
);
GO
 
-- ============================================
-- 7. FCT_STOCK
-- Granularidad: una fila por modelo de auto por fecha
-- ============================================
CREATE TABLE FCT_STOCK (
    id_stock        INT             NOT NULL,
    id_automovil    INT             NOT NULL,
    id_tiempo       INT             NOT NULL,
    cantidad_stock  INT             NOT NULL,
    CONSTRAINT PK_FCT_STOCK         PRIMARY KEY (id_stock),
    CONSTRAINT FK_STK_AUTOMOVIL     FOREIGN KEY (id_automovil)  REFERENCES DIM_AUTOMOVIL(id_automovil),
    CONSTRAINT FK_STK_TIEMPO        FOREIGN KEY (id_tiempo)     REFERENCES DIM_TIEMPO(id_tiempo)
);
GO
 
-- ============================================
-- 8. FCT_VENTAS
-- Granularidad: una fila por accesorio por venta
-- (autos sin accesorios usan id_accesorio = 0)
-- ============================================
CREATE TABLE FCT_VENTAS (
    id_venta            INT             NOT NULL,
    id_tiempo_compra    INT             NOT NULL,
    id_tiempo_entrega   INT             NOT NULL,
    id_automovil        INT             NOT NULL,
    id_accesorio        INT             NOT NULL,
    id_vendedor         INT             NOT NULL,
    id_sucursal         INT             NOT NULL,
    id_modo_pago        INT             NOT NULL,
    precio_lista        DECIMAL(15,2)   NOT NULL,
    descuento           DECIMAL(15,2)   NOT NULL DEFAULT 0,
    precio_accesorio    DECIMAL(15,2)   NOT NULL DEFAULT 0,
    precio_final        AS (precio_lista - descuento + precio_accesorio),
    patente             VARCHAR(20)             ,
    CONSTRAINT PK_FCT_VENTAS        PRIMARY KEY (id_venta),
    CONSTRAINT FK_VTA_TIEMPO_COM    FOREIGN KEY (id_tiempo_compra)  REFERENCES DIM_TIEMPO(id_tiempo),
    CONSTRAINT FK_VTA_TIEMPO_ENT    FOREIGN KEY (id_tiempo_entrega) REFERENCES DIM_TIEMPO(id_tiempo),
    CONSTRAINT FK_VTA_AUTOMOVIL     FOREIGN KEY (id_automovil)      REFERENCES DIM_AUTOMOVIL(id_automovil),
    CONSTRAINT FK_VTA_ACCESORIO     FOREIGN KEY (id_accesorio)      REFERENCES DIM_ACCESORIO(id_accesorio),
    CONSTRAINT FK_VTA_VENDEDOR      FOREIGN KEY (id_vendedor)       REFERENCES DIM_VENDEDOR(id_vendedor),
    CONSTRAINT FK_VTA_SUCURSAL      FOREIGN KEY (id_sucursal)       REFERENCES DIM_SUCURSAL(id_sucursal),
    CONSTRAINT FK_VTA_MODO_PAGO     FOREIGN KEY (id_modo_pago)      REFERENCES DIM_MODO_PAGO(id_modo_pago)
);
GO