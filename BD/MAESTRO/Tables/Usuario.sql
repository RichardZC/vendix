CREATE TABLE [MAESTRO].[Usuario] (
    [UsuarioId]     INT           IDENTITY (1, 1) NOT NULL,
    [PersonaId]     INT           NOT NULL,
    [NombreUsuario] NVARCHAR (50) NOT NULL,
    [ClaveUsuario]  NVARCHAR (50) NOT NULL,
    [Estado]        BIT           NOT NULL,
    CONSTRAINT [PK__Usuario] PRIMARY KEY CLUSTERED ([UsuarioId] ASC),
    CONSTRAINT [FK__Usuario__Persona__33C07256] FOREIGN KEY ([PersonaId]) REFERENCES [MAESTRO].[Persona] ([PersonaId])
);

