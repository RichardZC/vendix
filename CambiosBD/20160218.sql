USE [VENDIX]
GO
/****** Object:  StoredProcedure [CREDITO].[usp_EstadoPlanPago]    Script Date: 18/02/2016 17:22:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- EXEC CREDITO.usp_EstadoPlanPago 2518
ALTER PROC [CREDITO].[usp_EstadoPlanPago] 
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

GO
 
/*
UPDATE CREDITO.SolicitudCredito SET EstadoId=1
DELETE FROM CREDITO.CuentaxCobrar
DELETE FROM CREDITO.PlanPago
DELETE FROM  CREDITO.Credito

SELECT * FROM CREDITO.Credito
SELECT * FROM CREDITO.PlanPago
SELECT * FROM CREDITO.SolicitudCredito
*/


-- CREDITO.usp_Credito_Ins 4,10, 500,'D',26,7,'20140101','',1
ALTER PROC [CREDITO].[usp_Credito_Ins]
@SolicitudCreditoId INT,
@ProductoId INT,
@TipoCuota CHAR(1),
@AnalistaId INT,
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

DECLARE @Mensaje VARCHAR(100)='', @MontoGA DECIMAL(16,2)=0

IF EXISTS(SELECT 1 FROM CREDITO.Credito WHERE CreditoId=@SolicitudCreditoId AND Estado<>'CRE')
BEGIN
	SET @Mensaje='ERROR: La Solicitud debe estar en estado CREADA'
	SELECT @Mensaje 'Mensaje'
	RETURN
END

IF @IndGastoAdm='CUO'
	SET @MontoGA=@MontoGastosAdm

/*CREACION PLAN PAGOS*/
DECLARE @tPlanPagos TABLE(Numero INT,Capital DECIMAL(16,2),FechaPago DATE,Amortizacion DECIMAL(16,2),Interes DECIMAL(16,2),GastosAdm DECIMAL(16,2),Cuota DECIMAL(16,2))
INSERT INTO @tPlanPagos
EXEC CREDITO.usp_SimuladorCredito @TipoCuota, @FormaPago, @MontoCredito, @NroCuotas ,@Interes, @FechaPrimerPago,@MontoGA

INSERT INTO CREDITO.PlanPago ( CreditoId ,Numero ,Capital ,FechaVencimiento ,Amortizacion ,Interes,GastosAdm ,Cuota,Estado)
SELECT @SolicitudCreditoId 'CreditoId', *, 'CRE' FROM @tPlanPagos

/*ACTUALIZAR CREDITO*/
UPDATE CREDITO.Credito 
SET Estado='PEN' , 
FechaPrimerPago=@FechaPrimerPago,InteresMensual=@Interes,
FormaPago=@FormaPago,NumeroCuotas=@NroCuotas,
MontoInicial=@MontoInicial,MontoGastosAdm=@MontoGastosAdm,MontoCredito=@MontoCredito,
ProductoId=@ProductoId,AnalistaId=@AnalistaId,
Observacion=@Observacion,
TipoCuota=@TipoCuota,
FechaMod=GETDATE(),UsuarioModId=@UsuarioId,
FechaVencimiento=(SELECT MAX(FechaPago) FROM @tPlanPagos) 
WHERE CreditoId=@SolicitudCreditoId

SELECT @Mensaje 'Mensaje'		

GO
-- CREDITO.usp_SimuladorCredito 2,28833.34,'M',10,21.58,'20121001'
ALTER PROC [CREDITO].[usp_SimuladorCredito]
@Tipo CHAR(1)='V',
@FormaPago CHAR(1)='M', 
@Monto DECIMAL(16,2) = 0.0,
@NroCuotas INT=24, 
@TEA DECIMAL(4,2)= 19,
@FechaPrimerPago DATE = '20150101',
@GastosAdm DECIMAL(16,2) = NULL
AS

