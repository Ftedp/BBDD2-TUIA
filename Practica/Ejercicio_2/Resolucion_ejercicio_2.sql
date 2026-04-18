CREATE DATABASE DW_Herfor

CREATE TABLE dTiempo (
    Fecha           date        NOT NULL PRIMARY KEY,
    Dia             int         NOT NULL,
    NombreDiaSemana varchar(20) NOT NULL,
    DiaSemana       int         NOT NULL,
    Quincena        int         NOT NULL,
    Semana          int         NOT NULL,
    NombreMes       varchar(20) NOT NULL,
    Mes             int         NOT NULL,
    Trimestre       int         NOT NULL,
    Semestre        int         NOT NULL,
    Anio            int         NOT NULL
)

CREATE TABLE dAsegurado (
    ID_Asegurado        int          NOT NULL PRIMARY KEY IDENTITY(1,1),
    Cod_Sist_Origen     varchar(10)  NOT NULL,
    ID_Asegurado_Origen varchar(100) NOT NULL,
    FechaVigencia       datetime2(6) NOT NULL,
    NombreAsegurado     varchar(100) NOT NULL,
    ApellidoAsegurado   varchar(100) NOT NULL,
    NroDocumento        varchar(20)  NOT NULL,
    Direccion           varchar(200) NOT NULL,
    Localidad           varchar(100) NOT NULL,
    Provincia           varchar(100) NOT NULL,
    Email               varchar(100) NULL,
    Telefono            varchar(20)  NULL
)

CREATE TABLE dProducto (
	ID_Producto			int          NOT NULL PRIMARY KEY IDENTITY(1,1), 
	Cod_Sist_Origen     varchar(10)  NOT NULL,
	ID_Producto_Origen  varchar(100) NOT NULL,
	FechaVigencia       datetime2(6) NOT NULL,
	CodigoProducto      varchar(20)  NOT NULL,
	Ramo			    varchar(100) NOT NULL,
	TipoSeguro          varchar(100) NOT NULL,
	Descripcion         varchar(100) NOT NULL
)

CREATE TABLE dSucursal (
	ID_Sucursal			int          NOT NULL PRIMARY KEY IDENTITY(1,1),
	Cod_Sist_Origen     varchar(10)  NOT NULL,
	ID_Sucursal_Origen  varchar(100) NOT NULL,
	FechaVigencia       datetime2(6) NOT NULL,
	NombreSucursal      varchar(100) NOT NULL,
	Direccion			varchar(100) NOT NULL,
	Localidad			varchar(100) NOT NULL,
	Provincia			varchar(100) NOT NULL,
	Pais				varchar(100) NOT NULL,
	Telefono			varchar(100) NOT NULL
)

CREATE TABLE hCobranza (
    ID_Cobranza         int          NOT NULL PRIMARY KEY IDENTITY(1,1),
    Cod_Sist_Origen     varchar(10)  NOT NULL,
    ID_Cobranza_Origen  varchar(100) NOT NULL,
    FechaTransaccion    datetime2(6) NOT NULL,
    Fecha               date         NOT NULL,
    ID_Asegurado_Origen int NOT NULL,
    ID_Producto_Origen  int NOT NULL,
    ID_Sucursal_Origen  int NOT NULL,
    MontoTotal_Moneda   money        NOT NULL,
    MontoTotal_Dolar    money        NOT NULL,
    Cod_Moneda          varchar(10)  NOT NULL,
    MetodoPago          varchar(20)  NOT NULL,
    PlazoPago           varchar(20)  NOT NULL,

    FOREIGN KEY (Fecha) REFERENCES dTiempo(Fecha),
	FOREIGN KEY (ID_Asegurado_Origen) REFERENCES dAsegurado(ID_Asegurado),
	FOREIGN KEY (ID_Producto_Origen) REFERENCES dProducto(ID_Producto),
	FOREIGN KEY (ID_Sucursal_Origen) REFERENCES dSucursal(ID_Sucursal)
)