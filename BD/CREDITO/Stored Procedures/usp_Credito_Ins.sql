 
/*
UPDATE CREDITO.SolicitudCredito SET EstadoId=1
DELETE FROM CREDITO.CuentaxCobrar
DELETE FROM CREDITO.PlanPago
DELETE FROM  CREDITO.Credito

SELECT * FROM CREDITO.Credito
SELECT * FROM CREDITO.PlanPago
SELECT * FROM CREDITO.SolicitudCredito
*/


-- CREDITO.usp_Credito_Ins 512,1,'V',0,800, 16,'CAP','M',12,19.80,'20160526','',1
CREATE PROC [CREDITO].[usp_Credito_Ins]
@SolicitudCreditoId INT,
@ProductoId INT,
@TipoCuota CHAR(1),
@MontoInicial DECIMAL(16,2),
@MontoCredito DECIMAL(16,2),
@MontoGastosAdm DECIMAL(16,2),
@IndGastoAdm CHAR(3),
@FormaPago CHAR(1), 
@NroCuotas INT, 
@Interes DECIMAL(4,2),
@FechaPrimerPago DATE,
@Observacion VARCHAR(MAX),
@UsuarioId INT 
AS

DECLARE @Mensaje VARCHAR(100)='', @MontoGA DECIMAL(16,2)=0, @Desembolso DECIMAL(16,2) = @MontoCredito

IF EXISTS(SELECT 1 FROM CREDITO.Credito WHERE CreditoId=@SolicitudCreditoId AND Estado<>'CRE')
BEGIN
	SET @Mensaje='ERROR: La Solicitud debe estar en estado CREADA'
	SELECT @Mensaje 'Mensaje'
	RETURN
END

IF @IndGastoAdm='CUO'
	SET @MontoGA=@MontoGastosAdm

IF @IndGastoAdm='CAP'
	SET @Desembolso = @MontoCredito - @MontoGastosAdm

/*CREACION PLAN PAGOS*/
DECLARE @tPlanPagos TABLE(Numero INT,Capital DECIMAL(16,2),FechaPago DATE,Amortizacion DECIMAL(16,2),Interes DECIMAL(16,2),GastosAdm DECIMAL(16,2),Cuota DECIMAL(16,2))
INSERT INTO @tPlanPagos
EXEC CREDITO.usp_SimuladorCredito @TipoCuota, @FormaPago, @MontoCredito, @NroCuotas ,@Interes, @FechaPrimerPago,@MontoGA

INSERT INTO CREDITO.PlanPago ( CreditoId ,Numero ,Capital ,FechaVencimiento ,Amortizacion ,Interes,GastosAdm ,Cuota,Estado)
SELECT @SolicitudCreditoId 'CreditoId', *, 'CRE' FROM @tPlanPagos

/*ACTUALIZAR CREDITO*/
UPDATE CREDITO.Credito 
SET Estado='PEN' , 
FechaPrimerPago=@FechaPrimerPago,Interes=@Interes,
FormaPago=@FormaPago,NumeroCuotas=@NroCuotas,
MontoInicial=@MontoInicial,MontoGastosAdm=@MontoGastosAdm,MontoCredito=@MontoCredito, MontoDesembolso = @Desembolso,
TipoGastoAdm=@IndGastoAdm,
ProductoId=@ProductoId,
Observacion=@Observacion,
TipoCuota=@TipoCuota,
FechaMod=GETDATE(),UsuarioModId=@UsuarioId,
FechaVencimiento=(SELECT MAX(FechaPago) FROM @tPlanPagos)
WHERE CreditoId=@SolicitudCreditoId

SELECT @Mensaje 'Mensaje'		

