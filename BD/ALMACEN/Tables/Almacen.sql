CREATE TABLE [ALMACEN].[Almacen] (
    [AlmacenId]         INT           IDENTITY (1, 1) NOT NULL,
    [OficinaId]         INT           NULL,
    [Denominacion]      VARCHAR (100) NULL,
    [Descripcion]       VARCHAR (250) NULL,
    [IndEstadoApertura] BIT           NULL,
    [FechaApertura]     DATETIME      NULL,
    [Estado]            BIT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([AlmacenId] ASC),
    CONSTRAINT [FK_ALMACEN_OficinaId] FOREIGN KEY ([OficinaId]) REFERENCES [MAESTRO].[Oficina] ([OficinaId])
);

