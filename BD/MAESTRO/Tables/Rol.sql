CREATE TABLE [MAESTRO].[Rol] (
    [RolId]        INT           IDENTITY (1, 1) NOT NULL,
    [Denominacion] VARCHAR (255) NULL,
    [Estado]       BIT           NOT NULL,
    CONSTRAINT [PK__Rol__F92302F1615232DC] PRIMARY KEY CLUSTERED ([RolId] ASC)
);

