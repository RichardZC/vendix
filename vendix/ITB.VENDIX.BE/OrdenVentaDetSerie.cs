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
    
    public partial class OrdenVentaDetSerie
    {
        public int OrdenVentaDetSerieId { get; set; }
        public Nullable<int> OrdenVentaDetId { get; set; }
        public Nullable<int> SerieArticuloId { get; set; }
    
        public virtual SerieArticulo SerieArticulo { get; set; }
        public virtual OrdenVentaDet OrdenVentaDet { get; set; }
    }
}
