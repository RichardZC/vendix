

CREATE PROCEDURE [CREDITO].[usp_TransferirBoveda](@BovedaInicioId INT,@BovedaDestinoId INT,@Glosa VARCHAR(MAX),
									  @Monto DECIMAL(16,2), @UsuarioRegId INT,@flagAceptar INT, 
									  @BovedaMovTempId INT=0)

AS
DECLARE @Estado BIT,@SaldoInicial DECIMAL(16,2),@Entradas DECIMAL(16,2),@Salidas DECIMAL(16,2),@IndCierre BIT, 
		@CodOperacion CHAR(3),@IndEntrada INT, @FechaReg DATETIME, @MovimientoBovedaIniId INT
		
		 		
SET @CodOperacion = 'TRE'
SET @SaldoInicial = 0
SET @Entradas = 0
SET @Salidas = 0
SET @Estado= 1
SET @IndCierre = 0
SET @IndEntrada = 1
SET @FechaReg = GETDATE()
set @MovimientoBovedaIniId = 0

BEGIN
IF @flagAceptar = 0
	BEGIN
	--Inserta BovedaMov Inicio
	INSERT INTO CREDITO.BovedaMov (BovedaId, CodOperacion,Glosa,Importe,IndEntrada,Estado,UsuarioRegId,FechaReg)
				VALUES(@BovedaInicioId, 'TRS',@Glosa, @Monto,0,@Estado,@UsuarioRegId,@FechaReg)		
	
	SELECT @MovimientoBovedaIniId = @@identity
	
	--Actualiza  Boveda Inicio
	EXEC CREDITO.usp_ActualizarSaldosBoveda @BovedaInicioId
	
	--Inserta BOVEDAMOVTEMP
	INSERT INTO CREDITO.BovedaMovTemp (BovedaInicioId,BovedaDestinoId,CodOperacion,Glosa,Importe,UsuarioRegId,MovimientoBovedaIniId,
										FechaReg,IndEntrada,Estado) VALUES (@BovedaInicioId,@BovedaDestinoId,@CodOperacion,
										@Glosa,@Monto,@UsuarioRegId,@MovimientoBovedaIniId,@FechaReg,@IndEntrada,@Estado)
	END
	 
IF @flagAceptar = 1
	BEGIN
	--Inserta BOVEDAMOV Destino
	INSERT INTO CREDITO.BovedaMov(BovedaId,CodOperacion, Glosa,Importe,IndEntrada,
								  UsuarioRegId, FechaReg,Estado) SELECT BovedaDestinoId,CodOperacion, Glosa,Importe,IndEntrada,
								  UsuarioRegId, FechaReg,Estado FROM CREDITO.BovedaMovTemp 
								  WHERE BovedaMovTempId =@BovedaMovTempId
	
	--Actualiza  Boveda Destino
	SET @BovedaDestinoId = (SELECT BovedaDestinoId FROM CREDITO.BovedaMovTemp WHERE BovedaMovTempId =@BovedaMovTempId )
	
	EXEC CREDITO.usp_ActualizarSaldosBoveda @BovedaDestinoId
	
	--Elimina BovedaMovTemp
	DELETE CREDITO.BovedaMovTemp where BovedaMovTempId = @BovedaMovTempId
	END
	
IF @flagAceptar = 2
	BEGIN
	--Elimino BovedaMov Inicio
	DELETE CREDITO.BovedaMov WHERE MovimientoBovedaId = (SELECT MovimientoBovedaIniId FROM CREDITO.BovedaMovTemp
														 WHERE BovedaMovTempId = @BovedaMovTempId )
	--Actualiza  Boveda Inicio
	SET @BovedaInicioId = (SELECT BovedaInicioId  FROM CREDITO.BovedaMovTemp WHERE BovedaMovTempId = @BovedaMovTempId)
	
	EXEC CREDITO.usp_ActualizarSaldosBoveda @BovedaInicioId

	--Elimina BovedaMovTemp
	DELETE CREDITO.BovedaMovTemp where BovedaMovTempId = @BovedaMovTempId
	END
END

