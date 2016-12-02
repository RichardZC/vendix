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

        public ActionResult Index()
        {
            var oficinaId = VendixGlobal.GetOficinaId();
            var lstalmacen = AlmacenBL.Listar(x => x.Estado && x.OficinaId == oficinaId);
            var lstTipoMov = TipoMovimientoBL.Listar(x => x.Estado && x.IndEntrada);

            ViewBag.cboAlmacen = new SelectList(AlmacenBL.Listar(x => x.Estado && x.OficinaId != oficinaId), "AlmacenId", "Denominacion");
            ViewBag.cboAlmacen2 = new SelectList(lstalmacen, "AlmacenId", "Denominacion");
            ViewBag.cboDestino = new SelectList(AlmacenBL.Listar(x => x.Estado && x.OficinaId != oficinaId), "AlmacenId", "Denominacion");
            ViewBag.cboTipoMovimiento2 = new SelectList(lstTipoMov, "TipoMovimientoId", "Denominacion");
            ViewBag.cboTipoDocumento = new SelectList(TipoDocumentoBL.Listar(x => x.Estado && x.IndAlmacen.Value && x.IndAlmacenMov == false), "TipoDocumentoId", "Denominacion");
            ViewBag.cboMedida = new SelectList(ValorTablaBL.Listar(x => x.TablaId == 10 && x.ItemId > 0), "ItemId", "DesCorta");
            return View();
        }

        public ActionResult Listar(GridDataRequest request)
        {
            int totalRecords = 0;
            var lstGrd = TransferenciaBL.LstTransferenciaJGrid(request, ref totalRecords);

            var productsData = new
            {
                total = (int)Math.Ceiling((float)totalRecords / (float)request.rows),
                page = request.page,
                records = totalRecords,
                rows = (from item in lstGrd
                        select new
                        {
                            id = item.TransferenciaId,
                            cell = new string[] {
                                                    item.TransferenciaId.ToString(),
                                                    item.AlmacenDestino,
                                                    item.Fecha.ToString(),
                                                    item.Estado
                                                }
                        }
                       ).ToArray()
            };
            return Json(productsData, JsonRequestBehavior.AllowGet);
        }

        public ActionResult CrearTransferencia(int pAlmacenDestinoId)
        {
            var oficinaid = VendixGlobal.GetOficinaId();
            var usuarioid = VendixGlobal.GetUsuarioId();

            var item = new Transferencia
            {
                AlmacenOrigenId = AlmacenBL.Obtener(x => x.OficinaId == oficinaid).AlmacenId,
                AlmacenDestinoId = pAlmacenDestinoId,
                UsuarioId = usuarioid,
                Fecha = DateTime.Now,
                Estado = "P"
                
            };
            TransferenciaBL.Crear(item);

            return Json(item.TransferenciaId, JsonRequestBehavior.AllowGet);

        }
        public ActionResult Guardar(int pMovimientoId, int pAlmacenId, int pTipoMovimientoId, string pFecha, string pObservacion)
        {
            if (pMovimientoId == 0)
            {
                var item = new Movimiento
                {
                    MovimientoId = pMovimientoId,
                    AlmacenId = pAlmacenId,
                    TipoMovimientoId = 3,
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

        public ActionResult AgregarOrdenDetalle(string pNumeroSerie, int pMovimientoId)
        {
            
            
            return Json(MovimientoDetBL.AgregarDetalleTranferencia(pNumeroSerie, pMovimientoId), JsonRequestBehavior.AllowGet);
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

        public ActionResult ObtenerMovimiento(int pTranferenciaId)
        {
            return Json(TransferenciaBL.Obtener(pTranferenciaId), JsonRequestBehavior.AllowGet);
        }

    }










}
