CREATE TABLE [CREDITO].[Aprobacion] (
    [CreditoId] INT      NOT NULL,
    [Nivel]     INT      NOT NULL,
    [UsuarioId] INT      NULL,
    [Fecha]     DATETIME NULL,
    CONSTRAINT [PK__CreditoE__4FE406DDCF29B870] PRIMARY KEY CLUSTERED ([CreditoId] ASC, [Nivel] ASC),
    CONSTRAINT [FK__CreditoEx__Credi__5AFA3B08] FOREIGN KEY ([CreditoId]) REFERENCES [CREDITO].[Credito] ([CreditoId]),
    CONSTRAINT [FK__CreditoEx__Usuar__5BEE5F41] FOREIGN KEY ([UsuarioId]) REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
);

