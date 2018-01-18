CREATE TABLE [ALMACEN].[TipoMovimiento] (
    [TipoMovimientoId] INT           IDENTITY (1, 1) NOT NULL,
    [Denominacion]     VARCHAR (70)  NULL,
    [Descripcion]      VARCHAR (250) NULL,
    [IndEntrada]       BIT           NOT NULL,
    [IndTransferencia] BIT           NULL,
    [IndDevolucion]    BIT           NULL,
    [Estado]           BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([TipoMovimientoId] ASC)
);

