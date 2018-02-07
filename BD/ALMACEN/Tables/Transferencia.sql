CREATE TABLE [ALMACEN].[Transferencia] (
	[TransferenciaId]     INT IDENTITY (1, 1) NOT NULL,
	[AlmacenOrigenId]  INT NOT NULL references Almacen.Almacen(AlmacenId),
	AlmacenDestinoId   INT NOT NULL references Almacen.Almacen(AlmacenId),
	UsuarioId INT NOT NULL references Maestro.Usuario(UsuarioId),
	Fecha Datetime not null,
	[Estado]       CHAR(3) NOT NULL, 
	CONSTRAINT [PK_Transferencia] PRIMARY KEY ([TransferenciaId])
);

