﻿
/*
UPDATE CREDITO.PlanPago SET Estado='PEN', MovimientoCajaId=NULL,FechaPagoCuota=NULL, DiasAtrazo=0,Mora=0,PagoCuota=0
WHERE PlanPagoId IN(2)
DELETE FROM CREDITO.MovimientoCaja

EXEC CREDITO.usp_PagarCuotas 2,'2',100,3

SELECT * FROM CREDITO.PlanPago where planpagoid in(2)
SELECT * FROM CREDITO.MovimientoCaja
SELECT * FROM VENTAS.OrdenVenta

*/
CREATE PROC [CREDITO].[usp_PagarCuotas]
@CajaDiarioId INT ,
@CreditoId INT,
@ListaPlanPagoId VARCHAR(MAX),
@ImporteRecibido DECIMAL(16,2) = 0,
@UsuarioId INT,
@FechaPago DATE=NULL
AS

DECLARE @TotalPago DECIMAL(16,2)=0, @IndImporteLibre BIT = 0

IF @ListaPlanPagoId IS NULL
	SET @ListaPlanPagoId = ''
	
IF LEN(@ListaPlanPagoId) > 0 AND NOT EXISTS(	SELECT	1 FROM dbo.Split(@ListaPlanPagoId,',') L
												INNER JOIN CREDITO.PlanPago PP ON L.Name=pp.PlanPagoId
												WHERE PP.Estado='PEN' AND PP.CreditoId=@CreditoId)
BEGIN
	RETURN
END

IF @FechaPago IS NULL
	SET @FechaPago=GETDATE()

DECLARE @tCuotasPendientes TABLE(Id INT IDENTITY(1,1),PlanPagoId INT,Glosa VARCHAR(MAX),FechaVencimiento DATE,Amortizacion DECIMAL(16,2),
								Interes DECIMAL(16,2), GastosAdm DECIMAL(16,2), Cuota DECIMAL(16,2), DiasAtrazo INT,
								ImporteMora DECIMAL(16,2),InteresMora DECIMAL(16,2), Cargo DECIMAL(16,2),
								PagoLibre DECIMAL(16,2),PagoCuota DECIMAL(16,2))
INSERT INTO @tCuotasPendientes
EXEC CREDITO.usp_CuotasPendientes @CreditoId,@FechaPago
--SELECT * FROM @tCuotasPendientes

DECLARE @PlanPagoIdUlt INT,@SumaPagoCuotaUlt DECIMAL(16,2)=0
IF LEN(@ListaPlanPagoId) = 0
BEGIN
	DECLARE @NroCuotas INT=0,@PagoCuota DECIMAL(16,2)=0,@Index INT=1
	SET @NroCuotas = (SELECT COUNT(1) FROM @tCuotasPendientes)
	SET @PagoCuota = (SELECT TOP 1 PagoCuota FROM @tCuotasPendientes)
	SET @IndImporteLibre = 1
	
	WHILE @SumaPagoCuotaUlt <= @ImporteRecibido AND @Index <= @NroCuotas
	BEGIN
		SELECT @PagoCuota=PagoCuota, @PlanPagoIdUlt=PlanPagoId 
		FROM @tCuotasPendientes WHERE Id=@Index
		
		IF @SumaPagoCuotaUlt + @PagoCuota <= @ImporteRecibido
		BEGIN
			SET @SumaPagoCuotaUlt = @SumaPagoCuotaUlt + @PagoCuota
			SET @ListaPlanPagoId = @ListaPlanPagoId + CAST(@PlanPagoIdUlt AS VARCHAR(10)) + ','
		END
		ELSE
			BREAK
		SET @Index = @Index + 1
	END
	
	IF LEN(@ListaPlanPagoId)>0
		SET @ListaPlanPagoId = SUBSTRING(@ListaPlanPagoId,1,LEN(@ListaPlanPagoId)-1)