DECLARE @FactorCompensacion DECIMAL(4,2) = 0.0 , @FRC DECIMAL(18,16)
DECLARE @PeriodoAnio INT= CASE @FormaPago WHEN 'M' THEN 12 WHEN 'Q' THEN 24 WHEN 'S' THEN 52 WHEN 'D' THEN 360 END
DECLARE @TEM DECIMAL (18,16) = (POWER(CAST(1+(@TEA/100) AS FLOAT),CAST(1.0/@PeriodoAnio AS FLOAT)))-1

SELECT @FactorCompensacion = Valor FROM MAESTRO.ValorTabla WHERE TablaId=3 AND DesCorta=@Tipo

SET @FRC = CAST((@TEM * POWER(1+@TEM,@NroCuotas)) AS FLOAT) / (-1 + POWER(1+@TEM,@NroCuotas))

--SELECT @Monto, @TEA, @TEM, @PeriodoAnio, @FechaPrimerPago, @FactorCompensacion,@FRC

DECLARE @Sec INT=0, @Capital DECIMAL(16,2)=@Monto,@Cuota DECIMAL(16,2)=0,@FechaCuota DATE=@FechaPrimerPago
DECLARE @Amortizacion DECIMAL(16,2)=@Monto/@NroCuotas,@Interes DECIMAL(16,2),@GastoAdmCuota DECIMAL(16,2)
DECLARE @tPlanPagos TABLE(Numero INT,Capital DECIMAL(16,2),FechaPago DATE,Amortizacion DECIMAL(16,2),Interes DECIMAL(16,2),GastosAdm DECIMAL(16,2),Cuota DECIMAL(16,2))

IF @GastosAdm IS NULL
BEGIN
	SET @GastosAdm = 0
	SELECT @GastosAdm = @GastosAdm + CASE WHEN IndPorcentaje=1 THEN @monto*(Valor/100) ELSE valor END
	FROM CREDITO.GastosAdm 
	WHERE Estado=1 AND @Monto BETWEEN MontoMinimo AND MontoMaximo
END
SET @GastoAdmCuota=@GastosAdm/@NroCuotas


WHILE (@Sec<@NroCuotas)
BEGIN
	SET @Sec=@Sec+1
	
	IF @FormaPago='D' --DIARIO
		IF datepart(dw, @FechaCuota) = 1 -- excluimos si es domingo
			SET @FechaCuota = DATEADD(DAY,1,@FechaCuota)
	
	IF @Tipo = 'V' 
		SET @Interes = @Capital - @Capital * POWER(1 - @TEM,CAST(@FactorCompensacion AS FLOAT) / (@FactorCompensacion - 1))
		
	IF @Tipo = 'F' 
	BEGIN
		SET @Interes = @Capital * @TEM
		SET @Cuota = @Monto * @FRC
		SET @Amortizacion = @Cuota - @Interes		
	END			
	
	INSERT INTO	@tPlanPagos(Numero,Capital,FechaPago,Amortizacion,Interes,GastosAdm, Cuota) 
		VALUES		(@Sec,@Capital,@FechaCuota,@Amortizacion,@Interes,@GastoAdmCuota, @Cuota)
	
	SET @Capital=@Capital-@Amortizacion
		
	IF @FormaPago='D' --DIARIO
		SET @FechaCuota = DATEADD(DAY,1,@FechaCuota)
	IF @FormaPago='S' --SEMANAL
		SET @FechaCuota = DATEADD(DAY,7,@FechaCuota)
	IF @FormaPago='Q' --QUINCENAL
		SET @FechaCuota = DATEADD(DAY,15,@FechaCuota)
	IF @FormaPago='M' --MENSUAL
		SET @FechaCuota = DATEADD(MONTH,1,@FechaCuota)
END

UPDATE	@tPlanPagos 
SET		Amortizacion = Capital, 
		GastosAdm = @GastosAdm - (@GastoAdmCuota * (@NroCuotas-1))
WHERE	Numero=@NroCuotas

UPDATE @tPlanPagos SET Cuota=Amortizacion+Interes+GastosAdm


SELECT * FROM @tPlanPagos
 








