CREATE TABLE [MAESTRO].[Provincia] (
    [idProv]    INT          DEFAULT ('0') NOT NULL,
    [provincia] VARCHAR (50) DEFAULT (NULL) NULL,
    [idDepa]    INT          DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([idProv] ASC),
    FOREIGN KEY ([idDepa]) REFERENCES [MAESTRO].[Departamento] ([idDepa])
);

