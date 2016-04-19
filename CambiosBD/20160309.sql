
ALTER TABLE CREDITO.Credito ADD
	TipoCuota char(1) NOT NULL DEFAULT('V')

DROP TABLE CREDITO.GastosAdm
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


INSERT INTO CREDITO.GastosAdm ( Denominacion ,MontoMinimo ,MontoMaximo ,IndPorcentaje ,Valor ,Estado)
VALUES  ( 'GASTO ADMINISTRATIVO' , 0 , 2000 , 1 , 2 , 1  )
INSERT INTO CREDITO.GastosAdm ( Denominacion ,MontoMinimo ,MontoMaximo ,IndPorcentaje ,Valor ,Estado)
VALUES  ( 'GASTO ADMINISTRATIVO' , 2001 , 9999999 , 0 , 20 , 1  )
INSERT INTO CREDITO.GastosAdm ( Denominacion ,MontoMinimo ,MontoMaximo ,IndPorcentaje ,Valor ,Estado)
VALUES  ( 'INFOCORP' , 2001 , 9999999 , 0 , 10 , 1  )
INSERT INTO CREDITO.GastosAdm ( Denominacion ,MontoMinimo ,MontoMaximo ,IndPorcentaje ,Valor ,Estado)
VALUES  ( 'DESGRAVAMEN' , 2001 , 9999999 , 1 , 0.7 , 1  )

