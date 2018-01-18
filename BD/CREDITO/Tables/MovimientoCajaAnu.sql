CREATE TABLE [CREDITO].[MovimientoCajaAnu] (
    [MovimientoCajaAnuId] INT           IDENTITY (1, 1) NOT NULL,
    [MovimientoCajaId]    INT           NULL,
    [Observacion]         VARCHAR (MAX) NULL,
    [UsuarioRegId]        INT           NULL,
    [FechaReg]            DATETIME      NULL,
    CONSTRAINT [PK__Movimien__E2AB2E7E4FBD9286] PRIMARY KEY CLUSTERED ([MovimientoCajaAnuId] ASC),
    CONSTRAINT [FK__Movimient__Movim__51A5DAF8] FOREIGN KEY ([MovimientoCajaId]) REFERENCES [CREDITO].[MovimientoCaja] ([MovimientoCajaId])
);

