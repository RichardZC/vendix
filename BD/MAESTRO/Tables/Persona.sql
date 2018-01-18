CREATE TABLE [MAESTRO].[Persona] (
    [PersonaId]       INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]          VARCHAR (70)  NOT NULL,
    [ApePaterno]      VARCHAR (70)  NULL,
    [ApeMaterno]      VARCHAR (70)  NULL,
    [NombreCompleto]  VARCHAR (250) NULL,
    [TipoDocumento]   CHAR (3)      NOT NULL,
    [NumeroDocumento] VARCHAR (12)  NOT NULL,
    [Sexo]            CHAR (1)      NULL,
    [TipoPersona]     CHAR (1)      NOT NULL,
    [EmailPersonal]   VARCHAR (100) NULL,
    [FechaNacimiento] DATETIME      NULL,
    [Direccion]       VARCHAR (MAX) NULL,
    [Estado]          BIT           DEFAULT ((0)) NOT NULL,
    [Celular1]        VARCHAR (10)  NULL,
    [Celular2]        VARCHAR (10)  NULL,
    PRIMARY KEY CLUSTERED ([PersonaId] ASC),
    CONSTRAINT [IX_Persona] UNIQUE NONCLUSTERED ([NumeroDocumento] ASC)
);

