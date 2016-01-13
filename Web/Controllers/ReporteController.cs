﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ITB.VENDIX.BE;
using ITB.VENDIX.BL;
using VendixWeb.Models;
using Microsoft.Reporting.WebForms;


namespace VendixWeb.Controllers
{
    public class ReporteController : Controller
    {

        public ActionResult Almacen()
        {
            ViewBag.cboOficina = new SelectList(OficinaBL.Listar(x => x.Estado), "OficinaId", "Denominacion");

            return View(SerieArticuloBL.ObtenerIndicadoresAlmacen());
        }
        public ActionResult ConstanciaAlmacen(int pMovimientoId)
        {
            var mov = MovimientoBL.ObtenerEntradaSalida(pMovimientoId);
            var det = MovimientoDetBL.Listar(x => x.MovimientoId == pMovimientoId);

            return View(new ReporteConstanciaAlmacen { Cabecera = mov, Detalle = det });
        }
        public ActionResult Credito()
        {
            var lstoficina = new SelectList(OficinaBL.Listar(x => x.Estado), "OficinaId", "Denominacion");
            ViewBag.cboOficina = lstoficina;
            ViewBag.cboOficina1 = lstoficina;
            return View();
        }
        public ActionResult Venta()
        {
            ViewBag.cboMarca = new SelectList(MarcaBL.Listar(x => x.Estado, x => x.OrderBy(y => y.Denominacion)), "MarcaId", "Denominacion");
            ViewBag.cboOficina = new SelectList(OficinaBL.Listar(x => x.Estado), "OficinaId", "Denominacion");
            return View();
        }
        #region "ReportViewer"
        public ActionResult ReporteMovimientoCaja(int pMovimientoCajaId)
        {
            var operacion = MovimientoCajaBL.Obtener(pMovimientoCajaId).Operacion;
            if (operacion == "CUO")
            {
                if (PlanPagoBL.Contar(x => x.MovimientoCajaId == pMovimientoCajaId) > 0)
                {
                    var data = MovimientoCajaBL.RptMovCajaCredito(pMovimientoCajaId);
                    var parametros = new List<ReportParameter>
                                         {
                                             new ReportParameter("MovimientoCajaId", data.MovimientoCajaId.ToString()),
                                             new ReportParameter("PersonaId", data.PersonaId.ToString()),
                                             new ReportParameter("Cliente", data.Cliente),
                                             new ReportParameter("User", data.User),
                                             new ReportParameter("FechaReg", data.FechaReg.ToString()),
                                             new ReportParameter("Oficina", data.Oficina),
                                             new ReportParameter("Producto", data.Producto),
                                             new ReportParameter("SaldoAnterior", data.SaldoAnterior.ToString()),
                                             new ReportParameter("PagoDeuda", data.PagoDeuda.ToString()),
                                             new ReportParameter("Interes", data.Interes.ToString()),
                                             new ReportParameter("GastosAdm", data.GastosAdm.ToString()),
                                             new ReportParameter("MoraCargo", data.MoraCargo.ToString()),
                                             new ReportParameter("ImporteLibre", data.ImporteLibre.ToString()),
                                             new ReportParameter("ImportePagado", data.ImportePagado.ToString()),
                                             new ReportParameter("SaldoCapital", data.SaldoCapital.ToString()),
                                             new ReportParameter("ProximaCuota", data.ProximaCuota),
                                             new ReportParameter("CuotasAtrazadas", data.CuotasAtrazadas.ToString())
                                         };
                    return Reporte("PDF", "rptMovCajaCuota.rdlc", null, "TicketCaja", parametros);
                }
                else
                {
                    var data = MovimientoCajaBL.RptMovCajaLibre(pMovimientoCajaId);
                    var parametros = new List<ReportParameter>
                                         {
                                             new ReportParameter("MovimientoCajaId", data.MovimientoCajaId.ToString()),
                                             new ReportParameter("PersonaId", data.PersonaId.ToString()),
                                             new ReportParameter("Cliente", data.Cliente),
                                             new ReportParameter("User", data.User),
                                             new ReportParameter("FechaReg", data.FechaReg.ToString()),
                                             new ReportParameter("Oficina", data.Oficina),
                                             new ReportParameter("Producto", data.Producto),
                                             new ReportParameter("ImportePago", data.ImportePago.ToString()),
                                             new ReportParameter("Articulo", data.Articulo),
                                             new ReportParameter("Concepto", "PAGO LIBRE")
                                         };
                    return Reporte("PDF", "rptMovCaja.rdlc", null, "TicketCaja", parametros);
                }
            }
            if (operacion == "INI" || operacion == "GAD")
            {
                var data = MovimientoCajaBL.RptMovCajaInicial(pMovimientoCajaId);
                var concepto = string.Empty;
                switch (operacion)
                {
                    case "INI": concepto = "PAGO INICIAL"; break;
                    case "GAD": concepto = "GASTO ADM ADELANTADO"; break;
                }

                var parametros = new List<ReportParameter>
                                     {
                                         new ReportParameter("MovimientoCajaId", data.MovimientoCajaId.ToString()),
                                         new ReportParameter("PersonaId", data.PersonaId.ToString()),
                                         new ReportParameter("Cliente", data.Cliente),
                                         new ReportParameter("User", data.User),
                                         new ReportParameter("FechaReg", data.FechaReg.ToString()),
                                         new ReportParameter("Oficina", data.Oficina),
                                         new ReportParameter("Producto", data.Producto),
                                         new ReportParameter("ImportePago", data.ImportePago.ToString()),
                                         new ReportParameter("Articulo", data.Articulo),
                                         new ReportParameter("Concepto", concepto)
                                     };
                return Reporte("PDF", "rptMovCaja.rdlc", null, "TicketCaja", parametros);
            }
            if (operacion == "CON")
            {
                var data = MovimientoCajaBL.RptMovCajaContado(pMovimientoCajaId);
                var parametros = new List<ReportParameter>
                                     {
                                         new ReportParameter("MovimientoCajaId", data.MovimientoCajaId.ToString()),
                                         new ReportParameter("PersonaId", data.PersonaId.ToString()),
                                         new ReportParameter("Cliente", data.Cliente),
                                         new ReportParameter("User", data.User),
                                         new ReportParameter("FechaReg", data.FechaReg.ToString()),
                                         new ReportParameter("Oficina", data.Oficina),
                                         new ReportParameter("Producto", data.Producto),
                                         new ReportParameter("ImportePago", data.ImportePago.ToString()),
                                         new ReportParameter("Articulo", data.Articulo),
                                         new ReportParameter("Concepto", "PAGO CONTADO")
                                     };
                return Reporte("PDF", "rptMovCaja.rdlc", null, "TicketCaja", parametros);
            }

            var dato = MovimientoCajaBL.RptMovCajaOtros(pMovimientoCajaId);
            var param = new List<ReportParameter>
                                     {
                                         new ReportParameter("MovimientoCajaId", dato.MovimientoCajaId.ToString()),
                                         new ReportParameter("PersonaId", "0"),
                                         new ReportParameter("Cliente", dato.Cliente),
                                         new ReportParameter("User", dato.User),
                                         new ReportParameter("FechaReg", dato.FechaReg.ToString()),
                                         new ReportParameter("Oficina", dato.Oficina),
                                         new ReportParameter("Producto", dato.Producto),
                                         new ReportParameter("ImportePago", dato.ImportePago.ToString()),
                                         new ReportParameter("Articulo", dato.Articulo),
                                         new ReportParameter("Concepto", dato.IndEntrada?"ENTRADA":"SALIDA")
                                     };
            return Reporte("PDF", "rptMovCaja.rdlc", null, "TicketCaja", param);

        }
        public ActionResult ReporteCodBarras(int pMovimientoId)
        {
            var data = SerieArticuloBL.ListarArticuloCodigoBarras(pMovimientoId);
            var rd = new ReportDataSource("dsCodigo", data);
            return Reporte("PDF", "rptCodigo.rdlc", rd, "CodigoBarras");
        }
        public ActionResult ReporteKardex(int pArticuloId, int pAlmacenId)
        {
            var kardexData = AlmacenBL.GenerarKardex(pArticuloId, pAlmacenId);
            var rd = new ReportDataSource("dsKardex", kardexData);
            return Reporte("PDF", "rptKardex.rdlc", rd, "A4Horizontal0.25");
        }
        public ActionResult ReporteSimuladorPlanPagos(int pProductoId,string pTipo, decimal pMonto, int pCuotas, decimal pInteres, string pFecha, string pModalidad, decimal? pGastosAdm = null)
        {
            var oPlanPago = CreditoBL.SimuladorCredito(pProductoId, pTipo,pMonto, pModalidad,  pCuotas, pInteres, DateTime.Parse(pFecha), pGastosAdm);
            var rd = new ReportDataSource("dsSimuladorPlanPago", oPlanPago);

            switch (pModalidad)
            {
                case "D": pModalidad = "DIARIO"; break;
                case "S": pModalidad = "SEMANAL"; break;
                case "Q": pModalidad = "QUINCENAL"; break;
                case "M": pModalidad = "MENSUAL"; break;
            }
            var parametros = new List<ReportParameter>
                                 {
                                     new ReportParameter("Monto", pMonto.ToString()),
                                     new ReportParameter("Cuotas", pCuotas.ToString()),
                                     new ReportParameter("Producto", ProductoBL.Obtener(pProductoId).Denominacion),
                                     new ReportParameter("Fecha", pFecha),
                                     new ReportParameter("Modalidad", pModalidad),
                                     new ReportParameter("Cliente", string.Empty)
                                 };

            return Reporte("PDF", "rptSimuladorPlanPago.rdlc", rd, "A4Vertical0.25", parametros);
        }
        public ActionResult ReportePlanPagos(int pCreditoId)
        {
            var credito = CreditoBL.Obtener(x => x.CreditoId == pCreditoId, "Persona");
            var oPlanPago = CreditoBL.ReportePlanPago(pCreditoId);
            var rd = new ReportDataSource("dsSimuladorPlanPago", oPlanPago);

            string pModalidad = string.Empty;
            switch (credito.FormaPago)
            {
                case "D": pModalidad = "DIARIO"; break;
                case "S": pModalidad = "SEMANAL"; break;
                case "Q": pModalidad = "QUINCENAL"; break;
                case "M": pModalidad = "MENSUAL"; break;
            }
            var parametros = new List<ReportParameter>
                                 {
                                     new ReportParameter("Monto", credito.MontoCredito.ToString()),
                                     new ReportParameter("Cuotas", credito.NumeroCuotas.ToString()),
                                     new ReportParameter("Producto", ProductoBL.Obtener(credito.ProductoId).Denominacion),
                                     new ReportParameter("Fecha", credito.FechaPrimerPago.ToShortDateString()),
                                     new ReportParameter("Modalidad", pModalidad),
                                     new ReportParameter("Cliente", credito.Persona.NombreCompleto)
                                 };

            return Reporte("PDF", "rptSimuladorPlanPago.rdlc", rd, "A4Vertical0.25", parametros);
        }
        public ActionResult ReporteEstadoCredito(int pCreditoId)
        {
            string pModalidad = string.Empty;
            var credito = CreditoBL.Obtener(x => x.CreditoId == pCreditoId, includeProperties: "Persona,Persona1");
            var data = CreditoBL.ListarEstadoPlanPago(pCreditoId);
            var rd = new ReportDataSource("dsEstadoCredito", data);

            switch (credito.FormaPago)
            {
                case "D": pModalidad = "DIARIO"; break;
                case "S": pModalidad = "SEMANAL"; break;
                case "Q": pModalidad = "QUINCENAL"; break;
                case "M": pModalidad = "MENSUAL"; break;
            }
            var parametros = new List<ReportParameter>
                                 {
                                     new ReportParameter("Cliente", credito.Persona.NumeroDocumento + " " + credito.Persona.NombreCompleto),
                                     new ReportParameter("Producto", credito.Descripcion),
                                     new ReportParameter("MontoProducto", credito.MontoProducto.ToString()),
                                     new ReportParameter("MontoInicial", credito.MontoInicial.ToString()),
                                     new ReportParameter("MontoCredito", credito.MontoCredito.ToString()),
                                     new ReportParameter("Modalidad", pModalidad),
                                     new ReportParameter("Cuotas", credito.NumeroCuotas.ToString()),
                                     new ReportParameter("Interes", credito.InteresMensual.ToString()),
                                     new ReportParameter("Estado", credito.Estado),
                                     new ReportParameter("Analista", credito.Persona1.NombreCompleto)
                                 };
            return Reporte("PDF", "rptEstadoCredito.rdlc", rd, "A4Vertical0.25", parametros);
        }
        public ActionResult ReporteCredito(int? pOficinaId, string pFechaIni, string pFechaFin)
        {
            var data = ReporteBL.ListarReporteCredito(pOficinaId, DateTime.Parse(pFechaIni), DateTime.Parse(pFechaFin));
            var rd = new ReportDataSource("dsCredito", data);

            var oficina = "TODOS";
            if (pOficinaId != null)
                oficina = OficinaBL.Obtener(pOficinaId.Value).Denominacion;

            var parametros = new List<ReportParameter>
                                 {
                                     new ReportParameter("Oficina", oficina),
                                     new ReportParameter("FechaIni", DateTime.Parse(pFechaIni).ToShortDateString()),
                                     new ReportParameter("FechaFin", DateTime.Parse(pFechaFin).ToShortDateString())
                                 };
            return Reporte("PDF", "rptCredito.rdlc", rd, "A4Horizontal0.25", parametros);
        }
        public ActionResult ReporteCreditoRentabilidad(string pFechaIni, string pFechaFin, bool indTodos, int? pOficinaId)
        {
            if (indTodos)
            {
                pFechaIni = "01/10/2013";
                pFechaFin = DateTime.Now.ToShortDateString();
            }
            var data = CreditoBL.ReporteCreditoRentabilidad(pOficinaId, DateTime.Parse(pFechaIni), DateTime.Parse(pFechaFin));
            var rd = new ReportDataSource("dsCreditoRentabilidad", data);

            var oficina = "TODOS";
            if (pOficinaId != null)
                oficina = OficinaBL.Obtener(pOficinaId.Value).Denominacion;

            var parametros = new List<ReportParameter>
                                 {
                                     new ReportParameter("Oficina", oficina),
                                     new ReportParameter("FechaIni", indTodos?"----": DateTime.Parse(pFechaIni).ToShortDateString()),
                                     new ReportParameter("FechaFin", DateTime.Parse(pFechaFin).ToShortDateString())
                                 };
            return Reporte("PDF", "rptCreditoRentabilidad.rdlc", rd, "A4Horizontal0.25", parametros);
        }
        public ActionResult ReporteCreditoMorosidad(int? pOficinaId, string pFechaHasta, int pDiasAtrazoIni, int pDiasAtrazoFin)
        {
            var data = CreditoBL.ReporteCreditoMorosidad(pOficinaId, DateTime.Parse(pFechaHasta), pDiasAtrazoIni, pDiasAtrazoFin);
            var rd = new ReportDataSource("dsCreditoMorosidad", data);

            var oficina = "TODOS";
            if (pOficinaId != null)
                oficina = OficinaBL.Obtener(pOficinaId.Value).Denominacion;

            var parametros = new List<ReportParameter>
                                 {
                                     new ReportParameter("Oficina", oficina),
                                     new ReportParameter("HastaFecha",DateTime.Parse(pFechaHasta).ToShortDateString()),
                                     new ReportParameter("DiasAtrazoIni", pDiasAtrazoIni.ToString()),
                                     new ReportParameter("DiasAtrazoFin", pDiasAtrazoFin.ToString())
                                 };
            return Reporte("PDF", "rptCreditoMorosidad.rdlc", rd, "A4Horizontal0.25", parametros);
        }
        public ActionResult ReporteAvanceVenta(string pFechaIni, string pFechaFin, bool indContado, bool indCredito, int? pOficinaId)
        {
            var data = ReporteBL.ListarReporteRentabilidadVenta(DateTime.Parse(pFechaIni), DateTime.Parse(pFechaFin), indContado, indCredito, pOficinaId);
            var rd = new ReportDataSource("dsRentabilidad", data);

            var oficina = "TODOS";
            if (pOficinaId != null)
                oficina = OficinaBL.Obtener(pOficinaId.Value).Denominacion;

            var parametros = new List<ReportParameter>
                                 {
                                     new ReportParameter("Oficina", oficina),
                                     new ReportParameter("FechaIni", DateTime.Parse(pFechaIni).ToShortDateString()),
                                     new ReportParameter("FechaFin", DateTime.Parse(pFechaFin).ToShortDateString())
                                 };
            return Reporte("PDF", "rptRentabilidad.rdlc", rd, "A4Horizontal0.25", parametros);
        }
        public ActionResult ReporteListaPrecio(int? pMarcaId, bool pIndDescuento, bool pIndPuntos, string pTipo = "PDF")
        {
            var data = ReporteBL.ListarReporteListaPrecio(pMarcaId, pIndDescuento, pIndPuntos);
            var rd = new ReportDataSource("dsListaPrecio", data);
            var marca = "TODOS";
            if (pMarcaId != null)
                marca = MarcaBL.Obtener(pMarcaId.Value).Denominacion;

            var parametros = new List<ReportParameter>
                                 {
                                     new ReportParameter("Marca", marca),
                                     new ReportParameter("EsDescuento", pIndDescuento?"SI":"NO"),
                                     new ReportParameter("EsPunto", pIndPuntos?"SI":"NO")
                                 };
            return Reporte(pTipo, "rptListaPrecio.rdlc", rd, "A4Vertical0.25", parametros);
        }
        public ActionResult ReporteStock(int? pOficinaId, string pTipoReporte = "PDF")
        {
            var data = ReporteBL.ListarReporteStockGeneral(pOficinaId);
            var rd = new ReportDataSource("dsStock", data);

            var oficina = "TODOS";
            if (pOficinaId != null)
                oficina = OficinaBL.Obtener(pOficinaId.Value).Denominacion;

            var parametros = new List<ReportParameter>
                                 {
                                     new ReportParameter("Oficina", oficina)
                                 };
            //return Reporte("Excel", "rptStock.rdlc", rd, "A4Vertical0.25", parametros);
            return Reporte(pTipoReporte, "rptStock.rdlc", rd, "A4Horizontal0.25", parametros);
        }
        public ActionResult ReporteSaldoCajaActual()
        {
            return ReporteSaldoCaja(VendixGlobal.GetCajaDiarioId());
        }
        public ActionResult ReporteSaldoCaja(int pCajaDiarioId)
        {
            var data = CajaDiarioBL.ReporteSaldoCajaDiario(pCajaDiarioId);
            var rd = new ReportDataSource("dsSaldoCaja", data);
            var cab = CajaDiarioBL.ObtenerRptSaldoCajaCab(pCajaDiarioId);

            var parametros = new List<ReportParameter>
                                 {
                                     new ReportParameter("Oficina",cab.Oficina ),
                                     new ReportParameter("Cajero",cab.Cajero ),
                                     new ReportParameter("Estado",cab.Estado),
                                     new ReportParameter("Fecha",cab.Fecha.ToShortDateString() ),
                                     new ReportParameter("SaldoInicial",cab.SaldoInicial.ToString() ),
                                     new ReportParameter("SaldoFinal",cab.SaldoFinal.ToString())
                                 };
            return Reporte("PDF", "rptSaldoCaja.rdlc", rd, "A4Vertical0.25", parametros);

        }
        public ActionResult ReporteCreditoMovimiento(int pCreditoId)
        {
            var credito = CreditoBL.Obtener(x => x.CreditoId == pCreditoId, "Persona");
            var oMov = CreditoBL.ReporteCreditoMovimiento(pCreditoId);
            var rd = new ReportDataSource("dsCreditoMov", oMov);

            var parametros = new List<ReportParameter>
                                 {
                                     new ReportParameter("CreditoId", pCreditoId.ToString()),
                                     new ReportParameter("Cliente", credito.Persona.NombreCompleto),
                                     new ReportParameter("Articulo", credito.Descripcion)
                                 };

            return Reporte("PDF", "rptCreditoMov.rdlc", rd, "A4Vertical0.25", parametros);
        }
        public ActionResult Reporte(string pTipoReporte, string rdlc, ReportDataSource rds, string pPapel, List<ReportParameter> pParametros = null)
        {
            var lr = new LocalReport();
            lr.ReportPath = Path.Combine(Server.MapPath("~/Reporte"), rdlc);

            if (rds != null) lr.DataSources.Add(rds);
            if (pParametros != null) lr.SetParameters(pParametros);

            string reportType = pTipoReporte;
            string mimeType;
            string encoding;
            string fileNameExtension;

            var deviceInfo = ObtenerPapel(pPapel).Replace("[TipoReporte]", pTipoReporte);
            Warning[] warnings;
            string[] streams;

            byte[] renderedBytes = lr.Render(reportType, deviceInfo, out mimeType, out encoding,
                                             out fileNameExtension, out streams, out warnings);

            return File(renderedBytes, mimeType);
        }

