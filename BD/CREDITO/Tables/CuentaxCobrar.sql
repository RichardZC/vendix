CREATE TABLE [CREDITO].[CuentaxCobrar] (
    [CuentaxCobrarId]  INT             IDENTITY (1, 1) NOT NULL,
    [Operacion]        CHAR (3)        NOT NULL,
    [Monto]            DECIMAL (16, 2) CONSTRAINT [DF__CuentasxC__Monto__39643D13] DEFAULT ((0)) NOT NULL,
    [Estado]           CHAR (3)        NOT NULL,
    [MovimientoCajaId] INT             NULL,
    [CreditoId]        INT             NULL,
    CONSTRAINT [PK__Cuentasx__D5EF24B3377BF4A1] PRIMARY KEY CLUSTERED ([CuentaxCobrarId] ASC),
    CONSTRAINT [FK__CuentasxC__Movim__3A58614C] FOREIGN KEY ([MovimientoCajaId]) REFERENCES [CREDITO].[MovimientoCaja] ([MovimientoCajaId]),
    CONSTRAINT [FK__CuentaxCo__Credi__3D69D821] FOREIGN KEY ([CreditoId]) REFERENCES [CREDITO].[Credito] ([CreditoId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'INI= cuota inicial,CON= pago al contado', @level0type = N'SCHEMA', @level0name = N'CREDITO', @level1type = N'TABLE', @level1name = N'CuentaxCobrar', @level2type = N'COLUMN', @level2name = N'Operacion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PEN,CAN', @level0type = N'SCHEMA', @level0name = N'CREDITO', @level1type = N'TABLE', @level1name = N'CuentaxCobrar', @level2type = N'COLUMN', @level2name = N'Estado';

