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
    
    public partial class OrdenVentaDet
    {
        public OrdenVentaDet()
        {
            this.OrdenVentaDetSerie = new HashSet<OrdenVentaDetSerie>();
        }
    
        public int OrdenVentaDetId { get; set; }
        public int OrdenVentaId { get; set; }
        public int ArticuloId { get; set; }
        public int Cantidad { get; set; }
        public string Descripcion { get; set; }
        public decimal ValorVenta { get; set; }
        public decimal Descuento { get; set; }
        public decimal Subtotal { get; set; }
        public bool Estado { get; set; }
    
        public virtual Articulo Articulo { get; set; }
        public virtual OrdenVenta OrdenVenta { get; set; }
        public virtual ICollection<OrdenVentaDetSerie> OrdenVentaDetSerie { get; set; }
    }
}
