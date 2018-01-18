-- EXEC CREDITO.usp_RptSaldosCaja 1

CREATE PROC [CREDITO].[usp_RptSaldosCaja]
@CajaDiarioId INT
AS

SELECT	MC.MovimientoCajaId, MC.Operacion, MC.FechaReg, P.NombreCompleto 'Cliente', ImportePago, IndEntrada,
		MC.Descripcion 'Glosa'
FROM CREDITO.MovimientoCaja MC
LEFT JOIN MAESTRO.Persona P ON MC.PersonaId = P.PersonaId
WHERE MC.CajaDiarioId=@CajaDiarioId AND MC.Estado=1 
ORDER BY FechaReg 





