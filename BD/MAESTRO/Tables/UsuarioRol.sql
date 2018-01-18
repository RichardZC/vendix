CREATE TABLE [MAESTRO].[UsuarioRol] (
    [UsuarioRolId] INT IDENTITY (1, 1) NOT NULL,
    [UsuarioId]    INT NULL,
    [RolId]        INT NULL,
    [OficinaId]    INT NULL,
    CONSTRAINT [PK__UsuarioR__C869CDCA6EAC2DFA] PRIMARY KEY CLUSTERED ([UsuarioRolId] ASC),
    CONSTRAINT [FK__UsuarioRo__Ofici__764D4FC2] FOREIGN KEY ([OficinaId]) REFERENCES [MAESTRO].[Oficina] ([OficinaId]),
    CONSTRAINT [FK__UsuarioRo__RolId__71889AA5] FOREIGN KEY ([RolId]) REFERENCES [MAESTRO].[Rol] ([RolId]),
    CONSTRAINT [FK__UsuarioRo__Usuar__7094766C] FOREIGN KEY ([UsuarioId]) REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
);

