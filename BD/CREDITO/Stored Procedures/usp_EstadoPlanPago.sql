﻿

-- EXEC CREDITO.usp_EstadoPlanPago 2518
CREATE PROC [CREDITO].[usp_EstadoPlanPago] 
@CreditoId INT
AS

DECLARE @Fecha DATE = GETDATE()
DECLARE @tplanpago TABLE(PlanPagoId INT,Glosa VARCHAR(MAX),FechaVencimiento DATE,Amortizacion DECIMAL(16,2),
						Interes DECIMAL(16,2), GastosAdm DECIMAL(16,2), Cuota DECIMAL(16,2), DiasAtrazo INT,
						ImporteMora DECIMAL(16,2),InteresMora DECIMAL(16,2), Cargo DECIMAL(16,2),
						PagoLibre DECIMAL(16,2),PagoCuota DECIMAL(16,2))

INSERT INTO @tplanpago
EXEC CREDITO.usp_CuotasPendientes @CreditoId,@Fecha

SELECT	PP.PlanPagoId,PP.Numero,PP.Capital,PP.FechaVencimiento,PP.Amortizacion,PP.Interes,PP.GastosAdm,PP.Cuota,PP.Estado, 
		CASE WHEN PP.Estado='PEN' THEN P.DiasAtrazo ELSE PP.DiasAtrazo END 'DiasAtrazo', 
		CASE WHEN PP.Estado='PEN' THEN P.ImporteMora ELSE PP.ImporteMora END 'ImporteMora', 
		CASE WHEN PP.Estado='PEN' THEN P.InteresMora ELSE PP.InteresMora END 'InteresMora', 
		CASE WHEN PP.Estado='PEN' THEN P.Cargo ELSE PP.Cargo END 'Cargo', 
		CASE WHEN PP.Estado='PEN' THEN P.PagoLibre ELSE PP.PagoLibre END 'PagoLibre', 
		CASE WHEN PP.Estado='PEN' THEN NULL ELSE PP.FechaPagoCuota END 'FechaPagoCuota', 
		CASE WHEN PP.Estado='PEN' THEN P.PagoCuota ELSE PP.PagoCuota END 'PagoCuota',
		CASE WHEN PP.Estado='PEN' THEN null ELSE PP.MovimientoCajaId END 'MovimientoCajaId'
FROM	CREDITO.PlanPago  PP
LEFT JOIN @tplanpago P ON PP.PlanPagoId=P.PlanPagoId
WHERE	PP.CreditoId = @CreditoId
ORDER BY PP.Numero