        private static string ObtenerPapel(string pPapel)
        {
            switch (pPapel)
            {
                case "A4Horizontal":
                    return "<DeviceInfo>" +
                           "  <OutputFormat>[TipoReporte]</OutputFormat>" +
                           "  <PageWidth>11in</PageWidth>" +
                           "  <PageHeight>8.5in</PageHeight>" +
                           "  <MarginTop>0in</MarginTop>" +
                           "  <MarginLeft>0in</MarginLeft>" +
                           "  <MarginRight>0in</MarginRight>" +
                           "  <MarginBottom>0in</MarginBottom>" +
                           "</DeviceInfo>";
                case "A4Vertical":
                    return "<DeviceInfo>" +
                           "  <OutputFormat>[TipoReporte]</OutputFormat>" +
                           "  <PageWidth>8.5in</PageWidth>" +
                           "  <PageHeight>11in</PageHeight>" +
                           "  <MarginTop>0in</MarginTop>" +
                           "  <MarginLeft>0in</MarginLeft>" +
                           "  <MarginRight>0in</MarginRight>" +
                           "  <MarginBottom>0in</MarginBottom>" +
                           "</DeviceInfo>";
                case "A4Horizontal0.25":
                    return "<DeviceInfo>" +
                           "  <OutputFormat>[TipoReporte]</OutputFormat>" +
                           "  <PageWidth>11in</PageWidth>" +
                           "  <PageHeight>8.5in</PageHeight>" +
                           "  <MarginTop>0.25in</MarginTop>" +
                           "  <MarginLeft>0.25in</MarginLeft>" +
                           "  <MarginRight>0.25in</MarginRight>" +
                           "  <MarginBottom>0.25in</MarginBottom>" +
                           "</DeviceInfo>";
                case "A4Vertical0.25":
                    return "<DeviceInfo>" +
                           "  <OutputFormat>[TipoReporte]</OutputFormat>" +
                           "  <PageWidth>8.5in</PageWidth>" +
                           "  <PageHeight>11in</PageHeight>" +
                           "  <MarginTop>0.25in</MarginTop>" +
                           "  <MarginLeft>0.25in</MarginLeft>" +
                           "  <MarginRight>0.25in</MarginRight>" +
                           "  <MarginBottom>0.25in</MarginBottom>" +
                           "</DeviceInfo>";
                case "TicketCaja":
                    return "<DeviceInfo>" +
                           "  <OutputFormat>[TipoReporte]</OutputFormat>" +
                           "  <PageWidth>3.5in</PageWidth>" +
                           "  <PageHeight>5.0in</PageHeight>" +
                           "  <MarginTop>0in</MarginTop>" +
                           "  <MarginLeft>0.1in</MarginLeft>" +
                           "  <MarginRight>0in</MarginRight>" +
                           "  <MarginBottom>0in</MarginBottom>" +
                           "</DeviceInfo>";
                case "CodigoBarras":
                    return "<DeviceInfo>" +
                           "  <OutputFormat>[TipoReporte]</OutputFormat>" +
                           "  <PageWidth>4.13in</PageWidth>" +
                           "  <PageHeight>2.76in</PageHeight>" +
                           "  <MarginTop>0in</MarginTop>" +
                           "  <MarginLeft>0in</MarginLeft>" +
                           "  <MarginRight>0in</MarginRight>" +
                           "  <MarginBottom>0in</MarginBottom>" +
                           "</DeviceInfo>";

            }

            return "<DeviceInfo>" +
                   "  <OutputFormat>[TipoReporte]</OutputFormat>" +
                   "  <PageWidth>8.5in</PageWidth>" +
                   "  <PageHeight>11in</PageHeight>" +
                   "  <MarginTop>0in</MarginTop>" +
                   "  <MarginLeft>0in</MarginLeft>" +
                   "  <MarginRight>0in</MarginRight>" +
                   "  <MarginBottom>0in</MarginBottom>" +
                   "</DeviceInfo>";
        }
        #endregion

    }
}