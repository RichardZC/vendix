
//------------------------------------------------------------------------------
// <auto-generated>
//    Este código se generó a partir de una plantilla.
//
//    Los cambios manuales en este archivo pueden causar un comportamiento inesperado de la aplicación.
//    Los cambios manuales en este archivo se sobrescribirán si se regenera el código.
// </auto-generated>
//------------------------------------------------------------------------------


namespace ITB.VENDIX.BE
{

using System;
    using System.Collections.Generic;
    
public partial class TipoDocumento
{

    public TipoDocumento()
    {

        this.MovimientoDoc = new HashSet<MovimientoDoc>();

    }


    public int TipoDocumentoId { get; set; }

    public string Denominacion { get; set; }

    public string Descripcion { get; set; }

    public bool IndVenta { get; set; }

    public bool IndAlmacen { get; set; }

    public bool IndAlmacenMov { get; set; }

    public bool Estado { get; set; }



    public virtual ICollection<MovimientoDoc> MovimientoDoc { get; set; }

}

}
