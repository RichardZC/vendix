CREATE TABLE [ALMACEN].[MovimientoDoc] (
    [MovimientoDocId] INT           IDENTITY (1, 1) NOT NULL,
    [MovimientoId]    INT           NULL,
    [TipoDocumentoId] INT           NULL,
    [SerieDocumento]  VARCHAR (12)  NULL,
    [NroDocumento]    VARCHAR (12)  NULL,
    [RemitenteId]     INT           NULL,
    [DestinatarioId]  INT           NULL,
    [DestinoRef]      VARCHAR (150) NULL,
    PRIMARY KEY CLUSTERED ([MovimientoDocId] ASC),
    CONSTRAINT [FK_DOCENTRADASALIDA_DestinatarioId] FOREIGN KEY ([DestinatarioId]) REFERENCES [MAESTRO].[Persona] ([PersonaId]),
    CONSTRAINT [FK_DOCENTRADASALIDA_MovimientoId] FOREIGN KEY ([MovimientoId]) REFERENCES [ALMACEN].[Movimiento] ([MovimientoId]),
    CONSTRAINT [FK_DOCENTRADASALIDA_RemitenteId] FOREIGN KEY ([RemitenteId]) REFERENCES [MAESTRO].[Persona] ([PersonaId]),
    CONSTRAINT [FK_DOCENTRADASALIDA_TipoDocumentoId] FOREIGN KEY ([TipoDocumentoId]) REFERENCES [MAESTRO].[TipoDocumento] ([TipoDocumentoId])
);

