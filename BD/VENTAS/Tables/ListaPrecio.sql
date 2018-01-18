CREATE TABLE [VENTAS].[ListaPrecio] (
    [ListaPrecioId] INT             IDENTITY (1, 1) NOT NULL,
    [ArticuloId]    INT             NULL,
    [Monto]         DECIMAL (16, 2) NULL,
    [Descuento]     DECIMAL (16, 2) NULL,
    [Estado]        BIT             CONSTRAINT [DF__ListaPrec__Estad__5DEBB64C] DEFAULT ((0)) NOT NULL,
    [Puntos]        INT             NULL,
    [PuntosCanje]   INT             NULL,
    CONSTRAINT [PK__ListaPre__44C04A8F5C036DDA] PRIMARY KEY CLUSTERED ([ListaPrecioId] ASC),
    CONSTRAINT [FK_ListaPrecio_Articulo] FOREIGN KEY ([ArticuloId]) REFERENCES [ALMACEN].[Articulo] ([ArticuloId])
);

