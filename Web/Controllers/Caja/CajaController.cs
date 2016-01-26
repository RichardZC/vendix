﻿using ITB.VENDIX.BL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ITB.VENDIX.BE;

namespace VendixWeb.Controllers
{
    public class CajaController : Controller
    {
        //
        // GET: /Caja/

        public ActionResult Index()
        {
            ViewBag.cboOficina = new SelectList(OficinaBL.Listar(x => x.Estado), "OficinaId", "Denominacion");
            return View();
        }

        public ActionResult ListarCajaGrid(GridDataRequest request)
        {
            int totalRecords = 0;
            var lstGrd = CajaBL.LstCajaJGrid(request, ref totalRecords);

            var productsData = new
            {
                total = (int)Math.Ceiling((float)totalRecords / (float)request.rows),
                page = request.page,
                records = totalRecords,
                rows = (from item in lstGrd
                        select new
                        {
                            id = item.CajaId,
                            cell = new string[] {
                                                    item.CajaId.ToString(),
                                                    item.Denominacion,
                                                    item.Oficina.Denominacion,
                                                    item.Estado.ToString(),
                                                    item.CajaId.ToString() + "," + (item.Estado ? "1":"0")
                                                }
                        }
                       ).ToArray()
            };
            return Json(productsData, JsonRequestBehavior.AllowGet);
        }
        public ActionResult GuardarCaja(int pCajaId, int pOficinaId, string pDenominacion, bool pActivo)
        {
            Caja caja;
            if (pCajaId == 0)
            {
                caja = new Caja
                {
                    CajaId = pCajaId,
                    OficinaId = pOficinaId,
                    Denominacion = pDenominacion,
                    Estado = pActivo,
                    IndAbierto = false,
                    FechaReg = DateTime.Now,
                    UsuarioRegId = VendixGlobal.GetUsuarioId()
                };
                CajaBL.Crear(caja);
            }
            else {
                caja = CajaBL.Obtener(pCajaId);
                caja.OficinaId = pOficinaId;
                caja.Denominacion = pDenominacion;
                caja.Estado = pActivo;
                caja.FechaMod = DateTime.Now;
                caja.UsuarioModId = VendixGlobal.GetUsuarioId();
                CajaBL.Actualizar(caja);
            }

            return Json(true, JsonRequestBehavior.AllowGet);
        }

        public ActionResult Activar(int pid)
        {
            var item = CajaBL.Obtener(pid);
            item.Estado = !item.Estado;
            CajaBL.Actualizar(item);
            return Json(true);
        }
        public ActionResult CargarComboOficina()
        {
            var xxx = CajaBL.Listar(x => x.Estado).Select(c => new { Id = c.CajaId, Valor = c.Denominacion });
            return Json(xxx, JsonRequestBehavior.AllowGet);
        }
    }
}