END
--SELECT @ListaPlanPagoId
UPDATE PP
SET DiasAtrazo= CP.DiasAtrazo ,
	ImporteMora=CP.ImporteMora,
	InteresMora=CP.InteresMora,
	PagoCuota = CP.PagoCuota
FROM dbo.Split(@ListaPlanPagoId,',') L 
INNER JOIN @tCuotasPendientes CP ON L.Name=CP.PlanPagoId
INNER JOIN CREDITO.PlanPago PP ON CP.PlanPagoId = PP.PlanPagoId
WHERE PP.CreditoId=@CreditoId

SELECT	@TotalPago = SUM(PP.PagoCuota) 
FROM dbo.Split(@ListaPlanPagoId,',') L
INNER JOIN CREDITO.PlanPago PP ON L.Name=pp.PlanPagoId
WHERE PP.Estado='PEN' AND PP.CreditoId=@CreditoId

DECLARE @Cuotas VARCHAR(MAX)='',@PersonaId INT, @OrdenVentaId INT
SELECT	@PersonaId = PersonaId , @OrdenVentaId = OrdenVentaId
FROM	CREDITO.Credito WHERE CreditoId = @CreditoId

SET @Cuotas = STUFF((SELECT ',' + rtrim(convert(char(15),Numero))
				FROM dbo.Split(@ListaPlanPagoId,',') L
				INNER JOIN CREDITO.PlanPago PP ON L.Name=pp.PlanPagoId
				FOR XML PATH('')),1,1,'') 
	
DECLARE @MovimientoCajaId INT
IF @IndImporteLibre=0
BEGIN
	INSERT INTO CREDITO.MovimientoCaja
			( CajaDiarioId,PersonaId ,Operacion ,ImporteRecibido ,ImportePago ,
			  MontoVuelto ,Descripcion ,IndEntrada ,Estado,OrdenVentaId,CreditoId,UsuarioRegId ,FechaReg
			)
	VALUES  ( @CajaDiarioId,@PersonaId, 'CUO' , @ImporteRecibido, @TotalPago , 
			  @ImporteRecibido -  @TotalPago, 'CREDITO ' + CAST(@CreditoId AS VARCHAR(20)) + ' CUOTA ' + @Cuotas  , 
			  1, 1,@OrdenVentaId,@CreditoId, @UsuarioId , GETDATE())
	SET @MovimientoCajaId = @@IDENTITY
