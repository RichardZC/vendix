
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
    
public partial class Modelo
{

    public Modelo()
    {

        this.Articulo = new HashSet<Articulo>();

    }


    public int ModeloId { get; set; }

    public string Denominacion { get; set; }

    public Nullable<int> MarcaId { get; set; }

    public bool Estado { get; set; }



    public virtual ICollection<Articulo> Articulo { get; set; }

    public virtual Marca Marca { get; set; }

}

}
