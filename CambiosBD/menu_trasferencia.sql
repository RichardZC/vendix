SELECT * FROM MAESTRO.Menu

INSERT MAESTRO.Menu
        ( Denominacion ,
          Modulo ,
          Url ,
          Icono ,
          IndPadre ,
          Orden ,
          Referencia
        )
VALUES  ( 'TRANSFERENCIA' , -- Denominacion - varchar(255)
          'ALMACEN' , -- Modulo - varchar(255)
          'Transferencia' , -- Url - varchar(255)
          'icon-list' , -- Icono - varchar(255)
          0 , -- IndPadre - bit
          10.4 , -- Orden - decimal
          10.0  -- Referencia - decimal
        )