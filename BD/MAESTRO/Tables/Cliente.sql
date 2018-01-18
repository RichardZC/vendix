CREATE TABLE [MAESTRO].[Cliente] (
    [ClienteId]          INT             IDENTITY (1, 1) NOT NULL,
    [PersonaId]          INT             NOT NULL,
    [FechaCaptacion]     DATE            NULL,
    [ActividadEconId]    INT             NULL,
    [Calificacion]       CHAR (1)        NULL,
    [Inscripcion]        DECIMAL (16, 2) CONSTRAINT [DF_Cliente_Inscripcion] DEFAULT ((0)) NOT NULL,
    [IndPagoInscripcion] BIT             CONSTRAINT [DF_Cliente_IndPagoInscripcion] DEFAULT ((0)) NOT NULL,
    [FechaRegistro]      DATETIME        NULL,
    [Estado]             BIT             NOT NULL,
    CONSTRAINT [PK__Cliente__71ABD0877929BC6D] PRIMARY KEY CLUSTERED ([ClienteId] ASC),
    CONSTRAINT [FK_Cliente_Persona] FOREIGN KEY ([PersonaId]) REFERENCES [MAESTRO].[Persona] ([PersonaId])
);

