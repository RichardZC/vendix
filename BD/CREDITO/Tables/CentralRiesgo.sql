CREATE TABLE [CREDITO].[CentralRiesgo] (
    [Anio]         INT             NOT NULL,
    [Mes]          INT             NOT NULL,
    [CreditoId]    INT             NOT NULL,
    [DiasAtrazo]   INT             CONSTRAINT [DF_CentralRiesgo_DiasAtrazo] DEFAULT ((0)) NOT NULL,
    [CuotasAtrazo] INT             CONSTRAINT [DF_CentralRiesgo_CuotasAtrazo] DEFAULT ((0)) NOT NULL,
    [DeudaAtrazo]  DECIMAL (15, 2) CONSTRAINT [DF_CentralRiesgo_DeudaAtrazo] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__CentralR__C59D72C748BC35D3] PRIMARY KEY CLUSTERED ([Anio] ASC, [Mes] ASC, [CreditoId] ASC),
    CONSTRAINT [FK__CentralRi__Credi__6E0D0F7C] FOREIGN KEY ([CreditoId]) REFERENCES [CREDITO].[Credito] ([CreditoId])
);

