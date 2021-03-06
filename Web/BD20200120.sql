USE [VENDIX]
GO
/****** Object:  Schema [ALMACEN]    Script Date: 20/01/2020 14:53:57 ******/
CREATE SCHEMA [ALMACEN]
GO
/****** Object:  Schema [CREDITO]    Script Date: 20/01/2020 14:53:57 ******/
CREATE SCHEMA [CREDITO]
GO
/****** Object:  Schema [MAESTRO]    Script Date: 20/01/2020 14:53:57 ******/
CREATE SCHEMA [MAESTRO]
GO
/****** Object:  Schema [VENTAS]    Script Date: 20/01/2020 14:53:57 ******/
CREATE SCHEMA [VENTAS]
GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[Split] ( @stringToSplit VARCHAR(MAX), @Separador VARCHAR(3)=',')
RETURNS
 @returnList TABLE ([Name] [nvarchar] (500))
AS
BEGIN

 DECLARE @name NVARCHAR(255)
 DECLARE @pos INT

 WHILE CHARINDEX(@Separador, @stringToSplit) > 0
 BEGIN
  SELECT @pos  = CHARINDEX(@Separador, @stringToSplit)  
  SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

  INSERT INTO @returnList 
  SELECT @name

  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
 END

 INSERT INTO @returnList
 SELECT @stringToSplit

 RETURN 
END

-- select * from dbo.Split('Chennai-Bangalore-Mumbai','-')

GO
/****** Object:  UserDefinedFunction [dbo].[ufnCalcularDiasAtrazo]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*SELECT dbo.ufnCalcularDiasAtrazo('20140210')*/
CREATE FUNCTION [dbo].[ufnCalcularDiasAtrazo]
    (
      @FechaVencimiento DATE ,
      @FechaHoy DATE 
    )
RETURNS INTEGER
AS 
    BEGIN
    
        DECLARE @dia_sem INT ,
            @domingos INT ,
            @fecha DATE ,
            @diasAtrazo INT= 0
    
        SET @fecha = @FechaVencimiento
        SET @domingos = 0
        WHILE @fecha <= @FechaHoy 
            BEGIN   
                SELECT  @dia_sem = DATEPART(weekday, @fecha) 
                IF @dia_sem = 1 
                    SET @domingos = @domingos + 1    
                SELECT  @fecha = DATEADD(dd, 1, @fecha)     
            END
        SET @diasAtrazo = DATEDIFF(DAY, @FechaVencimiento, @FechaHoy) - @domingos
        IF @diasAtrazo < 0 
            SET @diasAtrazo = 0
        
        RETURN @diasAtrazo
    END
 
 
GO
/****** Object:  UserDefinedFunction [dbo].[ufnCalcularMora]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
SELECT dbo.ufnCalcularMora(7,5)
*/

CREATE FUNCTION [dbo].[ufnCalcularMora] ( @ImporteMoratorio DECIMAL(16,4) , @DiasAtrazo INT, @DiasGracia INT)
RETURNS DECIMAL(16,2)
AS 
    BEGIN
	    IF @DiasAtrazo <=0
			RETURN 0
        IF @DiasAtrazo <=@DiasGracia
			RETURN 0
        
		RETURN @ImporteMoratorio * @DiasAtrazo
    END
