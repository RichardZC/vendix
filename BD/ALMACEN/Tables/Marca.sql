CREATE TABLE [ALMACEN].[Marca] (
    [MarcaId]      INT           IDENTITY (1, 1) NOT NULL,
    [Denominacion] VARCHAR (100) NULL,
    [Estado]       BIT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([MarcaId] ASC)
);

