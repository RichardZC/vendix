CREATE TABLE [VENTAS].[TarjetaPuntoDet] (
    [TarjetaPuntoDetId] INT IDENTITY (1, 1) NOT NULL,
    [TarjetaPuntoId]    INT NOT NULL,
    [OrdenVentaId]      INT NOT NULL,
    [ValorCanje]        INT NOT NULL,
    CONSTRAINT [PK__TarjetaP__AC9614BF1467C28E] PRIMARY KEY CLUSTERED ([TarjetaPuntoDetId] ASC),
    CONSTRAINT [FK__TarjetaPu__Orden__17442F39] FOREIGN KEY ([OrdenVentaId]) REFERENCES [VENTAS].[OrdenVenta] ([OrdenVentaId]),
    CONSTRAINT [FK__TarjetaPu__Tarje__16500B00] FOREIGN KEY ([TarjetaPuntoId]) REFERENCES [VENTAS].[TarjetaPunto] ([TarjetaPuntoId])
);