GO
/****** Object:  UserDefinedFunction [dbo].[ufnListarSerie]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT dbo.ufnListarSerie(111111)
CREATE FUNCTION [dbo].[ufnListarSerie] ( @OrdenVentaId INT)
RETURNS VARCHAR(MAX)
AS 
    BEGIN
	    RETURN	LTRIM(ISNULL(
					STUFF(
						(SELECT ', ' + rtrim(convert(char(15),NumeroSerie))
							FROM VENTAS.OrdenVentaDet OVD
							INNER JOIN VENTAS.OrdenVentaDetSerie OVS ON OVD.OrdenVentaDetId = OVS.OrdenVentaDetId
							INNER JOIN ALMACEN.SerieArticulo SA ON OVS.SerieArticuloId = SA.SerieArticuloId
							WHERE OVD.OrdenVentaId = @OrdenVentaId
							FOR XML PATH(''))
						,1,1,'')
					,'')) 
    END
    
GO
/****** Object:  Table [ALMACEN].[Almacen]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMACEN].[Almacen](
	[AlmacenId] [int] IDENTITY(1,1) NOT NULL,
	[OficinaId] [int] NULL,
	[Denominacion] [varchar](100) NULL,
	[Descripcion] [varchar](250) NULL,
	[IndEstadoApertura] [bit] NULL,
	[FechaApertura] [datetime] NULL,
	[Estado] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AlmacenId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ALMACEN].[Articulo]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMACEN].[Articulo](
	[ArticuloId] [int] IDENTITY(1,1) NOT NULL,
	[ModeloId] [int] NULL,
	[TipoArticuloId] [int] NULL,
	[CodArticulo] [varchar](20) NULL,
	[Denominacion] [varchar](200) NULL,
	[Descripcion] [varchar](250) NULL,
	[Imagen] [varchar](max) NULL,
	[IndPerecible] [bit] NULL,
	[IndImportado] [bit] NULL,
	[IndCanjeable] [bit] NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK__Articulo__C0D725ED1C880743] PRIMARY KEY CLUSTERED 
(
	[ArticuloId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [ALMACEN].[Marca]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMACEN].[Marca](
	[MarcaId] [int] IDENTITY(1,1) NOT NULL,
	[Denominacion] [varchar](100) NULL,
	[Estado] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MarcaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ALMACEN].[Modelo]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMACEN].[Modelo](
	[ModeloId] [int] IDENTITY(1,1) NOT NULL,
	[Denominacion] [varchar](70) NULL,
	[MarcaId] [int] NULL,
	[Estado] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ModeloId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ALMACEN].[Movimiento]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMACEN].[Movimiento](
	[MovimientoId] [int] IDENTITY(1,1) NOT NULL,
	[TipoMovimientoId] [int] NOT NULL,
	[AlmacenId] [int] NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[SubTotal] [decimal](16, 2) NOT NULL,
	[IGV] [decimal](16, 2) NOT NULL,
	[AjusteRedondeo] [decimal](16, 2) NOT NULL,
	[TotalImporte] [decimal](16, 2) NOT NULL,
	[EstadoId] [int] NOT NULL,
	[Observacion] [varchar](500) NULL,
	[Documento] [varchar](50) NULL,
 CONSTRAINT [PK__Movimien__BF923C2C3C00B29C] PRIMARY KEY CLUSTERED 
(
	[MovimientoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ALMACEN].[MovimientoDet]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMACEN].[MovimientoDet](
	[MovimientoDetId] [int] IDENTITY(1,1) NOT NULL,
	[MovimientoId] [int] NOT NULL,
	[ArticuloId] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[Descripcion] [varchar](max) NULL,
	[PrecioUnitario] [decimal](16, 2) NOT NULL,
	[Descuento] [decimal](16, 2) NOT NULL,
	[Importe] [decimal](16, 2) NOT NULL,
	[IndCorrelativo] [bit] NOT NULL,
	[UnidadMedidaT10] [int] NULL,
 CONSTRAINT [PK__Movimien__C5252D9B41B98BF2] PRIMARY KEY CLUSTERED 
(
	[MovimientoDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [ALMACEN].[MovimientoDoc]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMACEN].[MovimientoDoc](
	[MovimientoDocId] [int] IDENTITY(1,1) NOT NULL,
	[MovimientoId] [int] NULL,
	[TipoDocumentoId] [int] NULL,
	[SerieDocumento] [varchar](12) NULL,
	[NroDocumento] [varchar](12) NULL,
	[RemitenteId] [int] NULL,
	[DestinatarioId] [int] NULL,
	[DestinoRef] [varchar](150) NULL,
PRIMARY KEY CLUSTERED 
(
	[MovimientoDocId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ALMACEN].[SerieArticulo]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMACEN].[SerieArticulo](
	[SerieArticuloId] [int] IDENTITY(1,1) NOT NULL,
	[NumeroSerie] [varchar](20) NOT NULL,
	[AlmacenId] [int] NOT NULL,
	[ArticuloId] [int] NOT NULL,
	[EstadoId] [int] NOT NULL,
	[MovimientoDetEntId] [int] NULL,
	[MovimientoDetSalId] [int] NULL,
 CONSTRAINT [PK__SerieArt__A6750CD55F49EED9] PRIMARY KEY CLUSTERED 
(
	[SerieArticuloId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ALMACEN].[TipoArticulo]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMACEN].[TipoArticulo](
	[TipoArticuloId] [int] IDENTITY(1,1) NOT NULL,
	[Denominacion] [varchar](100) NULL,
	[Descripcion] [varchar](250) NULL,
	[IndTieneCodigo] [bit] NULL,
	[Estado] [bit] NOT NULL,
	[IndMovimientoAlmacen] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[TipoArticuloId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ALMACEN].[TipoMovimiento]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ALMACEN].[TipoMovimiento](
	[TipoMovimientoId] [int] IDENTITY(1,1) NOT NULL,
	[Denominacion] [varchar](70) NULL,
	[Descripcion] [varchar](250) NULL,
	[IndEntrada] [bit] NOT NULL,
	[IndTransferencia] [bit] NULL,
	[IndDevolucion] [bit] NULL,
	[Estado] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TipoMovimientoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[Aprobacion]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[Aprobacion](
	[CreditoId] [int] NOT NULL,
	[Nivel] [int] NOT NULL,
	[UsuarioId] [int] NULL,
	[Fecha] [datetime] NULL,
 CONSTRAINT [PK__CreditoE__4FE406DDCF29B870] PRIMARY KEY CLUSTERED 
(
	[CreditoId] ASC,
	[Nivel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[Boveda]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[Boveda](
	[BovedaId] [int] IDENTITY(1,1) NOT NULL,
	[OficinaId] [int] NOT NULL,
	[SaldoInicial] [decimal](16, 2) NOT NULL,
	[Entradas] [decimal](16, 2) NOT NULL,
	[Salidas] [decimal](16, 2) NOT NULL,
	[SaldoFinal] [decimal](16, 2) NOT NULL,
	[FechaIniOperacion] [datetime] NOT NULL,
	[FechaFinOperacion] [datetime] NULL,
	[IndCierre] [bit] NOT NULL,
 CONSTRAINT [PK__Boveda__A7FEF717027E1C7D] PRIMARY KEY CLUSTERED 
(
	[BovedaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[BovedaMov]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[BovedaMov](
	[MovimientoBovedaId] [int] IDENTITY(1,1) NOT NULL,
	[BovedaId] [int] NOT NULL,
	[CodOperacion] [char](3) NOT NULL,
	[Glosa] [varchar](max) NULL,
	[Importe] [decimal](16, 2) NOT NULL,
	[IndEntrada] [bit] NOT NULL,
	[Estado] [bit] NOT NULL,
	[CajaDiarioId] [int] NULL,
	[UsuarioRegId] [int] NOT NULL,
	[FechaReg] [datetime] NOT NULL,
 CONSTRAINT [PK_MovimientoBoveda] PRIMARY KEY CLUSTERED 
(
	[MovimientoBovedaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[BovedaMovTemp]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[BovedaMovTemp](
	[BovedaMovTempId] [int] IDENTITY(1,1) NOT NULL,
	[BovedaInicioId] [int] NOT NULL,
	[BovedaDestinoId] [int] NOT NULL,
	[CodOperacion] [char](3) NOT NULL,
	[Glosa] [varchar](max) NULL,
	[Importe] [decimal](16, 2) NOT NULL,
	[UsuarioRegId] [int] NOT NULL,
	[MovimientoBovedaIniId] [int] NOT NULL,
	[FechaReg] [datetime] NOT NULL,
	[IndEntrada] [bit] NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK__BovedaMo__C04A9CF60154EE1A] PRIMARY KEY CLUSTERED 
(
	[BovedaMovTempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[Caja]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[Caja](
	[CajaId] [int] IDENTITY(1,1) NOT NULL,
	[OficinaId] [int] NOT NULL,
	[Denominacion] [varchar](100) NOT NULL,
	[Estado] [bit] NOT NULL,
	[UsuarioRegId] [int] NOT NULL,
	[FechaReg] [datetime] NOT NULL,
	[IndAbierto] [bit] NOT NULL,
	[UsuarioModId] [int] NULL,
	[FechaMod] [datetime] NULL,
 CONSTRAINT [PK__Caja__A74F87070742D19A] PRIMARY KEY CLUSTERED 
(
	[CajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[CajaDiario]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[CajaDiario](
	[CajaDiarioId] [int] IDENTITY(1,1) NOT NULL,
	[CajaId] [int] NOT NULL,
	[UsuarioAsignadoId] [int] NOT NULL,
	[SaldoInicial] [decimal](16, 2) NOT NULL,
	[Entradas] [decimal](16, 2) NOT NULL,
	[Salidas] [decimal](16, 2) NOT NULL,
	[SaldoFinal] [decimal](16, 2) NOT NULL,
	[FechaIniOperacion] [datetime] NOT NULL,
	[FechaFinOperacion] [datetime] NULL,
	[IndCierre] [bit] NOT NULL,
	[TransBoveda] [bit] NOT NULL,
 CONSTRAINT [PK__CajaDiar__A7FC1B240C0786B7] PRIMARY KEY CLUSTERED 
(
	[CajaDiarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[Cargo]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[Cargo](
	[CargoId] [int] IDENTITY(1,1) NOT NULL,
	[CreditoId] [int] NOT NULL,
	[NumCuota] [int] NOT NULL,
	[TipoCargoT2] [int] NOT NULL,
	[Importe] [decimal](16, 2) NOT NULL,
	[Descripcion] [varchar](max) NOT NULL,
	[Estado] [char](3) NOT NULL,
	[UsuarioId] [int] NOT NULL,
	[Fecha] [datetime] NOT NULL,
 CONSTRAINT [PK__Cargo__B4E665CD0EAEE938] PRIMARY KEY CLUSTERED 
(
	[CargoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[Credito]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[Credito](
	[CreditoId] [int] IDENTITY(1,1) NOT NULL,
	[PersonaId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Descripcion] [varchar](max) NOT NULL,
	[MontoProducto] [decimal](16, 2) NOT NULL,
	[MontoInicial] [decimal](16, 2) NOT NULL,
	[MontoCredito] [decimal](16, 2) NOT NULL,
	[MontoGastosAdm] [decimal](16, 2) NOT NULL,
	[MontoDesembolso] [decimal](16, 2) NOT NULL,
	[TipoGastoAdm] [char](3) NOT NULL,
	[FormaPago] [char](1) NOT NULL,
	[NumeroCuotas] [int] NOT NULL,
	[Interes] [decimal](4, 2) NOT NULL,
	[FechaPrimerPago] [date] NOT NULL,
	[FechaAprobacion] [datetime] NULL,
	[FechaDesembolso] [datetime] NULL,
	[Observacion] [varchar](max) NULL,
	[Estado] [char](3) NOT NULL,
	[FechaReg] [datetime] NOT NULL,
	[UsuarioRegId] [int] NOT NULL,
	[FechaMod] [datetime] NULL,
	[UsuarioModId] [int] NULL,
	[OficinaId] [int] NOT NULL,
	[FechaVencimiento] [date] NOT NULL,
	[OrdenVentaId] [int] NULL,
	[TipoCuota] [char](1) NOT NULL,
 CONSTRAINT [PK__Credito__4FE406DD6FA05233] PRIMARY KEY CLUSTERED 
(
	[CreditoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[CuentaxCobrar]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[CuentaxCobrar](
	[CuentaxCobrarId] [int] IDENTITY(1,1) NOT NULL,
	[Operacion] [char](3) NOT NULL,
	[Monto] [decimal](16, 2) NOT NULL,
	[Estado] [char](3) NOT NULL,
	[MovimientoCajaId] [int] NULL,
	[CreditoId] [int] NULL,
 CONSTRAINT [PK__Cuentasx__D5EF24B3377BF4A1] PRIMARY KEY CLUSTERED 
(
	[CuentaxCobrarId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[GastosAdm]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[GastosAdm](
	[GastosAdmId] [int] IDENTITY(1,1) NOT NULL,
	[Denominacion] [varchar](50) NOT NULL,
	[MontoMinimo] [decimal](16, 2) NOT NULL,
	[MontoMaximo] [decimal](16, 2) NOT NULL,
	[IndPorcentaje] [bit] NOT NULL,
	[Valor] [decimal](16, 2) NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK__GastosAd__B499EA5B2962DF74] PRIMARY KEY CLUSTERED 
(
	[GastosAdmId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[MovimientoCaja]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[MovimientoCaja](
	[MovimientoCajaId] [int] IDENTITY(1,1) NOT NULL,
	[CajaDiarioId] [int] NOT NULL,
	[Operacion] [char](3) NOT NULL,
	[ImportePago] [decimal](16, 2) NOT NULL,
	[ImporteRecibido] [decimal](16, 2) NOT NULL,
	[MontoVuelto] [decimal](16, 2) NOT NULL,
	[PersonaId] [int] NULL,
	[Descripcion] [varchar](max) NULL,
	[IndEntrada] [bit] NOT NULL,
	[Estado] [bit] NOT NULL,
	[UsuarioRegId] [int] NOT NULL,
	[FechaReg] [datetime] NOT NULL,
	[OrdenVentaId] [int] NULL,
	[CreditoId] [int] NULL,
 CONSTRAINT [PK__Movimien__266F555F11C0600D] PRIMARY KEY CLUSTERED 
(
	[MovimientoCajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[MovimientoCajaAnu]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[MovimientoCajaAnu](
	[MovimientoCajaAnuId] [int] IDENTITY(1,1) NOT NULL,
	[MovimientoCajaId] [int] NULL,
	[Observacion] [varchar](max) NULL,
	[UsuarioRegId] [int] NULL,
	[FechaReg] [datetime] NULL,
 CONSTRAINT [PK__Movimien__E2AB2E7E4FBD9286] PRIMARY KEY CLUSTERED 
(
	[MovimientoCajaAnuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[PlanPago]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[PlanPago](
	[PlanPagoId] [int] IDENTITY(1,1) NOT NULL,
	[CreditoId] [int] NOT NULL,
	[Numero] [int] NOT NULL,
	[Capital] [decimal](16, 2) NOT NULL,
	[FechaVencimiento] [date] NOT NULL,
	[Amortizacion] [decimal](16, 2) NOT NULL,
	[Interes] [decimal](16, 2) NOT NULL,
	[GastosAdm] [decimal](16, 2) NOT NULL,
	[Cuota] [decimal](16, 2) NOT NULL,
	[Estado] [char](3) NOT NULL,
	[DiasAtrazo] [int] NOT NULL,
	[ImporteMora] [decimal](16, 2) NOT NULL,
	[InteresMora] [decimal](16, 2) NOT NULL,
	[PagoCuota] [decimal](16, 2) NULL,
	[FechaPagoCuota] [datetime] NULL,
	[MovimientoCajaId] [int] NULL,
	[UsuarioModId] [int] NULL,
	[FechaMod] [datetime] NULL,
	[PagoLibre] [decimal](16, 2) NOT NULL,
	[Cargo] [decimal](16, 2) NOT NULL,
 CONSTRAINT [PK__PlanPago__D534AF6F7370E317] PRIMARY KEY CLUSTERED 
(
	[PlanPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[PlanPagoLibre]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[PlanPagoLibre](
	[PlanPagoId] [int] NULL,
	[MovimientoCajaId] [int] NULL,
	[PagoLibre] [decimal](16, 2) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [CREDITO].[Producto]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CREDITO].[Producto](
	[ProductoId] [int] IDENTITY(1,1) NOT NULL,
	[Denominacion] [varchar](255) NOT NULL,
	[InteresMinima] [decimal](16, 2) NOT NULL,
	[InteresMaxima] [decimal](16, 2) NOT NULL,
	[DiasGracia] [int] NOT NULL,
	[ImporteMoratorio] [decimal](8, 3) NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK__Producto__A430AEA325924E90] PRIMARY KEY CLUSTERED 
(
	[ProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MAESTRO].[Cliente]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MAESTRO].[Cliente](
	[ClienteId] [int] IDENTITY(1,1) NOT NULL,
	[PersonaId] [int] NOT NULL,
	[FechaCaptacion] [date] NULL,
	[ActividadEconId] [int] NULL,
	[Calificacion] [char](1) NULL,
	[Inscripcion] [decimal](16, 2) NOT NULL,
	[IndPagoInscripcion] [bit] NOT NULL,
	[FechaRegistro] [datetime] NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK__Cliente__71ABD0877929BC6D] PRIMARY KEY CLUSTERED 
(
	[ClienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MAESTRO].[Menu]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MAESTRO].[Menu](
	[MenuId] [int] IDENTITY(1,1) NOT NULL,
	[Denominacion] [varchar](255) NULL,
	[Modulo] [varchar](255) NULL,
	[Url] [varchar](255) NULL,
	[Icono] [varchar](255) NULL,
	[IndPadre] [bit] NULL,
	[Orden] [decimal](3, 1) NULL,
	[Referencia] [decimal](3, 1) NULL,
 CONSTRAINT [PK__Menu__C99ED2306522C3C0] PRIMARY KEY CLUSTERED 
(
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MAESTRO].[Ocupacion]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MAESTRO].[Ocupacion](
	[OcupacionId] [int] IDENTITY(1,1) NOT NULL,
	[Denominacion] [varchar](200) NULL,
	[Estado] [bit] NULL,
 CONSTRAINT [PK__Ocupacio__77075F7735FDC083] PRIMARY KEY CLUSTERED 
(
	[OcupacionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MAESTRO].[Oficina]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MAESTRO].[Oficina](
	[OficinaId] [int] IDENTITY(1,1) NOT NULL,
	[Denominacion] [varchar](100) NULL,
	[Descripcion] [varchar](250) NULL,
	[Telefono] [varchar](20) NULL,
	[IndPrincipal] [bit] NOT NULL,
	[Estado] [bit] NOT NULL,
	[UsuarioAsignadoId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[OficinaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MAESTRO].[Persona]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MAESTRO].[Persona](
	[PersonaId] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](70) NOT NULL,
	[ApePaterno] [varchar](70) NULL,
	[ApeMaterno] [varchar](70) NULL,
	[NombreCompleto] [varchar](250) NULL,
	[TipoDocumento] [char](3) NOT NULL,
	[NumeroDocumento] [varchar](12) NOT NULL,
	[Sexo] [char](1) NULL,
	[TipoPersona] [char](1) NOT NULL,
	[EmailPersonal] [varchar](100) NULL,
	[FechaNacimiento] [datetime] NULL,
	[Direccion] [varchar](max) NULL,
	[Estado] [bit] NOT NULL,
	[Celular1] [varchar](10) NULL,
	[Celular2] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [MAESTRO].[Rol]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MAESTRO].[Rol](
	[RolId] [int] IDENTITY(1,1) NOT NULL,
	[Denominacion] [varchar](255) NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK__Rol__F92302F1615232DC] PRIMARY KEY CLUSTERED 
(
	[RolId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MAESTRO].[RolMenu]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MAESTRO].[RolMenu](
	[RolMenuId] [int] IDENTITY(1,1) NOT NULL,
	[RolId] [int] NULL,
	[MenuId] [int] NULL,
 CONSTRAINT [PK__RolMenu__8339C1FE68F354A4] PRIMARY KEY CLUSTERED 
(
	[RolMenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MAESTRO].[TipoDocumento]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MAESTRO].[TipoDocumento](
	[TipoDocumentoId] [int] IDENTITY(1,1) NOT NULL,
	[Denominacion] [varchar](100) NULL,
	[Descripcion] [varchar](250) NULL,
	[IndVenta] [bit] NULL,
	[IndAlmacen] [bit] NULL,
	[IndAlmacenMov] [bit] NULL,
	[Estado] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TipoDocumentoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MAESTRO].[TipoOperacion]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MAESTRO].[TipoOperacion](
	[TipoOperacionId] [int] NOT NULL,
	[Codigo] [char](3) NOT NULL,
	[Denominacion] [varchar](50) NOT NULL,
	[IndEntrada] [bit] NOT NULL,
	[IndCajaDiario] [bit] NOT NULL,
 CONSTRAINT [PK__TipoOper__72B493817CFA4D51] PRIMARY KEY CLUSTERED 
(
	[TipoOperacionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MAESTRO].[Usuario]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MAESTRO].[Usuario](
	[UsuarioId] [int] IDENTITY(1,1) NOT NULL,
	[PersonaId] [int] NOT NULL,
	[NombreUsuario] [nvarchar](50) NOT NULL,
	[ClaveUsuario] [nvarchar](50) NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK__Usuario] PRIMARY KEY CLUSTERED 
(
	[UsuarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MAESTRO].[UsuarioOficina]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MAESTRO].[UsuarioOficina](
	[UsuarioOficinaId] [int] IDENTITY(1,1) NOT NULL,
	[UsuarioId] [int] NOT NULL,
	[OficinaId] [int] NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK__UsuarioO__EF670E7473A5ED41] PRIMARY KEY CLUSTERED 
(
	[UsuarioOficinaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MAESTRO].[UsuarioRol]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MAESTRO].[UsuarioRol](
	[UsuarioRolId] [int] IDENTITY(1,1) NOT NULL,
	[UsuarioId] [int] NULL,
	[RolId] [int] NULL,
	[OficinaId] [int] NULL,
 CONSTRAINT [PK__UsuarioR__C869CDCA6EAC2DFA] PRIMARY KEY CLUSTERED 
(
	[UsuarioRolId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MAESTRO].[ValorTabla]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MAESTRO].[ValorTabla](
	[TablaId] [int] NOT NULL,
	[ItemId] [int] NOT NULL,
	[Denominacion] [varchar](70) NULL,
	[DesCorta] [varchar](30) NULL,
	[Valor] [varchar](100) NULL,
 CONSTRAINT [PK_VALORTABLA] PRIMARY KEY CLUSTERED 
(
	[TablaId] ASC,
	[ItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [VENTAS].[ListaPrecio]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [VENTAS].[ListaPrecio](
	[ListaPrecioId] [int] IDENTITY(1,1) NOT NULL,
	[ArticuloId] [int] NULL,
	[Monto] [decimal](16, 2) NULL,
	[Descuento] [decimal](16, 2) NULL,
	[Estado] [bit] NOT NULL,
	[Puntos] [int] NULL,
	[PuntosCanje] [int] NULL,
 CONSTRAINT [PK__ListaPre__44C04A8F5C036DDA] PRIMARY KEY CLUSTERED 
(
	[ListaPrecioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [VENTAS].[OrdenVenta]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [VENTAS].[OrdenVenta](
	[OrdenVentaId] [int] IDENTITY(1,1) NOT NULL,
	[OficinaId] [int] NOT NULL,
	[Subtotal] [decimal](16, 2) NOT NULL,
	[TotalImpuesto] [decimal](16, 2) NOT NULL,
	[TotalNeto] [decimal](16, 2) NOT NULL,
	[TotalDescuento] [decimal](16, 2) NOT NULL,
	[Estado] [char](3) NOT NULL,
	[UsuarioRegId] [int] NOT NULL,
	[FechaReg] [datetime] NOT NULL,
	[UsuarioModId] [int] NULL,
	[FechaMod] [datetime] NULL,
	[PersonaId] [int] NOT NULL,
	[MovimientoAlmacenId] [int] NULL,
	[TipoVenta] [char](3) NOT NULL,
 CONSTRAINT [PK__OrdenVen__16E7FA0661BC4730] PRIMARY KEY CLUSTERED 
(
	[OrdenVentaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [VENTAS].[OrdenVentaDet]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [VENTAS].[OrdenVentaDet](
	[OrdenVentaDetId] [int] IDENTITY(1,1) NOT NULL,
	[OrdenVentaId] [int] NOT NULL,
	[ArticuloId] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[Descripcion] [varchar](max) NOT NULL,
	[ValorVenta] [decimal](16, 4) NOT NULL,
	[Descuento] [decimal](16, 4) NOT NULL,
	[Subtotal] [decimal](16, 4) NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK__OrdenVen__A9F54CD367752086] PRIMARY KEY CLUSTERED 
(
	[OrdenVentaDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [VENTAS].[OrdenVentaDetSerie]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [VENTAS].[OrdenVentaDetSerie](
	[OrdenVentaDetSerieId] [int] IDENTITY(1,1) NOT NULL,
	[OrdenVentaDetId] [int] NULL,
	[SerieArticuloId] [int] NULL,
 CONSTRAINT [PK__OrdenVen__8CB6EF5D06B8C1B5] PRIMARY KEY CLUSTERED 
(
	[OrdenVentaDetSerieId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [VENTAS].[TarjetaPunto]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [VENTAS].[TarjetaPunto](
	[TarjetaPuntoId] [int] IDENTITY(1,1) NOT NULL,
	[PersonaId] [int] NOT NULL,
	[TotalPuntos] [int] NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK__TarjetaP__1D2E93810FA30D71] PRIMARY KEY CLUSTERED 
(
	[TarjetaPuntoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [VENTAS].[TarjetaPuntoDet]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [VENTAS].[TarjetaPuntoDet](
	[TarjetaPuntoDetId] [int] IDENTITY(1,1) NOT NULL,
	[TarjetaPuntoId] [int] NOT NULL,
	[OrdenVentaId] [int] NOT NULL,
	[ValorCanje] [int] NOT NULL,
 CONSTRAINT [PK__TarjetaP__AC9614BF1467C28E] PRIMARY KEY CLUSTERED 
(
	[TarjetaPuntoDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [ALMACEN].[Almacen] ON 
GO
INSERT [ALMACEN].[Almacen] ([AlmacenId], [OficinaId], [Denominacion], [Descripcion], [IndEstadoApertura], [FechaApertura], [Estado]) VALUES (9, 1, N'ALMACEN PRINCIPAL', N'ALMACEN PRINCIPAL', NULL, NULL, 1)
GO
SET IDENTITY_INSERT [ALMACEN].[Almacen] OFF
GO
SET IDENTITY_INSERT [ALMACEN].[Articulo] ON 
GO
INSERT [ALMACEN].[Articulo] ([ArticuloId], [ModeloId], [TipoArticuloId], [CodArticulo], [Denominacion], [Descripcion], [Imagen], [IndPerecible], [IndImportado], [IndCanjeable], [Estado]) VALUES (2359, 1420, 47, N'', N'LAPTOP PAVILIUM MEMORIO 4GB 1TB DISCO', N' ', NULL, 0, 0, 0, 1)
GO
SET IDENTITY_INSERT [ALMACEN].[Articulo] OFF
GO
SET IDENTITY_INSERT [ALMACEN].[Marca] ON 
GO
INSERT [ALMACEN].[Marca] ([MarcaId], [Denominacion], [Estado]) VALUES (996, N'HP', 1)
GO
SET IDENTITY_INSERT [ALMACEN].[Marca] OFF
GO
SET IDENTITY_INSERT [ALMACEN].[Modelo] ON 
GO
INSERT [ALMACEN].[Modelo] ([ModeloId], [Denominacion], [MarcaId], [Estado]) VALUES (1420, N'HP PAVILIUN', 996, 1)
GO
SET IDENTITY_INSERT [ALMACEN].[Modelo] OFF
GO
SET IDENTITY_INSERT [ALMACEN].[Movimiento] ON 
GO
INSERT [ALMACEN].[Movimiento] ([MovimientoId], [TipoMovimientoId], [AlmacenId], [Fecha], [SubTotal], [IGV], [AjusteRedondeo], [TotalImporte], [EstadoId], [Observacion], [Documento]) VALUES (2448, 1, 9, CAST(N'2020-01-18T22:09:14.437' AS DateTime), CAST(6355.93 AS Decimal(16, 2)), CAST(1144.07 AS Decimal(16, 2)), CAST(0.00 AS Decimal(16, 2)), CAST(7500.00 AS Decimal(16, 2)), 2, N'', NULL)
GO
INSERT [ALMACEN].[Movimiento] ([MovimientoId], [TipoMovimientoId], [AlmacenId], [Fecha], [SubTotal], [IGV], [AjusteRedondeo], [TotalImporte], [EstadoId], [Observacion], [Documento]) VALUES (2449, 2, 9, CAST(N'2020-01-18T22:38:15.807' AS DateTime), CAST(6355.93 AS Decimal(16, 2)), CAST(1144.07 AS Decimal(16, 2)), CAST(0.00 AS Decimal(16, 2)), CAST(7500.00 AS Decimal(16, 2)), 3, N'Nro Orden:2191', NULL)
GO
SET IDENTITY_INSERT [ALMACEN].[Movimiento] OFF
GO
SET IDENTITY_INSERT [ALMACEN].[MovimientoDet] ON 
GO
INSERT [ALMACEN].[MovimientoDet] ([MovimientoDetId], [MovimientoId], [ArticuloId], [Cantidad], [Descripcion], [PrecioUnitario], [Descuento], [Importe], [IndCorrelativo], [UnidadMedidaT10]) VALUES (6214, 2448, 2359, 2, N'LAPTOP PAVILIUM MEMORIO 4GB 1TB DISCO100,101', CAST(2500.00 AS Decimal(16, 2)), CAST(0.00 AS Decimal(16, 2)), CAST(5000.00 AS Decimal(16, 2)), 0, 1)
GO
INSERT [ALMACEN].[MovimientoDet] ([MovimientoDetId], [MovimientoId], [ArticuloId], [Cantidad], [Descripcion], [PrecioUnitario], [Descuento], [Importe], [IndCorrelativo], [UnidadMedidaT10]) VALUES (6215, 2448, 2359, 1, N'LAPTOP PAVILIUM MEMORIO 4GB 1TB DISCO102', CAST(2500.00 AS Decimal(16, 2)), CAST(0.00 AS Decimal(16, 2)), CAST(2500.00 AS Decimal(16, 2)), 0, 1)
GO
INSERT [ALMACEN].[MovimientoDet] ([MovimientoDetId], [MovimientoId], [ArticuloId], [Cantidad], [Descripcion], [PrecioUnitario], [Descuento], [Importe], [IndCorrelativo], [UnidadMedidaT10]) VALUES (6216, 2449, 2359, 3, N'LAPTOP PAVILIUM MEMORIO 4GB 1TB DISCO SN: 100,101,102', CAST(2500.00 AS Decimal(16, 2)), CAST(0.00 AS Decimal(16, 2)), CAST(7500.00 AS Decimal(16, 2)), 0, NULL)
GO
SET IDENTITY_INSERT [ALMACEN].[MovimientoDet] OFF
GO
SET IDENTITY_INSERT [ALMACEN].[SerieArticulo] ON 
GO
INSERT [ALMACEN].[SerieArticulo] ([SerieArticuloId], [NumeroSerie], [AlmacenId], [ArticuloId], [EstadoId], [MovimientoDetEntId], [MovimientoDetSalId]) VALUES (19321, N'100', 9, 2359, 4, 6214, 6216)
GO
INSERT [ALMACEN].[SerieArticulo] ([SerieArticuloId], [NumeroSerie], [AlmacenId], [ArticuloId], [EstadoId], [MovimientoDetEntId], [MovimientoDetSalId]) VALUES (19322, N'101', 9, 2359, 4, 6214, 6216)
GO
INSERT [ALMACEN].[SerieArticulo] ([SerieArticuloId], [NumeroSerie], [AlmacenId], [ArticuloId], [EstadoId], [MovimientoDetEntId], [MovimientoDetSalId]) VALUES (19323, N'102', 9, 2359, 4, 6215, 6216)
GO
SET IDENTITY_INSERT [ALMACEN].[SerieArticulo] OFF
GO
SET IDENTITY_INSERT [ALMACEN].[TipoArticulo] ON 
GO
INSERT [ALMACEN].[TipoArticulo] ([TipoArticuloId], [Denominacion], [Descripcion], [IndTieneCodigo], [Estado], [IndMovimientoAlmacen]) VALUES (47, N'LAPTOP', N'LAPTOP', NULL, 1, NULL)
GO
SET IDENTITY_INSERT [ALMACEN].[TipoArticulo] OFF
GO
SET IDENTITY_INSERT [ALMACEN].[TipoMovimiento] ON 
GO
INSERT [ALMACEN].[TipoMovimiento] ([TipoMovimientoId], [Denominacion], [Descripcion], [IndEntrada], [IndTransferencia], [IndDevolucion], [Estado]) VALUES (1, N'COMPRA', N'ENTRADA DE ARTICULOS POR COMPRA', 1, 0, 0, 1)
GO
INSERT [ALMACEN].[TipoMovimiento] ([TipoMovimientoId], [Denominacion], [Descripcion], [IndEntrada], [IndTransferencia], [IndDevolucion], [Estado]) VALUES (2, N'POR VENTA', N'SALIDA DE ARTICULOS POR VENTA', 0, 0, 0, 1)
GO
INSERT [ALMACEN].[TipoMovimiento] ([TipoMovimientoId], [Denominacion], [Descripcion], [IndEntrada], [IndTransferencia], [IndDevolucion], [Estado]) VALUES (3, N'TRANSFERENCIA (SA)', N'SALIDA DE ARTICULOS POR TRANSFERENCIA', 0, 1, 0, 1)
GO
INSERT [ALMACEN].[TipoMovimiento] ([TipoMovimientoId], [Denominacion], [Descripcion], [IndEntrada], [IndTransferencia], [IndDevolucion], [Estado]) VALUES (4, N'DEVOLUCION A PROVEEDOR', N'SALIDA DE ARTÍCULOS POR DEVOLUCIÓN A PROVEEDOR', 0, 0, 1, 1)
GO
INSERT [ALMACEN].[TipoMovimiento] ([TipoMovimientoId], [Denominacion], [Descripcion], [IndEntrada], [IndTransferencia], [IndDevolucion], [Estado]) VALUES (5, N'TRANSFERENCIA (EN)', N'ENTRADA DE ARTÍCULOS POR TRANSFERENCIA', 1, 1, 0, 1)
GO
INSERT [ALMACEN].[TipoMovimiento] ([TipoMovimientoId], [Denominacion], [Descripcion], [IndEntrada], [IndTransferencia], [IndDevolucion], [Estado]) VALUES (6, N'DEVOLUCIÓN DE CLIENTE', N'ENTRADA DE ARTÍCULOS POR DEVOLUCIÓN DE CLIENTE', 1, 0, 1, 1)
GO
INSERT [ALMACEN].[TipoMovimiento] ([TipoMovimientoId], [Denominacion], [Descripcion], [IndEntrada], [IndTransferencia], [IndDevolucion], [Estado]) VALUES (7, N'POR PÉRDIDA', N'SALIDA DE ARTÍCULOS POR PÉRDIDA', 0, 0, 0, 1)
GO
INSERT [ALMACEN].[TipoMovimiento] ([TipoMovimientoId], [Denominacion], [Descripcion], [IndEntrada], [IndTransferencia], [IndDevolucion], [Estado]) VALUES (8, N'ENTRADA AJUSTE INVENTARIO', N'ENTRADA POR AJUSTE DE INVENTARIO', 1, 0, 0, 1)
GO
INSERT [ALMACEN].[TipoMovimiento] ([TipoMovimientoId], [Denominacion], [Descripcion], [IndEntrada], [IndTransferencia], [IndDevolucion], [Estado]) VALUES (9, N'SALIDA AJUSTE INVENTARIO', N'SALIDA POR AJUSTE DE INVENTARIO', 0, 0, 0, 1)
GO
SET IDENTITY_INSERT [ALMACEN].[TipoMovimiento] OFF
GO
SET IDENTITY_INSERT [CREDITO].[Boveda] ON 
GO
INSERT [CREDITO].[Boveda] ([BovedaId], [OficinaId], [SaldoInicial], [Entradas], [Salidas], [SaldoFinal], [FechaIniOperacion], [FechaFinOperacion], [IndCierre]) VALUES (1, 1, CAST(50000.00 AS Decimal(16, 2)), CAST(0.00 AS Decimal(16, 2)), CAST(0.00 AS Decimal(16, 2)), CAST(50000.00 AS Decimal(16, 2)), CAST(N'2020-01-20T14:49:16.797' AS DateTime), NULL, 0)
GO
SET IDENTITY_INSERT [CREDITO].[Boveda] OFF
GO
SET IDENTITY_INSERT [CREDITO].[Caja] ON 
GO
INSERT [CREDITO].[Caja] ([CajaId], [OficinaId], [Denominacion], [Estado], [UsuarioRegId], [FechaReg], [IndAbierto], [UsuarioModId], [FechaMod]) VALUES (2, 1, N'CAJA 1', 1, 3, CAST(N'2014-03-18T00:00:00.000' AS DateTime), 0, 3, CAST(N'2020-01-18T22:38:29.710' AS DateTime))
GO
INSERT [CREDITO].[Caja] ([CajaId], [OficinaId], [Denominacion], [Estado], [UsuarioRegId], [FechaReg], [IndAbierto], [UsuarioModId], [FechaMod]) VALUES (3, 1, N'CAJA 2', 1, 3, CAST(N'2015-01-01T00:00:00.000' AS DateTime), 0, 3, CAST(N'2020-01-18T22:36:22.630' AS DateTime))
GO
SET IDENTITY_INSERT [CREDITO].[Caja] OFF
GO
SET IDENTITY_INSERT [CREDITO].[GastosAdm] ON 
GO
INSERT [CREDITO].[GastosAdm] ([GastosAdmId], [Denominacion], [MontoMinimo], [MontoMaximo], [IndPorcentaje], [Valor], [Estado]) VALUES (1, N'GASTO ADMINISTRATIVO', CAST(0.00 AS Decimal(16, 2)), CAST(2000.00 AS Decimal(16, 2)), 1, CAST(2.00 AS Decimal(16, 2)), 1)
GO
INSERT [CREDITO].[GastosAdm] ([GastosAdmId], [Denominacion], [MontoMinimo], [MontoMaximo], [IndPorcentaje], [Valor], [Estado]) VALUES (2, N'GASTO ADMINISTRATIVO', CAST(2001.00 AS Decimal(16, 2)), CAST(9999999.00 AS Decimal(16, 2)), 0, CAST(20.00 AS Decimal(16, 2)), 1)
GO
INSERT [CREDITO].[GastosAdm] ([GastosAdmId], [Denominacion], [MontoMinimo], [MontoMaximo], [IndPorcentaje], [Valor], [Estado]) VALUES (3, N'INFOCORP', CAST(2001.00 AS Decimal(16, 2)), CAST(9999999.00 AS Decimal(16, 2)), 0, CAST(10.00 AS Decimal(16, 2)), 1)
GO
INSERT [CREDITO].[GastosAdm] ([GastosAdmId], [Denominacion], [MontoMinimo], [MontoMaximo], [IndPorcentaje], [Valor], [Estado]) VALUES (4, N'DESGRAVAMEN', CAST(2001.00 AS Decimal(16, 2)), CAST(9999999.00 AS Decimal(16, 2)), 1, CAST(0.70 AS Decimal(16, 2)), 1)
GO
SET IDENTITY_INSERT [CREDITO].[GastosAdm] OFF
GO
SET IDENTITY_INSERT [CREDITO].[Producto] ON 
GO
INSERT [CREDITO].[Producto] ([ProductoId], [Denominacion], [InteresMinima], [InteresMaxima], [DiasGracia], [ImporteMoratorio], [Estado]) VALUES (1, N'CREDI 1', CAST(19.00 AS Decimal(16, 2)), CAST(24.00 AS Decimal(16, 2)), 3, CAST(0.020 AS Decimal(8, 3)), 1)
GO
INSERT [CREDITO].[Producto] ([ProductoId], [Denominacion], [InteresMinima], [InteresMaxima], [DiasGracia], [ImporteMoratorio], [Estado]) VALUES (2, N'CREDI 2', CAST(16.50 AS Decimal(16, 2)), CAST(19.00 AS Decimal(16, 2)), 3, CAST(0.020 AS Decimal(8, 3)), 1)
GO
INSERT [CREDITO].[Producto] ([ProductoId], [Denominacion], [InteresMinima], [InteresMaxima], [DiasGracia], [ImporteMoratorio], [Estado]) VALUES (3, N'CREDI 3', CAST(11.80 AS Decimal(16, 2)), CAST(15.50 AS Decimal(16, 2)), 3, CAST(0.020 AS Decimal(8, 3)), 1)
GO
INSERT [CREDITO].[Producto] ([ProductoId], [Denominacion], [InteresMinima], [InteresMaxima], [DiasGracia], [ImporteMoratorio], [Estado]) VALUES (4, N'CREDI 4', CAST(14.10 AS Decimal(16, 2)), CAST(14.50 AS Decimal(16, 2)), 3, CAST(0.020 AS Decimal(8, 3)), 1)
GO
INSERT [CREDITO].[Producto] ([ProductoId], [Denominacion], [InteresMinima], [InteresMaxima], [DiasGracia], [ImporteMoratorio], [Estado]) VALUES (5, N'CREDI 5', CAST(18.20 AS Decimal(16, 2)), CAST(18.20 AS Decimal(16, 2)), 3, CAST(0.020 AS Decimal(8, 3)), 1)
GO
INSERT [CREDITO].[Producto] ([ProductoId], [Denominacion], [InteresMinima], [InteresMaxima], [DiasGracia], [ImporteMoratorio], [Estado]) VALUES (6, N'CREDI 6', CAST(15.80 AS Decimal(16, 2)), CAST(16.20 AS Decimal(16, 2)), 3, CAST(0.020 AS Decimal(8, 3)), 1)
GO
SET IDENTITY_INSERT [CREDITO].[Producto] OFF
GO
SET IDENTITY_INSERT [MAESTRO].[Menu] ON 
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (1, N'ALMACEN', N'', N'', N'img/icons/packs/fugue/16x16/ui-layered-pane.png', 1, CAST(10.0 AS Decimal(3, 1)), NULL)
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (2, N'ENTRADA', N'ALMACEN', N'Entrada', N'icon-list', 0, CAST(10.1 AS Decimal(3, 1)), CAST(10.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (3, N'KARDEX', N'ALMACEN', N'Kardex', N'icon-list', 0, CAST(10.2 AS Decimal(3, 1)), CAST(10.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (4, N'VENTAS', N'', N'', N'img/icons/packs/fugue/16x16/application-form.png', 1, CAST(20.0 AS Decimal(3, 1)), NULL)
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (5, N'ORDENES DE VENTA', N'VENTAS', N'OrdenVenta/OrdenesVenta', N'icon-list', 0, CAST(20.1 AS Decimal(3, 1)), CAST(20.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (7, N'LISTA DE PRECIO', N'VENTAS', N'ListaPrecio', N'icon-list', 0, CAST(20.3 AS Decimal(3, 1)), CAST(20.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (8, N'REPORTES', N'', N'', N'img/icons/packs/fugue/16x16/chart.png', 1, CAST(30.0 AS Decimal(3, 1)), NULL)
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (9, N'VENTAS', N'REPORTES', N'Reporte/Venta', N'icon-list', 0, CAST(30.2 AS Decimal(3, 1)), CAST(30.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (10, N'ALMACEN', N'REPORTES', N'Reporte/Almacen', N'icon-list', 0, CAST(30.1 AS Decimal(3, 1)), CAST(30.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (11, N'MANTENIMIENTO', N'', N'', N'img/icons/packs/fugue/16x16/table.png', 1, CAST(40.0 AS Decimal(3, 1)), NULL)
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (12, N'OFICINA', N'MANTENIMIENTO', N'Oficina', N'icon-list', 0, CAST(40.1 AS Decimal(3, 1)), CAST(40.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (13, N'ALMACEN', N'MANTENIMIENTO', N'Almacen', N'icon-list', 0, CAST(40.2 AS Decimal(3, 1)), CAST(40.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (14, N'MARCA', N'MANTENIMIENTO', N'Marca', N'icon-list', 0, CAST(40.3 AS Decimal(3, 1)), CAST(40.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (15, N'MODELO', N'MANTENIMIENTO', N'Modelo', N'icon-list', 0, CAST(40.4 AS Decimal(3, 1)), CAST(40.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (16, N'ARTICULO', N'ALMACEN', N'Articulo', N'icon-list', 0, CAST(10.3 AS Decimal(3, 1)), CAST(10.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (17, N'TIPOARTICULO', N'MANTENIMIENTO', N'TipoArticulo', N'icon-list', 0, CAST(40.6 AS Decimal(3, 1)), CAST(40.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (18, N'CLIENTE', N'CREDITO', N'Cliente', N'icon-list', 0, CAST(60.2 AS Decimal(3, 1)), CAST(60.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (19, N'SEGURIDAD', N'', N'', N'img/icons/packs/fugue/16x16/document-horizontal.png', 1, CAST(50.0 AS Decimal(3, 1)), NULL)
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (20, N'USUARIO', N'SEGURIDAD', N'Usuario', N'icon-list', 0, CAST(50.1 AS Decimal(3, 1)), CAST(50.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (21, N'ROL', N'SEGURIDAD', N'Rol', N'icon-list', 0, CAST(50.2 AS Decimal(3, 1)), CAST(50.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (22, N'CONSULTA DE PRECIO', N'VENTAS', N'ListaPrecio/Consulta', N'icon-list', 0, CAST(20.4 AS Decimal(3, 1)), CAST(20.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (23, N'CANJE PUNTOS', N'VENTAS', N'CanjearPuntos', N'icon-list', 0, CAST(20.5 AS Decimal(3, 1)), CAST(20.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (24, N'CREDITO', N'', N'', N'img/icons/packs/fugue/16x16/table.png', 1, CAST(60.0 AS Decimal(3, 1)), NULL)
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (25, N'CREDITOS', N'CREDITO', N'Credito/Creditos', N'icon-list', 0, CAST(60.1 AS Decimal(3, 1)), CAST(60.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (26, N'SIMULADOR', N'CREDITO', N'Credito/Simulador', N'icon-list', 0, CAST(60.5 AS Decimal(3, 1)), CAST(60.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (27, N'CAJA DIARIO', N'CREDITO', N'Credito/CajaDiario', N'icon-list', 0, CAST(60.6 AS Decimal(3, 1)), CAST(60.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (28, N'BOVEDA', N'CREDITO', N'Boveda', N'icon-list', 0, CAST(60.7 AS Decimal(3, 1)), CAST(60.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (29, N'CREDITO', N'REPORTES', N'Reporte/Credito', N'icon-list', 0, CAST(30.3 AS Decimal(3, 1)), CAST(30.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (30, N'SALDOS CAJA', N'CREDITO', N'Saldos', N'icon-list', 0, CAST(60.8 AS Decimal(3, 1)), CAST(60.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (31, N'PARAMETROS SIMULADOR', N'CREDITO', N'Credito/ParametrosSimulador', N'icon-list', 0, CAST(60.4 AS Decimal(3, 1)), CAST(60.0 AS Decimal(3, 1)))
GO
INSERT [MAESTRO].[Menu] ([MenuId], [Denominacion], [Modulo], [Url], [Icono], [IndPadre], [Orden], [Referencia]) VALUES (32, N'CAJA', N'MANTENIMIENTO', N'Caja', N'icon-list', 0, CAST(40.5 AS Decimal(3, 1)), CAST(40.0 AS Decimal(3, 1)))
GO
SET IDENTITY_INSERT [MAESTRO].[Menu] OFF
GO
SET IDENTITY_INSERT [MAESTRO].[Ocupacion] ON 
GO
INSERT [MAESTRO].[Ocupacion] ([OcupacionId], [Denominacion], [Estado]) VALUES (1, N'Empleado', 1)
GO
INSERT [MAESTRO].[Ocupacion] ([OcupacionId], [Denominacion], [Estado]) VALUES (2, N'Administrador', 1)
GO
INSERT [MAESTRO].[Ocupacion] ([OcupacionId], [Denominacion], [Estado]) VALUES (3, N'Estudiante', 1)
GO
SET IDENTITY_INSERT [MAESTRO].[Ocupacion] OFF
GO
SET IDENTITY_INSERT [MAESTRO].[Oficina] ON 
GO
INSERT [MAESTRO].[Oficina] ([OficinaId], [Denominacion], [Descripcion], [Telefono], [IndPrincipal], [Estado], [UsuarioAsignadoId]) VALUES (1, N'OFICINA PRINCIPAL', N'OFICINA PRINCIPAL', N'123', 1, 1, 3)
GO
SET IDENTITY_INSERT [MAESTRO].[Oficina] OFF
GO
SET IDENTITY_INSERT [MAESTRO].[Persona] ON 
GO
INSERT [MAESTRO].[Persona] ([PersonaId], [Nombre], [ApePaterno], [ApeMaterno], [NombreCompleto], [TipoDocumento], [NumeroDocumento], [Sexo], [TipoPersona], [EmailPersonal], [FechaNacimiento], [Direccion], [Estado], [Celular1], [Celular2]) VALUES (1, N'admVendix', N'ADMVENDIX', N'ADMVENDIX', N'ADMVENDIX ADMVENDIX, admVendix', N'DNI', N'41901791', N'M', N'N', N'', NULL, NULL, 1, NULL, NULL)
GO
SET IDENTITY_INSERT [MAESTRO].[Persona] OFF
GO
SET IDENTITY_INSERT [MAESTRO].[Rol] ON 
GO
INSERT [MAESTRO].[Rol] ([RolId], [Denominacion], [Estado]) VALUES (1, N'ADMINISTRADOR', 1)
GO
INSERT [MAESTRO].[Rol] ([RolId], [Denominacion], [Estado]) VALUES (2, N'VENDEDOR', 0)
GO
INSERT [MAESTRO].[Rol] ([RolId], [Denominacion], [Estado]) VALUES (3, N'ALMACEN', 0)
GO
INSERT [MAESTRO].[Rol] ([RolId], [Denominacion], [Estado]) VALUES (4, N'CAJA', 1)
GO
INSERT [MAESTRO].[Rol] ([RolId], [Denominacion], [Estado]) VALUES (5, N'PROMOTOR', 1)
GO
INSERT [MAESTRO].[Rol] ([RolId], [Denominacion], [Estado]) VALUES (6, N'ANALISTA', 1)
GO
INSERT [MAESTRO].[Rol] ([RolId], [Denominacion], [Estado]) VALUES (7, N'APROBADOR 1', 1)
GO
INSERT [MAESTRO].[Rol] ([RolId], [Denominacion], [Estado]) VALUES (8, N'APROBADOR 2', 1)
GO
SET IDENTITY_INSERT [MAESTRO].[Rol] OFF
GO
SET IDENTITY_INSERT [MAESTRO].[RolMenu] ON 
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (136, 2, 10)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (137, 2, 22)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (138, 2, 5)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (139, 2, 18)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (252, 3, 16)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (253, 3, 2)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (254, 3, 3)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (255, 3, 13)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (256, 3, 14)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (257, 3, 15)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (258, 3, 10)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (259, 3, 7)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (268, 4, 27)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (269, 4, 10)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (270, 4, 22)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (271, 4, 5)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (272, 4, 3)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (278, 6, 3)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (279, 6, 18)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (280, 6, 25)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (281, 6, 26)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (282, 6, 29)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (283, 1, 16)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (284, 1, 2)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (285, 1, 3)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (286, 1, 28)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (287, 1, 27)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (288, 1, 18)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (289, 1, 25)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (290, 1, 30)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (291, 1, 26)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (292, 1, 13)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (293, 1, 14)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (294, 1, 15)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (295, 1, 12)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (296, 1, 17)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (297, 1, 10)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (298, 1, 29)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (299, 1, 9)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (300, 1, 21)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (301, 1, 20)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (302, 1, 23)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (303, 1, 22)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (304, 1, 7)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (305, 1, 5)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (306, 1, 31)
GO
INSERT [MAESTRO].[RolMenu] ([RolMenuId], [RolId], [MenuId]) VALUES (307, 1, 32)
GO
SET IDENTITY_INSERT [MAESTRO].[RolMenu] OFF
GO
SET IDENTITY_INSERT [MAESTRO].[TipoDocumento] ON 
GO
INSERT [MAESTRO].[TipoDocumento] ([TipoDocumentoId], [Denominacion], [Descripcion], [IndVenta], [IndAlmacen], [IndAlmacenMov], [Estado]) VALUES (1, N'FACTURA', N'FT', 1, 1, 0, 1)
GO
INSERT [MAESTRO].[TipoDocumento] ([TipoDocumentoId], [Denominacion], [Descripcion], [IndVenta], [IndAlmacen], [IndAlmacenMov], [Estado]) VALUES (2, N'BOLETA DE VENTA', N'BLT', 1, 1, 0, 1)
GO
INSERT [MAESTRO].[TipoDocumento] ([TipoDocumentoId], [Denominacion], [Descripcion], [IndVenta], [IndAlmacen], [IndAlmacenMov], [Estado]) VALUES (3, N'TICKET', N'TK', 1, 0, 0, 1)
GO
INSERT [MAESTRO].[TipoDocumento] ([TipoDocumentoId], [Denominacion], [Descripcion], [IndVenta], [IndAlmacen], [IndAlmacenMov], [Estado]) VALUES (4, N'PROFORMA', N'PF', 1, 0, 0, 1)
GO
INSERT [MAESTRO].[TipoDocumento] ([TipoDocumentoId], [Denominacion], [Descripcion], [IndVenta], [IndAlmacen], [IndAlmacenMov], [Estado]) VALUES (5, N'GUIA DE REMISION', N'G.REM', 0, 1, 0, 1)
GO
INSERT [MAESTRO].[TipoDocumento] ([TipoDocumentoId], [Denominacion], [Descripcion], [IndVenta], [IndAlmacen], [IndAlmacenMov], [Estado]) VALUES (6, N'NOTA ENTRADA', N'NE', 0, 1, 1, 1)
GO
INSERT [MAESTRO].[TipoDocumento] ([TipoDocumentoId], [Denominacion], [Descripcion], [IndVenta], [IndAlmacen], [IndAlmacenMov], [Estado]) VALUES (7, N'NOTA SALIDA', N'NS', 0, 1, 1, 1)
GO
INSERT [MAESTRO].[TipoDocumento] ([TipoDocumentoId], [Denominacion], [Descripcion], [IndVenta], [IndAlmacen], [IndAlmacenMov], [Estado]) VALUES (8, N'NOTA DE CREDITO', N'NC', 1, 0, 0, 1)
GO
SET IDENTITY_INSERT [MAESTRO].[TipoDocumento] OFF
GO
INSERT [MAESTRO].[TipoOperacion] ([TipoOperacionId], [Codigo], [Denominacion], [IndEntrada], [IndCajaDiario]) VALUES (1, N'INS', N'INSCRIPCION SOCIO', 1, 0)
GO
INSERT [MAESTRO].[TipoOperacion] ([TipoOperacionId], [Codigo], [Denominacion], [IndEntrada], [IndCajaDiario]) VALUES (2, N'CON', N'PAGO CONTADO', 1, 0)
GO
INSERT [MAESTRO].[TipoOperacion] ([TipoOperacionId], [Codigo], [Denominacion], [IndEntrada], [IndCajaDiario]) VALUES (3, N'INI', N'PAGO INICIAL', 1, 0)
GO
INSERT [MAESTRO].[TipoOperacion] ([TipoOperacionId], [Codigo], [Denominacion], [IndEntrada], [IndCajaDiario]) VALUES (4, N'CUO', N'PAGO CUOTA', 1, 0)
GO
INSERT [MAESTRO].[TipoOperacion] ([TipoOperacionId], [Codigo], [Denominacion], [IndEntrada], [IndCajaDiario]) VALUES (5, N'CMP', N'POR COMPRA', 0, 1)
GO
INSERT [MAESTRO].[TipoOperacion] ([TipoOperacionId], [Codigo], [Denominacion], [IndEntrada], [IndCajaDiario]) VALUES (6, N'SER', N'PAGO DE SERVICIOS', 0, 1)
GO
INSERT [MAESTRO].[TipoOperacion] ([TipoOperacionId], [Codigo], [Denominacion], [IndEntrada], [IndCajaDiario]) VALUES (7, N'TRS', N'TRANSFERENCIA', 0, 1)
GO
INSERT [MAESTRO].[TipoOperacion] ([TipoOperacionId], [Codigo], [Denominacion], [IndEntrada], [IndCajaDiario]) VALUES (8, N'OTS', N'OTROS', 0, 1)
GO
INSERT [MAESTRO].[TipoOperacion] ([TipoOperacionId], [Codigo], [Denominacion], [IndEntrada], [IndCajaDiario]) VALUES (9, N'AJS', N'AJUSTE CAJA', 0, 1)
GO
INSERT [MAESTRO].[TipoOperacion] ([TipoOperacionId], [Codigo], [Denominacion], [IndEntrada], [IndCajaDiario]) VALUES (10, N'GAD', N'PAGO GASTO ADM', 1, 0)
GO
INSERT [MAESTRO].[TipoOperacion] ([TipoOperacionId], [Codigo], [Denominacion], [IndEntrada], [IndCajaDiario]) VALUES (15, N'TRE', N'TRANSFERENCIA', 1, 1)
GO
INSERT [MAESTRO].[TipoOperacion] ([TipoOperacionId], [Codigo], [Denominacion], [IndEntrada], [IndCajaDiario]) VALUES (20, N'OTE', N'OTROS', 1, 1)
GO
SET IDENTITY_INSERT [MAESTRO].[Usuario] ON 
GO
INSERT [MAESTRO].[Usuario] ([UsuarioId], [PersonaId], [NombreUsuario], [ClaveUsuario], [Estado]) VALUES (3, 1, N'ADMVENDIX', N'admvendix', 1)
GO
SET IDENTITY_INSERT [MAESTRO].[Usuario] OFF
GO
SET IDENTITY_INSERT [MAESTRO].[UsuarioOficina] ON 
GO
INSERT [MAESTRO].[UsuarioOficina] ([UsuarioOficinaId], [UsuarioId], [OficinaId], [Estado]) VALUES (8, 3, 1, 1)
GO
SET IDENTITY_INSERT [MAESTRO].[UsuarioOficina] OFF
GO
SET IDENTITY_INSERT [MAESTRO].[UsuarioRol] ON 
GO
INSERT [MAESTRO].[UsuarioRol] ([UsuarioRolId], [UsuarioId], [RolId], [OficinaId]) VALUES (1165, 3, 1, 1)
GO
INSERT [MAESTRO].[UsuarioRol] ([UsuarioRolId], [UsuarioId], [RolId], [OficinaId]) VALUES (1166, 3, 4, 1)
GO
INSERT [MAESTRO].[UsuarioRol] ([UsuarioRolId], [UsuarioId], [RolId], [OficinaId]) VALUES (1167, 3, 7, 1)
GO
SET IDENTITY_INSERT [MAESTRO].[UsuarioRol] OFF
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (1, 0, N'CREDITO GASTOS', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (1, 1, N'Gasto Administrativo', N'GA', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (1, 2, N'INFOCORP', N'INF', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (1, 3, N'Desgravamen', N'DESGR', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (2, 0, N'TIPO CARGO COMISION', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (2, 1, N'Notificacion cobranza', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (2, 2, N'Notificacion Judicial', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (2, 3, N'Cobro Telefonico', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (2, 4, N'Copias', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (2, 5, N'Movilidad', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (2, 9, N'Otros', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (3, 0, N'--SIMULADOR CREDITO--', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (3, 1, N'--SIMULADOR CREDITO--', N'V', N'5')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (3, 2, N'--SIMULADOR CREDITO--', N'F', N'1.09')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (5, 0, N'--ESTADO MOVIMIENTO ALMACEN--', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (5, 1, N'SIN CONFIRMAR', N'ENTRADA', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (5, 2, N'CONFIRMADO', N'ENTRADA', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (5, 3, N'SALIDA', N'SALIDA', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (5, 4, N'ANULADO', N'ANULADO', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (6, 0, N'--ESTADO SERIE ARTICULO--', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (6, 1, N'SIN CONFIRMAR', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (6, 2, N'EN ALMACEN', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (6, 3, N'PREVENTA', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (6, 4, N'VENDIDO', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (6, 5, N'ANULADO', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (10, 0, N'--UNIDAD DE MEDIDA--', N'', N'')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (10, 1, N'UNIDAD', N'UNID.', N'1')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (10, 2, N'MEDIA DOCENA', N'1/2 DOCENA', N'6')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (10, 3, N'DOCENA', N'DOCENA', N'12')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (10, 4, N'MEDIO CIENTO', N'1/2 CIENTO', N'50')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (10, 5, N'CIENTO', N'CIENTO', N'100')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (10, 6, N'MEDIO MILLAR', N'1/2 MILLAR', N'500')
GO
INSERT [MAESTRO].[ValorTabla] ([TablaId], [ItemId], [Denominacion], [DesCorta], [Valor]) VALUES (10, 7, N'MILLAR', N'MILLAR', N'1000')
GO
SET IDENTITY_INSERT [VENTAS].[ListaPrecio] ON 
GO
INSERT [VENTAS].[ListaPrecio] ([ListaPrecioId], [ArticuloId], [Monto], [Descuento], [Estado], [Puntos], [PuntosCanje]) VALUES (2248, 2359, CAST(2500.00 AS Decimal(16, 2)), CAST(10.00 AS Decimal(16, 2)), 1, NULL, NULL)
GO
SET IDENTITY_INSERT [VENTAS].[ListaPrecio] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Persona]    Script Date: 20/01/2020 14:53:57 ******/
ALTER TABLE [MAESTRO].[Persona] ADD  CONSTRAINT [IX_Persona] UNIQUE NONCLUSTERED 
(
	[NumeroDocumento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [ALMACEN].[Almacen] ADD  DEFAULT ((0)) FOR [Estado]
GO
ALTER TABLE [ALMACEN].[Articulo] ADD  CONSTRAINT [DF__Articulo__IndPer__1E704FB5]  DEFAULT ((0)) FOR [IndPerecible]
GO
ALTER TABLE [ALMACEN].[Articulo] ADD  CONSTRAINT [DF__Articulo__IndImp__1F6473EE]  DEFAULT ((0)) FOR [IndImportado]
GO
ALTER TABLE [ALMACEN].[Articulo] ADD  CONSTRAINT [DF__Articulo__Estado__20589827]  DEFAULT ((0)) FOR [Estado]
GO
ALTER TABLE [ALMACEN].[Marca] ADD  DEFAULT ((0)) FOR [Estado]
GO
ALTER TABLE [ALMACEN].[Modelo] ADD  DEFAULT ((0)) FOR [Estado]
GO
ALTER TABLE [ALMACEN].[Movimiento] ADD  CONSTRAINT [DF_Movimiento_SubTotal]  DEFAULT ((0)) FOR [SubTotal]
GO
ALTER TABLE [ALMACEN].[Movimiento] ADD  CONSTRAINT [DF_Movimiento_IGV]  DEFAULT ((0)) FOR [IGV]
GO
ALTER TABLE [ALMACEN].[Movimiento] ADD  CONSTRAINT [DF_Movimiento_AjusteRedondeo]  DEFAULT ((0)) FOR [AjusteRedondeo]
GO
ALTER TABLE [ALMACEN].[Movimiento] ADD  CONSTRAINT [DF_Movimiento_TotalImporte]  DEFAULT ((0)) FOR [TotalImporte]
GO
ALTER TABLE [ALMACEN].[MovimientoDet] ADD  CONSTRAINT [DF_MovimientoDet_Cantidad]  DEFAULT ((0)) FOR [Cantidad]
GO
ALTER TABLE [ALMACEN].[MovimientoDet] ADD  CONSTRAINT [DF_MovimientoDet_PrecioUnitario]  DEFAULT ((0)) FOR [PrecioUnitario]
GO
ALTER TABLE [ALMACEN].[MovimientoDet] ADD  CONSTRAINT [DF_MovimientoDet_Descuento]  DEFAULT ((0)) FOR [Descuento]
GO
ALTER TABLE [ALMACEN].[MovimientoDet] ADD  CONSTRAINT [DF_MovimientoDet_Importe]  DEFAULT ((0)) FOR [Importe]
GO
ALTER TABLE [ALMACEN].[TipoArticulo] ADD  DEFAULT ((0)) FOR [Estado]
GO
ALTER TABLE [ALMACEN].[TipoArticulo] ADD  DEFAULT ((0)) FOR [IndMovimientoAlmacen]
GO
ALTER TABLE [CREDITO].[Boveda] ADD  CONSTRAINT [DF_Boveda_SaldoInicial]  DEFAULT ((0)) FOR [SaldoInicial]
GO
ALTER TABLE [CREDITO].[Boveda] ADD  CONSTRAINT [DF_Boveda_Entradas]  DEFAULT ((0)) FOR [Entradas]
GO
ALTER TABLE [CREDITO].[Boveda] ADD  CONSTRAINT [DF_Boveda_Salidas]  DEFAULT ((0)) FOR [Salidas]
GO
ALTER TABLE [CREDITO].[Boveda] ADD  CONSTRAINT [DF_Boveda_SaldoFinal]  DEFAULT ((0)) FOR [SaldoFinal]
GO
ALTER TABLE [CREDITO].[Boveda] ADD  CONSTRAINT [DF_Boveda_FechaIniOperacion]  DEFAULT (getdate()) FOR [FechaIniOperacion]
GO
ALTER TABLE [CREDITO].[Boveda] ADD  CONSTRAINT [DF_Boveda_IndCierre]  DEFAULT ((0)) FOR [IndCierre]
GO
ALTER TABLE [CREDITO].[BovedaMov] ADD  CONSTRAINT [DF_MovimientoBoveda_IndEntrada]  DEFAULT ((0)) FOR [IndEntrada]
GO
ALTER TABLE [CREDITO].[Caja] ADD  CONSTRAINT [DF_Caja_IndAbierto]  DEFAULT ((0)) FOR [IndAbierto]
GO
ALTER TABLE [CREDITO].[CajaDiario] ADD  CONSTRAINT [DF_CajaDiario_Entradas]  DEFAULT ((0)) FOR [Entradas]
GO
ALTER TABLE [CREDITO].[CajaDiario] ADD  CONSTRAINT [DF_CajaDiario_Salidas]  DEFAULT ((0)) FOR [Salidas]
GO
ALTER TABLE [CREDITO].[CajaDiario] ADD  CONSTRAINT [DF_CajaDiario_IndCierre]  DEFAULT ((0)) FOR [IndCierre]
GO
ALTER TABLE [CREDITO].[CajaDiario] ADD  CONSTRAINT [DF_CajaDiario_TransBoveda]  DEFAULT ((0)) FOR [TransBoveda]
GO
ALTER TABLE [CREDITO].[Cargo] ADD  CONSTRAINT [DF__Cargo__Importe__118B55E3]  DEFAULT ((0)) FOR [Importe]
GO
ALTER TABLE [CREDITO].[Credito] ADD  CONSTRAINT [DF_Credito_MontoDesembolso]  DEFAULT ((0)) FOR [MontoDesembolso]
GO
ALTER TABLE [CREDITO].[Credito] ADD  CONSTRAINT [DF_Credito_TipoGastoAdm]  DEFAULT ('CUO') FOR [TipoGastoAdm]
GO
ALTER TABLE [CREDITO].[Credito] ADD  CONSTRAINT [DF_Credito_OficinaId]  DEFAULT ((1)) FOR [OficinaId]
GO
ALTER TABLE [CREDITO].[Credito] ADD  CONSTRAINT [DF_Credito_FechaVencimiento]  DEFAULT (getdate()) FOR [FechaVencimiento]
GO
ALTER TABLE [CREDITO].[Credito] ADD  CONSTRAINT [DF__Credito__TipoCuo__20CD9973]  DEFAULT ('V') FOR [TipoCuota]
GO
ALTER TABLE [CREDITO].[CuentaxCobrar] ADD  CONSTRAINT [DF__CuentasxC__Monto__39643D13]  DEFAULT ((0)) FOR [Monto]
GO
ALTER TABLE [CREDITO].[MovimientoCaja] ADD  CONSTRAINT [DF_MovimientoCaja_ImportePago]  DEFAULT ((0)) FOR [ImportePago]
GO
ALTER TABLE [CREDITO].[MovimientoCaja] ADD  CONSTRAINT [DF_MovimientoCaja_ImporteRecibido]  DEFAULT ((0)) FOR [ImporteRecibido]
GO
ALTER TABLE [CREDITO].[MovimientoCaja] ADD  CONSTRAINT [DF_MovimientoCaja_MontoVuelto]  DEFAULT ((0)) FOR [MontoVuelto]
GO
ALTER TABLE [CREDITO].[PlanPago] ADD  CONSTRAINT [DF_PlanPago_EstadoId]  DEFAULT ((0)) FOR [Estado]
GO
ALTER TABLE [CREDITO].[PlanPago] ADD  CONSTRAINT [DF_PlanPago_DiasAtrazo]  DEFAULT ((0)) FOR [DiasAtrazo]
GO
ALTER TABLE [CREDITO].[PlanPago] ADD  CONSTRAINT [DF_PlanPago_ImporteMora]  DEFAULT ((0)) FOR [ImporteMora]
GO
ALTER TABLE [CREDITO].[PlanPago] ADD  CONSTRAINT [DF_PlanPago_Mora]  DEFAULT ((0)) FOR [InteresMora]
GO
ALTER TABLE [CREDITO].[PlanPago] ADD  CONSTRAINT [DF_PlanPago_PagoLibre]  DEFAULT ((0)) FOR [PagoLibre]
GO
ALTER TABLE [CREDITO].[PlanPago] ADD  CONSTRAINT [DF_PlanPago_Cargo]  DEFAULT ((0)) FOR [Cargo]
GO
ALTER TABLE [MAESTRO].[Cliente] ADD  CONSTRAINT [DF_Cliente_Inscripcion]  DEFAULT ((0)) FOR [Inscripcion]
GO
ALTER TABLE [MAESTRO].[Cliente] ADD  CONSTRAINT [DF_Cliente_IndPagoInscripcion]  DEFAULT ((0)) FOR [IndPagoInscripcion]
GO
ALTER TABLE [MAESTRO].[Oficina] ADD  DEFAULT ((0)) FOR [Estado]
GO
ALTER TABLE [MAESTRO].[Oficina] ADD  CONSTRAINT [DF_Oficina_UsuarioAsignadoId]  DEFAULT ((3)) FOR [UsuarioAsignadoId]
GO
ALTER TABLE [MAESTRO].[Persona] ADD  DEFAULT ((0)) FOR [Estado]
GO
ALTER TABLE [MAESTRO].[TipoDocumento] ADD  DEFAULT ((0)) FOR [IndVenta]
GO
ALTER TABLE [MAESTRO].[TipoDocumento] ADD  DEFAULT ((0)) FOR [IndAlmacen]
GO
ALTER TABLE [MAESTRO].[TipoDocumento] ADD  DEFAULT ((0)) FOR [IndAlmacenMov]
GO
ALTER TABLE [MAESTRO].[TipoDocumento] ADD  DEFAULT ((0)) FOR [Estado]
GO
ALTER TABLE [MAESTRO].[TipoOperacion] ADD  CONSTRAINT [DF_TipoOperacion_IndEntrada]  DEFAULT ((1)) FOR [IndEntrada]
GO
ALTER TABLE [MAESTRO].[TipoOperacion] ADD  CONSTRAINT [DF_TipoOperacion_IndCajaDiario]  DEFAULT ((0)) FOR [IndCajaDiario]
GO
ALTER TABLE [VENTAS].[ListaPrecio] ADD  CONSTRAINT [DF__ListaPrec__Estad__5DEBB64C]  DEFAULT ((0)) FOR [Estado]
GO
ALTER TABLE [VENTAS].[OrdenVenta] ADD  CONSTRAINT [DF_OrdenVenta_Subtotal]  DEFAULT ((0)) FOR [Subtotal]
GO
ALTER TABLE [VENTAS].[OrdenVenta] ADD  CONSTRAINT [DF_OrdenVenta_TotalImpuesto]  DEFAULT ((0)) FOR [TotalImpuesto]
GO
ALTER TABLE [VENTAS].[OrdenVenta] ADD  CONSTRAINT [DF_OrdenVenta_TotalNeto]  DEFAULT ((0)) FOR [TotalNeto]
GO
ALTER TABLE [VENTAS].[OrdenVenta] ADD  CONSTRAINT [DF_OrdenVenta_TotalDescuento]  DEFAULT ((0)) FOR [TotalDescuento]
GO
ALTER TABLE [VENTAS].[OrdenVenta] ADD  CONSTRAINT [DF__OrdenVent__TipoV__404644CC]  DEFAULT ('CON') FOR [TipoVenta]
GO
ALTER TABLE [VENTAS].[OrdenVentaDet] ADD  CONSTRAINT [DF__OrdenVent__Estad__695D68F8]  DEFAULT ((0)) FOR [Estado]
GO
ALTER TABLE [ALMACEN].[Almacen]  WITH CHECK ADD  CONSTRAINT [FK_ALMACEN_OficinaId] FOREIGN KEY([OficinaId])
REFERENCES [MAESTRO].[Oficina] ([OficinaId])
GO
ALTER TABLE [ALMACEN].[Almacen] CHECK CONSTRAINT [FK_ALMACEN_OficinaId]
GO
ALTER TABLE [ALMACEN].[Articulo]  WITH CHECK ADD  CONSTRAINT [FK_ARTICULO_ModeloId] FOREIGN KEY([ModeloId])
REFERENCES [ALMACEN].[Modelo] ([ModeloId])
GO
ALTER TABLE [ALMACEN].[Articulo] CHECK CONSTRAINT [FK_ARTICULO_ModeloId]
GO
ALTER TABLE [ALMACEN].[Articulo]  WITH CHECK ADD  CONSTRAINT [FK_ARTICULO_TipoArticuloId] FOREIGN KEY([TipoArticuloId])
REFERENCES [ALMACEN].[TipoArticulo] ([TipoArticuloId])
GO
ALTER TABLE [ALMACEN].[Articulo] CHECK CONSTRAINT [FK_ARTICULO_TipoArticuloId]
GO
ALTER TABLE [ALMACEN].[Modelo]  WITH CHECK ADD  CONSTRAINT [FK_MODELO_MarcaId] FOREIGN KEY([MarcaId])
REFERENCES [ALMACEN].[Marca] ([MarcaId])
GO
ALTER TABLE [ALMACEN].[Modelo] CHECK CONSTRAINT [FK_MODELO_MarcaId]
GO
ALTER TABLE [ALMACEN].[Movimiento]  WITH CHECK ADD  CONSTRAINT [FK_ENTRADASALIDA_AlmacenId] FOREIGN KEY([AlmacenId])
REFERENCES [ALMACEN].[Almacen] ([AlmacenId])
GO
ALTER TABLE [ALMACEN].[Movimiento] CHECK CONSTRAINT [FK_ENTRADASALIDA_AlmacenId]
GO
ALTER TABLE [ALMACEN].[Movimiento]  WITH CHECK ADD  CONSTRAINT [FK_ENTRADASALIDA_TipoMovimientoId] FOREIGN KEY([TipoMovimientoId])
REFERENCES [ALMACEN].[TipoMovimiento] ([TipoMovimientoId])
GO
ALTER TABLE [ALMACEN].[Movimiento] CHECK CONSTRAINT [FK_ENTRADASALIDA_TipoMovimientoId]
GO
ALTER TABLE [ALMACEN].[MovimientoDet]  WITH CHECK ADD  CONSTRAINT [FK_DETENTRADASALIDA_ArticuloId] FOREIGN KEY([ArticuloId])
REFERENCES [ALMACEN].[Articulo] ([ArticuloId])
GO
ALTER TABLE [ALMACEN].[MovimientoDet] CHECK CONSTRAINT [FK_DETENTRADASALIDA_ArticuloId]
GO
ALTER TABLE [ALMACEN].[MovimientoDet]  WITH CHECK ADD  CONSTRAINT [FK_DETENTRADASALIDA_EntradaSalidaId] FOREIGN KEY([MovimientoId])
REFERENCES [ALMACEN].[Movimiento] ([MovimientoId])
GO
ALTER TABLE [ALMACEN].[MovimientoDet] CHECK CONSTRAINT [FK_DETENTRADASALIDA_EntradaSalidaId]
GO
ALTER TABLE [ALMACEN].[MovimientoDoc]  WITH CHECK ADD  CONSTRAINT [FK_DOCENTRADASALIDA_DestinatarioId] FOREIGN KEY([DestinatarioId])
REFERENCES [MAESTRO].[Persona] ([PersonaId])
GO
ALTER TABLE [ALMACEN].[MovimientoDoc] CHECK CONSTRAINT [FK_DOCENTRADASALIDA_DestinatarioId]
GO
ALTER TABLE [ALMACEN].[MovimientoDoc]  WITH CHECK ADD  CONSTRAINT [FK_DOCENTRADASALIDA_MovimientoId] FOREIGN KEY([MovimientoId])
REFERENCES [ALMACEN].[Movimiento] ([MovimientoId])
GO
ALTER TABLE [ALMACEN].[MovimientoDoc] CHECK CONSTRAINT [FK_DOCENTRADASALIDA_MovimientoId]
GO
ALTER TABLE [ALMACEN].[MovimientoDoc]  WITH CHECK ADD  CONSTRAINT [FK_DOCENTRADASALIDA_RemitenteId] FOREIGN KEY([RemitenteId])
REFERENCES [MAESTRO].[Persona] ([PersonaId])
GO
ALTER TABLE [ALMACEN].[MovimientoDoc] CHECK CONSTRAINT [FK_DOCENTRADASALIDA_RemitenteId]
GO
ALTER TABLE [ALMACEN].[MovimientoDoc]  WITH CHECK ADD  CONSTRAINT [FK_DOCENTRADASALIDA_TipoDocumentoId] FOREIGN KEY([TipoDocumentoId])
REFERENCES [MAESTRO].[TipoDocumento] ([TipoDocumentoId])
GO
ALTER TABLE [ALMACEN].[MovimientoDoc] CHECK CONSTRAINT [FK_DOCENTRADASALIDA_TipoDocumentoId]
GO
ALTER TABLE [ALMACEN].[SerieArticulo]  WITH CHECK ADD  CONSTRAINT [FK_SERIEARTICULO_AlmacenId] FOREIGN KEY([AlmacenId])
REFERENCES [ALMACEN].[Almacen] ([AlmacenId])
GO
ALTER TABLE [ALMACEN].[SerieArticulo] CHECK CONSTRAINT [FK_SERIEARTICULO_AlmacenId]
GO
ALTER TABLE [ALMACEN].[SerieArticulo]  WITH CHECK ADD  CONSTRAINT [FK_SERIEARTICULO_ArticuloId] FOREIGN KEY([ArticuloId])
REFERENCES [ALMACEN].[Articulo] ([ArticuloId])
GO
ALTER TABLE [ALMACEN].[SerieArticulo] CHECK CONSTRAINT [FK_SERIEARTICULO_ArticuloId]
GO
ALTER TABLE [ALMACEN].[SerieArticulo]  WITH CHECK ADD  CONSTRAINT [FK_SERIEARTICULO_MOVIMIENTODET] FOREIGN KEY([MovimientoDetEntId])
REFERENCES [ALMACEN].[MovimientoDet] ([MovimientoDetId])
GO
ALTER TABLE [ALMACEN].[SerieArticulo] CHECK CONSTRAINT [FK_SERIEARTICULO_MOVIMIENTODET]
GO
ALTER TABLE [CREDITO].[Aprobacion]  WITH CHECK ADD  CONSTRAINT [FK__CreditoEx__Credi__5AFA3B08] FOREIGN KEY([CreditoId])
REFERENCES [CREDITO].[Credito] ([CreditoId])
GO
ALTER TABLE [CREDITO].[Aprobacion] CHECK CONSTRAINT [FK__CreditoEx__Credi__5AFA3B08]
GO
ALTER TABLE [CREDITO].[Aprobacion]  WITH CHECK ADD  CONSTRAINT [FK__CreditoEx__Usuar__5BEE5F41] FOREIGN KEY([UsuarioId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [CREDITO].[Aprobacion] CHECK CONSTRAINT [FK__CreditoEx__Usuar__5BEE5F41]
GO
ALTER TABLE [CREDITO].[Boveda]  WITH CHECK ADD  CONSTRAINT [FK__Boveda__OficinaI__046664EF] FOREIGN KEY([OficinaId])
REFERENCES [MAESTRO].[Oficina] ([OficinaId])
GO
ALTER TABLE [CREDITO].[Boveda] CHECK CONSTRAINT [FK__Boveda__OficinaI__046664EF]
GO
ALTER TABLE [CREDITO].[BovedaMov]  WITH CHECK ADD  CONSTRAINT [FK_MovimientoBoveda_Boveda] FOREIGN KEY([BovedaId])
REFERENCES [CREDITO].[Boveda] ([BovedaId])
GO
ALTER TABLE [CREDITO].[BovedaMov] CHECK CONSTRAINT [FK_MovimientoBoveda_Boveda]
GO
ALTER TABLE [CREDITO].[BovedaMovTemp]  WITH CHECK ADD  CONSTRAINT [FK_BovedaMovTemp_Boveda] FOREIGN KEY([BovedaInicioId])
REFERENCES [CREDITO].[Boveda] ([BovedaId])
GO
ALTER TABLE [CREDITO].[BovedaMovTemp] CHECK CONSTRAINT [FK_BovedaMovTemp_Boveda]
GO
ALTER TABLE [CREDITO].[BovedaMovTemp]  WITH CHECK ADD  CONSTRAINT [FK_BovedaMovTemp_Boveda1] FOREIGN KEY([BovedaDestinoId])
REFERENCES [CREDITO].[Boveda] ([BovedaId])
GO
ALTER TABLE [CREDITO].[BovedaMovTemp] CHECK CONSTRAINT [FK_BovedaMovTemp_Boveda1]
GO
ALTER TABLE [CREDITO].[Caja]  WITH CHECK ADD  CONSTRAINT [FK__Caja__OficinaId__092B1A0C] FOREIGN KEY([OficinaId])
REFERENCES [MAESTRO].[Oficina] ([OficinaId])
GO
ALTER TABLE [CREDITO].[Caja] CHECK CONSTRAINT [FK__Caja__OficinaId__092B1A0C]
GO
ALTER TABLE [CREDITO].[Caja]  WITH CHECK ADD  CONSTRAINT [FK_Caja_Usuario] FOREIGN KEY([UsuarioRegId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [CREDITO].[Caja] CHECK CONSTRAINT [FK_Caja_Usuario]
GO
ALTER TABLE [CREDITO].[Caja]  WITH CHECK ADD  CONSTRAINT [FK_Caja_Usuario1] FOREIGN KEY([UsuarioModId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [CREDITO].[Caja] CHECK CONSTRAINT [FK_Caja_Usuario1]
GO
ALTER TABLE [CREDITO].[CajaDiario]  WITH CHECK ADD  CONSTRAINT [FK__CajaDiari__CajaI__0EE3F362] FOREIGN KEY([CajaId])
REFERENCES [CREDITO].[Caja] ([CajaId])
GO
ALTER TABLE [CREDITO].[CajaDiario] CHECK CONSTRAINT [FK__CajaDiari__CajaI__0EE3F362]
GO
ALTER TABLE [CREDITO].[CajaDiario]  WITH CHECK ADD  CONSTRAINT [FK__CajaDiari__Usuar__0DEFCF29] FOREIGN KEY([UsuarioAsignadoId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [CREDITO].[CajaDiario] CHECK CONSTRAINT [FK__CajaDiari__Usuar__0DEFCF29]
GO
ALTER TABLE [CREDITO].[Cargo]  WITH CHECK ADD  CONSTRAINT [FK__Cargo__CreditoId__109731AA] FOREIGN KEY([CreditoId])
REFERENCES [CREDITO].[Credito] ([CreditoId])
GO
ALTER TABLE [CREDITO].[Cargo] CHECK CONSTRAINT [FK__Cargo__CreditoId__109731AA]
GO
ALTER TABLE [CREDITO].[Cargo]  WITH CHECK ADD  CONSTRAINT [FK_Cargo_Usuario] FOREIGN KEY([UsuarioId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [CREDITO].[Cargo] CHECK CONSTRAINT [FK_Cargo_Usuario]
GO
ALTER TABLE [CREDITO].[Credito]  WITH CHECK ADD  CONSTRAINT [FK__Credito__OrdenVe__3E5DFC5A] FOREIGN KEY([OrdenVentaId])
REFERENCES [VENTAS].[OrdenVenta] ([OrdenVentaId])
GO
ALTER TABLE [CREDITO].[Credito] CHECK CONSTRAINT [FK__Credito__OrdenVe__3E5DFC5A]
GO
ALTER TABLE [CREDITO].[Credito]  WITH CHECK ADD  CONSTRAINT [FK_Credito_Oficina] FOREIGN KEY([OficinaId])
REFERENCES [MAESTRO].[Oficina] ([OficinaId])
GO
ALTER TABLE [CREDITO].[Credito] CHECK CONSTRAINT [FK_Credito_Oficina]
GO
ALTER TABLE [CREDITO].[Credito]  WITH CHECK ADD  CONSTRAINT [FK_Credito_Persona] FOREIGN KEY([PersonaId])
REFERENCES [MAESTRO].[Persona] ([PersonaId])
GO
ALTER TABLE [CREDITO].[Credito] CHECK CONSTRAINT [FK_Credito_Persona]
GO
ALTER TABLE [CREDITO].[Credito]  WITH CHECK ADD  CONSTRAINT [FK_Credito_Producto] FOREIGN KEY([ProductoId])
REFERENCES [CREDITO].[Producto] ([ProductoId])
GO
ALTER TABLE [CREDITO].[Credito] CHECK CONSTRAINT [FK_Credito_Producto]
GO
ALTER TABLE [CREDITO].[Credito]  WITH CHECK ADD  CONSTRAINT [FK_Credito_Usuario3] FOREIGN KEY([UsuarioRegId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [CREDITO].[Credito] CHECK CONSTRAINT [FK_Credito_Usuario3]
GO
ALTER TABLE [CREDITO].[Credito]  WITH CHECK ADD  CONSTRAINT [FK_Credito_Usuario4] FOREIGN KEY([UsuarioModId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [CREDITO].[Credito] CHECK CONSTRAINT [FK_Credito_Usuario4]
GO
ALTER TABLE [CREDITO].[CuentaxCobrar]  WITH CHECK ADD  CONSTRAINT [FK__CuentasxC__Movim__3A58614C] FOREIGN KEY([MovimientoCajaId])
REFERENCES [CREDITO].[MovimientoCaja] ([MovimientoCajaId])
GO
ALTER TABLE [CREDITO].[CuentaxCobrar] CHECK CONSTRAINT [FK__CuentasxC__Movim__3A58614C]
GO
ALTER TABLE [CREDITO].[CuentaxCobrar]  WITH CHECK ADD  CONSTRAINT [FK__CuentaxCo__Credi__3D69D821] FOREIGN KEY([CreditoId])
REFERENCES [CREDITO].[Credito] ([CreditoId])
GO
ALTER TABLE [CREDITO].[CuentaxCobrar] CHECK CONSTRAINT [FK__CuentaxCo__Credi__3D69D821]
GO
ALTER TABLE [CREDITO].[MovimientoCaja]  WITH CHECK ADD  CONSTRAINT [FK__Movimient__CajaD__149CCCB8] FOREIGN KEY([CajaDiarioId])
REFERENCES [CREDITO].[CajaDiario] ([CajaDiarioId])
GO
ALTER TABLE [CREDITO].[MovimientoCaja] CHECK CONSTRAINT [FK__Movimient__CajaD__149CCCB8]
GO
ALTER TABLE [CREDITO].[MovimientoCaja]  WITH CHECK ADD  CONSTRAINT [FK__Movimient__Usuar__17793963] FOREIGN KEY([UsuarioRegId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [CREDITO].[MovimientoCaja] CHECK CONSTRAINT [FK__Movimient__Usuar__17793963]
GO
ALTER TABLE [CREDITO].[MovimientoCaja]  WITH CHECK ADD  CONSTRAINT [FK_MovimientoCaja_Credito] FOREIGN KEY([CreditoId])
REFERENCES [CREDITO].[Credito] ([CreditoId])
GO
ALTER TABLE [CREDITO].[MovimientoCaja] CHECK CONSTRAINT [FK_MovimientoCaja_Credito]
GO
ALTER TABLE [CREDITO].[MovimientoCaja]  WITH CHECK ADD  CONSTRAINT [FK_MovimientoCaja_OrdenVenta] FOREIGN KEY([OrdenVentaId])
REFERENCES [VENTAS].[OrdenVenta] ([OrdenVentaId])
GO
ALTER TABLE [CREDITO].[MovimientoCaja] CHECK CONSTRAINT [FK_MovimientoCaja_OrdenVenta]
GO
ALTER TABLE [CREDITO].[MovimientoCaja]  WITH CHECK ADD  CONSTRAINT [FK_MovimientoCaja_Persona] FOREIGN KEY([PersonaId])
REFERENCES [MAESTRO].[Persona] ([PersonaId])
GO
ALTER TABLE [CREDITO].[MovimientoCaja] CHECK CONSTRAINT [FK_MovimientoCaja_Persona]
GO
ALTER TABLE [CREDITO].[MovimientoCajaAnu]  WITH CHECK ADD  CONSTRAINT [FK__Movimient__Movim__51A5DAF8] FOREIGN KEY([MovimientoCajaId])
REFERENCES [CREDITO].[MovimientoCaja] ([MovimientoCajaId])
GO
ALTER TABLE [CREDITO].[MovimientoCajaAnu] CHECK CONSTRAINT [FK__Movimient__Movim__51A5DAF8]
GO
ALTER TABLE [CREDITO].[PlanPago]  WITH CHECK ADD  CONSTRAINT [FK__PlanPago__Credit__75592B89] FOREIGN KEY([CreditoId])
REFERENCES [CREDITO].[Credito] ([CreditoId])
GO
ALTER TABLE [CREDITO].[PlanPago] CHECK CONSTRAINT [FK__PlanPago__Credit__75592B89]
GO
ALTER TABLE [CREDITO].[PlanPago]  WITH CHECK ADD  CONSTRAINT [FK_PlanPago_MovimientoCaja] FOREIGN KEY([MovimientoCajaId])
REFERENCES [CREDITO].[MovimientoCaja] ([MovimientoCajaId])
GO
ALTER TABLE [CREDITO].[PlanPago] CHECK CONSTRAINT [FK_PlanPago_MovimientoCaja]
GO
ALTER TABLE [CREDITO].[PlanPago]  WITH CHECK ADD  CONSTRAINT [FK_PlanPago_Usuario] FOREIGN KEY([UsuarioModId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [CREDITO].[PlanPago] CHECK CONSTRAINT [FK_PlanPago_Usuario]
GO
ALTER TABLE [CREDITO].[PlanPagoLibre]  WITH CHECK ADD  CONSTRAINT [FK__PlanPagoL__Movim__75E33B6E] FOREIGN KEY([MovimientoCajaId])
REFERENCES [CREDITO].[MovimientoCaja] ([MovimientoCajaId])
GO
ALTER TABLE [CREDITO].[PlanPagoLibre] CHECK CONSTRAINT [FK__PlanPagoL__Movim__75E33B6E]
GO
ALTER TABLE [CREDITO].[PlanPagoLibre]  WITH CHECK ADD  CONSTRAINT [FK__PlanPagoL__PlanP__74EF1735] FOREIGN KEY([PlanPagoId])
REFERENCES [CREDITO].[PlanPago] ([PlanPagoId])
GO
ALTER TABLE [CREDITO].[PlanPagoLibre] CHECK CONSTRAINT [FK__PlanPagoL__PlanP__74EF1735]
GO
ALTER TABLE [MAESTRO].[Cliente]  WITH CHECK ADD  CONSTRAINT [FK_Cliente_Persona] FOREIGN KEY([PersonaId])
REFERENCES [MAESTRO].[Persona] ([PersonaId])
GO
ALTER TABLE [MAESTRO].[Cliente] CHECK CONSTRAINT [FK_Cliente_Persona]
GO
ALTER TABLE [MAESTRO].[Oficina]  WITH CHECK ADD  CONSTRAINT [FK_Oficina_Usuario] FOREIGN KEY([UsuarioAsignadoId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [MAESTRO].[Oficina] CHECK CONSTRAINT [FK_Oficina_Usuario]
GO
ALTER TABLE [MAESTRO].[RolMenu]  WITH NOCHECK ADD  CONSTRAINT [FK__RolMenu__MenuId__6BCFC14F] FOREIGN KEY([MenuId])
REFERENCES [MAESTRO].[Menu] ([MenuId])
GO
ALTER TABLE [MAESTRO].[RolMenu] CHECK CONSTRAINT [FK__RolMenu__MenuId__6BCFC14F]
GO
ALTER TABLE [MAESTRO].[RolMenu]  WITH CHECK ADD  CONSTRAINT [FK__RolMenu__RolId__6ADB9D16] FOREIGN KEY([RolId])
REFERENCES [MAESTRO].[Rol] ([RolId])
GO
ALTER TABLE [MAESTRO].[RolMenu] CHECK CONSTRAINT [FK__RolMenu__RolId__6ADB9D16]
GO
ALTER TABLE [MAESTRO].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK__Usuario__Persona__33C07256] FOREIGN KEY([PersonaId])
REFERENCES [MAESTRO].[Persona] ([PersonaId])
GO
ALTER TABLE [MAESTRO].[Usuario] CHECK CONSTRAINT [FK__Usuario__Persona__33C07256]
GO
ALTER TABLE [MAESTRO].[UsuarioOficina]  WITH CHECK ADD  CONSTRAINT [FK__UsuarioOf__Ofici__768259EC] FOREIGN KEY([OficinaId])
REFERENCES [MAESTRO].[Oficina] ([OficinaId])
GO
ALTER TABLE [MAESTRO].[UsuarioOficina] CHECK CONSTRAINT [FK__UsuarioOf__Ofici__768259EC]
GO
ALTER TABLE [MAESTRO].[UsuarioOficina]  WITH CHECK ADD  CONSTRAINT [FK__UsuarioOf__Usuar__758E35B3] FOREIGN KEY([UsuarioId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [MAESTRO].[UsuarioOficina] CHECK CONSTRAINT [FK__UsuarioOf__Usuar__758E35B3]
GO
ALTER TABLE [MAESTRO].[UsuarioRol]  WITH CHECK ADD  CONSTRAINT [FK__UsuarioRo__Ofici__764D4FC2] FOREIGN KEY([OficinaId])
REFERENCES [MAESTRO].[Oficina] ([OficinaId])
GO
ALTER TABLE [MAESTRO].[UsuarioRol] CHECK CONSTRAINT [FK__UsuarioRo__Ofici__764D4FC2]
GO
ALTER TABLE [MAESTRO].[UsuarioRol]  WITH CHECK ADD  CONSTRAINT [FK__UsuarioRo__RolId__71889AA5] FOREIGN KEY([RolId])
REFERENCES [MAESTRO].[Rol] ([RolId])
GO
ALTER TABLE [MAESTRO].[UsuarioRol] CHECK CONSTRAINT [FK__UsuarioRo__RolId__71889AA5]
GO
ALTER TABLE [MAESTRO].[UsuarioRol]  WITH CHECK ADD  CONSTRAINT [FK__UsuarioRo__Usuar__7094766C] FOREIGN KEY([UsuarioId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [MAESTRO].[UsuarioRol] CHECK CONSTRAINT [FK__UsuarioRo__Usuar__7094766C]
GO
ALTER TABLE [VENTAS].[ListaPrecio]  WITH CHECK ADD  CONSTRAINT [FK_ListaPrecio_Articulo] FOREIGN KEY([ArticuloId])
REFERENCES [ALMACEN].[Articulo] ([ArticuloId])
GO
ALTER TABLE [VENTAS].[ListaPrecio] CHECK CONSTRAINT [FK_ListaPrecio_Articulo]
GO
ALTER TABLE [VENTAS].[OrdenVenta]  WITH CHECK ADD  CONSTRAINT [FK_ORDENVENTA_OficinaId] FOREIGN KEY([OficinaId])
REFERENCES [MAESTRO].[Oficina] ([OficinaId])
GO
ALTER TABLE [VENTAS].[OrdenVenta] CHECK CONSTRAINT [FK_ORDENVENTA_OficinaId]
GO
ALTER TABLE [VENTAS].[OrdenVenta]  WITH CHECK ADD  CONSTRAINT [FK_OrdenVenta_Persona] FOREIGN KEY([PersonaId])
REFERENCES [MAESTRO].[Persona] ([PersonaId])
GO
ALTER TABLE [VENTAS].[OrdenVenta] CHECK CONSTRAINT [FK_OrdenVenta_Persona]
GO
ALTER TABLE [VENTAS].[OrdenVenta]  WITH CHECK ADD  CONSTRAINT [FK_OrdenVenta_Usuario] FOREIGN KEY([UsuarioRegId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [VENTAS].[OrdenVenta] CHECK CONSTRAINT [FK_OrdenVenta_Usuario]
GO
ALTER TABLE [VENTAS].[OrdenVenta]  WITH CHECK ADD  CONSTRAINT [FK_OrdenVenta_Usuario1] FOREIGN KEY([UsuarioModId])
REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
GO
ALTER TABLE [VENTAS].[OrdenVenta] CHECK CONSTRAINT [FK_OrdenVenta_Usuario1]
GO
ALTER TABLE [VENTAS].[OrdenVentaDet]  WITH CHECK ADD  CONSTRAINT [FK_DETORDENVENTA_ArticuloId] FOREIGN KEY([ArticuloId])
REFERENCES [ALMACEN].[Articulo] ([ArticuloId])
GO
ALTER TABLE [VENTAS].[OrdenVentaDet] CHECK CONSTRAINT [FK_DETORDENVENTA_ArticuloId]
GO
ALTER TABLE [VENTAS].[OrdenVentaDet]  WITH CHECK ADD  CONSTRAINT [FK_DETORDENVENTA_OrdenVentaId] FOREIGN KEY([OrdenVentaId])
REFERENCES [VENTAS].[OrdenVenta] ([OrdenVentaId])
GO
ALTER TABLE [VENTAS].[OrdenVentaDet] CHECK CONSTRAINT [FK_DETORDENVENTA_OrdenVentaId]
GO
ALTER TABLE [VENTAS].[OrdenVentaDetSerie]  WITH CHECK ADD  CONSTRAINT [FK__OrdenVent__Orden__08A10A27] FOREIGN KEY([OrdenVentaDetId])
REFERENCES [VENTAS].[OrdenVentaDet] ([OrdenVentaDetId])
GO
ALTER TABLE [VENTAS].[OrdenVentaDetSerie] CHECK CONSTRAINT [FK__OrdenVent__Orden__08A10A27]
GO
ALTER TABLE [VENTAS].[OrdenVentaDetSerie]  WITH CHECK ADD  CONSTRAINT [FK__OrdenVent__Serie__09952E60] FOREIGN KEY([SerieArticuloId])
REFERENCES [ALMACEN].[SerieArticulo] ([SerieArticuloId])
GO
ALTER TABLE [VENTAS].[OrdenVentaDetSerie] CHECK CONSTRAINT [FK__OrdenVent__Serie__09952E60]
GO
ALTER TABLE [VENTAS].[TarjetaPunto]  WITH CHECK ADD  CONSTRAINT [FK__TarjetaPu__Perso__118B55E3] FOREIGN KEY([PersonaId])
REFERENCES [MAESTRO].[Persona] ([PersonaId])
GO
ALTER TABLE [VENTAS].[TarjetaPunto] CHECK CONSTRAINT [FK__TarjetaPu__Perso__118B55E3]
GO
ALTER TABLE [VENTAS].[TarjetaPuntoDet]  WITH CHECK ADD  CONSTRAINT [FK__TarjetaPu__Orden__17442F39] FOREIGN KEY([OrdenVentaId])
REFERENCES [VENTAS].[OrdenVenta] ([OrdenVentaId])
GO
ALTER TABLE [VENTAS].[TarjetaPuntoDet] CHECK CONSTRAINT [FK__TarjetaPu__Orden__17442F39]
GO
ALTER TABLE [VENTAS].[TarjetaPuntoDet]  WITH CHECK ADD  CONSTRAINT [FK__TarjetaPu__Tarje__16500B00] FOREIGN KEY([TarjetaPuntoId])
REFERENCES [VENTAS].[TarjetaPunto] ([TarjetaPuntoId])
GO
ALTER TABLE [VENTAS].[TarjetaPuntoDet] CHECK CONSTRAINT [FK__TarjetaPu__Tarje__16500B00]
GO
/****** Object:  StoredProcedure [ALMACEN].[usp_CrearMovimientoDet]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 

	EXEC ALMACEN.usp_CrearMovimientoDet @MovimientoId=18,@ArticuloId=1,@ListaSerie='99669966996888889658',@IndCorrelativo=1,
	@PrecioUnitario=55.08,@Descuento=45.76,@Cantidad=50

	SELECT * FROM ALMACEN.Movimiento 
	SELECT * FROM ALMACEN.MovimientoDet 
	SELECT * FROM ALMACEN.SerieArticulo 

delete from ALMACEN.SerieArticulo
delete from ALMACEN.MovimientoDet
*/


CREATE PROC [ALMACEN].[usp_CrearMovimientoDet]
@MovimientoId INT,
@MovimientoDetId INT=0,
@ArticuloId INT,
@IndAutogenerar BIT=0,
@ListaSerie VARCHAR(MAX),
@Cantidad INT=0,
@IndCorrelativo BIT=0,
@PrecioUnitario DECIMAL(16,2)=0,	
@Descuento DECIMAL(16,2)=0,	
@Medida INT=0
AS
BEGIN
	
	DECLARE @EstadoSerie INT,@Importe DECIMAL(16,2),@IGV DECIMAL(16,2), @Descripcion VARCHAR(MAX),@AlmacenId INT
	DECLARE @CantidadLista INT
	SET @EstadoSerie = 1 --sin confirmar
	SET @ListaSerie = RTRIM(LTRIM(@ListaSerie))
	SET @IGV = 0.18
		
	SELECT @Descripcion = (Denominacion + CHAR(13)) FROM ALMACEN.Articulo WHERE ArticuloId=@ArticuloId
	SELECT @AlmacenId=AlmacenId FROM ALMACEN.Movimiento WHERE MovimientoId=@MovimientoId
	IF @IndAutogenerar=0 AND @IndCorrelativo=0
		SELECT @Cantidad = COUNT(1) FROM dbo.Split(@ListaSerie,',')
	
	SET @Importe = @Cantidad * (@PrecioUnitario - @Descuento)
	
	IF @MovimientoDetId=0
	BEGIN
		INSERT INTO ALMACEN.MovimientoDet
				( MovimientoId ,ArticuloId ,Cantidad ,Descripcion , PrecioUnitario ,
				Descuento ,Importe ,UnidadMedidaT10 , IndCorrelativo )
		VALUES  ( @MovimientoId , @ArticuloId, @Cantidad, @Descripcion + @ListaSerie, @PrecioUnitario, 
				  @Descuento , @Importe, @Medida, @IndCorrelativo)
		SELECT @MovimientoDetId=@@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE	ALMACEN.MovimientoDet
		SET		PrecioUnitario=@PrecioUnitario,
				Descuento = @Descuento,
				Cantidad = @Cantidad,
				Importe = @Importe,
				Descripcion = @Descripcion + @ListaSerie,
				IndCorrelativo = @IndCorrelativo,				
				UnidadMedidaT10 = @Medida
		WHERE	MovimientoDetId = @MovimientoDetId
	END
	
	DELETE FROM ALMACEN.SerieArticulo WHERE MovimientoDetEntId=@MovimientoDetId
	
					
	IF @IndAutogenerar=0 AND @IndCorrelativo=0
	BEGIN
		INSERT INTO ALMACEN.SerieArticulo
		(NumeroSerie,AlmacenId,ArticuloId,EstadoId,MovimientoDetEntId)
		SELECT	Name 'Serie',@AlmacenId,@ArticuloId,@EstadoSerie,@MovimientoDetId
		FROM	dbo.Split(@ListaSerie,',')
	END
	ELSE
	BEGIN
		DECLARE @SerieIni BIGINT, @SerieFin BIGINT, @Serie VARCHAR(20), @Limite INT
		IF @IndAutogenerar=1
		BEGIN
			SELECT @ListaSerie =CAST(MAX(CAST(NumeroSerie AS BIGINT) + 1) AS VARCHAR(20)) FROM ALMACEN.SerieArticulo
		END
		
		SET @Limite = LEN(@ListaSerie)
		IF @Limite > 9
			SET @Limite = 9
				
		SET @SerieIni = CAST(SUBSTRING(@ListaSerie, LEN(@ListaSerie)- @Limite, LEN(@ListaSerie)+1) AS BIGINT)
		SET @SerieFin = @SerieIni + @Cantidad - 1
		SET @Serie = SUBSTRING(@ListaSerie, 0,LEN(@ListaSerie)- @Limite) 
		
		WHILE(@SerieIni <= @SerieFin)	
		BEGIN
			INSERT INTO ALMACEN.SerieArticulo
			(NumeroSerie,AlmacenId,ArticuloId,EstadoId,MovimientoDetEntId)
			VALUES(	@Serie + CAST(@SerieIni AS VARCHAR(20)),@AlmacenId,@ArticuloId,@EstadoSerie,@MovimientoDetId)
			
			SET @SerieIni = @SerieIni + 1
		END
		
		IF @Cantidad>1
			UPDATE	ALMACEN.MovimientoDet 
			SET		Descripcion = @Descripcion + @ListaSerie + ' al ' + @Serie + CAST(@SerieFin AS VARCHAR(20))
			WHERE	MovimientoDetId=@MovimientoDetId
		ELSE
			UPDATE	ALMACEN.MovimientoDet 
			SET		Descripcion = @Descripcion + @ListaSerie 
			WHERE	MovimientoDetId=@MovimientoDetId
		
			
	END
	
	;WITH DETALLE AS (
		SELECT	MovimientoId,SUM(Importe) 'TotalImporte' 
		FROM	ALMACEN.MovimientoDet 
		WHERE	MovimientoId=@MovimientoId 
		GROUP	BY MovimientoId
	)
	UPDATE	M
	SET		M.SubTotal=D.TotalImporte / (1 + @IGV),
			M.IGV = D.TotalImporte - (D.TotalImporte / (1 + @IGV)),
			M.AjusteRedondeo = 0,
			M.TotalImporte = D.TotalImporte
	FROM	ALMACEN.Movimiento M
	INNER JOIN DETALLE D ON M.MovimientoId = D.MovimientoId 
	WHERE	M.MovimientoId=@MovimientoId
	--UPDATE	M
	--SET		M.SubTotal=D.TotalImporte,
	--		M.IGV = D.TotalImporte * @IGV,
	--		M.AjusteRedondeo = 0,
	--		M.TotalImporte = D.TotalImporte * ( 1 + @IGV )
	--FROM	ALMACEN.Movimiento M
	--INNER JOIN DETALLE D ON M.MovimientoId = D.MovimientoId 
	--WHERE	M.MovimientoId=@MovimientoId
	
END



GO
/****** Object:  StoredProcedure [ALMACEN].[usp_EliminarMovimientoDet]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [ALMACEN].[usp_EliminarMovimientoDet]
@MovimientoDetId INT
AS
BEGIN
	--DECLARE @tserie TABLE (SerieArticuloId int)

	--INSERT INTO @tserie
	--SELECT	SerieArticuloId 
	--FROM	ALMACEN.MovimientoDetSerie 
	--WHERE	MovimientoDetId=@MovimientoDetId
	
	DECLARE @MovimientoId INT, @IGV DECIMAL(16,2)
	SELECT @MovimientoId = MovimientoId FROM ALMACEN.MovimientoDet WHERE MovimientoDetId=@MovimientoDetId
	SET @IGV = 0.18
	
	DELETE FROM ALMACEN.SerieArticulo 
	WHERE MovimientoDetEntId = @MovimientoDetId
	
	DELETE FROM ALMACEN.MovimientoDet 
	WHERE MovimientoDetId=@MovimientoDetId

	;WITH DETALLE AS (
		SELECT	MovimientoId,SUM(Importe) 'TotalImporte' 
		FROM	ALMACEN.MovimientoDet 
		WHERE	MovimientoId=@MovimientoId 
		GROUP	BY MovimientoId
	)
	UPDATE	M
	SET		M.SubTotal=D.TotalImporte,
			M.IGV = D.TotalImporte * @IGV,
			M.AjusteRedondeo = 0,
			M.TotalImporte = D.TotalImporte * ( 1 + @IGV )
	FROM	ALMACEN.Movimiento M
	INNER JOIN DETALLE D ON M.MovimientoId = D.MovimientoId 
	WHERE	M.MovimientoId=@MovimientoId
	
END

GO
/****** Object:  StoredProcedure [ALMACEN].[usp_ExisteSerieArticulo]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
declare @retorno varchar(50)
exec ALMACEN.usp_ExisteSerieArticulo @ListaSerie = '120',@IndCorrelativo = 0,@Cantidad = 10,
		@Retorno=@retorno OUTPUT				
select @retorno
*/
CREATE PROC [ALMACEN].[usp_ExisteSerieArticulo]
	@ListaSerie VARCHAR(MAX),
	@Cantidad INT,
	@IndCorrelativo BIT=0--,
	--@Retorno VARCHAR(50) OUTPUT
AS
BEGIN
	
DECLARE @lstExiste VARCHAR(50), @SerieAnulado INT
SET @SerieAnulado = 4

IF @IndCorrelativo=0
	BEGIN
		SELECT	@lstExiste =  ISNULL(@lstExiste+',','') + Name 
		FROM	dbo.Split(@ListaSerie,',') S
		INNER JOIN ALMACEN.SerieArticulo SA ON SA.NumeroSerie=S.Name AND SA.EstadoId<>@SerieAnulado		
	END
ELSE
	BEGIN
		DECLARE @tserie TABLE (NumeroSerie VARCHAR(20))
		DECLARE @SerieIni BIGINT, @SerieFin BIGINT, @Serie VARCHAR(20), @Limite INT
		SET @Limite = LEN(@ListaSerie)
		IF @Limite > 9
			SET @Limite = 9
				
		SET @SerieIni = CAST(SUBSTRING(@ListaSerie, LEN(@ListaSerie)- @Limite, LEN(@ListaSerie)+1) AS BIGINT)
		SET @SerieFin = @SerieIni + @Cantidad - 1
		SET @Serie = SUBSTRING(@ListaSerie, 0,LEN(@ListaSerie)- @Limite) 
		
		WHILE(@SerieIni <= @SerieFin)	
		BEGIN
			INSERT INTO @tserie VALUES(@Serie + CAST(@SerieIni AS VARCHAR(20)))
			SET @SerieIni+=1
		END
				
		SELECT	@lstExiste =  ISNULL(@lstExiste+',','') + S.NumeroSerie 
		FROM	@tserie S
		INNER JOIN ALMACEN.SerieArticulo SA ON SA.NumeroSerie=S.NumeroSerie AND SA.EstadoId<>@SerieAnulado
		
	END		
		
	--SET @Retorno = ISNULL(@lstExiste,'') 		
	SELECT ISNULL(@lstExiste,'') 'Existe'		
		
END		





GO
/****** Object:  StoredProcedure [ALMACEN].[usp_GenerarKardex]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
ALMACEN.usp_GenerarKardex @ArticuloId = 534,  @AlmacenId = 9
*/

CREATE PROC [ALMACEN].[usp_GenerarKardex]
@ArticuloId INT,	
@AlmacenId INT
--@AFecha DATE=NULL,
--@IndCierre BIT = 0
AS

DECLARE	@tmpKardex TABLE(Fila INT,MovimientoDetId INT,Fecha DATETIME,IndEntrada BIT,Concepto VARCHAR(MAX),
		CantEnt INT,PUEnt DECIMAL(16,2),TotalEnt DECIMAL(16,2),
		CantSal INT,PUSal DECIMAL(16,2) ,TotalSal DECIMAL(16,2) ,
		CantSaldo INT,PUSaldo DECIMAL(16,2),TotalSaldo DECIMAL(16,2))
			
;WITH DATOS AS(
	SELECT	MD.MovimientoDetId,M.Fecha, 1 'IndEntrada',MD.PrecioUnitario,M.TipoMovimientoId
	FROM	ALMACEN.SerieArticulo SA
	INNER JOIN ALMACEN.MovimientoDet MD ON SA.MovimientoDetEntId = MD.MovimientoDetId
	INNER JOIN ALMACEN.Movimiento M ON MD.MovimientoId = M.MovimientoId
	--INNER JOIN ALMACEN.TipoMovimiento TM ON M.TipoMovimientoId = TM.TipoMovimientoId
	WHERE SA.EstadoId IN(2,3,4) AND SA.ArticuloId=@ArticuloId AND SA.AlmacenId=@AlmacenId
	UNION ALL
	SELECT	MD.MovimientoDetId,M.Fecha,0 'IndEntrada',MD.PrecioUnitario,M.TipoMovimientoId
	FROM ALMACEN.SerieArticulo SA
	INNER JOIN ALMACEN.MovimientoDet MD ON SA.MovimientoDetSalId = MD.MovimientoDetId
	INNER JOIN ALMACEN.Movimiento M ON MD.MovimientoId = M.MovimientoId
	--INNER JOIN ALMACEN.TipoMovimiento TM ON M.TipoMovimientoId = TM.TipoMovimientoId
	WHERE SA.EstadoId = 4 AND SA.ArticuloId=@ArticuloId AND SA.AlmacenId=@AlmacenId
),CANTIDAD AS(
	SELECT	ROW_NUMBER() OVER(ORDER BY Fecha ASC) AS 'Fila',MovimientoDetId,Fecha,IndEntrada,TipoMovimientoId,PrecioUnitario,COUNT(1) 'Cantidad'
		   --STUFF((SELECT ',' + rtrim(convert(char(10),NumeroSerie))
		--   FROM   DATOS b WHERE  a.Fecha = b.Fecha AND A.IndEntrada=b.IndEntrada
		--   FOR XML PATH('')),1,1,'') 'Codigos'
	FROM DATOS A
	GROUP BY MovimientoDetId,Fecha,IndEntrada,TipoMovimientoId,PrecioUnitario
)
INSERT INTO @tmpKardex(Fila,MovimientoDetId,Fecha,IndEntrada,Concepto,CantEnt,PUEnt,TotalEnt,CantSal)
SELECT	Fila,MovimientoDetId,Fecha,C.IndEntrada,TM.Descripcion,
		CASE WHEN C.IndEntrada=1 THEN Cantidad ELSE NULL END 'CantEnt',
		CASE WHEN C.IndEntrada=1 THEN PrecioUnitario ELSE NULL END 'PUEnt',
		CASE WHEN C.IndEntrada=1 THEN PrecioUnitario*Cantidad ELSE NULL END 'TotalEnt',
		CASE WHEN C.IndEntrada=0 THEN Cantidad ELSE NULL END 'CantSal'
FROM CANTIDAD C
INNER JOIN ALMACEN.TipoMovimiento TM ON C.TipoMovimientoId = TM.TipoMovimientoId



DECLARE @CantSaldoAnt INT=0, @PUSaldoAnt DECIMAL(16,2)=0, @TotalSaldoAnt DECIMAL(16,2)=0
DECLARE @Sec INT=1, @Limite INT =(select COUNT(1) from @tmpKardex), @IndEntrada BIT
WHILE (@Sec<=@Limite)
BEGIN 
	SELECT	@IndEntrada = IndEntrada FROM @tmpKardex WHERE Fila=@Sec
	
	IF @Sec>1	
	BEGIN
		SELECT	@CantSaldoAnt = CantSaldo, @PUSaldoAnt=PUSaldo, @TotalSaldoAnt=TotalSaldo
		FROM @tmpKardex WHERE Fila=@Sec-1
	END
	
	IF @IndEntrada=1
	BEGIN		
		UPDATE @tmpKardex 
		SET CantSaldo = @CantSaldoAnt + CantEnt,
			TotalSaldo = @TotalSaldoAnt + TotalEnt , 
			PUSaldo=CASE WHEN (@CantSaldoAnt + CantEnt)= 0 THEN 0 
								ELSE ((@TotalSaldoAnt + TotalEnt)/(@CantSaldoAnt + CantEnt)) 
					END
		WHERE Fila=@Sec
	END
	ELSE
	BEGIN
		UPDATE @tmpKardex 
		SET PUSal = @PUSaldoAnt,
			TotalSal = @PUSaldoAnt * CantSal,
			CantSaldo = @CantSaldoAnt - CantSal,
			TotalSaldo = @TotalSaldoAnt - (@PUSaldoAnt * CantSal) , 
			PUSaldo=CASE WHEN (@CantSaldoAnt - CantSal)= 0 THEN 0 
								ELSE ((@TotalSaldoAnt - (@PUSaldoAnt * CantSal))/(@CantSaldoAnt - CantSal)) 
					END
		WHERE Fila=@Sec
	END		
	
	SET @Sec=@Sec+1
END

SELECT	MovimientoDetId,CAST(Fecha AS DATE) 'Fecha',Concepto,
		CantEnt,PUEnt,TotalEnt,CantSal,PUSal,TotalSal,CantSaldo,PUSaldo,TotalSaldo
FROM @tmpKardex










GO
/****** Object:  StoredProcedure [ALMACEN].[usp_ListarSerieKardex]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
EXEC ALMACEN.usp_ListarSerieKardex 1612
*/
CREATE PROC [ALMACEN].[usp_ListarSerieKardex]
@MovimientoDetalleId INT,
@IndStock BIT=0
AS
DECLARE @AlmacenId INT,@ArticuloId INT,@IndEntrada BIT,@Fecha DATETIME

SELECT @AlmacenId=M.AlmacenId, @ArticuloId=MD.ArticuloId,@IndEntrada=TM.IndEntrada,@Fecha=M.Fecha
FROM ALMACEN.MovimientoDet MD
INNER JOIN ALMACEN.Movimiento M ON MD.MovimientoId = M.MovimientoId
INNER JOIN ALMACEN.TipoMovimiento TM ON M.TipoMovimientoId = TM.TipoMovimientoId
WHERE MovimientoDetId=@MovimientoDetalleId

IF @IndStock=1
BEGIN
	SELECT	STUFF((SELECT ', ' + rtrim(convert(char(15),NumeroSerie))
	FROM	ALMACEN.SerieArticulo b 
	INNER JOIN ALMACEN.MovimientoDet MD ON b.MovimientoDetEntId = MD.MovimientoDetId
	INNER JOIN ALMACEN.Movimiento M ON MD.MovimientoId = M.MovimientoId
	LEFT JOIN ALMACEN.MovimientoDet MDS ON b.MovimientoDetSalId = MDS.MovimientoDetId
	LEFT JOIN ALMACEN.Movimiento MS ON MDS.MovimientoId = MS.MovimientoId
	WHERE	b.ArticuloId=@ArticuloId AND b.AlmacenId=@AlmacenId
	AND ((b.EstadoId IN(2,3) AND M.Fecha<=@Fecha)  OR
			(b.EstadoId =4 AND M.Fecha<=@Fecha AND MS.Fecha>@Fecha))
	FOR XML PATH('')),1,1,'') 'Series'
	
END
ELSE
BEGIN
	IF @IndEntrada=1
	BEGIN
		SELECT	STUFF((SELECT ', ' + rtrim(convert(char(15),NumeroSerie))
		FROM	ALMACEN.SerieArticulo b 
		WHERE	ArticuloId=@ArticuloId AND AlmacenId=@AlmacenId AND MovimientoDetEntId=@MovimientoDetalleId
		FOR XML PATH('')),1,1,'') 'Series'	
	END
	ELSE
	BEGIN
		SELECT	STUFF((SELECT ', ' + rtrim(convert(char(15),NumeroSerie))
		FROM	ALMACEN.SerieArticulo b 
		WHERE	ArticuloId=@ArticuloId AND AlmacenId=@AlmacenId AND MovimientoDetSalId=@MovimientoDetalleId
		FOR XML PATH('')),1,1,'') 'Series'	
	END	
	
END



GO
/****** Object:  StoredProcedure [ALMACEN].[usp_Movimiento_Upd]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ALMACEN].[usp_Movimiento_Upd]
	@Flag INT = 1,
	@MovimientoId INT,
	@TipoMovimientoId INT=0,
	@FechaMov DATE=NULL,
	@Observacion VARCHAR(MAX)=NULL
AS

DECLARE @Retorno VARCHAR(50) = ''

IF @Flag=1 --DESCONFIRMAR MOVIMIENTO
BEGIN
	
	IF NOT EXISTS(SELECT 1 FROM ALMACEN.MovimientoDet MD
				INNER JOIN ALMACEN.SerieArticulo SA ON MD.MovimientoDetId = SA.MovimientoDetEntId
				WHERE MD.MovimientoId=@MovimientoId AND SA.EstadoId<>2
			)
	BEGIN
		
		UPDATE ALMACEN.Movimiento SET EstadoId=1
		WHERE MovimientoId=@MovimientoId
		
		UPDATE SA
		SET SA.EstadoId = 1
		FROM ALMACEN.MovimientoDet MD
		INNER JOIN ALMACEN.SerieArticulo SA ON MD.MovimientoDetId = SA.MovimientoDetEntId
		WHERE MD.MovimientoId=@MovimientoId
		
		SET @Retorno='UPD'
	END
	
	SELECT ISNULL(@Retorno,'') 'Retorno'
	RETURN
END
IF @Flag=2 --ACTUALIZAR MOVIMIENTO
BEGIN
	
	UPDATE	ALMACEN.Movimiento 
	SET		TipoMovimientoId=@TipoMovimientoId,
			Fecha=@FechaMov,
			Observacion=@Observacion
	WHERE	MovimientoId=@MovimientoId
		
	SELECT '' 'Retorno'

	RETURN
END
IF @Flag=3 --CONFIRMAR MOVIMIENTO
BEGIN
	
	IF NOT EXISTS( SELECT 1 FROM ALMACEN.MovimientoDet WHERE MovimientoId=@MovimientoId)
	BEGIN
		SELECT 'Esta Acción requiere que ingrese un Detalle.' 'Retorno'
		RETURN 
	END
	
	UPDATE ALMACEN.Movimiento SET EstadoId=2
	WHERE MovimientoId=@MovimientoId
	
	UPDATE SA
	SET SA.EstadoId = 2
	FROM ALMACEN.MovimientoDet MD
	INNER JOIN ALMACEN.SerieArticulo SA ON MD.MovimientoDetId = SA.MovimientoDetEntId
	WHERE MD.MovimientoId=@MovimientoId
	
	SELECT '' 'Retorno'
	RETURN
END
GO
/****** Object:  StoredProcedure [ALMACEN].[usp_ReporteStock]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 -- EXEC [ALMACEN].[usp_ReporteStock] 1
CREATE PROC [ALMACEN].[usp_ReporteStock]
@OficinaId INT
AS
;WITH STOCK AS(
	SELECT SA.ArticuloId,COUNT(1) 'Stock' 
	FROM ALMACEN.SerieArticulo SA
	INNER JOIN ALMACEN.Almacen A ON SA.AlmacenId = A.AlmacenId
	WHERE EstadoId=2 AND A.OficinaId = ISNULL(@OficinaId,A.OficinaId)
	GROUP BY SA.ArticuloId
	HAVING COUNT(1)>0
)
SELECT	ROW_NUMBER() OVER(ORDER BY A.TipoArticuloId , A.Denominacion) 'Nro',
		TA.Denominacion 'TipoArticulo',A.ArticuloId,A.Denominacion 'Articulo', ISNULL(S.Stock,0) 'Stock',
		LTRIM(
			STUFF((SELECT ', ' + RTRIM(convert(char(15),NumeroSerie))
			FROM	ALMACEN.SerieArticulo b 
			INNER JOIN ALMACEN.Almacen AL ON  b.AlmacenId = AL.AlmacenId
			WHERE	b.ArticuloId=A.ArticuloId AND AL.OficinaId=ISNULL(@OficinaId,AL.OficinaId) AND b.EstadoId=2
			FOR XML PATH('')),1,1,'')
		) 'Series'
FROM ALMACEN.Articulo A
INNER JOIN STOCK S ON A.ArticuloId=S.ArticuloId
INNER JOIN ALMACEN.TipoArticulo TA ON A.TipoArticuloId = TA.TipoArticuloId
ORDER BY A.TipoArticuloId , A.Denominacion


GO
/****** Object:  StoredProcedure [CREDITO].[usp_ActualizarSaldosBoveda]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [CREDITO].[usp_ActualizarSaldosBoveda](@BovedaId INT)

AS
DECLARE @Entradas DECIMAL(16,2), @Salidas DECIMAL(16,2), @SaldoInicial DECIMAL(16,2)

BEGIN 

	SELECT @Entradas = ISNULL(SUM(Importe),0) FROM credito.bovedamov 
	WHERE BovedaId= @BovedaId AND indEntrada = 1 AND Estado= 1
	
	SELECT @Salidas = ISNULL(SUM(Importe),0)  FROM credito.bovedamov 
	WHERE BovedaId= @BovedaId AND indEntrada = 0 AND Estado= 1

	SET @SaldoInicial = (SELECT SaldoInicial FROM CREDITO.BOVEDA 
						WHERE BovedaId= @BovedaId AND IndCierre = 0)
	
	UPDATE CREDITO.BOVEDA SET Entradas = @Entradas, Salidas = @Salidas ,
	SaldoFinal = @SaldoInicial + @Entradas - @Salidas 
	WHERE BovedaId = @BovedaId AND IndCierre = 0
	
END
GO
/****** Object:  StoredProcedure [CREDITO].[usp_CalcularTEM]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--DECLARE @tem TABLE(Capital DECIMAL(18,16))
--INSERT INTO @tem
--exec [CREDITO].[usp_CalcularTEM] 19.2,'M'
--select * from @tem

/*
exec [CREDITO].[usp_CalcularTEM] 19.2,'M'
*/

CREATE PROC [CREDITO].[usp_CalcularTEM] ( @TEA DECIMAL(4,2) , @FormaPago CHAR(1) )
AS
DECLARE @TEM DECIMAL(18,16) 
DECLARE @PeriodoAnio INT= CASE @FormaPago WHEN 'M' THEN 12 WHEN 'Q' THEN 24 WHEN 'S' THEN 52 WHEN 'D' THEN 360 END
SET @TEM = (POWER(CAST(1+(@TEA/100) AS FLOAT),CAST(1.0/@PeriodoAnio AS FLOAT)))-1

SELECT @TEM 'TEM'
GO
/****** Object:  StoredProcedure [CREDITO].[usp_Credito_Del]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [CREDITO].[usp_Credito_Del]
@CreditoId INT,
@Observacion VARCHAR(MAX),
@UsuarioId INT
AS

DECLARE @OrdenVentaId INT,@EstadoEnAlmacen INT=2

SELECT @OrdenVentaId = OrdenVentaId FROM CREDITO.Credito
WHERE CreditoId = @CreditoId

UPDATE CREDITO.Credito SET Estado='ANU',Observacion=@Observacion , UsuarioModId=@UsuarioId,FechaMod=GETDATE()
WHERE CreditoId=@CreditoId

UPDATE	CREDITO.CuentaxCobrar
SET		Estado = 'ANU'
WHERE CreditoId=@CreditoId		
		
UPDATE VENTAS.OrdenVenta SET Estado=0,MovimientoAlmacenId=NULL ,UsuarioModId=@UsuarioId,FechaMod=GETDATE()
WHERE OrdenVentaId=@OrdenVentaId 

UPDATE	SA
SET		SA.EstadoId=@EstadoEnAlmacen, 
		SA.MovimientoDetSalId = NULL
FROM VENTAS.OrdenVentaDet OVD
INNER JOIN VENTAS.OrdenVentaDetSerie OVDS ON OVD.OrdenVentaDetId = OVDS.OrdenVentaDetId
INNER JOIN ALMACEN.SerieArticulo SA ON SA.SerieArticuloId=OVDS.SerieArticuloId
WHERE OVD.OrdenVentaId=@OrdenVentaId

DELETE MD
FROM VENTAS.OrdenVenta OV
INNER JOIN ALMACEN.Movimiento M ON OV.MovimientoAlmacenId=M.MovimientoId
INNER JOIN ALMACEN.MovimientoDet MD ON M.MovimientoId = MD.MovimientoId
WHERE OV.OrdenVentaId=@OrdenVentaId

DELETE M
FROM VENTAS.OrdenVenta OV
INNER JOIN ALMACEN.Movimiento M ON OV.MovimientoAlmacenId=M.MovimientoId
WHERE OV.OrdenVentaId=@OrdenVentaId



GO
/****** Object:  StoredProcedure [CREDITO].[usp_Credito_Ins]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
/*
UPDATE CREDITO.SolicitudCredito SET EstadoId=1
DELETE FROM CREDITO.CuentaxCobrar
DELETE FROM CREDITO.PlanPago
DELETE FROM  CREDITO.Credito

SELECT * FROM CREDITO.Credito
SELECT * FROM CREDITO.PlanPago
SELECT * FROM CREDITO.SolicitudCredito
*/


-- CREDITO.usp_Credito_Ins 512,1,'V',0,800, 16,'CAP','M',12,19.80,'20160526','',1
CREATE PROC [CREDITO].[usp_Credito_Ins]
@SolicitudCreditoId INT,
@ProductoId INT,
@TipoCuota CHAR(1),
@MontoInicial DECIMAL(16,2),
@MontoCredito DECIMAL(16,2),
@MontoGastosAdm DECIMAL(16,2),
@IndGastoAdm CHAR(3),
@FormaPago CHAR(1), 
@NroCuotas INT, 
@Interes DECIMAL(4,2),
@FechaPrimerPago DATE,
@Observacion VARCHAR(MAX),
@UsuarioId INT 
AS

DECLARE @Mensaje VARCHAR(100)='', @MontoGA DECIMAL(16,2)=0, @Desembolso DECIMAL(16,2) = @MontoCredito

IF EXISTS(SELECT 1 FROM CREDITO.Credito WHERE CreditoId=@SolicitudCreditoId AND Estado<>'CRE')
BEGIN
	SET @Mensaje='ERROR: La Solicitud debe estar en estado CREADA'
	SELECT @Mensaje 'Mensaje'
	RETURN
END

IF @IndGastoAdm='CUO'
	SET @MontoGA=@MontoGastosAdm

IF @IndGastoAdm='CAP'
	SET @Desembolso = @MontoCredito - @MontoGastosAdm

/*CREACION PLAN PAGOS*/
DECLARE @tPlanPagos TABLE(Numero INT,Capital DECIMAL(16,2),FechaPago DATE,Amortizacion DECIMAL(16,2),Interes DECIMAL(16,2),GastosAdm DECIMAL(16,2),Cuota DECIMAL(16,2))
INSERT INTO @tPlanPagos
EXEC CREDITO.usp_SimuladorCredito @TipoCuota, @FormaPago, @MontoCredito, @NroCuotas ,@Interes, @FechaPrimerPago,@MontoGA

INSERT INTO CREDITO.PlanPago ( CreditoId ,Numero ,Capital ,FechaVencimiento ,Amortizacion ,Interes,GastosAdm ,Cuota,Estado)
SELECT @SolicitudCreditoId 'CreditoId', *, 'CRE' FROM @tPlanPagos

/*ACTUALIZAR CREDITO*/
UPDATE CREDITO.Credito 
SET Estado='PEN' , 
FechaPrimerPago=@FechaPrimerPago,Interes=@Interes,
FormaPago=@FormaPago,NumeroCuotas=@NroCuotas,
MontoInicial=@MontoInicial,MontoGastosAdm=@MontoGastosAdm,MontoCredito=@MontoCredito, MontoDesembolso = @Desembolso,
TipoGastoAdm=@IndGastoAdm,
ProductoId=@ProductoId,
Observacion=@Observacion,
TipoCuota=@TipoCuota,
FechaMod=GETDATE(),UsuarioModId=@UsuarioId,
FechaVencimiento=(SELECT MAX(FechaPago) FROM @tPlanPagos)
WHERE CreditoId=@SolicitudCreditoId

SELECT @Mensaje 'Mensaje'		

GO
/****** Object:  StoredProcedure [CREDITO].[usp_Credito_Upd]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* 

SELECT * FROM CREDITO.Credito	
SELECT * FROM CREDITO.PlanPago
SELECT * FROM CREDITO.SolicitudCredito
SELECT * FROM CREDITO.CuentaxCobrar
SELECT * FROM VENTAS.OrdenVenta


[CREDITO].[usp_Credito_Upd] 1, 29,1
*/



CREATE PROC [CREDITO].[usp_Credito_Upd]
@Opcion INT = 1,
@CreditoId INT = 0,
@UsuarioId INT 
AS
BEGIN
	IF @Opcion = 0 -- PRIMERA APROBACION
	BEGIN
		UPDATE CREDITO.Credito SET Estado='AP1' WHERE CreditoId=@CreditoId
		INSERT INTO CREDITO.Aprobacion
		        ( CreditoId, Nivel, UsuarioId, Fecha )
		VALUES  ( @CreditoId, 1, @UsuarioId, GETDATE()  )

	END

	IF @Opcion = 1 -- APROBAR CREDITO - SEGUNDA APROBACION
	BEGIN
		DECLARE @TipoMovSalidaxVenta INT=2 , @EstMovVendido INT =3, @MovimientoId INT,@AlmacenId INT,
		@OrdenVentaId INT , @EstadoVendido INT=4
		
		IF EXISTS(SELECT 1 FROM CREDITO.Credito WHERE CreditoId=@CreditoId AND MontoInicial>0)
		BEGIN
			INSERT INTO CREDITO.CuentaxCobrar( Operacion,Monto ,Estado ,CreditoId)
			SELECT 'INI',MontoInicial,'PEN',CreditoId
			FROM CREDITO.Credito WHERE CreditoId=@CreditoId
		END
		IF EXISTS(SELECT 1 FROM CREDITO.Credito WHERE CreditoId=@CreditoId AND MontoGastosAdm>0)
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM CREDITO.PlanPago WHERE CreditoId=@CreditoId AND GastosAdm>0)
				INSERT INTO CREDITO.CuentaxCobrar( Operacion,Monto ,Estado ,CreditoId)
				SELECT 'GAD',MontoGastosAdm,'PEN',CreditoId
				FROM CREDITO.Credito WHERE CreditoId=@CreditoId
		END
		
		UPDATE CREDITO.Credito 
		SET Estado='APR',FechaAprobacion=GETDATE(),FechaDesembolso=GETDATE(),
			FechaMod=GETDATE(), UsuarioModId=@UsuarioId
		WHERE CreditoId = @CreditoId

		INSERT INTO CREDITO.Aprobacion
		        ( CreditoId, Nivel, UsuarioId, Fecha )
		VALUES  ( @CreditoId, 2, @UsuarioId, GETDATE()  )
		
		UPDATE CREDITO.PlanPago 
		SET Estado='PEN', FechaMod=GETDATE(), UsuarioModId=@UsuarioId
		WHERE CreditoId = @CreditoId
				
		
		SELECT @OrdenVentaId = OrdenVentaId 
		FROM CREDITO.Credito
		WHERE CreditoId=@CreditoId
		
		IF EXISTS(SELECT 1 FROM VENTAS.OrdenVenta WHERE OrdenVentaId = @OrdenVentaId AND Estado='ENT')
			RETURN
					
		SELECT @AlmacenId= AlmacenId
		FROM	VENTAS.OrdenVenta OV
		INNER JOIN ALMACEN.Almacen A ON OV.OficinaId = A.OficinaId AND A.Estado=1
		WHERE	OV.OrdenVentaId = @OrdenVentaId
		
		INSERT INTO ALMACEN.Movimiento ( TipoMovimientoId ,AlmacenId ,Fecha ,SubTotal ,IGV , 
				AjusteRedondeo ,TotalImporte ,EstadoId ,Observacion )
		SELECT	@TipoMovSalidaxVenta 'TipoMovimientoId', @AlmacenId 'AlmacenId', GETDATE() 'Fecha', OV.Subtotal,OV.TotalImpuesto,0 'AjusteRedondeo',
				OV.TotalNeto, @EstMovVendido 'EstadoId', 'Nro Orden:' + CAST(@OrdenVentaId AS VARCHAR(20)) 'Observacion'	
		FROM	VENTAS.OrdenVenta OV
		WHERE	OV.OrdenVentaId = @OrdenVentaId
		
		SELECT @MovimientoId=@@IDENTITY
		
		INSERT INTO ALMACEN.MovimientoDet
		(	MovimientoId ,ArticuloId ,Cantidad ,Descripcion ,PrecioUnitario ,
			Descuento ,Importe ,IndCorrelativo )
		SELECT	@MovimientoId 'MovimientoId', ArticuloId,Cantidad,Descripcion,
				ValorVenta,Descuento,Subtotal,0 'IndicadorCorrelativo'
		FROM	VENTAS.OrdenVentaDet
		WHERE	OrdenVentaId = @OrdenVentaId
		
		UPDATE	VENTAS.OrdenVenta 
		SET		Estado='ENT',MovimientoAlmacenId=@MovimientoId,FechaMod=GETDATE(),UsuarioModId=@UsuarioId
		WHERE	OrdenVentaId = @OrdenVentaId
				
		UPDATE	SA
		SET		SA.EstadoId=@EstadoVendido, 
				SA.MovimientoDetSalId = MD.MovimientoDetId
		FROM VENTAS.OrdenVenta OV
		INNER JOIN VENTAS.OrdenVentaDet OVD ON OV.OrdenVentaId = OVD.OrdenVentaId
		INNER JOIN VENTAS.OrdenVentaDetSerie OVDS ON OVD.OrdenVentaDetId = OVDS.OrdenVentaDetId
		INNER JOIN ALMACEN.SerieArticulo SA ON OVDS.SerieArticuloId = SA.SerieArticuloId
		INNER JOIN ALMACEN.Movimiento M ON OV.MovimientoAlmacenId=M.MovimientoId
		INNER JOIN ALMACEN.MovimientoDet MD ON M.MovimientoId = MD.MovimientoId AND MD.ArticuloId=SA.ArticuloId
		WHERE OV.OrdenVentaId = @OrdenVentaId
			
	END
	
	--SELECT * FROM ALMACEN.SerieArticulo
END

GO
/****** Object:  StoredProcedure [CREDITO].[usp_CuotasPendientes]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
	SELECT * FROM CREDITO.Credito where estado='DES'
	SELECT * FROM CREDITO.PlanPago where creditoid=88
	CREDITO.usp_CuotasPendientes 292,'20140806',1
	
*/
CREATE PROC [CREDITO].[usp_CuotasPendientes]
@CreditoId INT,
@FechaCalculo DATE,
@IndCancelacion BIT = 0
AS

DECLARE @CuotaCalculo INT,@CuotaIni INT,@CuotaFin INT,@CuotaCancel INT,@Modalidad CHAR(1), @FechaVctoIni DATE

IF @IndCancelacion=1
BEGIN
	SELECT	TOP 1 @CuotaCalculo=Numero 
	FROM	CREDITO.PlanPago PP
	WHERE	PP.CreditoId=@CreditoId AND PP.Estado='PEN' AND @FechaCalculo<=PP.FechaVencimiento 
	ORDER BY Numero

	IF @CuotaCalculo IS NULL
		SELECT	TOP 1 @CuotaCalculo=MAX(Numero) 
		FROM	CREDITO.PlanPago PP
		WHERE	PP.CreditoId=@CreditoId AND PP.Estado='PEN' 

	SELECT @CuotaFin = CASE FormaPago 
								WHEN 'M' THEN  @CuotaCalculo
								WHEN 'Q' THEN  CEILING(CAST(@CuotaCalculo AS DECIMAL)/2) * 2
								WHEN 'S' THEN  CEILING(CAST(@CuotaCalculo AS DECIMAL)/4) * 4
								WHEN 'D' THEN  CEILING(CAST(@CuotaCalculo AS DECIMAL)/26) * 26
						 END,
			@CuotaIni = CASE FormaPago 
								WHEN 'M' THEN  @CuotaCalculo
								WHEN 'Q' THEN  CEILING(CAST(@CuotaCalculo AS DECIMAL)/2) * 2 - 1
								WHEN 'S' THEN  CEILING(CAST(@CuotaCalculo AS DECIMAL)/4) * 4 - 3
								WHEN 'D' THEN  CEILING(CAST(@CuotaCalculo AS DECIMAL)/26) * 26 - 25
						 END,
			@Modalidad=FormaPago
	FROM CREDITO.Credito WHERE CreditoId=@CreditoId

	SET @CuotaCancel=@CuotaFin
	
	IF @Modalidad='D'
	BEGIN
		SELECT @FechaVctoIni=FechaVencimiento FROM CREDITO.PlanPago WHERE CreditoId=@CreditoId AND Numero=@CuotaIni
		IF DATEDIFF(DAY,@FechaVctoIni,@FechaCalculo)<2
			SET @CuotaCancel=@CuotaCalculo
	END
	ELSE IF @Modalidad='M'
	BEGIN
		IF @CuotaCalculo>1
			SELECT @FechaVctoIni=FechaVencimiento FROM CREDITO.PlanPago WHERE CreditoId=@CreditoId AND Numero=@CuotaCalculo-1
		ELSE
			SELECT @FechaVctoIni=DATEADD(MONTH,-1,FechaVencimiento) FROM CREDITO.PlanPago WHERE CreditoId=@CreditoId AND Numero=1
			
		SET @FechaVctoIni=DATEADD(DAY,1,@FechaVctoIni)
		--SELECT @FechaVctoIni 'VctoIni',@FechaCalculo 'FCalculo',DATEDIFF(DAY,@FechaVctoIni,@FechaCalculo)
		IF DATEDIFF(DAY,@FechaVctoIni,@FechaCalculo)<2
			SET @CuotaCancel=@CuotaCalculo - 1		
	END
	ELSE
	BEGIN		
		IF @CuotaCalculo = @CuotaIni
			BEGIN
				IF @CuotaCalculo>1
					SELECT @FechaVctoIni=FechaVencimiento FROM CREDITO.PlanPago WHERE CreditoId=@CreditoId AND Numero=@CuotaCalculo-1
				ELSE
				BEGIN
					IF @Modalidad='Q'
						SELECT @FechaVctoIni=DATEADD(day,-15,FechaVencimiento) FROM CREDITO.PlanPago WHERE CreditoId=@CreditoId AND Numero=1
					IF @Modalidad='S'
						SELECT @FechaVctoIni=DATEADD(day,-7,FechaVencimiento) FROM CREDITO.PlanPago WHERE CreditoId=@CreditoId AND Numero=1
				END	
				SET @FechaVctoIni=DATEADD(DAY,1,@FechaVctoIni)
				--SELECT @FechaVctoIni 'VctoIni',@FechaCalculo 'FCalculo',DATEDIFF(DAY,@FechaVctoIni,@FechaCalculo)
				IF DATEDIFF(DAY,@FechaVctoIni,@FechaCalculo)<0
					SET @CuotaCancel=0
				ELSE IF DATEDIFF(DAY,@FechaVctoIni,@FechaCalculo)<2
					SET @CuotaCancel=@CuotaCalculo
			END	
	END
	--SELECT @CuotaIni 'CuotaIni',@CuotaCalculo 'CuotaCalculo',@CuotaFin 'CuotaFin', @CuotaCancel 'CuotaCancelacion'
END

;WITH CUOTAS AS(
	SELECT	pp.PlanPagoId, 
			'CREDITO ' + CAST(C.CreditoId AS VARCHAR(12)) + ' - CUOTA ' + CAST(PP.Numero AS VARCHAR(8)) 'Glosa', 
			PP.Numero, PP.FechaVencimiento,PP.Amortizacion,PP.Interes,PP.GastosAdm, PP.Cuota ,
			dbo.ufnCalcularDiasAtrazo(pp.FechaVencimiento,@FechaCalculo) 'DiasAtrazo',
			ISNULL(P.ImporteMoratorio,0) 'ImporteMoratorio', ISNULL(P.DiasGracia,0) 'DiasGracia',
			ISNULL(PP.PagoLibre,0) 'PagoLibre',C.FechaDesembolso,PP.Cargo,
			CASE WHEN C.FormaPago='D' THEN 26 ELSE 30 END 'DiasMes'
	FROM CREDITO.Credito C 
	INNER JOIN CREDITO.PlanPago PP ON C.CreditoId = PP.CreditoId AND PP.Estado='PEN'
	LEFT JOIN CREDITO.Producto P ON C.ProductoId=P.ProductoId
	WHERE C.Estado='DES' AND C.CreditoId=@CreditoId
), CUOTASREF AS(
	SELECT	C.*, dbo.ufnCalcularMora(C.ImporteMoratorio, C.DiasAtrazo,C.DiasGracia) 'ImporteMora',
			dbo.ufnCalcularMora((C.Interes+C.Amortizacion)*C.ImporteMoratorio/C.DiasMes, C.DiasAtrazo,C.DiasGracia) 'InteresMora',
			ISNULL(PN.FechaVencimiento,C.FechaDesembolso) 'FechaPagoAnt'
	FROM CUOTAS C
	LEFT JOIN CREDITO.PlanPago PN ON PN.Numero=C.Numero-1 AND PN.CreditoId=@CreditoId
)
	SELECT	PlanPagoId, Glosa, FechaVencimiento, Amortizacion,Interes,GastosAdm,Cuota, 
			DiasAtrazo, ImporteMora, InteresMora, Cargo, PagoLibre, 
			Cuota + ImporteMora + InteresMora + Cargo - PagoLibre 'PagoCuota'
	FROM CUOTASREF 
	WHERE @IndCancelacion=0
UNION ALL
	SELECT	PlanPagoId, Glosa, FechaVencimiento, Amortizacion,
			CASE WHEN Numero>@CuotaCancel THEN 0 ELSE Interes END 'Interes',GastosAdm,
			CASE WHEN Numero>@CuotaCancel THEN Amortizacion + GastosAdm ELSE Cuota END 'Cuota', 
			DiasAtrazo, ImporteMora,InteresMora,Cargo,PagoLibre, 
			CASE WHEN Numero>@CuotaCancel 
			THEN Amortizacion + GastosAdm + ImporteMora + InteresMora + Cargo - PagoLibre 
			ELSE Cuota + ImporteMora + InteresMora + Cargo - PagoLibre END 'PagoCuota'			
	FROM CUOTASREF 
	WHERE @IndCancelacion=1
ORDER BY 1
GO
/****** Object:  StoredProcedure [CREDITO].[usp_EntradaSalidaCajaDiario]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*


*/
CREATE PROC [CREDITO].[usp_EntradaSalidaCajaDiario]
@CajaDiarioId INT ,
@PersonaId INT ,
@TipoOperacionId INT,
@Importe DECIMAL(16,2) = 0,
@Decripcion VARCHAR(MAX),
@UsuarioId INT
AS

DECLARE @IndEntrada BIT,@TipoOperacion CHAR(3)

SELECT @IndEntrada=IndEntrada , @TipoOperacion=Codigo
FROM MAESTRO.TipoOperacion 
WHERE TipoOperacionId=@TipoOperacionId

INSERT INTO CREDITO.MovimientoCaja
        ( CajaDiarioId,PersonaId ,Operacion ,ImporteRecibido ,ImportePago ,
          MontoVuelto ,Descripcion ,IndEntrada ,Estado ,UsuarioRegId ,FechaReg
        )
VALUES  ( @CajaDiarioId,@PersonaId, @TipoOperacion , 0, 
          @Importe , 0 , @Decripcion , @IndEntrada, 1, @UsuarioId , GETDATE())
        
/*actualizar caja diario*/
DECLARE @entradas DECIMAL(16,2)=0, @salidas DECIMAL(16,2)=0
SELECT @entradas=SUM(ImportePago) 
FROM CREDITO.MovimientoCaja
WHERE CajaDiarioId=@CajaDiarioId AND Estado=1 AND IndEntrada=1

SELECT @salidas=SUM(ImportePago) 
FROM CREDITO.MovimientoCaja
WHERE CajaDiarioId=@CajaDiarioId AND Estado=1 AND IndEntrada=0

UPDATE CREDITO.CajaDiario 
SET Entradas=ISNULL(@entradas,0) , Salidas = ISNULL(@salidas,0) , 
	SaldoFinal = SaldoInicial + ISNULL(@entradas,0) - ISNULL(@salidas,0)
WHERE CajaDiarioId=@CajaDiarioId

GO
/****** Object:  StoredProcedure [CREDITO].[usp_EstadoPlanPago]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- EXEC CREDITO.usp_EstadoPlanPago 2518
CREATE PROC [CREDITO].[usp_EstadoPlanPago] 
@CreditoId INT
AS

DECLARE @Fecha DATE = GETDATE()
DECLARE @tplanpago TABLE(PlanPagoId INT,Glosa VARCHAR(MAX),FechaVencimiento DATE,Amortizacion DECIMAL(16,2),
						Interes DECIMAL(16,2), GastosAdm DECIMAL(16,2), Cuota DECIMAL(16,2), DiasAtrazo INT,
						ImporteMora DECIMAL(16,2),InteresMora DECIMAL(16,2), Cargo DECIMAL(16,2),
						PagoLibre DECIMAL(16,2),PagoCuota DECIMAL(16,2))

INSERT INTO @tplanpago
EXEC CREDITO.usp_CuotasPendientes @CreditoId,@Fecha

SELECT	PP.PlanPagoId,PP.Numero,PP.Capital,PP.FechaVencimiento,PP.Amortizacion,PP.Interes,PP.GastosAdm,PP.Cuota,PP.Estado, 
		CASE WHEN PP.Estado='PEN' THEN P.DiasAtrazo ELSE PP.DiasAtrazo END 'DiasAtrazo', 
		CASE WHEN PP.Estado='PEN' THEN P.ImporteMora ELSE PP.ImporteMora END 'ImporteMora', 
		CASE WHEN PP.Estado='PEN' THEN P.InteresMora ELSE PP.InteresMora END 'InteresMora', 
		CASE WHEN PP.Estado='PEN' THEN P.Cargo ELSE PP.Cargo END 'Cargo', 
		CASE WHEN PP.Estado='PEN' THEN P.PagoLibre ELSE PP.PagoLibre END 'PagoLibre', 
		CASE WHEN PP.Estado='PEN' THEN NULL ELSE PP.FechaPagoCuota END 'FechaPagoCuota', 
		CASE WHEN PP.Estado='PEN' THEN P.PagoCuota ELSE PP.PagoCuota END 'PagoCuota',
		CASE WHEN PP.Estado='PEN' THEN null ELSE PP.MovimientoCajaId END 'MovimientoCajaId'
FROM	CREDITO.PlanPago  PP
LEFT JOIN @tplanpago P ON PP.PlanPagoId=P.PlanPagoId
WHERE	PP.CreditoId = @CreditoId
ORDER BY PP.Numero

GO
/****** Object:  StoredProcedure [CREDITO].[usp_MovimientoCaja_Del]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
[CREDITO].[usp_MovimientoCaja_Del] 43,'pruebas',3
*/
CREATE PROC [CREDITO].[usp_MovimientoCaja_Del] 
@MovimientoCajaId INT,
@Observacion VARCHAR(MAX),
@UsuarioId INT
AS

DECLARE @Operacion CHAR(3),@CreditoId INT,@OrdenVentaId INT,@CajaDiarioId INT,@EstadoEnAlmacen INT=2
SELECT @Operacion=Operacion,@CajaDiarioId=CajaDiarioId 
FROM CREDITO.MovimientoCaja 
WHERE MovimientoCajaId=@MovimientoCajaId

INSERT INTO CREDITO.MovimientoCajaAnu ( MovimientoCajaId ,Observacion ,UsuarioRegId ,FechaReg)
VALUES  ( @MovimientoCajaId , @Observacion ,@UsuarioId ,GETDATE())

IF @Operacion='CUO'
BEGIN	
	SELECT TOP 1 @CreditoId=CreditoId FROM CREDITO.PlanPago WHERE MovimientoCajaId = @MovimientoCajaId
	
	UPDATE CREDITO.PlanPago 
	SET MovimientoCajaId=NULL, Estado='PEN',DiasAtrazo=0,ImporteMora=0,InteresMora=0,PagoCuota=NULL,FechaPagoCuota=NULL 
	WHERE MovimientoCajaId = @MovimientoCajaId	
	
	DELETE FROM CREDITO.PlanPagoLibre WHERE MovimientoCajaId=@MovimientoCajaId
	
	;WITH PAGOLIBRE AS(
		SELECT PPL.PlanPagoId,SUM(PPL.PagoLibre) 'PagoLibre' 
		FROM CREDITO.PlanPagoLibre PPL
		INNER JOIN CREDITO.PlanPago PP ON PPL.PlanPagoId = PP.PlanPagoId
		WHERE PP.CreditoId=@CreditoId AND PP.Estado='PEN' 
		GROUP BY PPL.PlanPagoId
	)
	UPDATE PP
	SET PagoLibre = ISNULL(PL.PagoLibre,0)
	FROM CREDITO.PlanPago PP
	LEFT JOIN PAGOLIBRE PL ON PL.PlanPagoId = PP.PlanPagoId
	WHERE PP.CreditoId=@CreditoId AND PP.Estado='PEN' AND PP.PagoLibre>0
	
	UPDATE CREDITO.MovimientoCaja SET Estado=0 WHERE MovimientoCajaId = @MovimientoCajaId	
	UPDATE CREDITO.Credito SET Estado='DES',UsuarioModId=@UsuarioId,FechaMod=GETDATE() WHERE CreditoId=@CreditoId AND Estado='PAG'
END
ELSE
IF @Operacion='INI' OR @Operacion='GAD'
BEGIN	
	SELECT @CreditoId=CreditoId FROM CREDITO.CuentaxCobrar 
	WHERE MovimientoCajaId = @MovimientoCajaId
	
	UPDATE CREDITO.CuentaxCobrar SET MovimientoCajaId=NULL, Estado='PEN' WHERE MovimientoCajaId = @MovimientoCajaId	
	UPDATE CREDITO.MovimientoCaja SET Estado=0 WHERE MovimientoCajaId = @MovimientoCajaId	
	UPDATE CREDITO.Credito SET Estado='DES',UsuarioModId=@UsuarioId,FechaMod=GETDATE() WHERE CreditoId=@CreditoId AND Estado='PAG'
END
ELSE
IF @Operacion='CON'
BEGIN	
	DECLARE @MovimientoAlmacenId INT
	SELECT @OrdenVentaId = ov.OrdenVentaId ,@MovimientoAlmacenId = OV.MovimientoAlmacenId
	FROM CREDITO.MovimientoCaja mc
	INNER JOIN VENTAS.OrdenVenta ov ON ov.OrdenVentaId = mc.OrdenVentaId
	WHERE mc.MovimientoCajaId = @MovimientoCajaId
			
	UPDATE CREDITO.CuentaxCobrar SET Estado='ANU' WHERE MovimientoCajaId = @MovimientoCajaId	
	UPDATE CREDITO.MovimientoCaja SET Estado=0 WHERE MovimientoCajaId = @MovimientoCajaId	
	UPDATE VENTAS.OrdenVenta SET Estado=0,MovimientoAlmacenId=NULL ,UsuarioModId=@UsuarioId,FechaMod=GETDATE()
	WHERE OrdenVentaId=@OrdenVentaId 
	
	UPDATE	SA
	SET		SA.EstadoId=@EstadoEnAlmacen, 
			SA.MovimientoDetSalId = NULL
	FROM VENTAS.OrdenVentaDet OVD
	INNER JOIN VENTAS.OrdenVentaDetSerie OVDS ON OVD.OrdenVentaDetId = OVDS.OrdenVentaDetId
	INNER JOIN ALMACEN.SerieArticulo SA ON SA.SerieArticuloId=OVDS.SerieArticuloId
	WHERE OVD.OrdenVentaId=@OrdenVentaId
	
	DELETE FROM ALMACEN.MovimientoDet WHERE MovimientoId=@MovimientoAlmacenId
	DELETE FROM ALMACEN.Movimiento WHERE MovimientoId=@MovimientoAlmacenId
	
END
ELSE
BEGIN
	UPDATE CREDITO.MovimientoCaja SET Estado=0 WHERE MovimientoCajaId = @MovimientoCajaId	
END

/*actualizar caja diario*/
DECLARE @entradas DECIMAL(16,2)=0, @salidas DECIMAL(16,2)=0
SELECT @entradas=SUM(ImportePago) 
FROM CREDITO.MovimientoCaja
WHERE CajaDiarioId=@CajaDiarioId AND Estado=1 AND IndEntrada=1

SELECT @salidas=SUM(ImportePago) 
FROM CREDITO.MovimientoCaja
WHERE CajaDiarioId=@CajaDiarioId AND Estado=1 AND IndEntrada=0

UPDATE CREDITO.CajaDiario 
SET Entradas=ISNULL(@entradas,0) , Salidas = ISNULL(@salidas,0) , 
	SaldoFinal = SaldoInicial + ISNULL(@entradas,0) - ISNULL(@salidas,0)
WHERE CajaDiarioId=@CajaDiarioId



GO
/****** Object:  StoredProcedure [CREDITO].[usp_PagarCuentaxCobrar]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [CREDITO].[usp_PagarCuentaxCobrar]
@OrdenVentaId INT=0,
@CuentaxCobrarId INT=0,
@CajaDiarioId INT,
@UsuarioId INT 
AS

DECLARE @MovimientoCajaId INT, @EstadoVendido INT=4,@CreditoId INT

IF @CuentaxCobrarId > 0--CREDITO
BEGIN	
	SELECT @OrdenVentaId=C.OrdenVentaId,@CreditoId=C.CreditoId
	FROM CREDITO.CuentaxCobrar CXC 
	INNER JOIN CREDITO.Credito C ON CXC.CreditoId = C.CreditoId
	WHERE CXC.CuentaxCobrarId=@CuentaxCobrarId
	
	INSERT INTO CREDITO.MovimientoCaja
			( CajaDiarioId ,Operacion,ImportePago ,ImporteRecibido ,MontoVuelto ,
			  PersonaId ,Descripcion ,IndEntrada ,Estado,OrdenVentaId,CreditoId ,UsuarioRegId ,FechaReg )
	SELECT @CajaDiarioId,C.Operacion ,C.Monto,C.Monto,0,
			CR.PersonaId,'ORDEN:' + CONVERT(VARCHAR(15),@OrdenVentaId), OP.IndEntrada,1 'Estado',@OrdenVentaId,@CreditoId,@UsuarioId , GETDATE()
	FROM CREDITO.CuentaxCobrar C 
	INNER JOIN CREDITO.Credito CR ON C.CreditoId = CR.CreditoId
	INNER JOIN MAESTRO.TipoOperacion OP ON OP.Codigo=C.Operacion
	WHERE C.CuentaxCobrarId=@CuentaxCobrarId

	SELECT @MovimientoCajaId=@@IDENTITY
	
	UPDATE CREDITO.CuentaxCobrar
	SET Estado= 'CAN', MovimientoCajaId=@MovimientoCajaId
	WHERE CuentaxCobrarId = @CuentaxCobrarId
END
ELSE --CONTADO
BEGIN
	INSERT INTO CREDITO.MovimientoCaja
			( CajaDiarioId ,Operacion,ImportePago ,ImporteRecibido ,MontoVuelto ,
			  PersonaId ,Descripcion ,IndEntrada ,Estado,OrdenVentaId,CreditoId ,UsuarioRegId ,FechaReg )
	SELECT @CajaDiarioId,'CON' Operacion ,OV.TotalNeto,OV.TotalNeto,0,
			OV.PersonaId,'ORDEN:' + CONVERT(VARCHAR(15),@OrdenVentaId), 1 'IndEntrada',1 'Estado',@OrdenVentaId,NULL 'CreditoId',@UsuarioId , GETDATE()
	FROM VENTAS.OrdenVenta OV 
	WHERE OV.OrdenVentaId=@OrdenVentaId
	
	SELECT @MovimientoCajaId=@@IDENTITY	
	
	DECLARE @AlmacenId INT,@MovimientoId INT,@TipoMovSalidaxVenta INT=2 , @EstMovVendido INT =3	
	IF EXISTS(SELECT 1 FROM VENTAS.OrdenVenta WHERE OrdenVentaId = @OrdenVentaId AND Estado='ENT')
		RETURN
				
	SELECT @AlmacenId= AlmacenId
	FROM	VENTAS.OrdenVenta OV
	INNER JOIN ALMACEN.Almacen A ON OV.OficinaId = A.OficinaId AND A.Estado=1
	WHERE	OV.OrdenVentaId = @OrdenVentaId
		
	INSERT INTO ALMACEN.Movimiento ( TipoMovimientoId ,AlmacenId ,Fecha ,SubTotal ,IGV , 
			AjusteRedondeo ,TotalImporte ,EstadoId ,Observacion )
	SELECT	@TipoMovSalidaxVenta 'TipoMovimientoId', @AlmacenId 'AlmacenId', GETDATE() 'Fecha', OV.Subtotal,OV.TotalImpuesto,0 'AjusteRedondeo',
			OV.TotalNeto, @EstMovVendido 'EstadoId', 'Nro Orden:' + CAST(@OrdenVentaId AS VARCHAR(20)) 'Observacion'	
	FROM	VENTAS.OrdenVenta OV
	WHERE	OV.OrdenVentaId = @OrdenVentaId
	
	SELECT @MovimientoId=@@IDENTITY
		
	INSERT INTO ALMACEN.MovimientoDet
	(	MovimientoId ,ArticuloId ,Cantidad ,Descripcion ,PrecioUnitario ,
		Descuento ,Importe ,IndCorrelativo )
	SELECT	@MovimientoId 'MovimientoId', ArticuloId,Cantidad,Descripcion,
			ValorVenta,Descuento,Subtotal,0 'IndicadorCorrelativo'
	FROM	VENTAS.OrdenVentaDet
	WHERE	OrdenVentaId = @OrdenVentaId
	
	UPDATE	VENTAS.OrdenVenta 
	SET		Estado='ENT',MovimientoAlmacenId=@MovimientoId,FechaMod=GETDATE(),UsuarioModId=@UsuarioId
	WHERE	OrdenVentaId = @OrdenVentaId
			
	UPDATE	SA
	SET		SA.EstadoId=@EstadoVendido, 
			SA.MovimientoDetSalId = MD.MovimientoDetId
	FROM VENTAS.OrdenVenta OV
	INNER JOIN VENTAS.OrdenVentaDet OVD ON OV.OrdenVentaId = OVD.OrdenVentaId
	INNER JOIN VENTAS.OrdenVentaDetSerie OVDS ON OVD.OrdenVentaDetId = OVDS.OrdenVentaDetId
	INNER JOIN ALMACEN.SerieArticulo SA ON OVDS.SerieArticuloId = SA.SerieArticuloId
	INNER JOIN ALMACEN.Movimiento M ON OV.MovimientoAlmacenId=M.MovimientoId
	INNER JOIN ALMACEN.MovimientoDet MD ON M.MovimientoId = MD.MovimientoId AND MD.ArticuloId=SA.ArticuloId
	WHERE OV.OrdenVentaId = @OrdenVentaId
END
	
/*actualizar caja diario*/
DECLARE @entradas DECIMAL(16,2)=0, @salidas DECIMAL(16,2)=0
SELECT @entradas=SUM(ImportePago) 
FROM CREDITO.MovimientoCaja
WHERE CajaDiarioId=@CajaDiarioId AND Estado=1 AND IndEntrada=1

SELECT @salidas=SUM(ImportePago) 
FROM CREDITO.MovimientoCaja
WHERE CajaDiarioId=@CajaDiarioId AND Estado=1 AND IndEntrada=0

UPDATE CREDITO.CajaDiario 
SET Entradas=ISNULL(@entradas,0) , Salidas = ISNULL(@salidas,0) , 
	SaldoFinal = SaldoInicial + ISNULL(@entradas,0) - ISNULL(@salidas,0)
WHERE CajaDiarioId=@CajaDiarioId

SELECT @MovimientoCajaId
		
		
		
				
				
	
	
	


GO
/****** Object:  StoredProcedure [CREDITO].[usp_PagarCuotas]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
UPDATE CREDITO.PlanPago SET Estado='PEN', MovimientoCajaId=NULL,FechaPagoCuota=NULL, DiasAtrazo=0,Mora=0,PagoCuota=0
WHERE PlanPagoId IN(2)
DELETE FROM CREDITO.MovimientoCaja

EXEC CREDITO.usp_PagarCuotas 2,'2',100,3

SELECT * FROM CREDITO.PlanPago where planpagoid in(2)
SELECT * FROM CREDITO.MovimientoCaja
SELECT * FROM VENTAS.OrdenVenta

*/
CREATE PROC [CREDITO].[usp_PagarCuotas]
@CajaDiarioId INT ,
@CreditoId INT,
@ListaPlanPagoId VARCHAR(MAX),
@ImporteRecibido DECIMAL(16,2) = 0,
@UsuarioId INT,
@FechaPago DATE=NULL
AS

DECLARE @TotalPago DECIMAL(16,2)=0, @IndImporteLibre BIT = 0

IF @ListaPlanPagoId IS NULL
	SET @ListaPlanPagoId = ''
	
IF LEN(@ListaPlanPagoId) > 0 AND NOT EXISTS(	SELECT	1 FROM dbo.Split(@ListaPlanPagoId,',') L
												INNER JOIN CREDITO.PlanPago PP ON L.Name=pp.PlanPagoId
												WHERE PP.Estado='PEN' AND PP.CreditoId=@CreditoId)
BEGIN
	RETURN
END

IF @FechaPago IS NULL
	SET @FechaPago=GETDATE()

DECLARE @tCuotasPendientes TABLE(Id INT IDENTITY(1,1),PlanPagoId INT,Glosa VARCHAR(MAX),FechaVencimiento DATE,Amortizacion DECIMAL(16,2),
								Interes DECIMAL(16,2), GastosAdm DECIMAL(16,2), Cuota DECIMAL(16,2), DiasAtrazo INT,
								ImporteMora DECIMAL(16,2),InteresMora DECIMAL(16,2), Cargo DECIMAL(16,2),
								PagoLibre DECIMAL(16,2),PagoCuota DECIMAL(16,2))
INSERT INTO @tCuotasPendientes
EXEC CREDITO.usp_CuotasPendientes @CreditoId,@FechaPago
--SELECT * FROM @tCuotasPendientes

DECLARE @PlanPagoIdUlt INT,@SumaPagoCuotaUlt DECIMAL(16,2)=0
IF LEN(@ListaPlanPagoId) = 0
BEGIN
	DECLARE @NroCuotas INT=0,@PagoCuota DECIMAL(16,2)=0,@Index INT=1
	SET @NroCuotas = (SELECT COUNT(1) FROM @tCuotasPendientes)
	SET @PagoCuota = (SELECT TOP 1 PagoCuota FROM @tCuotasPendientes)
	SET @IndImporteLibre = 1
	
	WHILE @SumaPagoCuotaUlt <= @ImporteRecibido AND @Index <= @NroCuotas
	BEGIN
		SELECT @PagoCuota=PagoCuota, @PlanPagoIdUlt=PlanPagoId 
		FROM @tCuotasPendientes WHERE Id=@Index
		
		IF @SumaPagoCuotaUlt + @PagoCuota <= @ImporteRecibido
		BEGIN
			SET @SumaPagoCuotaUlt = @SumaPagoCuotaUlt + @PagoCuota
			SET @ListaPlanPagoId = @ListaPlanPagoId + CAST(@PlanPagoIdUlt AS VARCHAR(10)) + ','
		END
		ELSE
			BREAK
		SET @Index = @Index + 1
	END
	
	IF LEN(@ListaPlanPagoId)>0
		SET @ListaPlanPagoId = SUBSTRING(@ListaPlanPagoId,1,LEN(@ListaPlanPagoId)-1)
END
--SELECT @ListaPlanPagoId
UPDATE PP
SET DiasAtrazo= CP.DiasAtrazo ,
	ImporteMora=CP.ImporteMora,
	InteresMora=CP.InteresMora,
	PagoCuota = CP.PagoCuota
FROM dbo.Split(@ListaPlanPagoId,',') L 
INNER JOIN @tCuotasPendientes CP ON L.Name=CP.PlanPagoId
INNER JOIN CREDITO.PlanPago PP ON CP.PlanPagoId = PP.PlanPagoId
WHERE PP.CreditoId=@CreditoId

SELECT	@TotalPago = SUM(PP.PagoCuota) 
FROM dbo.Split(@ListaPlanPagoId,',') L
INNER JOIN CREDITO.PlanPago PP ON L.Name=pp.PlanPagoId
WHERE PP.Estado='PEN' AND PP.CreditoId=@CreditoId

DECLARE @Cuotas VARCHAR(MAX)='',@PersonaId INT, @OrdenVentaId INT
SELECT	@PersonaId = PersonaId , @OrdenVentaId = OrdenVentaId
FROM	CREDITO.Credito WHERE CreditoId = @CreditoId

SET @Cuotas = STUFF((SELECT ',' + rtrim(convert(char(15),Numero))
				FROM dbo.Split(@ListaPlanPagoId,',') L
				INNER JOIN CREDITO.PlanPago PP ON L.Name=pp.PlanPagoId
				FOR XML PATH('')),1,1,'') 
	
DECLARE @MovimientoCajaId INT
IF @IndImporteLibre=0
BEGIN
	INSERT INTO CREDITO.MovimientoCaja
			( CajaDiarioId,PersonaId ,Operacion ,ImporteRecibido ,ImportePago ,
			  MontoVuelto ,Descripcion ,IndEntrada ,Estado,OrdenVentaId,CreditoId,UsuarioRegId ,FechaReg
			)
	VALUES  ( @CajaDiarioId,@PersonaId, 'CUO' , @ImporteRecibido, @TotalPago , 
			  @ImporteRecibido -  @TotalPago, 'CREDITO ' + CAST(@CreditoId AS VARCHAR(20)) + ' CUOTA ' + @Cuotas  , 
			  1, 1,@OrdenVentaId,@CreditoId, @UsuarioId , GETDATE())
	SET @MovimientoCajaId = @@IDENTITY
END			  
ELSE
BEGIN
	-- PAGO IMPORTE LIBRE
	INSERT INTO CREDITO.MovimientoCaja
			( CajaDiarioId,PersonaId ,Operacion ,ImporteRecibido ,ImportePago ,
			  MontoVuelto ,Descripcion ,IndEntrada ,Estado,OrdenVentaId,CreditoId ,UsuarioRegId ,FechaReg
			)
	VALUES  ( @CajaDiarioId,@PersonaId, 'CUO' , @ImporteRecibido, @ImporteRecibido , 
			  0, 'CREDITO ' + CAST(@CreditoId AS VARCHAR(20)) + ISNULL(' CUOTA ' + @Cuotas,'') + ' PAGO LIBRE ' + CAST(@ImporteRecibido AS VARCHAR(20)) , 
			  1, 1,@OrdenVentaId,@CreditoId, @UsuarioId , GETDATE())
	SET @MovimientoCajaId = @@IDENTITY
	
	IF LEN(@ListaPlanPagoId)>0
		INSERT INTO CREDITO.PlanPagoLibre( PlanPagoId,MovimientoCajaId, PagoLibre)
		SELECT pp.PlanPagoId,@MovimientoCajaId,pp.PagoCuota
		FROM dbo.Split(@ListaPlanPagoId,',') L
		INNER JOIN CREDITO.PlanPago PP ON L.Name=pp.PlanPagoId
	
	IF @ImporteRecibido>@SumaPagoCuotaUlt 
	BEGIN
		SET @PlanPagoIdUlt = NULL
		IF LEN(@ListaPlanPagoId)>0
			SELECT TOP 1 @PlanPagoIdUlt = PlanPagoId FROM CREDITO.PlanPago PP
			LEFT JOIN dbo.Split(@ListaPlanPagoId,',') L ON L.Name=pp.PlanPagoId
			WHERE PP.CreditoId=@CreditoId AND PP.Estado='PEN' AND L.Name IS NULL 
			ORDER BY Numero ASC
		ELSE
			SELECT TOP 1 @PlanPagoIdUlt = PlanPagoId FROM CREDITO.PlanPago PP
			WHERE PP.CreditoId=@CreditoId AND PP.Estado='PEN' 
			ORDER BY Numero ASC
			
		IF @PlanPagoIdUlt IS NOT NULL
		BEGIN
			INSERT INTO CREDITO.PlanPagoLibre( PlanPagoId,MovimientoCajaId, PagoLibre)
			VALUES  ( @PlanPagoIdUlt, @MovimientoCajaId, @ImporteRecibido-@SumaPagoCuotaUlt)
			
			UPDATE CREDITO.PlanPago 
			SET PagoLibre=(SELECT SUM(PagoLibre) FROM CREDITO.PlanPagoLibre WHERE PlanPagoId=@PlanPagoIdUlt)
			WHERE PlanPagoId=@PlanPagoIdUlt
		END
	END	
	
	--;WITH PAGOLIBRE AS(
	--	SELECT PPL.PlanPagoId,SUM(PPL.PagoLibre) 'PagoLibre' 
	--	FROM CREDITO.PlanPagoLibre PPL
	--	INNER JOIN CREDITO.PlanPago PP ON PPL.PlanPagoId = PP.PlanPagoId
	--	WHERE PP.CreditoId=@CreditoId AND PP.Estado='PEN' 
	--	GROUP BY PPL.PlanPagoId
	--)
	--UPDATE PP
	--SET PagoLibre = PL.PagoLibre
	--FROM PAGOLIBRE PL
	--INNER JOIN CREDITO.PlanPago PP ON PL.PlanPagoId = PP.PlanPagoId
		
			
END	
        
UPDATE PP
SET Estado = 'PAG',MovimientoCajaId=@MovimientoCajaId,
	FechaPagoCuota=GETDATE(), UsuarioModId=@UsuarioId,FechaMod=GETDATE()
FROM dbo.Split(@ListaPlanPagoId,',') L
INNER JOIN CREDITO.PlanPago PP ON L.Name=pp.PlanPagoId
WHERE PP.Estado='PEN' AND PP.CreditoId=@CreditoId

/*actualizar caja diario*/
DECLARE @entradas DECIMAL(16,2)=0, @salidas DECIMAL(16,2)=0
SELECT @entradas=SUM(ImportePago) 
FROM CREDITO.MovimientoCaja
WHERE CajaDiarioId=@CajaDiarioId AND Estado=1 AND IndEntrada=1

SELECT @salidas=SUM(ImportePago) 
FROM CREDITO.MovimientoCaja
WHERE CajaDiarioId=@CajaDiarioId AND Estado=1 AND IndEntrada=0

UPDATE CREDITO.CajaDiario 
SET Entradas=ISNULL(@entradas,0) , Salidas = ISNULL(@salidas,0) , 
	SaldoFinal = SaldoInicial + ISNULL(@entradas,0) - ISNULL(@salidas,0)
WHERE CajaDiarioId=@CajaDiarioId

/*actualizar el credito*/

UPDATE	CREDITO.Credito
SET		Estado='PAG', UsuarioModId=@UsuarioId, FechaMod=GETDATE()
WHERE	CreditoId=@CreditoId AND
		NOT EXISTS(SELECT 1 FROM CREDITO.PlanPago WHERE CreditoId= @CreditoId AND Estado='PEN')

SELECT @MovimientoCajaId
GO
/****** Object:  StoredProcedure [CREDITO].[usp_PagarCuotasCancelacion]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
SELECT * FROM CREDITO.PlanPago WHERE CreditoId=16
EXEC [CREDITO].[usp_PagarCuotasCancelacion] 2,16,3,'20140311'
SELECT * FROM CREDITO.PlanPago WHERE CreditoId=13
SELECT * FROM CREDITO.CreditoPago

*/
CREATE PROC [CREDITO].[usp_PagarCuotasCancelacion]
@CajaDiarioId INT ,
@CreditoId INT,
@UsuarioId INT,
@FechaPago DATE=NULL
AS

DECLARE @ListaPlanPagoId VARCHAR(MAX)='',@PagoCuota DECIMAL(16,2)=0,@PlanPagoId INT,@Index INT=1, @SumaPagoCuota DECIMAL(16,2)=0,
		@NroCuotas INT=0

IF EXISTS(SELECT * FROM CREDITO.Credito WHERE Estado<>'DES' AND CreditoId=@CreditoId)
	RETURN
	
IF @FechaPago IS NULL
	SET @FechaPago=GETDATE()
	
DECLARE @tCuotasPendientes TABLE(Id INT IDENTITY(1,1),PlanPagoId INT,Glosa VARCHAR(MAX),FechaVencimiento DATE,Amortizacion DECIMAL(16,2),
								Interes DECIMAL(16,2), GastosAdm DECIMAL(16,2), Cuota DECIMAL(16,2), DiasAtrazo INT,
								ImporteMora DECIMAL(16,2),InteresMora DECIMAL(16,2), Cargo DECIMAL(16,2),
								PagoLibre DECIMAL(16,2),PagoCuota DECIMAL(16,2))
INSERT INTO @tCuotasPendientes
EXEC CREDITO.usp_CuotasPendientes @CreditoId,@FechaPago,1

UPDATE	PP
SET		Interes = P.Interes ,Cuota=P.Cuota ,PagoCuota=P.PagoCuota 
FROM	CREDITO.PlanPago PP
INNER JOIN @tCuotasPendientes P ON PP.PlanPagoId=P.PlanPagoId

SET @NroCuotas = (SELECT COUNT(1) FROM @tCuotasPendientes)

WHILE @Index<=@NroCuotas
BEGIN
	SELECT @PagoCuota=PagoCuota, @PlanPagoId=PlanPagoId 
	FROM @tCuotasPendientes WHERE Id=@Index
	
	SET @SumaPagoCuota=@SumaPagoCuota + @PagoCuota
	SET @ListaPlanPagoId = @ListaPlanPagoId + CAST(@PlanPagoId AS VARCHAR(10)) + ','
	SET @Index = @Index + 1
END

IF LEN(@ListaPlanPagoId)>0
BEGIN
	SET @ListaPlanPagoId = SUBSTRING(@ListaPlanPagoId,1,LEN(@ListaPlanPagoId)-1)
	--SELECT @SumaPagoCuota, @ListaPlanPagoId 
	EXEC CREDITO.usp_PagarCuotas @CajaDiarioId,@CreditoId,@ListaPlanPagoId,@SumaPagoCuota,@UsuarioId,@FechaPago
END



GO
/****** Object:  StoredProcedure [CREDITO].[usp_ReprogramarCredito]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [CREDITO].[usp_ReprogramarCredito]
@CreditoId INT,
@UsuarioId INT
AS

--DECLARE @CreditoId INT=91,@UsuarioId INT=3

DECLARE @Deuda DECIMAL(16,2)=0, @FechaAct DATE = GETDATE() 
DECLARE @tCuotasPendientes TABLE(Id INT IDENTITY(1,1),PlanPagoId INT,Glosa VARCHAR(MAX),FechaVencimiento DATE,Amortizacion DECIMAL(16,2),
								Interes DECIMAL(16,2), GastosAdm DECIMAL(16,2), Cuota DECIMAL(16,2), DiasAtrazo INT,
								ImporteMora DECIMAL(16,2),InteresMora DECIMAL(16,2), Cargo DECIMAL(16,2),
								PagoLibre DECIMAL(16,2),PagoCuota DECIMAL(16,2))
INSERT INTO @tCuotasPendientes
EXEC CREDITO.usp_CuotasPendientes @CreditoId,@FechaAct

SET @Deuda = (SELECT SUM(PagoCuota) FROM @tCuotasPendientes)

INSERT INTO	CREDITO.Credito
( OficinaId,PersonaId,ProductoId, Descripcion, MontoProducto, MontoInicial ,MontoGastosAdm ,MontoCredito ,
  FormaPago,NumeroCuotas,Interes,FechaPrimerPago,Observacion,Estado,FechaReg,UsuarioRegId,OrdenVentaId )
SELECT	OficinaId,PersonaId,ProductoId,Descripcion, @Deuda , 0 'Inicial' , 0 'GastoAdm', @Deuda,
		FormaPago,NumeroCuotas,Interes,GETDATE() 'PrimerPago','REPROGRAMADO CREDITO ' + CAST(@CreditoId AS VARCHAR(10)) 'Obs',
		'CRE',@FechaAct,@UsuarioId,OrdenVentaId
FROM CREDITO.Credito WHERE CreditoId=@CreditoId

--DECLARE @CreditoRep INT = @@IDENTITY
--UPDATE VENTAS.OrdenVenta SET CreditoId=@CreditoRep WHERE CreditoId=@CreditoId

UPDATE CREDITO.Credito SET Estado = 'REP'
WHERE CreditoId = @CreditoId

GO
/****** Object:  StoredProcedure [CREDITO].[usp_RptCredito]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM CREDITO.PlanPago WHERE CreditoId=45
EXEC CREDITO.usp_RptCredito 1,'20140101','20140501'

*/
CREATE PROC [CREDITO].[usp_RptCredito]
@OficinaId INT ,
@FechaDesIni DATE ,
@FechaDesFin DATE 
AS

SELECT	UPPER(PR.Denominacion) 'Producto',P.NombreCompleto 'Cliente',Descripcion 'Articulo',C.CreditoId,FechaDesembolso,
		(SELECT MAX(FechaVencimiento) FROM CREDITO.PlanPago WHERE CreditoId=C.CreditoId) 'FechaVcto',
		C.FormaPago,NumeroCuotas,Interes,C.Estado,
		C.MontoProducto,C.MontoInicial,MontoCredito,MontoGastosAdm				
FROM CREDITO.Credito C
INNER JOIN CREDITO.Producto PR ON C.ProductoId = PR.ProductoId
INNER JOIN MAESTRO.Persona P ON C.PersonaId = P.PersonaId
WHERE	C.OficinaId = ISNULL(@OficinaId,C.OficinaId) AND
		CAST(C.FechaDesembolso AS DATE) BETWEEN @FechaDesIni AND @FechaDesFin 
--ORDER BY C.FechaDesembolso

GO
/****** Object:  StoredProcedure [CREDITO].[usp_RptCreditoMorosidad]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM CREDITO.PlanPago WHERE CreditoId=45
[CREDITO].[usp_RptCreditoMorosidad] NULL,'20140601', 1,1000

*/
CREATE PROC [CREDITO].[usp_RptCreditoMorosidad]
@OficinaId INT = NULL,
@HastaFecha DATE  =NULL,
@DiasAtrazoIni INT,
@DiasAtrazoFin INT
AS

DECLARE @FechaAct DATE=GETDATE()
DECLARE @tblCreditoMora TABLE(id INT IDENTITY(1,1),CreditoId INT,CuotasAtrazo INT,CapitalAtrazo DECIMAL(16,2),GA DECIMAL(16,2),
							InteresAtrazo DECIMAL(16,2),Mora DECIMAL(16,2),ImporteLibre DECIMAL(16,2),DiasAtrazo INT,DeudaAtrazo DECIMAL(16,2))
DECLARE @tCuotasPendientes TABLE(Id INT IDENTITY(1,1),PlanPagoId INT,Glosa VARCHAR(MAX),FechaVencimiento DATE,Amortizacion DECIMAL(16,2),
								Interes DECIMAL(16,2), GastosAdm DECIMAL(16,2), Cuota DECIMAL(16,2), DiasAtrazo INT,
								ImporteMora DECIMAL(16,2),InteresMora DECIMAL(16,2), Cargo DECIMAL(16,2),
								PagoLibre DECIMAL(16,2),PagoCuota DECIMAL(16,2))

;WITH DESEMBOLSOS AS(
	SELECT	C.CreditoId,
			dbo.ufnCalcularDiasAtrazo(
				(SELECT MIN(FechaVencimiento) FROM CREDITO.PlanPago WHERE CreditoId=C.CreditoId AND Estado='PEN')
				,@FechaAct) 'DiasAtrazo'			
	FROM	CREDITO.Credito C
	WHERE	C.Estado='DES' AND C.OficinaId=ISNULL(@OficinaId,C.OficinaId) AND
			CAST(C.FechaDesembolso AS DATE) <= ISNULL(@HastaFecha, @FechaAct)
)
INSERT INTO @tblCreditoMora(CreditoId,DiasAtrazo)
SELECT	C.CreditoId,CM.DiasAtrazo
FROM CREDITO.Credito C
INNER JOIN DESEMBOLSOS CM ON C.CreditoId = CM.CreditoId
WHERE CM.DiasAtrazo BETWEEN @DiasAtrazoIni AND @DiasAtrazoFin	

DECLARE @index INT=1,@Filas INT = (SELECT COUNT(1) FROM @tblCreditoMora),@CreditoId INT
WHILE(@index<=@Filas)
BEGIN
	SELECT @CreditoId=CreditoId FROM @tblCreditoMora WHERE id=@index
	
	DELETE FROM @tCuotasPendientes
	INSERT INTO @tCuotasPendientes
	EXEC CREDITO.usp_CuotasPendientes @CreditoId,@FechaAct
	
	UPDATE @tblCreditoMora 
	SET CapitalAtrazo = (SELECT SUM(Amortizacion) FROM @tCuotasPendientes WHERE DiasAtrazo>0),
	GA = (SELECT SUM(GastosAdm) FROM @tCuotasPendientes WHERE DiasAtrazo>0),
	InteresAtrazo = (SELECT SUM(Interes + InteresMora) FROM @tCuotasPendientes WHERE DiasAtrazo>0),
	Mora = (SELECT SUM(ImporteMora) FROM @tCuotasPendientes WHERE DiasAtrazo>0),
	ImporteLibre = (SELECT SUM(PagoLibre) FROM @tCuotasPendientes WHERE DiasAtrazo>0),
	DiasAtrazo = (SELECT MAX(DiasAtrazo) FROM @tCuotasPendientes WHERE DiasAtrazo>0),
	CuotasAtrazo = (SELECT COUNT(1) FROM @tCuotasPendientes WHERE DiasAtrazo>0),
	DeudaAtrazo = (SELECT SUM(PagoCuota) FROM @tCuotasPendientes WHERE DiasAtrazo>0)
	WHERE CreditoId=@CreditoId
	
	SET @index=@index+1
END


SELECT	C.CreditoId,P.NombreCompleto 'Cliente',p.Direccion,p.Celular1 + ' ' + p.Celular2 'Celular',
		FechaDesembolso,(SELECT MAX(FechaVencimiento) FROM CREDITO.PlanPago WHERE CreditoId=C.CreditoId)'FechaVcto',
		Descripcion 'Articulo',MontoCredito,
		(SELECT SUM(Amortizacion) FROM CREDITO.PlanPago WHERE CreditoId=C.CreditoId AND Estado='PEN') 'SaldoCredito' ,
		(SELECT MAX(FechaPagoCuota) FROM CREDITO.PlanPago WHERE CreditoId=C.CreditoId AND Estado='PAG') 'FechaUltPago',
		CR.CapitalAtrazo,CR.GA,CR.InteresAtrazo,CR.Mora,CR.ImporteLibre,
		CR.DiasAtrazo,CR.CuotasAtrazo,CR.DeudaAtrazo
FROM CREDITO.Credito C
INNER JOIN @tblCreditoMora CR ON C.CreditoId = CR.CreditoId
INNER JOIN MAESTRO.Persona P ON C.PersonaId = P.PersonaId
ORDER BY P.NombreCompleto

GO
/****** Object:  StoredProcedure [CREDITO].[usp_RptCreditoRentabilidad]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- CREDITO.usp_RptCreditoRentabilidad 1,'20140201','20140630'
CREATE PROC [CREDITO].[usp_RptCreditoRentabilidad]
@OficnaId INT = NULL,
@FechaIni DATE ,
@FechaFin DATE 
AS

;WITH CREDITOSUM AS(
	SELECT CR.CreditoId,COUNT(1) 'CuotasPagadas', SUM(PP.Amortizacion) 'SumAmortizacion',SUM(PP.Interes) 'SumInteres',
	SUM(PP.GastosAdm) 'SumGastosAdm',SUM(PP.Cuota) 'SumCuota',SUM(PP.ImporteMora + PP.InteresMora) 'SumMora',
	SUM(PP.PagoCuota + PP.PagoLibre) 'SumPago'
	FROM CREDITO.Credito CR
	INNER JOIN CREDITO.PlanPago PP ON CR.CreditoId = PP.CreditoId AND PP.Estado='PAG'
	WHERE	CR.OficinaId=ISNULL(@OficnaId,CR.OficinaId) 
	AND CAST(CR.FechaDesembolso AS DATE) BETWEEN @FechaIni AND @FechaFin
	--check anulados
	GROUP BY CR.CreditoId
)
SELECT	C.CreditoId,O.Denominacion 'Oficina',P.NombreCompleto 'Cliente',
		C.FechaDesembolso,C.NumeroCuotas,C.Interes,C.FormaPago,c.Estado,
		C.MontoProducto,C.MontoInicial,C.MontoCredito,C.MontoGastosAdm,
		CS.CuotasPagadas,Cs.SumAmortizacion,CS.SumGastosAdm,CS.SumInteres,CS.SumCuota,CS.SumMora,CS.SumPago
FROM CREDITO.Credito C
INNER JOIN CREDITOSUM CS ON C.CreditoId = CS.CreditoId
INNER JOIN MAESTRO.Persona P ON C.PersonaId = P.PersonaId
INNER JOIN MAESTRO.Oficina O ON C.OficinaId = O.OficinaId
ORDER BY C.FechaDesembolso

GO
/****** Object:  StoredProcedure [CREDITO].[usp_RptSaldosCaja]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXEC CREDITO.usp_RptSaldosCaja 1

CREATE PROC [CREDITO].[usp_RptSaldosCaja]
@CajaDiarioId INT
AS

SELECT	MC.MovimientoCajaId, MC.Operacion, MC.FechaReg, P.NombreCompleto 'Cliente', ImportePago, IndEntrada,
		CASE WHEN IndEntrada=1 THEN dbo.ufnListarSerie(OrdenVentaId) ELSE MC.Descripcion END 'Glosa'
FROM CREDITO.MovimientoCaja MC
LEFT JOIN MAESTRO.Persona P ON MC.PersonaId = P.PersonaId
WHERE MC.CajaDiarioId=@CajaDiarioId AND MC.Estado=1 
ORDER BY FechaReg 





GO
/****** Object:  StoredProcedure [CREDITO].[usp_SimuladorCredito]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- CREDITO.usp_SimuladorCredito 'V','M',28833.34,10,19.02,'20121001'
CREATE PROC [CREDITO].[usp_SimuladorCredito]
@Tipo CHAR(1)='V',
@FormaPago CHAR(1)='M', 
@Monto DECIMAL(16,2) = 0.0,
@NroCuotas INT=24, 
@TEA DECIMAL(4,2)= 19,
@FechaPrimerPago DATE = '20150101',
@GastosAdm DECIMAL(16,2) = NULL
AS

DECLARE @FactorCompensacion DECIMAL(4,2) = 0.0 , @FRC DECIMAL(18,16)

--DECLARE @tTEM TABLE(t DECIMAL(18,16))
--INSERT INTO @tTEM EXEC [CREDITO].[usp_CalcularTEM] @TEA,@FormaPago
--DECLARE @TEM DECIMAL (18,16) 
--SELECT @TEM = t FROM @tTEM

DECLARE @PeriodoAnio INT= CASE @FormaPago WHEN 'M' THEN 12 WHEN 'Q' THEN 24 WHEN 'S' THEN 52 WHEN 'D' THEN 360 END
DECLARE @TEM DECIMAL (18,16) = (POWER(CAST(1+(@TEA/100) AS FLOAT),CAST(1.0/@PeriodoAnio AS FLOAT)))-1


SELECT @FactorCompensacion = Valor FROM MAESTRO.ValorTabla WHERE TablaId=3 AND DesCorta=@Tipo

SET @FRC = CAST((@TEM * POWER(1+@TEM,@NroCuotas)) AS FLOAT) / (-1 + POWER(1+@TEM,@NroCuotas))

--SELECT @Monto, @TEA, @TEM, @PeriodoAnio, @FechaPrimerPago, @FactorCompensacion,@FRC

DECLARE @Sec INT=0, @Capital DECIMAL(16,2)=@Monto,@Cuota DECIMAL(16,2)=0,@FechaCuota DATE=@FechaPrimerPago
DECLARE @Amortizacion DECIMAL(16,2)=@Monto/@NroCuotas,@Interes DECIMAL(16,2),@GastoAdmCuota DECIMAL(16,2)
DECLARE @tPlanPagos TABLE(Numero INT,Capital DECIMAL(16,2),FechaPago DATE,Amortizacion DECIMAL(16,2),Interes DECIMAL(16,2),GastosAdm DECIMAL(16,2),Cuota DECIMAL(16,2))

IF @GastosAdm IS NULL
BEGIN
	SET @GastosAdm = 0
	SELECT @GastosAdm = @GastosAdm + CASE WHEN IndPorcentaje=1 THEN @monto*(Valor/100) ELSE valor END
	FROM CREDITO.GastosAdm 
	WHERE Estado=1 AND @Monto BETWEEN MontoMinimo AND MontoMaximo
END
SET @GastoAdmCuota=@GastosAdm/@NroCuotas


WHILE (@Sec<@NroCuotas)
BEGIN
	SET @Sec=@Sec+1
	
	IF @FormaPago='D' --DIARIO
		IF datepart(dw, @FechaCuota) = 1 -- excluimos si es domingo
			SET @FechaCuota = DATEADD(DAY,1,@FechaCuota)
	
	IF @Tipo = 'V' 
		SET @Interes = @Capital - @Capital * POWER(1 - @TEM,CAST(@FactorCompensacion AS FLOAT) / (@FactorCompensacion - 1))
		
	IF @Tipo = 'F' 
	BEGIN
		SET @Interes = @Capital * @TEM
		SET @Cuota = @Monto * @FRC
		SET @Amortizacion = @Cuota - @Interes		
	END			
	
	INSERT INTO	@tPlanPagos(Numero,Capital,FechaPago,Amortizacion,Interes,GastosAdm, Cuota) 
		VALUES		(@Sec,@Capital,@FechaCuota,@Amortizacion,@Interes,@GastoAdmCuota, @Cuota)
	
	SET @Capital=@Capital-@Amortizacion
		
	IF @FormaPago='D' --DIARIO
		SET @FechaCuota = DATEADD(DAY,1,@FechaCuota)
	IF @FormaPago='S' --SEMANAL
		SET @FechaCuota = DATEADD(DAY,7,@FechaCuota)
	IF @FormaPago='Q' --QUINCENAL
		SET @FechaCuota = DATEADD(DAY,15,@FechaCuota)
	IF @FormaPago='M' --MENSUAL
		SET @FechaCuota = DATEADD(MONTH,1,@FechaCuota)
END

UPDATE	@tPlanPagos 
SET		Amortizacion = Capital, 
		GastosAdm = @GastosAdm - (@GastoAdmCuota * (@NroCuotas-1))
WHERE	Numero=@NroCuotas

UPDATE @tPlanPagos SET Cuota=Amortizacion+Interes+GastosAdm


SELECT * FROM @tPlanPagos
 








GO
/****** Object:  StoredProcedure [CREDITO].[usp_TransferirBoveda]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [CREDITO].[usp_TransferirBoveda](@BovedaInicioId INT,@BovedaDestinoId INT,@Glosa VARCHAR(MAX),
									  @Monto DECIMAL(16,2), @UsuarioRegId INT,@flagAceptar INT, 
									  @BovedaMovTempId INT=0)

AS
DECLARE @Estado BIT,@SaldoInicial DECIMAL(16,2),@Entradas DECIMAL(16,2),@Salidas DECIMAL(16,2),@IndCierre BIT, 
		@CodOperacion CHAR(3),@IndEntrada INT, @FechaReg DATETIME, @MovimientoBovedaIniId INT
		
		 		
SET @CodOperacion = 'TRE'
SET @SaldoInicial = 0
SET @Entradas = 0
SET @Salidas = 0
SET @Estado= 1
SET @IndCierre = 0
SET @IndEntrada = 1
SET @FechaReg = GETDATE()
set @MovimientoBovedaIniId = 0

BEGIN
IF @flagAceptar = 0
	BEGIN
	--Inserta BovedaMov Inicio
	INSERT INTO CREDITO.BovedaMov (BovedaId, CodOperacion,Glosa,Importe,IndEntrada,Estado,UsuarioRegId,FechaReg)
				VALUES(@BovedaInicioId, 'TRS',@Glosa, @Monto,0,@Estado,@UsuarioRegId,@FechaReg)		
	
	SELECT @MovimientoBovedaIniId = @@identity
	
	--Actualiza  Boveda Inicio
	EXEC CREDITO.usp_ActualizarSaldosBoveda @BovedaInicioId
	
	--Inserta BOVEDAMOVTEMP
	INSERT INTO CREDITO.BovedaMovTemp (BovedaInicioId,BovedaDestinoId,CodOperacion,Glosa,Importe,UsuarioRegId,MovimientoBovedaIniId,
										FechaReg,IndEntrada,Estado) VALUES (@BovedaInicioId,@BovedaDestinoId,@CodOperacion,
										@Glosa,@Monto,@UsuarioRegId,@MovimientoBovedaIniId,@FechaReg,@IndEntrada,@Estado)
	END
	 
IF @flagAceptar = 1
	BEGIN
	--Inserta BOVEDAMOV Destino
	INSERT INTO CREDITO.BovedaMov(BovedaId,CodOperacion, Glosa,Importe,IndEntrada,
								  UsuarioRegId, FechaReg,Estado) SELECT BovedaDestinoId,CodOperacion, Glosa,Importe,IndEntrada,
								  UsuarioRegId, FechaReg,Estado FROM CREDITO.BovedaMovTemp 
								  WHERE BovedaMovTempId =@BovedaMovTempId
	
	--Actualiza  Boveda Destino
	SET @BovedaDestinoId = (SELECT BovedaDestinoId FROM CREDITO.BovedaMovTemp WHERE BovedaMovTempId =@BovedaMovTempId )
	
	EXEC CREDITO.usp_ActualizarSaldosBoveda @BovedaDestinoId
	
	--Elimina BovedaMovTemp
	DELETE CREDITO.BovedaMovTemp where BovedaMovTempId = @BovedaMovTempId
	END
	
IF @flagAceptar = 2
	BEGIN
	--Elimino BovedaMov Inicio
	DELETE CREDITO.BovedaMov WHERE MovimientoBovedaId = (SELECT MovimientoBovedaIniId FROM CREDITO.BovedaMovTemp
														 WHERE BovedaMovTempId = @BovedaMovTempId )
	--Actualiza  Boveda Inicio
	SET @BovedaInicioId = (SELECT BovedaInicioId  FROM CREDITO.BovedaMovTemp WHERE BovedaMovTempId = @BovedaMovTempId)
	
	EXEC CREDITO.usp_ActualizarSaldosBoveda @BovedaInicioId

	--Elimina BovedaMovTemp
	DELETE CREDITO.BovedaMovTemp where BovedaMovTempId = @BovedaMovTempId
	END
END

GO
/****** Object:  StoredProcedure [CREDITO].[usp_UsuariosNoAsignadosCaja]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [CREDITO].[usp_UsuariosNoAsignadosCaja]
@OficinaId INT
AS

;WITH USUARIO_CAJA AS(
	SELECT CD.UsuarioAsignadoId 
	FROM CREDITO.CajaDiario CD
	INNER JOIN CREDITO.Caja C ON CD.CajaId = C.CajaId
	WHERE	C.OficinaId=@OficinaId AND IndCierre=0 and TransBoveda=0
)
SELECT U.UsuarioId 'Id', P.NombreCompleto 'Valor'
FROM MAESTRO.Rol R
INNER JOIN MAESTRO.UsuarioRol UR ON R.RolId = UR.RolId
INNER JOIN MAESTRO.Usuario U ON UR.UsuarioId = U.UsuarioId
INNER JOIN MAESTRO.UsuarioOficina UO ON U.UsuarioId = UO.UsuarioId
INNER JOIN MAESTRO.Persona P ON U.PersonaId = P.PersonaId
LEFT JOIN USUARIO_CAJA UC ON UC.UsuarioAsignadoId = U.UsuarioId
WHERE	UO.OficinaId=@OficinaId AND U.Estado=1 AND P.Estado=1 
		AND R.Denominacion like 'CAJA' AND UC.UsuarioAsignadoId IS NULL
GO
/****** Object:  StoredProcedure [dbo].[usp_AgregarPuntos]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_AgregarPuntos]
@CodCliente NUMERIC(9,0), @OrdenVentaId INT

AS
DECLARE @TotalPuntos int = 0


SELECT @TotalPuntos = SUM(LP.Puntos*OVD.Cantidad) 
FROM VENTAS.OrdenVentaDet OVD 
INNER JOIN ALMACEN.Articulo A ON A.ArticuloId = OVD.ArticuloId
INNER JOIN VENTAS.ListaPrecio LP ON LP.ArticuloId = A.ArticuloId
WHERE OrdenVentaId = @OrdenVentaId

GO
/****** Object:  StoredProcedure [dbo].[usp_CanjearPuntos]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_CanjearPuntos]
@CodCliente NUMERIC(9,0),
@NumeroSerie varchar(20)

AS
DECLARE @NumPuntos	int , @TotalPuntos int, @Mensaje VARCHAR(150), @ArticuloId int,@EstadoEnAlmacen int,
		@Descripcion varchar(150) 
SET @NumPuntos = 0
SET @Mensaje = ''
SET @EstadoEnAlmacen = 2

BEGIN

IF EXISTS(SELECT 1 FROM ALMACEN.SerieArticulo sa WHERE sa.NumeroSerie = @NumeroSerie AND sa.EstadoId = 2) 
BEGIN
	SELECT  @ArticuloId = sa.ArticuloId FROM ALMACEN.SerieArticulo sa WHERE sa.NumeroSerie = @NumeroSerie
	SELECT  @NumPuntos = PuntosCanje FROM VENTAS.ListaPrecio WHERE ArticuloId = @ArticuloId
	SELECT  @TotalPuntos = TotalPuntos FROM VENTAS.TarjetaPunto --WHERE CodCliente = @CodCliente

	IF NOT EXISTS( SELECT	1 FROM	ALMACEN.SerieArticulo SA
						INNER	JOIN ALMACEN.Articulo A ON SA.ArticuloId = A.ArticuloId AND A.Estado=1
						INNER	JOIN VENTAS.ListaPrecio LP ON A.ArticuloId = LP.ArticuloId AND A.Estado=1
						WHERE	NumeroSerie=@NumeroSerie AND SA.EstadoId=@EstadoEnAlmacen)
		SELECT	@Mensaje='No existe Lista de Precio para el artículo ' + A.Denominacion
		FROM	ALMACEN.SerieArticulo SA
		INNER	JOIN ALMACEN.Articulo A ON SA.ArticuloId = A.ArticuloId
		WHERE	NumeroSerie = @NumeroSerie
	ELSE	
	BEGIN	
	IF(@TotalPuntos >= @NumPuntos)
		BEGIN
		UPDATE VENTAS.TarjetaPunto SET TotalPuntos = TotalPuntos - @NumPuntos --WHERE CodCliente = @CodCliente
	
		--RealizarCanje
		SELECT @Descripcion = a.Denominacion + ' SN: ' + @NumeroSerie  FROM ALMACEN.Articulo a WHERE a.ArticuloId = @ArticuloId
		--INSERT INTO VENTAS.TarjetaPuntoDet(ArticuloId, FechaCanje, Cantidad, Descripcion, ValorCanje)
		--	VALUES (@ArticuloId, GETDATE(), 1,@Descripcion, @NumPuntos )
	
		UPDATE ALMACEN.SerieArticulo SET EstadoId = 3 WHERE NumeroSerie = @NumeroSerie
		END
	ELSE
		BEGIN
		SET @Mensaje = 'No tiene Puntos Suficientes'
		END
	END
END
ELSE
	BEGIN
		SELECT	@Mensaje='El articulo ' + A.Denominacion + ' se encuentra en estado ' + E.Denominacion
		FROM	ALMACEN.SerieArticulo SA
		INNER	JOIN ALMACEN.Articulo A ON SA.ArticuloId = A.ArticuloId
		INNER	JOIN MAESTRO.ValorTabla E ON E.TablaId=6 AND E.ItemId = SA.EstadoId
		WHERE	NumeroSerie=@NumeroSerie 

		IF NOT EXISTS(SELECT 1 FROM ALMACEN.SerieArticulo WHERE NumeroSerie=@NumeroSerie)
		SET @Mensaje='No existe Artículo !!!'

	END

SELECT @Mensaje
END
GO
/****** Object:  StoredProcedure [MAESTRO].[usp_MenuLst]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- MAESTRO.usp_MenuLst @OficinaId=1,@UsuarioId=4
CREATE PROC [MAESTRO].[usp_MenuLst]
@OficinaId INT,
@UsuarioId INT
AS
BEGIN
	WITH MNU AS(
		SELECT DISTINCT M.* 
		FROM MAESTRO.UsuarioRol UR
		INNER JOIN MAESTRO.RolMenu RM ON UR.RolId = RM.RolId
		INNER JOIN MAESTRO.Menu M ON RM.MenuId = M.MenuId
		WHERE UR.UsuarioId=@UsuarioId AND UR.OficinaId=@OficinaId
	)
	SELECT * FROM MNU
	UNION
	SELECT M.* FROM MAESTRO.Menu M
	INNER JOIN MNU M1 ON M1.Referencia=M.Orden 
	WHERE M.IndPadre=1
	ORDER BY 7
END


GO
/****** Object:  StoredProcedure [VENTAS].[usp_CodigoBarras_Lst]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- VENTAS.usp_CodigoBarras_Lst 72
CREATE PROC [VENTAS].[usp_CodigoBarras_Lst]
@pMovimientoId INT=0
AS

WITH LISTA AS(
	SELECT	ROW_NUMBER() OVER(ORDER BY SerieArticuloId ASC) AS Fila,
			SA.SerieArticuloId,SA.NumeroSerie 'Serie',A.Denominacion 'Articulo',
			ISNULL(LP.Monto,0.0) 'Precio'
	FROM ALMACEN.MovimientoDet MD
	INNER JOIN ALMACEN.SerieArticulo SA ON MD.MovimientoDetId = SA.MovimientoDetEntId
	INNER JOIN ALMACEN.Articulo A ON SA.ArticuloId = A.ArticuloId
	LEFT JOIN VENTAS.ListaPrecio LP ON A.ArticuloId = LP.ArticuloId AND LP.Estado=1
	WHERE MD.MovimientoId=@pMovimientoId
),CAMPO1 AS (
	SELECT ROW_NUMBER() OVER(ORDER BY SerieArticuloId ASC) AS Row,* 
	FROM LISTA
	WHERE (Fila % 2) <> 0
),CAMPO2 AS (
	SELECT ROW_NUMBER() OVER(ORDER BY SerieArticuloId ASC) AS Row,* 
	FROM LISTA
	WHERE (Fila % 2) = 0
)
SELECT	'*' + C1.Serie + '*' 'Serie1',C1.Articulo 'Articulo1', C1.Precio 'Precio1',
		'*' + ISNULL(C2.Serie,C1.Serie) + '*' 'Serie2',ISNULL(C2.Articulo,C1.Articulo) 'Articulo2', ISNULL(C2.Precio,C1.Precio) 'Precio2'
FROM CAMPO1 C1
LEFT JOIN CAMPO2 C2 ON C1.Row = C2.Row
GO
/****** Object:  StoredProcedure [VENTAS].[usp_OrdenVenta_Del]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--BEGIN TRANSACTION
--	DECLARE @OrdenVentaId INT = 68
--	SELECT * FROM VENTAS.OrdenVenta WHERE OrdenVentaId=@OrdenVentaId
--	SELECT * FROM ALMACEN.SerieArticulo WHERE SerieArticuloId=10180
--	SELECT * FROM CREDITO.CuentaxCobrar WHERE CuentaxCobrarId=9

--	EXEC VENTAS.usp_OrdenVenta_Del @OrdenVentaId = @OrdenVentaId

--	SELECT * FROM VENTAS.OrdenVenta WHERE OrdenVentaId=@OrdenVentaId
--	SELECT * FROM ALMACEN.SerieArticulo WHERE SerieArticuloId=10180
--	SELECT * FROM CREDITO.CuentaxCobrar WHERE CuentaxCobrarId=9

--ROLLBACK TRANSACTION

CREATE PROC [VENTAS].[usp_OrdenVenta_Del]
@OrdenVentaId INT=0,
@OrdenVentaDetId INT=0 
AS
BEGIN

	DECLARE @IGV DECIMAL(16,2),@EstadoEnAlmacen INT
	SET @IGV = 0.18
	SET @EstadoEnAlmacen=2
	
	--Eliminacion de Orden de Venta
	IF @OrdenVentaId>0
	BEGIN
		DECLARE @IdRef INT 
		
		IF EXISTS(SELECT 1 FROM VENTAS.OrdenVenta WHERE OrdenVentaId=@OrdenVentaId AND Estado='ENT' )
			RETURN		
			
		--IF EXISTS(SELECT 1 FROM VENTAS.OrdenVenta WHERE OrdenVentaId=@OrdenVentaId AND IndContado=1)
		--BEGIN
		--	SELECT @IdRef=CuentaxCobrarId FROM VENTAS.OrdenVenta WHERE OrdenVentaId=@OrdenVentaId
		--	UPDATE VENTAS.OrdenVenta SET CuentaxCobrarId=NULL WHERE OrdenVentaId=@OrdenVentaId
		--	DELETE FROM CREDITO.CuentaxCobrar WHERE CuentaxCobrarId=@IdRef
		--END
		IF EXISTS(SELECT 1 FROM VENTAS.OrdenVenta WHERE OrdenVentaId=@OrdenVentaId AND TipoVenta='CRE')
		BEGIN
			SELECT @IdRef=CreditoId FROM CREDITO.Credito WHERE OrdenVentaId=@OrdenVentaId 
			--UPDATE VENTAS.OrdenVenta SET CreditoId=NULL WHERE OrdenVentaId=@OrdenVentaId
			DELETE FROM CREDITO.PlanPago WHERE CreditoId=@IdRef
			DELETE FROM CREDITO.Credito WHERE CreditoId=@IdRef
		END
		
		UPDATE SA
		SET SA.EstadoId = @EstadoEnAlmacen
		FROM VENTAS.OrdenVentaDet OVD
		INNER JOIN VENTAS.OrdenVentaDetSerie OVDS ON OVD.OrdenVentaDetId = OVDS.OrdenVentaDetId
		INNER JOIN ALMACEN.SerieArticulo SA ON SA.SerieArticuloId=OVDS.SerieArticuloId
		WHERE OVD.OrdenVentaId=@OrdenVentaId
			
		DELETE OVDS
		FROM VENTAS.OrdenVentaDet OVD
		INNER JOIN VENTAS.OrdenVentaDetSerie OVDS ON OVD.OrdenVentaDetId = OVDS.OrdenVentaDetId
		WHERE OVD.OrdenVentaId=@OrdenVentaId
		
		DELETE FROM VENTAS.OrdenVentaDet
		WHERE OrdenVentaId = @OrdenVentaId
		
		DELETE FROM VENTAS.OrdenVenta
		WHERE OrdenVentaId = @OrdenVentaId

		
		
		RETURN
	END

	--Eliminacion de Detalle Orden de Venta
	IF @OrdenVentaDetId>0
	BEGIN
			
		SELECT @OrdenVentaId = OrdenVentaId 
		FROM VENTAS.OrdenVentaDet
		WHERE OrdenVentaDetId = @OrdenVentaDetId
		
		UPDATE SA
		SET SA.EstadoId = @EstadoEnAlmacen
		FROM VENTAS.OrdenVentaDetSerie OVDS
		INNER JOIN ALMACEN.SerieArticulo SA ON SA.SerieArticuloId=OVDS.SerieArticuloId
		WHERE OVDS.OrdenVentaDetId=@OrdenVentaDetId
				
		DELETE FROM VENTAS.OrdenVentaDetSerie 
		WHERE OrdenVentaDetId = @OrdenVentaDetId
		
		DELETE FROM VENTAS.OrdenVentaDet
		WHERE OrdenVentaDetId = @OrdenVentaDetId

		;WITH OrdenDetalle AS(
			SELECT OrdenVentaId, SUM(Subtotal) 'Subtotal' , SUM(Descuento) 'Descuento'
			FROM VENTAS.OrdenVentaDet WHERE OrdenVentaId=@OrdenVentaId AND Estado=1
			GROUP BY OrdenVentaId
		)
		UPDATE OV
		SET OV.TotalNeto = OD.Subtotal,
		OV.TotalDescuento = OD.Descuento,
		OV.Subtotal = OD.Subtotal / (1 + @IGV),
		OV.TotalImpuesto = OD.Subtotal * ( @IGV/(1+@IGV) ) 
		FROM VENTAS.OrdenVenta OV
		INNER JOIN OrdenDetalle OD ON OV.OrdenVentaId = OD.OrdenVentaId
		WHERE OV.OrdenVentaId = @OrdenVentaId
		
		IF NOT EXISTS(SELECT 1 FROM VENTAS.OrdenVentaDet WHERE OrdenVentaId = @OrdenVentaId )
			UPDATE VENTAS.OrdenVenta 
			SET Subtotal = 0, TotalDescuento = 0,TotalImpuesto = 0, TotalNeto = 0
			WHERE OrdenVentaId = @OrdenVentaId
				
	END
END	

GO
/****** Object:  StoredProcedure [VENTAS].[usp_OrdenVentaDet_Ins]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
SELECT SA.* FROM VENTAS.ListaPrecio LP
INNER JOIN ALMACEN.SerieArticulo SA ON LP.ArticuloId = SA.ArticuloId AND EstadoId=2

SELECT * FROM VENTAS.OrdenVenta 
SELECT * FROM VENTAS.OrdenVentaDet 
SELECT * FROM VENTAS.OrdenVentaDetSerie 

EXEC VENTAS.usp_OrdenVentaDet_Ins @OficinaId = 1, @OrdenVentaId = 17, @NumeroSerie = '10006'

DELETE FROM VENTAS.OrdenVentaDetSerie
DELETE FROM VENTAS.OrdenVentaDet
DELETE FROM VENTAS.OrdenVenta
UPDATE ALMACEN.SerieArticulo SET EstadoId=2

*/

CREATE PROC [VENTAS].[usp_OrdenVentaDet_Ins]
@OrdenVentaId INT, 
@NumeroSerie VARCHAR(20),
@UsuarioId INT=1
AS
BEGIN
	
	DECLARE @ArticuloId INT, @Mensaje VARCHAR(255), @EstadoEnAlmacen INT
	DECLARE @Decripcion VARCHAR(250), @PrecioUnitario DECIMAL(16,2),@OrdenVentaDetId INT,@SerieArticuloId INT, @IGV DECIMAL(16,2)
	SET @EstadoEnAlmacen = 2
	SET @IGV = 0.18

	IF NOT EXISTS(SELECT 1 FROM ALMACEN.SerieArticulo WHERE NumeroSerie=@NumeroSerie)
		SET @Mensaje='No existe Artículo !!!'

	ELSE IF NOT EXISTS(SELECT 1 FROM ALMACEN.SerieArticulo WHERE NumeroSerie=@NumeroSerie AND EstadoId=@EstadoEnAlmacen)
		SELECT	@Mensaje='El articulo ' + A.Denominacion + ' se encuentra en estado ' + E.Denominacion
		FROM	ALMACEN.SerieArticulo SA
		INNER	JOIN ALMACEN.Articulo A ON SA.ArticuloId = A.ArticuloId
		INNER	JOIN MAESTRO.ValorTabla E ON E.TablaId=6 AND E.ItemId = SA.EstadoId
		WHERE	NumeroSerie=@NumeroSerie

	ELSE IF NOT EXISTS( SELECT	1 FROM	ALMACEN.SerieArticulo SA
						INNER	JOIN ALMACEN.Articulo A ON SA.ArticuloId = A.ArticuloId AND A.Estado=1
						INNER	JOIN VENTAS.ListaPrecio LP ON A.ArticuloId = LP.ArticuloId AND LP.Estado=1
						WHERE	NumeroSerie=@NumeroSerie AND SA.EstadoId=@EstadoEnAlmacen)
		SELECT	@Mensaje='No existe Lista de Precio para el artículo ' + A.Denominacion
		FROM	ALMACEN.SerieArticulo SA
		INNER	JOIN ALMACEN.Articulo A ON SA.ArticuloId = A.ArticuloId
		WHERE	NumeroSerie = @NumeroSerie


	SET @Mensaje = ISNULL(@Mensaje,'')
	IF LEN(@Mensaje)>0
	BEGIN
		SELECT @Mensaje 'Mensaje'		
		RETURN
	END	
		
	--IF	@OrdenVentaId = 0
	--BEGIN
	--	INSERT INTO VENTAS.OrdenVenta
	--	(PersonaId, OficinaId , Observacion ,Subtotal ,TotalDescuento ,TotalImpuesto ,TotalNeto ,IndEntregado ,Estado,UsuarioRegId,FechaReg)
	--	VALUES (@PersonaId, @OficinaId , '' , 0.0 , 0.0 , 0.0 , 0.0 , 0 , 1,@UsuarioId,GETDATE())
	--	SELECT @OrdenVentaId=@@IDENTITY
	--END

	SELECT	@ArticuloId=SA.ArticuloId,
			@PrecioUnitario=LP.Monto,
			@SerieArticuloId = SA.SerieArticuloId,
			@Decripcion = Denominacion + ' SN: ' + @NumeroSerie
	FROM ALMACEN.SerieArticulo SA	
	INNER JOIN ALMACEN.Articulo A ON SA.ArticuloId = A.ArticuloId
	INNER JOIN VENTAS.ListaPrecio LP ON A.ArticuloId = LP.ArticuloId AND LP.Estado=1
	WHERE SA.NumeroSerie = @NumeroSerie

	IF NOT EXISTS(SELECT 1 FROM VENTAS.OrdenVentaDet WHERE Estado=1 AND OrdenVentaId=@OrdenVentaId AND ArticuloId=@ArticuloId)
		BEGIN		
					
			INSERT INTO VENTAS.OrdenVentaDet
			(OrdenVentaId ,ArticuloId ,Cantidad ,Descripcion ,ValorVenta ,Descuento ,Subtotal ,Estado)
			VALUES  
			(@OrdenVentaId,@ArticuloId,1,@Decripcion,@PrecioUnitario,0.0,@PrecioUnitario, 1)
			
			SELECT @OrdenVentaDetId=@@IDENTITY
			
		END
	ELSE
			SELECT @OrdenVentaDetId = OrdenVentaDetId
			FROM VENTAS.OrdenVentaDet WHERE Estado=1 AND OrdenVentaId=@OrdenVentaId AND ArticuloId=@ArticuloId

	INSERT INTO VENTAS.OrdenVentaDetSerie ( OrdenVentaDetId,SerieArticuloId)
	VALUES  ( @OrdenVentaDetId , @SerieArticuloId )


	DECLARE @lstSerie VARCHAR(MAX)
	SELECT	@lstSerie =  ISNULL(@lstSerie + ',','') + SA.NumeroSerie
	FROM	VENTAS.OrdenVentaDetSerie S
	INNER JOIN ALMACEN.SerieArticulo SA ON S.SerieArticuloId = SA.SerieArticuloId
	WHERE	S.OrdenVentaDetId = @OrdenVentaDetId

	UPDATE D
	SET D.Descripcion = A.Denominacion + ' SN: ' + @lstSerie,
		Cantidad = (SELECT COUNT(1) FROM VENTAS.OrdenVentaDetSerie WHERE OrdenVentaDetId=@OrdenVentaDetId)
	FROM	VENTAS.OrdenVentaDet D
	INNER JOIN ALMACEN.Articulo A ON D.ArticuloId = A.ArticuloId
	WHERE	OrdenVentaDetId = @OrdenVentaDetId

	UPDATE VENTAS.OrdenVentaDet
	SET Subtotal = Cantidad * (ValorVenta - Descuento)
	WHERE OrdenVentaDetId = @OrdenVentaDetId

	;WITH OrdenDetalle AS(
		SELECT OrdenVentaId, SUM(Subtotal) 'Subtotal' , SUM(Descuento) 'Descuento'
		FROM VENTAS.OrdenVentaDet WHERE OrdenVentaId=@OrdenVentaId AND Estado=1
		GROUP BY OrdenVentaId
	)
	UPDATE OV
	SET OV.TotalNeto = OD.Subtotal,
	OV.TotalDescuento = OD.Descuento,
	OV.Subtotal = OD.Subtotal / (1 + @IGV),
	OV.TotalImpuesto = OD.Subtotal * ( @IGV/(1+@IGV) ) ,
	OV.UsuarioModId = @UsuarioId,
	OV.FechaMod = GETDATE()
	FROM VENTAS.OrdenVenta OV
	INNER JOIN OrdenDetalle OD ON OV.OrdenVentaId = OD.OrdenVentaId
	WHERE OV.OrdenVentaId = @OrdenVentaId

	UPDATE ALMACEN.SerieArticulo SET EstadoId=3 
	WHERE SerieArticuloId = @SerieArticuloId

	SELECT CAST(@OrdenVentaId AS VARCHAR(12)) 'Mensaje'
END




GO
/****** Object:  StoredProcedure [VENTAS].[usp_OrdenVentaDet_update]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC VENTAS.usp_OrdenVentaDet_update @OrdenVentaDetId = 120, @Descuento = 100

*/

CREATE PROC [VENTAS].[usp_OrdenVentaDet_update]
@OrdenVentaDetId INT, 
@Descuento DECIMAL(16,4)
AS
BEGIN
	
	DECLARE  @IGV DECIMAL(16,2), @OrdenVentaId INT
	SET @IGV = 0.18

	SELECT @OrdenVentaId = OrdenVentaId FROM VENTAS.OrdenVentaDet
	WHERE OrdenVentaDetId = @OrdenVentaDetId

	UPDATE VENTAS.OrdenVentaDet 
	SET Descuento = @Descuento, Subtotal = (ValorVenta-@Descuento)*Cantidad
	WHERE OrdenVentaDetId=@OrdenVentaDetId

	;WITH OrdenDetalle AS(
		SELECT OrdenVentaId, SUM(Subtotal) 'Subtotal' , SUM(Descuento) 'Descuento'
		FROM VENTAS.OrdenVentaDet WHERE OrdenVentaId=@OrdenVentaId AND Estado=1
		GROUP BY OrdenVentaId
	)
	UPDATE OV
	SET OV.TotalNeto = OD.Subtotal,
	OV.TotalDescuento = OD.Descuento,
	OV.Subtotal = OD.Subtotal / (1 + @IGV),
	OV.TotalImpuesto =  OD.Subtotal * ( @IGV/(1+@IGV) ) 
	FROM VENTAS.OrdenVenta OV
	INNER JOIN OrdenDetalle OD ON OV.OrdenVentaId = OD.OrdenVentaId
	WHERE OV.OrdenVentaId = @OrdenVentaId
END


GO
/****** Object:  StoredProcedure [VENTAS].[usp_RptRentabilidadVenta]    Script Date: 20/01/2020 14:53:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- VENTAS.usp_RptRentabilidadVenta '20140201','20141003', 1,1
CREATE PROC [VENTAS].[usp_RptRentabilidadVenta] 
@FechaIni DATE,
@FechaFin DATE,
@IndContado BIT = 1,
@IndCredito BIT = 1,
@OficinaId INT = NULL
AS

DECLARE @Contado CHAR(3)='CON',@Credito CHAR(3)='CRE'

IF @IndContado = 0
	SET @Contado=''
IF @IndCredito = 0
	SET @Credito=''

SELECT  ROW_NUMBER() OVER(ORDER BY A.Denominacion) 'Nro', SA.NumeroSerie 'Codigo',A.Denominacion 'Articulo',
		ME.MovimientoId, ME.Fecha 'FechaEnt',MDE.PrecioUnitario 'PrecioEnt',OV.OrdenVentaId,MS.Fecha 'FechaSal',
		CAST(OVD.Subtotal/OVD.Cantidad AS DECIMAL(15,2)) 'PrecioSal',
		CASE WHEN OV.TipoVenta='CON' THEN 'CONTADO' ELSE 'CREDITO' END 'Modalidad',
		CAST(OVD.Subtotal/OVD.Cantidad AS DECIMAL(15,2)) - MDE.PrecioUnitario 'Rentabilidad', P.NombreCompleto 'Cliente'
FROM ALMACEN.SerieArticulo SA
INNER JOIN ALMACEN.Articulo A ON SA.ArticuloId = A.ArticuloId
INNER JOIN ALMACEN.MovimientoDet MDS ON SA.MovimientoDetSalId = MDS.MovimientoDetId
INNER JOIN ALMACEN.Movimiento MS ON MDS.MovimientoId = MS.MovimientoId
INNER JOIN ALMACEN.MovimientoDet MDE ON SA.MovimientoDetEntId = MDE.MovimientoDetId
INNER JOIN ALMACEN.Movimiento ME ON MDE.MovimientoId = ME.MovimientoId
INNER JOIN VENTAS.OrdenVentaDetSerie OVS ON SA.SerieArticuloId = OVS.SerieArticuloId
INNER JOIN VENTAS.OrdenVentaDet OVD ON OVS.OrdenVentaDetId = OVD.OrdenVentaDetId
INNER JOIN VENTAS.OrdenVenta OV ON  OVD.OrdenVentaId = OV.OrdenVentaId --AND OV.Estado=1
INNER JOIN MAESTRO.Persona P ON OV.PersonaId = P.PersonaId
WHERE	OV.OficinaId=ISNULL(@OficinaId,OV.OficinaId) AND SA.EstadoId = 4 
		--AND (OV.IndContado=@IndContado OR OV.IndCredito=@IndCredito)
		AND OV.TipoVenta IN(@Contado,@Credito)
		AND CAST(MS.Fecha AS DATE) BETWEEN @FechaIni AND @FechaFin

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'INI= cuota inicial,CON= pago al contado' , @level0type=N'SCHEMA',@level0name=N'CREDITO', @level1type=N'TABLE',@level1name=N'CuentaxCobrar', @level2type=N'COLUMN',@level2name=N'Operacion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PEN,CAN' , @level0type=N'SCHEMA',@level0name=N'CREDITO', @level1type=N'TABLE',@level1name=N'CuentaxCobrar', @level2type=N'COLUMN',@level2name=N'Estado'
GO
