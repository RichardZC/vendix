CREATE TABLE [CREDITO].[BovedaMov] (
    [MovimientoBovedaId] INT             IDENTITY (1, 1) NOT NULL,
    [BovedaId]           INT             NOT NULL,
    [CodOperacion]       CHAR (3)        NOT NULL,
    [Glosa]              VARCHAR (MAX)   NULL,
    [Importe]            DECIMAL (16, 2) NOT NULL,
    [IndEntrada]         BIT             CONSTRAINT [DF_MovimientoBoveda_IndEntrada] DEFAULT ((0)) NOT NULL,
    [Estado]             BIT             NOT NULL,
    [CajaDiarioId]       INT             NULL,
    [UsuarioRegId]       INT             NOT NULL,
    [FechaReg]           DATETIME        NOT NULL,
    CONSTRAINT [PK_MovimientoBoveda] PRIMARY KEY CLUSTERED ([MovimientoBovedaId] ASC),
    CONSTRAINT [FK_MovimientoBoveda_Boveda] FOREIGN KEY ([BovedaId]) REFERENCES [CREDITO].[Boveda] ([BovedaId])
);

