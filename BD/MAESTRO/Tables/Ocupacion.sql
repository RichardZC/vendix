CREATE TABLE [MAESTRO].[Ocupacion] (
    [OcupacionId]  INT           IDENTITY (1, 1) NOT NULL,
    [Denominacion] VARCHAR (200) NULL,
    [Estado]       BIT           NULL,
    CONSTRAINT [PK__Ocupacio__77075F7735FDC083] PRIMARY KEY CLUSTERED ([OcupacionId] ASC)
);

