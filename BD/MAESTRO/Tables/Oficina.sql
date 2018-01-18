CREATE TABLE [MAESTRO].[Oficina] (
    [OficinaId]         INT           IDENTITY (1, 1) NOT NULL,
    [Denominacion]      VARCHAR (100) NULL,
    [Descripcion]       VARCHAR (250) NULL,
    [Telefono]          VARCHAR (20)  NULL,
    [IndPrincipal]      BIT           NOT NULL,
    [Estado]            BIT           DEFAULT ((0)) NOT NULL,
    [UsuarioAsignadoId] INT           CONSTRAINT [DF_Oficina_UsuarioAsignadoId] DEFAULT ((3)) NOT NULL,
    PRIMARY KEY CLUSTERED ([OficinaId] ASC),
    CONSTRAINT [FK_Oficina_Usuario] FOREIGN KEY ([UsuarioAsignadoId]) REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
);

