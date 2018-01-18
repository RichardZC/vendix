
/* 
	SELECT * FROM CREDITO.Credito where estado='DES'
	SELECT * FROM CREDITO.PlanPago where creditoid=88
	CREDITO.usp_CuotasPendientes 292,'20140806',1
	
*/
CREATE PROC [CREDITO].[usp_CuotasPendientes]
@CreditoId INT,
@FechaCalculo DATE,
@IndCancelacion BIT = 0
AS

DECLARE @CuotaCalculo INT,@CuotaIni INT,@CuotaFin INT,@CuotaCancel INT,@Modalidad CHAR(1), @FechaVctoIni DATE

IF @IndCancelacion=1
BEGIN
	SELECT	TOP 1 @CuotaCalculo=Numero 
	FROM	CREDITO.PlanPago PP
	WHERE	PP.CreditoId=@CreditoId AND PP.Estado='PEN' AND @FechaCalculo<=PP.FechaVencimiento 
	ORDER BY Numero

	IF @CuotaCalculo IS NULL
		SELECT	TOP 1 @CuotaCalculo=MAX(Numero) 
		FROM	CREDITO.PlanPago PP
		WHERE	PP.CreditoId=@CreditoId AND PP.Estado='PEN' 

	SELECT @CuotaFin = CASE FormaPago 
								WHEN 'M' THEN  @CuotaCalculo
								WHEN 'Q' THEN  CEILING(CAST(@CuotaCalculo AS DECIMAL)/2) * 2
								WHEN 'S' THEN  CEILING(CAST(@CuotaCalculo AS DECIMAL)/4) * 4
								WHEN 'D' THEN  CEILING(CAST(@CuotaCalculo AS DECIMAL)/26) * 26
						 END,
			@CuotaIni = CASE FormaPago 
								WHEN 'M' THEN  @CuotaCalculo
								WHEN 'Q' THEN  CEILING(CAST(@CuotaCalculo AS DECIMAL)/2) * 2 - 1
								WHEN 'S' THEN  CEILING(CAST(@CuotaCalculo AS DECIMAL)/4) * 4 - 3
								WHEN 'D' THEN  CEILING(CAST(@CuotaCalculo AS DECIMAL)/26) * 26 - 25
						 END,
			@Modalidad=FormaPago
	FROM CREDITO.Credito WHERE CreditoId=@CreditoId

	SET @CuotaCancel=@CuotaFin
	
	IF @Modalidad='D'
	BEGIN
		SELECT @FechaVctoIni=FechaVencimiento FROM CREDITO.PlanPago WHERE CreditoId=@CreditoId AND Numero=@CuotaIni
		IF DATEDIFF(DAY,@FechaVctoIni,@FechaCalculo)<2
			SET @CuotaCancel=@CuotaCalculo
	END
	ELSE IF @Modalidad='M'
	BEGIN
		IF @CuotaCalculo>1
			SELECT @FechaVctoIni=FechaVencimiento FROM CREDITO.PlanPago WHERE CreditoId=@CreditoId AND Numero=@CuotaCalculo-1
		ELSE
			SELECT @FechaVctoIni=DATEADD(MONTH,-1,FechaVencimiento) FROM CREDITO.PlanPago WHERE CreditoId=@CreditoId AND Numero=1
			
		SET @FechaVctoIni=DATEADD(DAY,1,@FechaVctoIni)
		--SELECT @FechaVctoIni 'VctoIni',@FechaCalculo 'FCalculo',DATEDIFF(DAY,@FechaVctoIni,@FechaCalculo)
		IF DATEDIFF(DAY,@FechaVctoIni,@FechaCalculo)<2
			SET @CuotaCancel=@CuotaCalculo - 1		
	END
	ELSE
	BEGIN		
		IF @CuotaCalculo = @CuotaIni
			BEGIN
				IF @CuotaCalculo>1
					SELECT @FechaVctoIni=FechaVencimiento FROM CREDITO.PlanPago WHERE CreditoId=@CreditoId AND Numero=@CuotaCalculo-1
				ELSE
				BEGIN
					IF @Modalidad='Q'
						SELECT @FechaVctoIni=DATEADD(day,-15,FechaVencimiento) FROM CREDITO.PlanPago WHERE CreditoId=@CreditoId AND Numero=1
					IF @Modalidad='S'
						SELECT @FechaVctoIni=DATEADD(day,-7,FechaVencimiento) FROM CREDITO.PlanPago WHERE CreditoId=@CreditoId AND Numero=1
				END	
				SET @FechaVctoIni=DATEADD(DAY,1,@FechaVctoIni)
				--SELECT @FechaVctoIni 'VctoIni',@FechaCalculo 'FCalculo',DATEDIFF(DAY,@FechaVctoIni,@FechaCalculo)
				IF DATEDIFF(DAY,@FechaVctoIni,@FechaCalculo)<0
					SET @CuotaCancel=0
				ELSE IF DATEDIFF(DAY,@FechaVctoIni,@FechaCalculo)<2
					SET @CuotaCancel=@CuotaCalculo
			END	
	END
	--SELECT @CuotaIni 'CuotaIni',@CuotaCalculo 'CuotaCalculo',@CuotaFin 'CuotaFin', @CuotaCancel 'CuotaCancelacion'
