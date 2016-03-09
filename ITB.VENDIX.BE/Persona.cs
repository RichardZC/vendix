
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
    
public partial class Persona
{

    public Persona()
    {

        this.MovimientoDoc = new HashSet<MovimientoDoc>();

        this.MovimientoDoc1 = new HashSet<MovimientoDoc>();

        this.Credito = new HashSet<Credito>();

        this.Credito1 = new HashSet<Credito>();

        this.MovimientoCaja = new HashSet<MovimientoCaja>();

        this.Cliente = new HashSet<Cliente>();

        this.TarjetaPunto = new HashSet<TarjetaPunto>();

        this.Usuario = new HashSet<Usuario>();

        this.OrdenVenta = new HashSet<OrdenVenta>();

    }


    public int PersonaId { get; set; }

    public string Nombre { get; set; }

    public string ApePaterno { get; set; }

    public string ApeMaterno { get; set; }

    public string NombreCompleto { get; set; }

    public string TipoDocumento { get; set; }

    public string NumeroDocumento { get; set; }

    public string Sexo { get; set; }

    public string TipoPersona { get; set; }

    public string EmailPersonal { get; set; }

    public Nullable<System.DateTime> FechaNacimiento { get; set; }

    public string Direccion { get; set; }

    public bool Estado { get; set; }

    public string Celular1 { get; set; }

    public string Celular2 { get; set; }



    public virtual ICollection<MovimientoDoc> MovimientoDoc { get; set; }

    public virtual ICollection<MovimientoDoc> MovimientoDoc1 { get; set; }

    public virtual ICollection<Credito> Credito { get; set; }

    public virtual ICollection<Credito> Credito1 { get; set; }

    public virtual ICollection<MovimientoCaja> MovimientoCaja { get; set; }

    public virtual ICollection<Cliente> Cliente { get; set; }

    public virtual ICollection<TarjetaPunto> TarjetaPunto { get; set; }

    public virtual ICollection<Usuario> Usuario { get; set; }

    public virtual ICollection<OrdenVenta> OrdenVenta { get; set; }

}

}
