/*
[CREDITO].[usp_MovimientoCaja_Del] 43,'pruebas',3
*/
CREATE PROC [CREDITO].[usp_MovimientoCaja_Del] 
@MovimientoCajaId INT,
@Observacion VARCHAR(MAX),
@UsuarioId INT
AS

DECLARE @Operacion CHAR(3),@CreditoId INT,@OrdenVentaId INT,@CajaDiarioId INT,@EstadoEnAlmacen INT=2
SELECT @Operacion=Operacion,@CajaDiarioId=CajaDiarioId 
FROM CREDITO.MovimientoCaja 
WHERE MovimientoCajaId=@MovimientoCajaId

INSERT INTO CREDITO.MovimientoCajaAnu ( MovimientoCajaId ,Observacion ,UsuarioRegId ,FechaReg)
VALUES  ( @MovimientoCajaId , @Observacion ,@UsuarioId ,GETDATE())

IF @Operacion='CUO'
BEGIN	
	SELECT TOP 1 @CreditoId=CreditoId FROM CREDITO.PlanPago WHERE MovimientoCajaId = @MovimientoCajaId
	
	UPDATE CREDITO.PlanPago 
	SET MovimientoCajaId=NULL, Estado='PEN',DiasAtrazo=0,ImporteMora=0,InteresMora=0,PagoCuota=NULL,FechaPagoCuota=NULL 
	WHERE MovimientoCajaId = @MovimientoCajaId	
	
	DELETE FROM CREDITO.PlanPagoLibre WHERE MovimientoCajaId=@MovimientoCajaId
	
	;WITH PAGOLIBRE AS(
		SELECT PPL.PlanPagoId,SUM(PPL.PagoLibre) 'PagoLibre' 
		FROM CREDITO.PlanPagoLibre PPL
		INNER JOIN CREDITO.PlanPago PP ON PPL.PlanPagoId = PP.PlanPagoId
		WHERE PP.CreditoId=@CreditoId AND PP.Estado='PEN' 
		GROUP BY PPL.PlanPagoId
	)
	UPDATE PP
	SET PagoLibre = ISNULL(PL.PagoLibre,0)
	FROM CREDITO.PlanPago PP
	LEFT JOIN PAGOLIBRE PL ON PL.PlanPagoId = PP.PlanPagoId
	WHERE PP.CreditoId=@CreditoId AND PP.Estado='PEN' AND PP.PagoLibre>0
	
	UPDATE CREDITO.MovimientoCaja SET Estado=0 WHERE MovimientoCajaId = @MovimientoCajaId	
	UPDATE CREDITO.Credito SET Estado='DES',UsuarioModId=@UsuarioId,FechaMod=GETDATE() WHERE CreditoId=@CreditoId AND Estado='PAG'
END
ELSE
IF @Operacion='INI' OR @Operacion='GAD'
BEGIN	
	SELECT @CreditoId=CreditoId FROM CREDITO.CuentaxCobrar 
	WHERE MovimientoCajaId = @MovimientoCajaId
	
	UPDATE CREDITO.CuentaxCobrar SET MovimientoCajaId=NULL, Estado='PEN' WHERE MovimientoCajaId = @MovimientoCajaId	
	UPDATE CREDITO.MovimientoCaja SET Estado=0 WHERE MovimientoCajaId = @MovimientoCajaId	
	UPDATE CREDITO.Credito SET Estado='DES',UsuarioModId=@UsuarioId,FechaMod=GETDATE() WHERE CreditoId=@CreditoId AND Estado='PAG'
END
ELSE
IF @Operacion='CON'
BEGIN	
	DECLARE @MovimientoAlmacenId INT
	SELECT @OrdenVentaId = ov.OrdenVentaId ,@MovimientoAlmacenId = OV.MovimientoAlmacenId
	FROM CREDITO.MovimientoCaja mc
	INNER JOIN VENTAS.OrdenVenta ov ON ov.OrdenVentaId = mc.OrdenVentaId
	WHERE mc.MovimientoCajaId = @MovimientoCajaId
			
	UPDATE CREDITO.CuentaxCobrar SET Estado='ANU' WHERE MovimientoCajaId = @MovimientoCajaId	
	UPDATE CREDITO.MovimientoCaja SET Estado=0 WHERE MovimientoCajaId = @MovimientoCajaId	
	UPDATE VENTAS.OrdenVenta SET Estado=0,MovimientoAlmacenId=NULL ,UsuarioModId=@UsuarioId,FechaMod=GETDATE()
	WHERE OrdenVentaId=@OrdenVentaId 
	
	UPDATE	SA
	SET		SA.EstadoId=@EstadoEnAlmacen, 
			SA.MovimientoDetSalId = NULL
	FROM VENTAS.OrdenVentaDet OVD
	INNER JOIN VENTAS.OrdenVentaDetSerie OVDS ON OVD.OrdenVentaDetId = OVDS.OrdenVentaDetId
	INNER JOIN ALMACEN.SerieArticulo SA ON SA.SerieArticuloId=OVDS.SerieArticuloId
	WHERE OVD.OrdenVentaId=@OrdenVentaId
	
	DELETE FROM ALMACEN.MovimientoDet WHERE MovimientoId=@MovimientoAlmacenId
	DELETE FROM ALMACEN.Movimiento WHERE MovimientoId=@MovimientoAlmacenId
	
END
ELSE
BEGIN
	UPDATE CREDITO.MovimientoCaja SET Estado=0 WHERE MovimientoCajaId = @MovimientoCajaId	
END

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



