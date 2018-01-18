CREATE TABLE [CREDITO].[GastosAdm] (
    [GastosAdmId]   INT             IDENTITY (1, 1) NOT NULL,
    [Denominacion]  VARCHAR (50)    NOT NULL,
    [MontoMinimo]   DECIMAL (16, 2) NOT NULL,
    [MontoMaximo]   DECIMAL (16, 2) NOT NULL,
    [IndPorcentaje] BIT             NOT NULL,
    [Valor]         DECIMAL (16, 2) NOT NULL,
    [Estado]        BIT             NOT NULL,
    CONSTRAINT [PK__GastosAd__B499EA5B2962DF74] PRIMARY KEY CLUSTERED ([GastosAdmId] ASC)
);

