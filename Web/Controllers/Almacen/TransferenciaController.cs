using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ITB.VENDIX.BE;
using ITB.VENDIX.BL;

namespace VendixWeb.Controllers.Almacen
{
    public class TransferenciaController : Controller
    {

        //public ActionResult Index(int id = 0, int pPersonaId = 0)
        //{
        //    if (id == 0 && pPersonaId > 0)
        //    {
        //        var orden = Repositorio<OrdenVenta>.Crear(new OrdenVenta()
        //        {
        //            OficinaId = VendixGlobal.GetOficinaId(),
        //            PersonaId = pPersonaId,
        //            Subtotal = 0,
        //            TotalDescuento = 0,
        //            TotalImpuesto = 0,
        //            TotalNeto = 0,
        //            TipoVenta = "CON",
        //            Estado = "PEN",
        //            UsuarioRegId = VendixGlobal.GetUsuarioId(),
        //            FechaReg = DateTime.Now
        //        });
        //        id = orden.OrdenVentaId;
        //    }

        //    if (id > 0)
        //    {
        //        return View(Repositorio<OrdenVenta>.Listar(x => x.OrdenVentaId == id, includeProperties: "OrdenVentaDet,Persona,Oficina").FirstOrDefault());
        //    }
        //    return View(new OrdenVenta { TotalNeto = 0, TotalDescuento = 0 });
        //}

        public ActionResult BuscarOrdenVentaDet(string pOrdenVentaId)
        {
            var orden = Int32.Parse(pOrdenVentaId);
            var ordenventadet = OrdenVentaDetBL.Listar(x => x.OrdenVentaId == orden);
            return Json(new
            {
                OrdenVenta = Repositorio<OrdenVenta>.Obtener(orden),
                OrdenVentaDet = ordenventadet,
                Cantidadov = ordenventadet.Sum(x => x.Cantidad)
            }

                        , JsonRequestBehavior.AllowGet);
        }

        public ActionResult AgregarOrdenVentaDetalle(string pNumeroSerie, string pOrdenVentaId)
        {
            var ordenVentaId = Int32.Parse(pOrdenVentaId);
            return Json(OrdenVentaDetBL.AgregarOrdenVentaDetalle(ordenVentaId, pNumeroSerie), JsonRequestBehavior.AllowGet);
        }

        
        public ActionResult AgregarDetalle(string pNumeroSerie, int pMovimientoId) {

           
            var serie = SerieArticuloBL.Obtener(x => x.NumeroSerie == pNumeroSerie, includeProperties:"Articulo");
            if (serie ==null)
            {               
                return Json("No existe Artículo !!!", JsonRequestBehavior.AllowGet);
            }
            if (serie.EstadoId != 2)
            {           
                return Json("El articulo " + serie.Articulo.Denominacion + " no se encuentra disponible.", JsonRequestBehavior.AllowGet);
            }

            // insertar a la tabla detalle movimiento

            return Json(string.Empty, JsonRequestBehavior.AllowGet);
        }


        // GET: Transferencia
        public ActionResult Index()
        {
            var oficinaId = VendixGlobal.GetOficinaId();
            var lstalmacen = AlmacenBL.Listar(x => x.Estado && x.OficinaId == oficinaId);
            var lstTipoMov = TipoMovimientoBL.Listar(x => x.Estado && x.IndEntrada);

            ViewBag.cboAlmacen = new SelectList(lstalmacen, "AlmacenId", "Denominacion");
            ViewBag.cboAlmacenSalida = new SelectList(lstalmacen, "AlmacenId", "Denominacion");
            ViewBag.cboAlmacenDestino = new SelectList(lstalmacen, "AlmacenId", "Denominacion");
            ViewBag.cboTipoMovimiento = new SelectList(lstTipoMov, "TipoMovimientoId", "Denominacion");
            ViewBag.cboTipoMovimiento2 = new SelectList(lstTipoMov, "TipoMovimientoId", "Denominacion");
            ViewBag.cboTipoDocumento = new SelectList(TipoDocumentoBL.Listar(x => x.Estado && x.IndAlmacen.Value && x.IndAlmacenMov == false), "TipoDocumentoId", "Denominacion");
            ViewBag.cboMedida = new SelectList(ValorTablaBL.Listar(x => x.TablaId == 10 && x.ItemId > 0), "ItemId", "DesCorta");

            return View();
        }

