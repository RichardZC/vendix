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
    
    public partial class usp_RptCreditoMorosidad_Result
    {
        public int CreditoId { get; set; }
        public string Cliente { get; set; }
        public string Direccion { get; set; }
        public string Celular { get; set; }
        public Nullable<System.DateTime> FechaDesembolso { get; set; }
        public Nullable<System.DateTime> FechaVcto { get; set; }
        public string Articulo { get; set; }
        public decimal MontoCredito { get; set; }
        public Nullable<decimal> SaldoCredito { get; set; }
        public Nullable<System.DateTime> FechaUltPago { get; set; }
        public Nullable<decimal> CapitalAtrazo { get; set; }
        public Nullable<decimal> GA { get; set; }
        public Nullable<decimal> InteresAtrazo { get; set; }
        public Nullable<decimal> Mora { get; set; }
        public Nullable<decimal> ImporteLibre { get; set; }
        public Nullable<int> DiasAtrazo { get; set; }
        public Nullable<int> CuotasAtrazo { get; set; }
        public Nullable<decimal> DeudaAtrazo { get; set; }
    }
}