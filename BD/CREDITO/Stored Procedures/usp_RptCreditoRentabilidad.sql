
-- CREDITO.usp_RptCreditoRentabilidad 1,'20140201','20140630'
CREATE PROC [CREDITO].[usp_RptCreditoRentabilidad]
@OficnaId INT = NULL,
@FechaIni DATE ,
@FechaFin DATE 
AS

;WITH CREDITOSUM AS(
	SELECT CR.CreditoId,COUNT(1) 'CuotasPagadas', SUM(PP.Amortizacion) 'SumAmortizacion',SUM(PP.Interes) 'SumInteres',
	SUM(PP.GastosAdm) 'SumGastosAdm',SUM(PP.Cuota) 'SumCuota',SUM(PP.ImporteMora + PP.InteresMora) 'SumMora',
	SUM(PP.PagoCuota + PP.PagoLibre) 'SumPago'
	FROM CREDITO.Credito CR
	INNER JOIN CREDITO.PlanPago PP ON CR.CreditoId = PP.CreditoId AND PP.Estado='PAG'
	WHERE	CR.OficinaId=ISNULL(@OficnaId,CR.OficinaId) 
	AND CAST(CR.FechaDesembolso AS DATE) BETWEEN @FechaIni AND @FechaFin
	--check anulados
	GROUP BY CR.CreditoId
)
SELECT	C.CreditoId,O.Denominacion 'Oficina',P.NombreCompleto 'Cliente',
		C.FechaDesembolso,C.NumeroCuotas,C.Interes,C.FormaPago,c.Estado,
		C.MontoProducto,C.MontoInicial,C.MontoCredito,C.MontoGastosAdm,
		CS.CuotasPagadas,Cs.SumAmortizacion,CS.SumGastosAdm,CS.SumInteres,CS.SumCuota,CS.SumMora,CS.SumPago
FROM CREDITO.Credito C
INNER JOIN CREDITOSUM CS ON C.CreditoId = CS.CreditoId
INNER JOIN MAESTRO.Persona P ON C.PersonaId = P.PersonaId
INNER JOIN MAESTRO.Oficina O ON C.OficinaId = O.OficinaId
ORDER BY C.FechaDesembolso

