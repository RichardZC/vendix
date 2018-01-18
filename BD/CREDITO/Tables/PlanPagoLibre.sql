CREATE TABLE [CREDITO].[PlanPagoLibre] (
    [PlanPagoId]       INT             NULL,
    [MovimientoCajaId] INT             NULL,
    [PagoLibre]        DECIMAL (16, 2) NOT NULL,
    CONSTRAINT [FK__PlanPagoL__Movim__75E33B6E] FOREIGN KEY ([MovimientoCajaId]) REFERENCES [CREDITO].[MovimientoCaja] ([MovimientoCajaId]),
    CONSTRAINT [FK__PlanPagoL__PlanP__74EF1735] FOREIGN KEY ([PlanPagoId]) REFERENCES [CREDITO].[PlanPago] ([PlanPagoId])
);

