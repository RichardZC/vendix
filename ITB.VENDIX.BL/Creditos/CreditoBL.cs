using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Transactions;
using ITB.VENDIX.BE;

namespace ITB.VENDIX.BL
{
    public class CreditoBL : Repositorio<Credito>
    {
        public static bool CrearSolicitudCredito(int pPersonaId)
        {
            var oCredito = new Credito
            {
                OficinaId = VendixGlobal.GetOficinaId(),
                PersonaId = pPersonaId,
                TipoCuota = "V",
                Descripcion = "",
                MontoProducto = 0,
                MontoInicial = 0,
                MontoCredito = 0,
                ProductoId = 1,
                MontoGastosAdm = 0,
                TipoGastoAdm = "CAP",
                Estado = "CRE",
                FormaPago = "M",
                NumeroCuotas = 12,
                Interes = 19,
                FechaPrimerPago = DateTime.Now,
                FechaVencimiento = DateTime.Now,
                FechaReg = DateTime.Now,
                UsuarioRegId = VendixGlobal.GetUsuarioId()
            };
            CreditoBL.Crear(oCredito);
            return true;
        }

        public static DatoCredito ObtenerDatoCredito(int pCreditoId)
        {
            
            using (var db = new VENDIXEntities())
            {
                var qry = from c in db.Credito
                          where c.CreditoId == pCreditoId
                          select new DatoCredito()
                          {
                              CreditoId = c.CreditoId,
                              Descripcion = c.Descripcion,
                              MontoProducto = c.MontoProducto,
                              MontoInicial = c.MontoInicial,
                              MontoCredito = c.MontoCredito,
                              MontoGastosAdm = c.MontoGastosAdm,
                              MontoDesembolso = c.MontoDesembolso,
                              TipoGastoAdm = c.TipoGastoAdm,
                              FormaPago = c.FormaPago,
                              NumeroCuotas = c.NumeroCuotas,
                              Interes = c.Interes,
                              Estado = c.Estado,
                              FechaDesembolso = c.FechaDesembolso,
                              FechaAprobacion = c.FechaAprobacion,
                              FechaVencimiento = c.FechaVencimiento,
                              Analista = c.Usuario.Persona.NombreCompleto,
                              ProductoCre = c.Producto.Denominacion
                          };
                var data = qry.First();
                data.Desembolso = data.FechaDesembolso.HasValue ? data.FechaDesembolso.Value.ToShortDateString() : string.Empty;
                data.Aprobacion = data.FechaAprobacion.HasValue ? data.FechaAprobacion.Value.ToShortDateString() : string.Empty;
                data.Vencimiento = data.FechaVencimiento.ToShortDateString();
                if (data.Estado == "DES")
                    data.SaldoCancelacion = ObtenerSaldoCancelacion(pCreditoId);
                return data;
            }
        }

        public static List<usp_SimuladorCredito_Result> SimuladorCredito
            (int pProductoId, string pTipo, decimal pMonto, string pFormaPago, int pNumerocuotas, decimal pInteres, DateTime pFechaPrimerPago,
             Decimal? pGastosAdm)
        {

            using (var db = new VENDIXEntities())
            {
                return db.usp_SimuladorCredito(pTipo, pFormaPago, pMonto, pNumerocuotas, pInteres,
                        pFechaPrimerPago, pGastosAdm).ToList();
            }

        }

        public static List<RptPlanPago> ReportePlanPago(int pCreditoId)
        {
            using (var db = new VENDIXEntities())
            {
                return db.PlanPago.Where(x => x.CreditoId == pCreditoId)
                .Select(x => new RptPlanPago
                {
                    Numero = x.Numero,
                    Capital = x.Capital,
                    FechaPago = x.FechaVencimiento,
                    Amortizacion = x.Amortizacion,
                    Interes = x.Interes,
                    GastosAdm = x.GastosAdm,
                    Cuota = x.Cuota
                }).ToList();
            }
        }

