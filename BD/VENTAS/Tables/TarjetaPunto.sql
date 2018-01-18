CREATE TABLE [VENTAS].[TarjetaPunto] (
    [TarjetaPuntoId] INT IDENTITY (1, 1) NOT NULL,
    [PersonaId]      INT NOT NULL,
    [TotalPuntos]    INT NOT NULL,
    [Estado]         BIT NOT NULL,
    CONSTRAINT [PK__TarjetaP__1D2E93810FA30D71] PRIMARY KEY CLUSTERED ([TarjetaPuntoId] ASC),
    CONSTRAINT [FK__TarjetaPu__Perso__118B55E3] FOREIGN KEY ([PersonaId]) REFERENCES [MAESTRO].[Persona] ([PersonaId])
);

