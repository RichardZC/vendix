CREATE TABLE [MAESTRO].[Menu] (
    [MenuId]       INT            IDENTITY (1, 1) NOT NULL,
    [Denominacion] VARCHAR (255)  NULL,
    [Modulo]       VARCHAR (255)  NULL,
    [Url]          VARCHAR (255)  NULL,
    [Icono]        VARCHAR (255)  NULL,
    [IndPadre]     BIT            NULL,
    [Orden]        DECIMAL (3, 1) NULL,
    [Referencia]   DECIMAL (3, 1) NULL,
    CONSTRAINT [PK__Menu__C99ED2306522C3C0] PRIMARY KEY CLUSTERED ([MenuId] ASC)
);

