CREATE TABLE [VENTAS].[OrdenVenta] (
    [OrdenVentaId]        INT             IDENTITY (1, 1) NOT NULL,
    [OficinaId]           INT             NOT NULL,
    [Subtotal]            DECIMAL (16, 2) CONSTRAINT [DF_OrdenVenta_Subtotal] DEFAULT ((0)) NOT NULL,
    [TotalImpuesto]       DECIMAL (16, 2) CONSTRAINT [DF_OrdenVenta_TotalImpuesto] DEFAULT ((0)) NOT NULL,
    [TotalNeto]           DECIMAL (16, 2) CONSTRAINT [DF_OrdenVenta_TotalNeto] DEFAULT ((0)) NOT NULL,
    [TotalDescuento]      DECIMAL (16, 2) CONSTRAINT [DF_OrdenVenta_TotalDescuento] DEFAULT ((0)) NOT NULL,
    [Estado]              CHAR (3)        NOT NULL,
    [UsuarioRegId]        INT             NOT NULL,
    [FechaReg]            DATETIME        NOT NULL,
    [UsuarioModId]        INT             NULL,
    [FechaMod]            DATETIME        NULL,
    [PersonaId]           INT             NOT NULL,
    [MovimientoAlmacenId] INT             NULL,
    [TipoVenta]           CHAR (3)        CONSTRAINT [DF__OrdenVent__TipoV__404644CC] DEFAULT ('CON') NOT NULL,
    CONSTRAINT [PK__OrdenVen__16E7FA0661BC4730] PRIMARY KEY CLUSTERED ([OrdenVentaId] ASC),
    CONSTRAINT [FK_ORDENVENTA_OficinaId] FOREIGN KEY ([OficinaId]) REFERENCES [MAESTRO].[Oficina] ([OficinaId]),
    CONSTRAINT [FK_OrdenVenta_Persona] FOREIGN KEY ([PersonaId]) REFERENCES [MAESTRO].[Persona] ([PersonaId]),
    CONSTRAINT [FK_OrdenVenta_Usuario] FOREIGN KEY ([UsuarioRegId]) REFERENCES [MAESTRO].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_OrdenVenta_Usuario1] FOREIGN KEY ([UsuarioModId]) REFERENCES [MAESTRO].[Usuario] ([UsuarioId])
);

