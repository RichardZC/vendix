CREATE TABLE [MAESTRO].[TipoOperacion] (
    [TipoOperacionId] INT          NOT NULL,
    [Codigo]          CHAR (3)     NOT NULL,
    [Denominacion]    VARCHAR (50) NOT NULL,
    [IndEntrada]      BIT          CONSTRAINT [DF_TipoOperacion_IndEntrada] DEFAULT ((1)) NOT NULL,
    [IndCajaDiario]   BIT          CONSTRAINT [DF_TipoOperacion_IndCajaDiario] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__TipoOper__72B493817CFA4D51] PRIMARY KEY CLUSTERED ([TipoOperacionId] ASC)
);

