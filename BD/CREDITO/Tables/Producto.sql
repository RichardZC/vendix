CREATE TABLE [CREDITO].[Producto] (
    [ProductoId]       INT             IDENTITY (1, 1) NOT NULL,
    [Denominacion]     VARCHAR (255)   NOT NULL,
    [InteresMinima]    DECIMAL (16, 2) NOT NULL,
    [InteresMaxima]    DECIMAL (16, 2) NOT NULL,
    [DiasGracia]       INT             NOT NULL,
    [ImporteMoratorio] DECIMAL (8, 3)  NOT NULL,
    [Estado]           BIT             NOT NULL,
    CONSTRAINT [PK__Producto__A430AEA325924E90] PRIMARY KEY CLUSTERED ([ProductoId] ASC)
);

