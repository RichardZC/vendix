CREATE TABLE [MAESTRO].[UsuarioOficina] (
    [UsuarioOficinaId] INT IDENTITY (1, 1) NOT NULL,
    [UsuarioId]        INT NOT NULL,
    [OficinaId]        INT NOT NULL,
    [Estado]           BIT NOT NULL,
    CONSTRAINT [PK__UsuarioO__EF670E7473A5ED41] PRIMARY KEY CLUSTERED ([UsuarioOficinaId] ASC),
    CONSTRAINT [FK__UsuarioOf__Ofici__768259EC] FOREIGN KEY ([OficinaId]) REFERENCES [MAESTRO].[Oficina] ([OficinaId]),
    CONSTRAINT [FK__UsuarioOf__Usuar__758E35B3] FOREIGN KEY ([UsuarioId]) REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
);

