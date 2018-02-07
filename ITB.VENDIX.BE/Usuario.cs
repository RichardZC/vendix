
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
    
public partial class Usuario
{

    public Usuario()
    {

        this.Aprobacion = new HashSet<Aprobacion>();

        this.Caja = new HashSet<Caja>();

        this.Caja1 = new HashSet<Caja>();

        this.CajaDiario = new HashSet<CajaDiario>();

        this.Cargo = new HashSet<Cargo>();

        this.Credito = new HashSet<Credito>();

        this.Credito1 = new HashSet<Credito>();

        this.MovimientoCaja = new HashSet<MovimientoCaja>();

        this.PlanPago = new HashSet<PlanPago>();

        this.Oficina = new HashSet<Oficina>();

        this.UsuarioOficina = new HashSet<UsuarioOficina>();

        this.UsuarioRol = new HashSet<UsuarioRol>();

        this.OrdenVenta = new HashSet<OrdenVenta>();

        this.OrdenVenta1 = new HashSet<OrdenVenta>();

        this.Transferencia = new HashSet<Transferencia>();

    }


    public int UsuarioId { get; set; }

    public int PersonaId { get; set; }

    public string NombreUsuario { get; set; }

    public string ClaveUsuario { get; set; }

    public bool Estado { get; set; }



    public virtual ICollection<Aprobacion> Aprobacion { get; set; }

    public virtual ICollection<Caja> Caja { get; set; }

    public virtual ICollection<Caja> Caja1 { get; set; }

    public virtual ICollection<CajaDiario> CajaDiario { get; set; }

    public virtual ICollection<Cargo> Cargo { get; set; }

    public virtual ICollection<Credito> Credito { get; set; }

    public virtual ICollection<Credito> Credito1 { get; set; }

    public virtual ICollection<MovimientoCaja> MovimientoCaja { get; set; }

    public virtual ICollection<PlanPago> PlanPago { get; set; }

    public virtual ICollection<Oficina> Oficina { get; set; }

    public virtual Persona Persona { get; set; }

    public virtual ICollection<UsuarioOficina> UsuarioOficina { get; set; }

    public virtual ICollection<UsuarioRol> UsuarioRol { get; set; }

    public virtual ICollection<OrdenVenta> OrdenVenta { get; set; }

    public virtual ICollection<OrdenVenta> OrdenVenta1 { get; set; }

    public virtual ICollection<Transferencia> Transferencia { get; set; }

}

}
