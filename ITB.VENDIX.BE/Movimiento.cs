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
    
    public partial class Movimiento
    {
        public Movimiento()
        {
            this.MovimientoDet = new HashSet<MovimientoDet>();
            this.MovimientoDoc = new HashSet<MovimientoDoc>();
        }
    
        public int MovimientoId { get; set; }
        public int TipoMovimientoId { get; set; }
        public int AlmacenId { get; set; }
        public System.DateTime Fecha { get; set; }
        public decimal SubTotal { get; set; }
        public decimal IGV { get; set; }
        public decimal AjusteRedondeo { get; set; }
        public decimal TotalImporte { get; set; }
        public int EstadoId { get; set; }
        public string Observacion { get; set; }
        public string Documento { get; set; }
    
        public virtual Almacen Almacen { get; set; }
        public virtual ICollection<MovimientoDet> MovimientoDet { get; set; }
        public virtual ICollection<MovimientoDoc> MovimientoDoc { get; set; }
        public virtual TipoMovimiento TipoMovimiento { get; set; }
    }
}
