CREATE TABLE [CREDITO].[Caja] (
    [CajaId]       INT           IDENTITY (1, 1) NOT NULL,
    [OficinaId]    INT           NOT NULL,
    [Denominacion] VARCHAR (100) NOT NULL,
    [Estado]       BIT           NOT NULL,
    [UsuarioRegId] INT           NOT NULL,
    [FechaReg]     DATETIME      NOT NULL,
    [IndAbierto]   BIT           CONSTRAINT [DF_Caja_IndAbierto] DEFAULT ((0)) NOT NULL,
    [UsuarioModId] INT           NULL,
    [FechaMod]     DATETIME      NULL,
    CONSTRAINT [PK__Caja__A74F87070742D19A] PRIMARY KEY CLUSTERED ([CajaId] ASC),
    CONSTRAINT [FK__Caja__OficinaId__092B1A0C] FOREIGN KEY ([OficinaId]) REFERENCES [MAESTRO].[Oficina] ([OficinaId]),
    CONSTRAINT [FK_Caja_Usuario] FOREIGN KEY ([UsuarioRegId]) REFERENCES [MAESTRO].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Caja_Usuario1] FOREIGN KEY ([UsuarioModId]) REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
);

