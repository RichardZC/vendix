
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
    
public partial class Credito
{

    public Credito()
    {

        this.Cargo = new HashSet<Cargo>();

        this.CuentaxCobrar = new HashSet<CuentaxCobrar>();

        this.PlanPago = new HashSet<PlanPago>();

        this.MovimientoCaja = new HashSet<MovimientoCaja>();

    }


    public int CreditoId { get; set; }

    public int PersonaId { get; set; }

    public int ProductoId { get; set; }

    public string Descripcion { get; set; }

    public decimal MontoProducto { get; set; }

    public decimal MontoInicial { get; set; }

    public decimal MontoGastosAdm { get; set; }

    public decimal MontoCredito { get; set; }

    public string FormaPago { get; set; }

    public int NumeroCuotas { get; set; }

    public decimal InteresMensual { get; set; }

    public System.DateTime FechaPrimerPago { get; set; }

    public Nullable<System.DateTime> FechaAprobacion { get; set; }

    public Nullable<System.DateTime> FechaDesembolso { get; set; }

    public string Observacion { get; set; }

    public string Estado { get; set; }

    public Nullable<int> AnalistaId { get; set; }

    public System.DateTime FechaReg { get; set; }

    public int UsuarioRegId { get; set; }

    public Nullable<System.DateTime> FechaMod { get; set; }

    public Nullable<int> UsuarioModId { get; set; }

    public int OficinaId { get; set; }

    public System.DateTime FechaVencimiento { get; set; }

    public Nullable<int> OrdenVentaId { get; set; }

    public string TipoCuota { get; set; }



    public virtual ICollection<Cargo> Cargo { get; set; }

    public virtual OrdenVenta OrdenVenta { get; set; }

    public virtual ICollection<CuentaxCobrar> CuentaxCobrar { get; set; }

    public virtual ICollection<PlanPago> PlanPago { get; set; }

    public virtual Oficina Oficina { get; set; }

    public virtual Persona Persona { get; set; }

    public virtual Persona Persona1 { get; set; }

    public virtual Producto Producto { get; set; }

    public virtual Usuario Usuario { get; set; }

    public virtual Usuario Usuario1 { get; set; }

    public virtual ICollection<MovimientoCaja> MovimientoCaja { get; set; }

}

}
