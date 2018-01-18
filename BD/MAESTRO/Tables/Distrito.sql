CREATE TABLE [MAESTRO].[Distrito] (
    [idDist]   INT          DEFAULT ('0') NOT NULL,
    [distrito] VARCHAR (50) DEFAULT (NULL) NULL,
    [idProv]   INT          DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([idDist] ASC),
    FOREIGN KEY ([idProv]) REFERENCES [MAESTRO].[Provincia] ([idProv])
);

