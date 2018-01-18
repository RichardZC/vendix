CREATE TABLE [ALMACEN].[Movimiento] (
    [MovimientoId]     INT             IDENTITY (1, 1) NOT NULL,
    [TipoMovimientoId] INT             NOT NULL,
    [AlmacenId]        INT             NOT NULL,
    [Fecha]            DATETIME        NOT NULL,
    [SubTotal]         DECIMAL (16, 2) CONSTRAINT [DF_Movimiento_SubTotal] DEFAULT ((0)) NOT NULL,
    [IGV]              DECIMAL (16, 2) CONSTRAINT [DF_Movimiento_IGV] DEFAULT ((0)) NOT NULL,
    [AjusteRedondeo]   DECIMAL (16, 2) CONSTRAINT [DF_Movimiento_AjusteRedondeo] DEFAULT ((0)) NOT NULL,
    [TotalImporte]     DECIMAL (16, 2) CONSTRAINT [DF_Movimiento_TotalImporte] DEFAULT ((0)) NOT NULL,
    [EstadoId]         INT             NOT NULL,
    [Observacion]      VARCHAR (500)   NULL,
    [Documento]        VARCHAR (50)    NULL,
    CONSTRAINT [PK__Movimien__BF923C2C3C00B29C] PRIMARY KEY CLUSTERED ([MovimientoId] ASC),
    CONSTRAINT [FK_ENTRADASALIDA_AlmacenId] FOREIGN KEY ([AlmacenId]) REFERENCES [ALMACEN].[Almacen] ([AlmacenId]),
    CONSTRAINT [FK_ENTRADASALIDA_TipoMovimientoId] FOREIGN KEY ([TipoMovimientoId]) REFERENCES [ALMACEN].[TipoMovimiento] ([TipoMovimientoId])
);