END

;WITH CUOTAS AS(
	SELECT	pp.PlanPagoId, 
			'CREDITO ' + CAST(C.CreditoId AS VARCHAR(12)) + ' - CUOTA ' + CAST(PP.Numero AS VARCHAR(8)) 'Glosa', 
			PP.Numero, PP.FechaVencimiento,PP.Amortizacion,PP.Interes,PP.GastosAdm, PP.Cuota ,
			dbo.ufnCalcularDiasAtrazo(pp.FechaVencimiento,@FechaCalculo) 'DiasAtrazo',
			ISNULL(P.ImporteMoratorio,0) 'ImporteMoratorio', ISNULL(P.DiasGracia,0) 'DiasGracia',
			ISNULL(PP.PagoLibre,0) 'PagoLibre',C.FechaDesembolso,PP.Cargo,
			CASE WHEN C.FormaPago='D' THEN 26 ELSE 30 END 'DiasMes'
	FROM CREDITO.Credito C 
	INNER JOIN CREDITO.PlanPago PP ON C.CreditoId = PP.CreditoId AND PP.Estado='PEN'
	LEFT JOIN CREDITO.Producto P ON C.ProductoId=P.ProductoId
	WHERE C.Estado='DES' AND C.CreditoId=@CreditoId
), CUOTASREF AS(
	SELECT	C.*, dbo.ufnCalcularMora(C.ImporteMoratorio, C.DiasAtrazo,C.DiasGracia) 'ImporteMora',
			dbo.ufnCalcularMora((C.Interes+C.Amortizacion)*C.ImporteMoratorio/C.DiasMes, C.DiasAtrazo,C.DiasGracia) 'InteresMora',
			ISNULL(PN.FechaVencimiento,C.FechaDesembolso) 'FechaPagoAnt'
	FROM CUOTAS C
	LEFT JOIN CREDITO.PlanPago PN ON PN.Numero=C.Numero-1 AND PN.CreditoId=@CreditoId
)
	SELECT	PlanPagoId, Glosa, FechaVencimiento, Amortizacion,Interes,GastosAdm,Cuota, 
			DiasAtrazo, ImporteMora, InteresMora, Cargo, PagoLibre, 
			Cuota + ImporteMora + InteresMora + Cargo - PagoLibre 'PagoCuota'
	FROM CUOTASREF 
	WHERE @IndCancelacion=0
UNION ALL
	SELECT	PlanPagoId, Glosa, FechaVencimiento, Amortizacion,
			CASE WHEN Numero>@CuotaCancel THEN 0 ELSE Interes END 'Interes',GastosAdm,
			CASE WHEN Numero>@CuotaCancel THEN Amortizacion + GastosAdm ELSE Cuota END 'Cuota', 
			DiasAtrazo, ImporteMora,InteresMora,Cargo,PagoLibre, 
			CASE WHEN Numero>@CuotaCancel 
			THEN Amortizacion + GastosAdm + ImporteMora + InteresMora + Cargo - PagoLibre 
			ELSE Cuota + ImporteMora + InteresMora + Cargo - PagoLibre END 'PagoCuota'			
	FROM CUOTASREF 
	WHERE @IndCancelacion=1
ORDER BY 1
