CREATE TABLE [CREDITO].[BovedaMovTemp] (
    [BovedaMovTempId]       INT             IDENTITY (1, 1) NOT NULL,
    [BovedaInicioId]        INT             NOT NULL,
    [BovedaDestinoId]       INT             NOT NULL,
    [CodOperacion]          CHAR (3)        NOT NULL,
    [Glosa]                 VARCHAR (MAX)   NULL,
    [Importe]               DECIMAL (16, 2) NOT NULL,
    [UsuarioRegId]          INT             NOT NULL,
    [MovimientoBovedaIniId] INT             NOT NULL,
    [FechaReg]              DATETIME        NOT NULL,
    [IndEntrada]            BIT             NOT NULL,
    [Estado]                BIT             NOT NULL,
    CONSTRAINT [PK__BovedaMo__C04A9CF60154EE1A] PRIMARY KEY CLUSTERED ([BovedaMovTempId] ASC),
    CONSTRAINT [FK_BovedaMovTemp_Boveda] FOREIGN KEY ([BovedaInicioId]) REFERENCES [CREDITO].[Boveda] ([BovedaId]),
    CONSTRAINT [FK_BovedaMovTemp_Boveda1] FOREIGN KEY ([BovedaDestinoId]) REFERENCES [CREDITO].[Boveda] ([BovedaId])
);

