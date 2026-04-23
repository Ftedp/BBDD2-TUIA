-- ============================================
-- DATA WAREHOUSE - SINIESTROS
-- TUIA - Bases de Datos 2 - 2023
-- ============================================

CREATE DATABASE dw_siniestros;
GO

USE dw_siniestros;
GO

-- ============================================
-- 1. DIM_TIEMPO
-- Jerarquia: Dia -> Mes -> Trimestre -> Semestre -> Anio
-- Dimension de rol: ocurrencia y denuncia
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
-- 2. DIM_GEOGRAFIA
-- Jerarquia: Direccion -> Ciudad -> Region -> Pais
-- Dimension de rol: ubicacion siniestro / asegurado / productor
-- ============================================
CREATE TABLE DIM_GEOGRAFIA (
    id_geografia    INT             NOT NULL,
    direccion       VARCHAR(200)            ,
    ciudad          VARCHAR(100)    NOT NULL,
    region          VARCHAR(100)    NOT NULL,
    pais            VARCHAR(100)    NOT NULL,
    codigo_postal   VARCHAR(20)             ,
    CONSTRAINT PK_DIM_GEOGRAFIA PRIMARY KEY (id_geografia)
);
GO
 
-- ============================================
-- 3. DIM_POLIZA
-- Jerarquia: Poliza -> Tipo_Poliza -> Ramo
-- ============================================
CREATE TABLE DIM_POLIZA (
    id_poliza       INT             NOT NULL,
    nro_poliza      VARCHAR(20)     NOT NULL,
    tipo_poliza     VARCHAR(50)     NOT NULL,
    cobertura       VARCHAR(100)            ,
    ramo            VARCHAR(50)             ,
    limite_poliza   DECIMAL(15,2)           ,
    CONSTRAINT PK_DIM_POLIZA PRIMARY KEY (id_poliza)
);
GO
 
-- ============================================
-- 4. DIM_ASEGURADO
-- Jerarquia: Asegurado -> Tipo_Cliente
-- ============================================
CREATE TABLE DIM_ASEGURADO (
    id_asegurado        INT             NOT NULL,
    nro_asegurado       VARCHAR(20)     NOT NULL,
    edad                INT                     ,
    genero              CHAR(1)                 ,
    tipo_cliente        VARCHAR(50)             ,
    fecha_nacimiento    DATE                    ,
    CONSTRAINT PK_DIM_ASEGURADO PRIMARY KEY (id_asegurado)
);
GO
 
-- ============================================
-- 5. DIM_TIPO_SINIESTRO
-- Jerarquia: Causa -> Tipo -> Clasificacion
-- ============================================
CREATE TABLE DIM_TIPO_SINIESTRO (
    id_tipo_siniestro   INT             NOT NULL,
    tipo                VARCHAR(50)     NOT NULL,
    clasificacion       VARCHAR(50)             ,
    causa               VARCHAR(100)            ,
    descripcion         VARCHAR(200)            ,
    CONSTRAINT PK_DIM_TIPO_SINIESTRO PRIMARY KEY (id_tipo_siniestro)
);
GO
 
-- ============================================
-- 6. DIM_MONEDA
-- ============================================
CREATE TABLE DIM_MONEDA (
    id_moneda       INT             NOT NULL,
    codigo          CHAR(3)         NOT NULL,
    descripcion     VARCHAR(50)     NOT NULL,
    CONSTRAINT PK_DIM_MONEDA PRIMARY KEY (id_moneda)
);
GO
 
-- ============================================
-- 7. FCT_SINIESTROS
-- Granularidad: una fila por siniestro reportado
-- ============================================
CREATE TABLE FCT_SINIESTROS (
    id_siniestro            INT             NOT NULL,
    nro_siniestro           VARCHAR(20)     NOT NULL,
    id_tiempo_ocurrencia    INT             NOT NULL,
    id_tiempo_denuncia      INT             NOT NULL,
    id_geo_siniestro        INT             NOT NULL,
    id_geo_asegurado        INT             NOT NULL,
    id_geo_productor        INT             NOT NULL,
    id_poliza               INT             NOT NULL,
    id_asegurado            INT             NOT NULL,
    id_tipo_siniestro       INT             NOT NULL,
    id_moneda               INT             NOT NULL,
    monto_reclamacion       DECIMAL(15,2)   NOT NULL,
    importe_pagado          DECIMAL(15,2)   NOT NULL,
    monto_rechazado         AS (monto_reclamacion - importe_pagado),
    descripcion_evento      VARCHAR(500)            ,
    CONSTRAINT PK_FCT_SINIESTROS        PRIMARY KEY (id_siniestro),
    CONSTRAINT FK_SIN_TIEMPO_OCU        FOREIGN KEY (id_tiempo_ocurrencia)  REFERENCES DIM_TIEMPO(id_tiempo),
    CONSTRAINT FK_SIN_TIEMPO_DEN        FOREIGN KEY (id_tiempo_denuncia)    REFERENCES DIM_TIEMPO(id_tiempo),
    CONSTRAINT FK_SIN_GEO_SIN           FOREIGN KEY (id_geo_siniestro)      REFERENCES DIM_GEOGRAFIA(id_geografia),
    CONSTRAINT FK_SIN_GEO_ASE           FOREIGN KEY (id_geo_asegurado)      REFERENCES DIM_GEOGRAFIA(id_geografia),
    CONSTRAINT FK_SIN_GEO_PRO           FOREIGN KEY (id_geo_productor)      REFERENCES DIM_GEOGRAFIA(id_geografia),
    CONSTRAINT FK_SIN_POLIZA            FOREIGN KEY (id_poliza)             REFERENCES DIM_POLIZA(id_poliza),
    CONSTRAINT FK_SIN_ASEGURADO         FOREIGN KEY (id_asegurado)          REFERENCES DIM_ASEGURADO(id_asegurado),
    CONSTRAINT FK_SIN_TIPO              FOREIGN KEY (id_tipo_siniestro)     REFERENCES DIM_TIPO_SINIESTRO(id_tipo_siniestro),
    CONSTRAINT FK_SIN_MONEDA            FOREIGN KEY (id_moneda)             REFERENCES DIM_MONEDA(id_moneda)
);
GO