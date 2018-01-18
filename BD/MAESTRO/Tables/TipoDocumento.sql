CREATE TABLE [MAESTRO].[TipoDocumento] (
    [TipoDocumentoId] INT           IDENTITY (1, 1) NOT NULL,
    [Denominacion]    VARCHAR (100) NULL,
    [Descripcion]     VARCHAR (250) NULL,
    [IndVenta]        BIT           DEFAULT ((0)) NULL,
    [IndAlmacen]      BIT           DEFAULT ((0)) NULL,
    [IndAlmacenMov]   BIT           DEFAULT ((0)) NULL,
    [Estado]          BIT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([TipoDocumentoId] ASC)
);

