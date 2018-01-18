
/*

SELECT * FROM CREDITO.PlanPago WHERE CreditoId=45
EXEC CREDITO.usp_RptCredito 1,'20140101','20140501'

*/
CREATE PROC [CREDITO].[usp_RptCredito]
@OficinaId INT ,
@Estado CHAR(3),
@FechaDesIni DATE ,
@FechaDesFin DATE 
AS


	SELECT	UPPER(PR.Denominacion) 'Producto',P.NombreCompleto 'Cliente',C.CreditoId,FechaDesembolso,
			(SELECT MAX(FechaVencimiento) FROM CREDITO.PlanPago WHERE CreditoId=C.CreditoId) 'FechaVcto',
			C.FormaPago,NumeroCuotas,Interes,C.Estado,
			C.MontoProducto,C.MontoInicial,MontoCredito,TipoGastoAdm,MontoGastosAdm,MontoDesembolso				
	FROM CREDITO.Credito C
	INNER JOIN CREDITO.Producto PR ON C.ProductoId = PR.ProductoId
	INNER JOIN MAESTRO.Persona P ON C.PersonaId = P.PersonaId
	WHERE	C.OficinaId = ISNULL(@OficinaId,C.OficinaId) AND C.Estado=@Estado AND
			CAST(C.FechaReg AS DATE) BETWEEN @FechaDesIni AND @FechaDesFin 
			
	
