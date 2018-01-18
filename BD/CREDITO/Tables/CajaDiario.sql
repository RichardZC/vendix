CREATE TABLE [CREDITO].[CajaDiario] (
    [CajaDiarioId]      INT             IDENTITY (1, 1) NOT NULL,
    [CajaId]            INT             NOT NULL,
    [UsuarioAsignadoId] INT             NOT NULL,
    [SaldoInicial]      DECIMAL (16, 2) NOT NULL,
    [Entradas]          DECIMAL (16, 2) CONSTRAINT [DF_CajaDiario_Entradas] DEFAULT ((0)) NOT NULL,
    [Salidas]           DECIMAL (16, 2) CONSTRAINT [DF_CajaDiario_Salidas] DEFAULT ((0)) NOT NULL,
    [SaldoFinal]        DECIMAL (16, 2) NOT NULL,
    [FechaIniOperacion] DATETIME        NOT NULL,
    [FechaFinOperacion] DATETIME        NULL,
    [IndCierre]         BIT             CONSTRAINT [DF_CajaDiario_IndCierre] DEFAULT ((0)) NOT NULL,
    [TransBoveda]       BIT             CONSTRAINT [DF_CajaDiario_TransBoveda] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__CajaDiar__A7FC1B240C0786B7] PRIMARY KEY CLUSTERED ([CajaDiarioId] ASC),
    CONSTRAINT [FK__CajaDiari__CajaI__0EE3F362] FOREIGN KEY ([CajaId]) REFERENCES [CREDITO].[Caja] ([CajaId]),
    CONSTRAINT [FK__CajaDiari__Usuar__0DEFCF29] FOREIGN KEY ([UsuarioAsignadoId]) REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
);

