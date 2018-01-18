CREATE TABLE [ALMACEN].[TipoArticulo] (
    [TipoArticuloId]       INT           IDENTITY (1, 1) NOT NULL,
    [Denominacion]         VARCHAR (100) NULL,
    [Descripcion]          VARCHAR (250) NULL,
    [IndTieneCodigo]       BIT           NULL,
    [Estado]               BIT           DEFAULT ((0)) NOT NULL,
    [IndMovimientoAlmacen] BIT           DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([TipoArticuloId] ASC)
);