        // GET: Transferencia/Details/5
        public ActionResult Listar(GridDataRequest request)
        {
            int totalRecords = 0;
            var lstGrd = MovimientoBL.LstTransferenciaJGrid(request, ref totalRecords);

            var productsData = new
            {
                total = (int)Math.Ceiling((float)totalRecords / (float)request.rows),
                page = request.page,
                records = totalRecords,
                rows = (from item in lstGrd
                        select new
                        {
                            id = item.MovimientoId,
                            cell = new string[] {
                                                    item.MovimientoId.ToString(),
                                                    item.Tipo,
                                                    item.TipoMovimientoId.ToString(),
                                                    item.TipoMovimiento,
                                                    item.Fecha.ToString(),
                                                    item.Documento,
                                                    item.Estado,
                                                    item.Observacion
                                                }
                        }
                       ).ToArray()
            };
            return Json(productsData, JsonRequestBehavior.AllowGet);

        }

        public ActionResult Guardar(int pMovimientoId, int pAlmacenId, int pTipoMovimientoId, string pFecha, string pObservacion)
        {
            if (pMovimientoId == 0)
            {
                var item = new Movimiento
                {
                    MovimientoId = pMovimientoId,
                    AlmacenId = pAlmacenId,
                    TipoMovimientoId = pTipoMovimientoId,
                    Fecha = DateTime.Now,
                    EstadoId = 1,
                    Observacion = string.Empty,
                    IGV = 0,
                    TotalImporte = 0,
                    SubTotal = 0,
                    AjusteRedondeo = 0
                };
                MovimientoBL.Crear(item);
                pMovimientoId = item.MovimientoId;
            }
            else
            {
                MovimientoBL.ActualizarMov(pMovimientoId, pTipoMovimientoId, DateTime.Parse(pFecha), pObservacion);
            }
            return Json(pMovimientoId, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult AgregarDocumento(int pMovimientoId, int pTipoDocumentoId, string pSerie, string pNumero)
        {
            var omov = MovimientoBL.Obtener(pMovimientoId);

            var item = new MovimientoDoc();
            item.MovimientoId = pMovimientoId;
            item.TipoDocumentoId = pTipoDocumentoId;
            item.SerieDocumento = pSerie;
            item.NroDocumento = pNumero;
            MovimientoDocBL.Crear(item);

            var lstdoc = MovimientoDocBL.Listar(x => x.MovimientoId == pMovimientoId,
                                                z => z.OrderBy(y => y.TipoDocumentoId), "TipoDocumento");
            omov.Documento = string.Empty;
            foreach (var x in lstdoc)
                omov.Documento += x.TipoDocumento.Descripcion + " " + x.SerieDocumento + "-" + x.NroDocumento + "  ";
            MovimientoBL.Actualizar(omov);

            return Json(true, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ListarDocs(GridDataRequest request)
        {
            int movimientoid = request.DataFilters().Count > 0 ? int.Parse(request.DataFilters()["MovimientoId"]) : 0;
            if (movimientoid == 0)
                return Json(null, JsonRequestBehavior.AllowGet);

            const int totalRecords = 10;
            var productsData = new
            {
                total = 1,
                page = 1,
                records = totalRecords,
                rows = (from item in MovimientoDocBL.Listar(x => x.MovimientoId == movimientoid, null, "TipoDocumento,Movimiento")
                        select new
                        {
                            id = item.MovimientoDocId,
                            cell = new string[] {
                                                    item.MovimientoDocId.ToString(),
                                                    item.TipoDocumento.Denominacion,
                                                    item.SerieDocumento,
                                                    item.NroDocumento,
                                                    item.Movimiento.EstadoId==1?item.MovimientoDocId.ToString():string.Empty
                                                }
                        }
                       ).ToArray()
            };
            return Json(productsData, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult Eliminar(int pid)
        {
            var odoc = MovimientoDocBL.Obtener(pid);
            MovimientoDocBL.Eliminar(pid);

            var lstdoc = MovimientoDocBL.Listar(x => x.MovimientoId == odoc.MovimientoId.Value,
                                                z => z.OrderBy(y => y.TipoDocumentoId), "TipoDocumento");

            var omov = MovimientoBL.Obtener(odoc.MovimientoId.Value);
            omov.Documento = string.Empty;
            foreach (var x in lstdoc)
                omov.Documento += x.TipoDocumento.Descripcion + " " + x.SerieDocumento + "-" + x.NroDocumento + "  ";

            MovimientoBL.Actualizar(omov);

            return Json(true);
        }

        public ActionResult ListarDetalle(GridDataRequest request)
        {
            int movimientoid = request.DataFilters().Count > 0 ? int.Parse(request.DataFilters()["MovimientoId"]) : 0;
            if (movimientoid == 0)
                return Json(null, JsonRequestBehavior.AllowGet);

            const int totalRecords = 10;
            var productsData = new
            {
                total = 1,
                page = 1,
                records = totalRecords,
                rows = (from item in MovimientoBL.ObtenerEntradaDetalle(movimientoid)
                        select new
                        {
                            id = item.MovimientoDetId,
                            cell = new string[] {
                                                    item.MovimientoDetId.ToString(),
                                                    item.ArticuloId.ToString(),
                                                    item.UnidadMedidaT10.ToString(),
                                                    item.Cantidad.ToString(),
                                                    item.UnidadMedida,
                                                    item.Descripcion,
                                                    item.PrecioUnitario.ToString(),
                                                    item.Descuento.ToString(),
                                                    item.Importe.ToString(),
                                                    item.IndCorrelativo.ToString(),
                                                    item.Elimina?item.MovimientoDetId.ToString():string.Empty
                                                }
                        }
                       ).ToArray()
            };
            return Json(productsData, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult Delete(int pid)
        {
            MovimientoDetBL.EliminarDetalle(pid);
            return Json(true);
        }

        [HttpPost]
        public ActionResult CrearMovimientoDetalle(int pMovimientoId, int pMovimientoDetId, int pArticuloId, bool pIndAutogenerar,
                                                    string pListaSerie, int pCantidad, bool pIndCorrelativo, decimal pPrecioUnitario, decimal pDescuento, int pMedida)
        {

            MovimientoDetBL.CrearDetalle(pMovimientoId, pMovimientoDetId, pArticuloId, pIndAutogenerar, pListaSerie, pCantidad,
                                          pIndCorrelativo, pPrecioUnitario, pDescuento, pMedida);
            return Json(true);
        }
        [HttpPost]
        public ActionResult Confirmar(int pMovimientoId)
        {
            return Json(MovimientoBL.ConfirmarMov(pMovimientoId), JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult ActualizarImporte(int pMovimientoId, decimal pAjuste)
        {
            MovimientoBL.ActualizarImporte(pMovimientoId, pAjuste);
            return Json(true, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ObtenerMovimiento(int pMovimientoId)
        {
            return Json(MovimientoBL.Obtener(pMovimientoId), JsonRequestBehavior.AllowGet);
        }

        public ActionResult ObtenerMovimientoExt(int pMovimientoId)
        {
            var mov = MovimientoBL.ObtenerEntradaSalida(pMovimientoId);
            return Json(new { Fecha = mov.Fecha.ToString(), mov.Estado, mov.Almacen }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ObtenerMovimientoDetalle(int pMovimientoDetId)
        {
            return
                Json(MovimientoDetBL.Listar(x => x.MovimientoDetId == pMovimientoDetId),
                     JsonRequestBehavior.AllowGet);
        }

        public ActionResult ObtenerSeriesMovimientoDetalle(int pMovimientoDetId)
        {
            return Json(SerieArticuloBL.Listar(x => x.MovimientoDetEntId == pMovimientoDetId).Select(c => new { c.NumeroSerie }),
                                JsonRequestBehavior.AllowGet);
        }

        public ActionResult ValidarExisteSerie(string pListaSerie, bool pIndCorrelativo, int? pCantidad)
        {
            return Json(SerieArticuloBL.ValidarExisteSerie(pListaSerie, pIndCorrelativo, pCantidad), JsonRequestBehavior.AllowGet);
        }

        public ActionResult Desconfirmar(int pMovimientoId)
        {
            return Json(MovimientoBL.Desconfirmar(pMovimientoId), JsonRequestBehavior.AllowGet);
        }
    }











    
}
