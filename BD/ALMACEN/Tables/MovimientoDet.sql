CREATE TABLE [ALMACEN].[MovimientoDet] (
    [MovimientoDetId] INT             IDENTITY (1, 1) NOT NULL,
    [MovimientoId]    INT             NOT NULL,
    [ArticuloId]      INT             NOT NULL,
    [Cantidad]        INT             CONSTRAINT [DF_MovimientoDet_Cantidad] DEFAULT ((0)) NOT NULL,
    [Descripcion]     VARCHAR (MAX)   NULL,
    [PrecioUnitario]  DECIMAL (16, 2) CONSTRAINT [DF_MovimientoDet_PrecioUnitario] DEFAULT ((0)) NOT NULL,
    [Descuento]       DECIMAL (16, 2) CONSTRAINT [DF_MovimientoDet_Descuento] DEFAULT ((0)) NOT NULL,
    [Importe]         DECIMAL (16, 2) CONSTRAINT [DF_MovimientoDet_Importe] DEFAULT ((0)) NOT NULL,
    [IndCorrelativo]  BIT             NOT NULL,
    [UnidadMedidaT10] INT             NULL,
    CONSTRAINT [PK__Movimien__C5252D9B41B98BF2] PRIMARY KEY CLUSTERED ([MovimientoDetId] ASC),
    CONSTRAINT [FK_DETENTRADASALIDA_ArticuloId] FOREIGN KEY ([ArticuloId]) REFERENCES [ALMACEN].[Articulo] ([ArticuloId]),
    CONSTRAINT [FK_DETENTRADASALIDA_EntradaSalidaId] FOREIGN KEY ([MovimientoId]) REFERENCES [ALMACEN].[Movimiento] ([MovimientoId])
);

