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
    
    public partial class MovimientoCajaAnu
    {
        public int MovimientoCajaAnuId { get; set; }
        public Nullable<int> MovimientoCajaId { get; set; }
        public string Observacion { get; set; }
        public Nullable<int> UsuarioRegId { get; set; }
        public Nullable<System.DateTime> FechaReg { get; set; }
    
        public virtual MovimientoCaja MovimientoCaja { get; set; }
    }
}
