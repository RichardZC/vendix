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
    
    public partial class Provincia
    {
        public Provincia()
        {
            this.Distrito = new HashSet<Distrito>();
        }
    
        public int idProv { get; set; }
        public string provincia1 { get; set; }
        public Nullable<int> idDepa { get; set; }
    
        public virtual Departamento Departamento { get; set; }
        public virtual ICollection<Distrito> Distrito { get; set; }
    }
}