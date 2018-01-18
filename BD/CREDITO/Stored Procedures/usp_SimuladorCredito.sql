-- CREDITO.usp_SimuladorCredito 'V','M',28833.34,10,19.02,'20121001'
CREATE PROC [CREDITO].[usp_SimuladorCredito]
@Tipo CHAR(1)='V',
@FormaPago CHAR(1)='M', 
@Monto DECIMAL(16,2) = 0.0,
@NroCuotas INT=24, 
@TEA DECIMAL(4,2)= 19,
@FechaPrimerPago DATE = '20150101',
@GastosAdm DECIMAL(16,2) = NULL
AS

DECLARE @FactorCompensacion DECIMAL(4,2) = 0.0 , @FRC DECIMAL(18,16)

--DECLARE @tTEM TABLE(t DECIMAL(18,16))
--INSERT INTO @tTEM EXEC [CREDITO].[usp_CalcularTEM] @TEA,@FormaPago
--DECLARE @TEM DECIMAL (18,16) 
--SELECT @TEM = t FROM @tTEM

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
 








