
ALTER TABLE CREDITO.Credito ADD
	TipoCuota char(1) NOT NULL DEFAULT('V')

	/* cambios de los gastos administrativos*/
CREATE TABLE [CREDITO].[GastosAdm]
(
[GastosAdmId] [int] NOT NULL IDENTITY(1, 1),
[Denominacion] [varchar] (50) COLLATE Modern_Spanish_CI_AS NOT NULL,
[MontoMinimo] [decimal] (16, 2) NOT NULL,
[MontoMaximo] [decimal] (16, 2) NOT NULL,
[IndPorcentaje] [bit] NOT NULL,
[Valor] [decimal] (16, 2) NOT NULL,
[Estado] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CREDITO].[GastosAdm] ADD CONSTRAINT [PK__GastosAd__B499EA5B2962DF74] PRIMARY KEY CLUSTERED  ([GastosAdmId]) ON [PRIMARY]
GO
