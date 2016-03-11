INSERT INTO MAESTRO.ValorTabla ( TablaId ,ItemId ,Denominacion , DesCorta , Valor)
VALUES  ( 3 , 0 , '--SIMULADOR CREDITO--' , '' , ''  )
INSERT INTO MAESTRO.ValorTabla ( TablaId ,ItemId ,Denominacion , DesCorta , Valor)
VALUES  ( 3 , 1 , '--SIMULADOR CREDITO--' , 'V' , '5'  )
INSERT INTO MAESTRO.ValorTabla ( TablaId ,ItemId ,Denominacion , DesCorta , Valor)
VALUES  ( 3 , 2 , '--SIMULADOR CREDITO--' , 'F' , '1.09'  )

/*menu*/
INSERT INTO MAESTRO.Menu
        ( Denominacion ,Modulo ,Url ,Icono ,IndPadre ,Orden ,Referencia)
VALUES  ( 'PARAMETROS SIMULADOR' , 'CREDITO' , 'Credito/ParametrosSimulador' , 'icon-list' , 0 , 60.4 , 60.0 )
INSERT INTO MAESTRO.Menu
        ( Denominacion ,Modulo ,Url ,Icono ,IndPadre ,Orden ,Referencia)
VALUES  ( 'CAJA' , 'MANTENIMIENTO' , 'Caja' , 'icon-list' , 0 , 40.5 , 40.0 )
