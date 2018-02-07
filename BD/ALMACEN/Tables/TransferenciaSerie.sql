CREATE TABLE [ALMACEN].[TransferenciaSerie] (
	TransferenciaSerieId     INT primary key IDENTITY (1, 1) NOT NULL,
	TransferenciaId  INT NOT NULL references Almacen.Transferencia(TransferenciaId),
	SerieArticuloId   INT NOT NULL references Almacen.SerieArticulo(SerieArticuloId)
);

