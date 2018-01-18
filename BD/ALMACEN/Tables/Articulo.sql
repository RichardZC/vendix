CREATE TABLE [ALMACEN].[Articulo] (
    [ArticuloId]     INT           IDENTITY (1, 1) NOT NULL,
    [ModeloId]       INT           NULL,
    [TipoArticuloId] INT           NULL,
    [CodArticulo]    VARCHAR (20)  NULL,
    [Denominacion]   VARCHAR (200) NULL,
    [Descripcion]    VARCHAR (250) NULL,
    [Imagen]         VARCHAR (MAX) NULL,
    [IndPerecible]   BIT           CONSTRAINT [DF__Articulo__IndPer__1E704FB5] DEFAULT ((0)) NULL,
    [IndImportado]   BIT           CONSTRAINT [DF__Articulo__IndImp__1F6473EE] DEFAULT ((0)) NULL,
    [IndCanjeable]   BIT           NULL,
    [Estado]         BIT           CONSTRAINT [DF__Articulo__Estado__20589827] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__Articulo__C0D725ED1C880743] PRIMARY KEY CLUSTERED ([ArticuloId] ASC),
    CONSTRAINT [FK_ARTICULO_ModeloId] FOREIGN KEY ([ModeloId]) REFERENCES [ALMACEN].[Modelo] ([ModeloId]),
    CONSTRAINT [FK_ARTICULO_TipoArticuloId] FOREIGN KEY ([TipoArticuloId]) REFERENCES [ALMACEN].[TipoArticulo] ([TipoArticuloId])
);

