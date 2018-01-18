CREATE TABLE [MAESTRO].[ValorTabla] (
    [TablaId]      INT           NOT NULL,
    [ItemId]       INT           NOT NULL,
    [Denominacion] VARCHAR (70)  NULL,
    [DesCorta]     VARCHAR (30)  NULL,
    [Valor]        VARCHAR (100) NULL,
    CONSTRAINT [PK_VALORTABLA] PRIMARY KEY CLUSTERED ([TablaId] ASC, [ItemId] ASC)
);

