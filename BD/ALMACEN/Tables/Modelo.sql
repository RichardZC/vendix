CREATE TABLE [ALMACEN].[Modelo] (
    [ModeloId]     INT          IDENTITY (1, 1) NOT NULL,
    [Denominacion] VARCHAR (70) NULL,
    [MarcaId]      INT          NULL,
    [Estado]       BIT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ModeloId] ASC),
    CONSTRAINT [FK_MODELO_MarcaId] FOREIGN KEY ([MarcaId]) REFERENCES [ALMACEN].[Marca] ([MarcaId])
);

