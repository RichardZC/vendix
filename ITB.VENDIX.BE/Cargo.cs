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
    
    public partial class Cargo
    {
        public int CargoId { get; set; }
        public int CreditoId { get; set; }
        public int NumCuota { get; set; }
        public int TipoCargoT2 { get; set; }
        public decimal Importe { get; set; }
        public string Descripcion { get; set; }
        public string Estado { get; set; }
        public int UsuarioId { get; set; }
        public System.DateTime Fecha { get; set; }
    
        public virtual Credito Credito { get; set; }
        public virtual Usuario Usuario { get; set; }
    }
}