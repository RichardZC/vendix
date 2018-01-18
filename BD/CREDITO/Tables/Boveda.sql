CREATE TABLE [CREDITO].[Boveda] (
    [BovedaId]          INT             IDENTITY (1, 1) NOT NULL,
    [OficinaId]         INT             NOT NULL,
    [SaldoInicial]      DECIMAL (16, 2) CONSTRAINT [DF_Boveda_SaldoInicial] DEFAULT ((0)) NOT NULL,
    [Entradas]          DECIMAL (16, 2) CONSTRAINT [DF_Boveda_Entradas] DEFAULT ((0)) NOT NULL,
    [Salidas]           DECIMAL (16, 2) CONSTRAINT [DF_Boveda_Salidas] DEFAULT ((0)) NOT NULL,
    [SaldoFinal]        DECIMAL (16, 2) CONSTRAINT [DF_Boveda_SaldoFinal] DEFAULT ((0)) NOT NULL,
    [FechaIniOperacion] DATETIME        CONSTRAINT [DF_Boveda_FechaIniOperacion] DEFAULT (getdate()) NOT NULL,
    [FechaFinOperacion] DATETIME        NULL,
    [IndCierre]         BIT             CONSTRAINT [DF_Boveda_IndCierre] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__Boveda__A7FEF717027E1C7D] PRIMARY KEY CLUSTERED ([BovedaId] ASC),
    CONSTRAINT [FK__Boveda__OficinaI__046664EF] FOREIGN KEY ([OficinaId]) REFERENCES [MAESTRO].[Oficina] ([OficinaId])
);

