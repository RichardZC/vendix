CREATE TABLE [ALMACEN].[SerieArticulo] (
    [SerieArticuloId]    INT          IDENTITY (1, 1) NOT NULL,
    [NumeroSerie]        VARCHAR (20) NOT NULL,
    [AlmacenId]          INT          NOT NULL,
    [ArticuloId]         INT          NOT NULL,
    [EstadoId]           INT          NOT NULL,
    [MovimientoDetEntId] INT          NULL,
    [MovimientoDetSalId] INT          NULL,
    CONSTRAINT [PK__SerieArt__A6750CD55F49EED9] PRIMARY KEY CLUSTERED ([SerieArticuloId] ASC),
    CONSTRAINT [FK_SERIEARTICULO_AlmacenId] FOREIGN KEY ([AlmacenId]) REFERENCES [ALMACEN].[Almacen] ([AlmacenId]),
    CONSTRAINT [FK_SERIEARTICULO_ArticuloId] FOREIGN KEY ([ArticuloId]) REFERENCES [ALMACEN].[Articulo] ([ArticuloId]),
    CONSTRAINT [FK_SERIEARTICULO_MOVIMIENTODET] FOREIGN KEY ([MovimientoDetEntId]) REFERENCES [ALMACEN].[MovimientoDet] ([MovimientoDetId])
);

