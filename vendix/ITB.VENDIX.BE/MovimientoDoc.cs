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
    
    public partial class MovimientoDoc
    {
        public int MovimientoDocId { get; set; }
        public Nullable<int> MovimientoId { get; set; }
        public Nullable<int> TipoDocumentoId { get; set; }
        public string SerieDocumento { get; set; }
        public string NroDocumento { get; set; }
        public Nullable<int> RemitenteId { get; set; }
        public Nullable<int> DestinatarioId { get; set; }
        public string DestinoRef { get; set; }
    
        public virtual Movimiento Movimiento { get; set; }
        public virtual Persona Persona { get; set; }
        public virtual Persona Persona1 { get; set; }
        public virtual TipoDocumento TipoDocumento { get; set; }
    }
}