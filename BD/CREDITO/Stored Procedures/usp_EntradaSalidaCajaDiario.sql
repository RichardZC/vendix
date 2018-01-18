
/*


*/
CREATE PROC [CREDITO].[usp_EntradaSalidaCajaDiario]
@CajaDiarioId INT ,
@PersonaId INT ,
@IndEntrada BIT,
@TipoOperacionId INT,
@Importe DECIMAL(16,2) = 0,
@Decripcion VARCHAR(MAX),
@UsuarioId INT
AS

DECLARE @TipoOperacion CHAR(3)

SELECT @TipoOperacion=Codigo
FROM MAESTRO.TipoOperacion 
WHERE TipoOperacionId=@TipoOperacionId

INSERT INTO CREDITO.MovimientoCaja
        ( CajaDiarioId,PersonaId ,Operacion ,ImporteRecibido ,ImportePago ,
          MontoVuelto ,Descripcion ,IndEntrada ,Estado ,UsuarioRegId ,FechaReg
        )
VALUES  ( @CajaDiarioId,@PersonaId, @TipoOperacion , 0, 
          @Importe , 0 , @Decripcion , @IndEntrada, 1, @UsuarioId , GETDATE())
        
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

