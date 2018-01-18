CREATE TABLE [CREDITO].[MovimientoCaja] (
    [MovimientoCajaId] INT             IDENTITY (1, 1) NOT NULL,
    [CajaDiarioId]     INT             NOT NULL,
    [Operacion]        CHAR (3)        NOT NULL,
    [ImportePago]      DECIMAL (16, 2) CONSTRAINT [DF_MovimientoCaja_ImportePago] DEFAULT ((0)) NOT NULL,
    [ImporteRecibido]  DECIMAL (16, 2) CONSTRAINT [DF_MovimientoCaja_ImporteRecibido] DEFAULT ((0)) NOT NULL,
    [MontoVuelto]      DECIMAL (16, 2) CONSTRAINT [DF_MovimientoCaja_MontoVuelto] DEFAULT ((0)) NOT NULL,
    [PersonaId]        INT             NULL,
    [Descripcion]      VARCHAR (MAX)   NULL,
    [IndEntrada]       BIT             NOT NULL,
    [Estado]           BIT             NOT NULL,
    [UsuarioRegId]     INT             NOT NULL,
    [FechaReg]         DATETIME        NOT NULL,
    [OrdenVentaId]     INT             NULL,
    [CreditoId]        INT             NULL,
    CONSTRAINT [PK__Movimien__266F555F11C0600D] PRIMARY KEY CLUSTERED ([MovimientoCajaId] ASC),
    CONSTRAINT [FK__Movimient__CajaD__149CCCB8] FOREIGN KEY ([CajaDiarioId]) REFERENCES [CREDITO].[CajaDiario] ([CajaDiarioId]),
    CONSTRAINT [FK__Movimient__Usuar__17793963] FOREIGN KEY ([UsuarioRegId]) REFERENCES [MAESTRO].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_MovimientoCaja_Credito] FOREIGN KEY ([CreditoId]) REFERENCES [CREDITO].[Credito] ([CreditoId]),
    CONSTRAINT [FK_MovimientoCaja_OrdenVenta] FOREIGN KEY ([OrdenVentaId]) REFERENCES [VENTAS].[OrdenVenta] ([OrdenVentaId]),
    CONSTRAINT [FK_MovimientoCaja_Persona] FOREIGN KEY ([PersonaId]) REFERENCES [MAESTRO].[Persona] ([PersonaId])
);

