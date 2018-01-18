CREATE TABLE [VENTAS].[OrdenVentaDetSerie] (
    [OrdenVentaDetSerieId] INT IDENTITY (1, 1) NOT NULL,
    [OrdenVentaDetId]      INT NULL,
    [SerieArticuloId]      INT NULL,
    CONSTRAINT [PK__OrdenVen__8CB6EF5D06B8C1B5] PRIMARY KEY CLUSTERED ([OrdenVentaDetSerieId] ASC),
    CONSTRAINT [FK__OrdenVent__Orden__08A10A27] FOREIGN KEY ([OrdenVentaDetId]) REFERENCES [VENTAS].[OrdenVentaDet] ([OrdenVentaDetId]),
    CONSTRAINT [FK__OrdenVent__Serie__09952E60] FOREIGN KEY ([SerieArticuloId]) REFERENCES [ALMACEN].[SerieArticulo] ([SerieArticuloId])
);

