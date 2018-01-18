CREATE TABLE [CREDITO].[Cargo] (
    [CargoId]     INT             IDENTITY (1, 1) NOT NULL,
    [CreditoId]   INT             NOT NULL,
    [NumCuota]    INT             NOT NULL,
    [TipoCargoT2] INT             NOT NULL,
    [Importe]     DECIMAL (16, 2) CONSTRAINT [DF__Cargo__Importe__118B55E3] DEFAULT ((0)) NOT NULL,
    [Descripcion] VARCHAR (MAX)   NOT NULL,
    [Estado]      CHAR (3)        NOT NULL,
    [UsuarioId]   INT             NOT NULL,
    [Fecha]       DATETIME        NOT NULL,
    CONSTRAINT [PK__Cargo__B4E665CD0EAEE938] PRIMARY KEY CLUSTERED ([CargoId] ASC),
    CONSTRAINT [FK__Cargo__CreditoId__109731AA] FOREIGN KEY ([CreditoId]) REFERENCES [CREDITO].[Credito] ([CreditoId]),
    CONSTRAINT [FK_Cargo_Usuario] FOREIGN KEY ([UsuarioId]) REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
);

