INSERT INTO MAESTRO.ValorTabla ( TablaId ,ItemId ,Denominacion , DesCorta , Valor)
VALUES  ( 3 , 0 , '--SIMULADOR CREDITO--' , '' , ''  )
INSERT INTO MAESTRO.ValorTabla ( TablaId ,ItemId ,Denominacion , DesCorta , Valor)
VALUES  ( 3 , 1 , '--SIMULADOR CREDITO--' , 'V' , '5'  )
INSERT INTO MAESTRO.ValorTabla ( TablaId ,ItemId ,Denominacion , DesCorta , Valor)
VALUES  ( 3 , 2 , '--SIMULADOR CREDITO--' , 'F' , '1.09'  )

INSERT INTO MAESTRO.Menu
        ( Denominacion ,Modulo ,Url ,Icono ,IndPadre ,Orden ,Referencia)
VALUES  ( 'PARAMETROS SIMULADOR' , 'CREDITO' , 'Credito/ParametrosSimulador' , 'icon-list' , 0 , 60.4 , 60.0 )
INSERT INTO MAESTRO.Menu
        ( Denominacion ,Modulo ,Url ,Icono ,IndPadre ,Orden ,Referencia)
VALUES  ( 'CAJA' , 'MANTENIMIENTO' , 'Caja' , 'icon-list' , 0 , 40.5 , 40.0 )


UPDATE CREDITO.Producto SET Denominacion='CREDI FAMILIARE', InteresMinima=19.10, InteresMaxima=19.80 WHERE ProductoId=1
UPDATE CREDITO.Producto SET Denominacion='IMPRENDITORE', InteresMinima=24.50, InteresMaxima=24.80 WHERE ProductoId=2
UPDATE CREDITO.Producto SET Denominacion='CUBIERTO', InteresMinima=11.80, InteresMaxima=15.50 WHERE ProductoId=3
UPDATE CREDITO.Producto SET Denominacion='CREDI NONNO', InteresMinima=14.10, InteresMaxima=14.50 WHERE ProductoId=4
UPDATE CREDITO.Producto SET Denominacion='CREDI SALUTE', InteresMinima=18.20, InteresMaxima=18.20 WHERE ProductoId=5

INSERT INTO CREDITO.Producto ( Denominacion ,InteresMinima ,InteresMaxima ,DiasGracia ,ImporteMoratorio ,Estado)
VALUES  ( 'CREDI CAMPAGNA' , 15.80, 16.20,3 , 0.020,1        )