        public static string CrearCredito(int pSolicitudCreditoId, int pProductoId, string pTipoCuota,
                                          decimal pMontoInicial, decimal pMontoGastosAdm, string pIndGastosAdm, decimal pMontoCredito,
                                          string pModalidad, int pNumerocuotas, decimal pInteresMensual, DateTime pFechaPrimerPago, string pObservacion)
        {

            string retorno;
            using (var scope = new TransactionScope())
            {
                try
                {
                    using (var db = new VENDIXEntities())
                    {
                        retorno =
                            db.usp_Credito_Ins(pSolicitudCreditoId, pProductoId, pTipoCuota, pMontoInicial, pMontoCredito,
                                               pMontoGastosAdm, pIndGastosAdm, pModalidad, pNumerocuotas, pInteresMensual,
                                               pFechaPrimerPago, pObservacion, VendixGlobal.GetUsuarioId()).ToList()[0];
                    }
                    scope.Complete();
                }
                catch (Exception ex)
                {
                    scope.Dispose();
                    retorno = ex.InnerException.Message;
                }
            }
            return retorno;
        }
        public static bool AprobarCredito(int pCreditoId, int pOpcion)
        {
            var usuario = VendixGlobal<int>.Obtener("UsuarioId");
            using (var scope = new TransactionScope())
            {
                try
                {
                    using (var db = new VENDIXEntities())
                    {
                        db.usp_Credito_Upd(pOpcion, pCreditoId, usuario);
                    }
                    scope.Complete();
                    return true;
                }
                catch (Exception)
                {
                    scope.Dispose();
                    throw;
                }
            }
        }
        public static bool RechazarCredito(int pCreditoId)
        {
            using (var scope = new TransactionScope())
            {
                try
                {
                    using (var db = new VENDIXEntities())
                    {
                        var firstOrDefault = db.Credito.Find(pCreditoId);
                        if (firstOrDefault != null)
                            db.usp_OrdenVenta_Del(firstOrDefault.OrdenVentaId, 0);
                    }
                    scope.Complete();
                    return true;
                }
                catch (Exception)
                {
                    scope.Dispose();
                    throw;
                }
            }
        }
        public static bool AnularCredito(int pCreditoId, string pObservacion)
        {
            using (var scope = new TransactionScope())
            {
                try
                {
                    using (var db = new VENDIXEntities())
                    {
                        db.usp_Credito_Del(pCreditoId, pObservacion, VendixGlobal.GetUsuarioId());
                    }
                    scope.Complete();
                    return true;
                }
                catch (Exception)
                {
                    scope.Dispose();
                    throw;
                }
            }
        }
        public static bool ReprogramarCredito(int pCreditoId)
        {
            using (var scope = new TransactionScope())
            {
                try
                {
                    using (var db = new VENDIXEntities())
                    {
                        db.usp_ReprogramarCredito(pCreditoId, VendixGlobal.GetUsuarioId());
                    }
                    scope.Complete();
                    return true;
                }
                catch (Exception)
                {
                    scope.Dispose();
                    throw;
                }
            }
        }
        public static List<Credito> ListarCreditosGrd(GridDataRequest request, ref int pTotalItems)
        {
            string filterExpression = string.Empty;

            if (request.DataFilters()["Buscar"] != string.Empty)
                filterExpression = "PersonaId=" + request.DataFilters()["Buscar"];

            if (request.DataFilters()["Estado"] == "DES")
                filterExpression += " && (Estado=\"PEN\" || Estado=\"APR\" || Estado=\"DES\")";
            else
                filterExpression += " && (Estado=\"ANU\" || Estado=\"PAG\" || Estado=\"REP\")";

            using (var db = new VENDIXEntities())
            {
                IQueryable<Credito> query = db.Credito;
                if (!String.IsNullOrEmpty(filterExpression))
                    query = query.Where(filterExpression);

                pTotalItems = query.Count();

                return query.OrderBy(request.sidx + " " + request.sord)
                    .Skip((request.page - 1) * request.rows).Take(request.rows).ToList();

            }
        }
        public static List<usp_EstadoPlanPago_Result> ListarEstadoPlanPago(int pCreditoId)
        {
            using (var db = new VENDIXEntities())
            {
                return db.usp_EstadoPlanPago(pCreditoId).ToList();
            }
        }
        public static List<usp_RptCreditoRentabilidad_Result> ReporteCreditoRentabilidad(int? pOficinaId, DateTime pFechaIni, DateTime pFechaFin)
        {
            using (var db = new VENDIXEntities())
            {
                return db.usp_RptCreditoRentabilidad(pOficinaId, pFechaIni, pFechaFin).ToList();
            }
        }
        public static List<usp_RptCreditoMorosidad_Result> ReporteCreditoMorosidad(int? pOficinaId, DateTime pFechaHasta, int pDiasAtrazoIni, int pDiasAtrazoFin)
        {
            using (var db = new VENDIXEntities())
            {
                return db.usp_RptCreditoMorosidad(pOficinaId, pFechaHasta, pDiasAtrazoIni, pDiasAtrazoFin).ToList();
            }
        }
        public static List<RptCreditoMov> ReporteCreditoMovimiento(int pCreditoId)
        {
            using (var db = new VENDIXEntities())
            {
                var qry = from mc in db.MovimientoCaja
                          where mc.CreditoId == pCreditoId && mc.Estado
                          orderby mc.FechaReg
                          select new RptCreditoMov
                          {
                              MovimientoCajaId = mc.MovimientoCajaId,
                              Operacion = mc.Operacion,
                              Fecha = mc.FechaReg,
                              Glosa = mc.Descripcion,
                              ImportePago = mc.ImportePago
                          };
                return qry.ToList();
            }
        }
        public static decimal ObtenerSaldoCancelacion(int pCreditoId)
        {
            using (var db = new VENDIXEntities())
            {
                var cancel = db.usp_CuotasPendientes(pCreditoId, DateTime.Now, true).Sum(x => x.PagoCuota);
                return (decimal)cancel;
            }
        }
        public static decimal ObtenerTEM(decimal pTEA,string pFormaPago)
        {
            
            using (var db = new VENDIXEntities())
            {
                decimal tem = db.usp_CalcularTEM(pTEA, pFormaPago).First().Value;
                return tem;
            }
        }


    }

    public class DatoCredito : Credito
    {
        public string ProductoCre { get; set; }
        public string Aprobacion { get; set; }
        public string Desembolso { get; set; }
        public string Vencimiento { get; set; }
        public string Analista { get; set; }
        public decimal SaldoCancelacion { get; set; }
    }


    public class RptPlanPago
    {
        public int Numero { get; set; }
        public decimal Capital { get; set; }
        public DateTime FechaPago { get; set; }
        public decimal Amortizacion { get; set; }
        public decimal Interes { get; set; }
        public decimal GastosAdm { get; set; }
        public decimal Cuota { get; set; }
    }
    public class RptCreditoMov
    {
        public int MovimientoCajaId { get; set; }
        public DateTime Fecha { get; set; }
        public string Operacion { get; set; }
        public string Glosa { get; set; }
        public decimal ImportePago { get; set; }
    }
}
