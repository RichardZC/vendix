CREATE TABLE [MAESTRO].[TipoDocumento] (
    [TipoDocumentoId] INT           IDENTITY (1, 1) NOT NULL,
    [Denominacion]    VARCHAR (100) NOT NULL,
    [Descripcion]     VARCHAR (250) NOT NULL,
    [IndVenta]        BIT           DEFAULT ((0)) NOT NULL,
    [IndAlmacen]      BIT           DEFAULT ((0)) NOT NULL,
    [IndAlmacenMov]   BIT           DEFAULT ((0)) NOT NULL,
    [Estado]          BIT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([TipoDocumentoId] ASC)
);