END			  
ELSE
BEGIN
	-- PAGO IMPORTE LIBRE
	INSERT INTO CREDITO.MovimientoCaja
			( CajaDiarioId,PersonaId ,Operacion ,ImporteRecibido ,ImportePago ,
			  MontoVuelto ,Descripcion ,IndEntrada ,Estado,OrdenVentaId,CreditoId ,UsuarioRegId ,FechaReg
			)
	VALUES  ( @CajaDiarioId,@PersonaId, 'CUO' , @ImporteRecibido, @ImporteRecibido , 
			  0, 'CREDITO ' + CAST(@CreditoId AS VARCHAR(20)) + ISNULL(' CUOTA ' + @Cuotas,'') + ' PAGO LIBRE ' + CAST(@ImporteRecibido AS VARCHAR(20)) , 
			  1, 1,@OrdenVentaId,@CreditoId, @UsuarioId , GETDATE())
	SET @MovimientoCajaId = @@IDENTITY
	
	IF LEN(@ListaPlanPagoId)>0
		INSERT INTO CREDITO.PlanPagoLibre( PlanPagoId,MovimientoCajaId, PagoLibre)
		SELECT pp.PlanPagoId,@MovimientoCajaId,pp.PagoCuota
		FROM dbo.Split(@ListaPlanPagoId,',') L
		INNER JOIN CREDITO.PlanPago PP ON L.Name=pp.PlanPagoId
	
	IF @ImporteRecibido>@SumaPagoCuotaUlt 
	BEGIN
		SET @PlanPagoIdUlt = NULL
		IF LEN(@ListaPlanPagoId)>0
			SELECT TOP 1 @PlanPagoIdUlt = PlanPagoId FROM CREDITO.PlanPago PP
			LEFT JOIN dbo.Split(@ListaPlanPagoId,',') L ON L.Name=pp.PlanPagoId
			WHERE PP.CreditoId=@CreditoId AND PP.Estado='PEN' AND L.Name IS NULL 
			ORDER BY Numero ASC
		ELSE
			SELECT TOP 1 @PlanPagoIdUlt = PlanPagoId FROM CREDITO.PlanPago PP
			WHERE PP.CreditoId=@CreditoId AND PP.Estado='PEN' 
			ORDER BY Numero ASC
			
		IF @PlanPagoIdUlt IS NOT NULL
		BEGIN
			INSERT INTO CREDITO.PlanPagoLibre( PlanPagoId,MovimientoCajaId, PagoLibre)
			VALUES  ( @PlanPagoIdUlt, @MovimientoCajaId, @ImporteRecibido-@SumaPagoCuotaUlt)
			
			UPDATE CREDITO.PlanPago 
			SET PagoLibre=(SELECT SUM(PagoLibre) FROM CREDITO.PlanPagoLibre WHERE PlanPagoId=@PlanPagoIdUlt)
			WHERE PlanPagoId=@PlanPagoIdUlt
		END
	END	
	
	--;WITH PAGOLIBRE AS(
	--	SELECT PPL.PlanPagoId,SUM(PPL.PagoLibre) 'PagoLibre' 
	--	FROM CREDITO.PlanPagoLibre PPL
	--	INNER JOIN CREDITO.PlanPago PP ON PPL.PlanPagoId = PP.PlanPagoId
	--	WHERE PP.CreditoId=@CreditoId AND PP.Estado='PEN' 
	--	GROUP BY PPL.PlanPagoId
	--)
	--UPDATE PP
	--SET PagoLibre = PL.PagoLibre
	--FROM PAGOLIBRE PL
	--INNER JOIN CREDITO.PlanPago PP ON PL.PlanPagoId = PP.PlanPagoId
		
			
END	
        
UPDATE PP
SET Estado = 'PAG',MovimientoCajaId=@MovimientoCajaId,
	FechaPagoCuota=GETDATE(), UsuarioModId=@UsuarioId,FechaMod=GETDATE()
FROM dbo.Split(@ListaPlanPagoId,',') L
INNER JOIN CREDITO.PlanPago PP ON L.Name=pp.PlanPagoId
WHERE PP.Estado='PEN' AND PP.CreditoId=@CreditoId

/*actualizar caja diario*/
DECLARE @entradas DECIMAL(16,2)=0, @salidas DECIMAL(16,2)=0
SELECT @entradas=SUM(ImportePago) 
FROM CREDITO.MovimientoCaja
WHERE CajaDiarioId=@CajaDiarioId AND Estado=1 AND IndEntrada=1

SELECT @salidas=SUM(ImportePago) 
FROM CREDITO.MovimientoCaja
WHERE CajaDiarioId=@CajaDiarioId AND Estado=1 AND IndEntrada=0

UPDATE CREDITO.CajaDiario 
SET Entradas=ISNULL(@entradas,0) , Salidas = ISNULL(@salidas,0) , 
	SaldoFinal = SaldoInicial + ISNULL(@entradas,0) - ISNULL(@salidas,0)
WHERE CajaDiarioId=@CajaDiarioId

/*actualizar el credito*/

UPDATE	CREDITO.Credito
SET		Estado='PAG', UsuarioModId=@UsuarioId, FechaMod=GETDATE()
WHERE	CreditoId=@CreditoId AND
		NOT EXISTS(SELECT 1 FROM CREDITO.PlanPago WHERE CreditoId= @CreditoId AND Estado='PEN')

SELECT @MovimientoCajaId
