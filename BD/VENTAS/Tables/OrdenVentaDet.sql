CREATE TABLE [VENTAS].[OrdenVentaDet] (
    [OrdenVentaDetId] INT             IDENTITY (1, 1) NOT NULL,
    [OrdenVentaId]    INT             NOT NULL,
    [ArticuloId]      INT             NOT NULL,
    [Cantidad]        INT             NOT NULL,
    [Descripcion]     VARCHAR (MAX)   NOT NULL,
    [ValorVenta]      DECIMAL (16, 4) NOT NULL,
    [Descuento]       DECIMAL (16, 4) NOT NULL,
    [Subtotal]        DECIMAL (16, 4) NOT NULL,
    [Estado]          BIT             CONSTRAINT [DF__OrdenVent__Estad__695D68F8] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__OrdenVen__A9F54CD367752086] PRIMARY KEY CLUSTERED ([OrdenVentaDetId] ASC),
    CONSTRAINT [FK_DETORDENVENTA_ArticuloId] FOREIGN KEY ([ArticuloId]) REFERENCES [ALMACEN].[Articulo] ([ArticuloId]),
    CONSTRAINT [FK_DETORDENVENTA_OrdenVentaId] FOREIGN KEY ([OrdenVentaId]) REFERENCES [VENTAS].[OrdenVenta] ([OrdenVentaId])
);

