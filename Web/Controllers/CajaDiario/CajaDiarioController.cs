using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ITB.VENDIX.BE;
using ITB.VENDIX.BL;

namespace VendixWeb.Controllers.CajaDiario
{
    public class CajaDiarioController : Controller
    {
        [HttpPost]
        public ActionResult MostrarMontoCaja()
        {
            var ofid = VendixGlobal.GetOficinaId();
            var cajaDiarioId = VendixGlobal.GetCajaDiarioId();

            var monto = CajaDiarioBL.Obtener(x => x.CajaDiarioId == cajaDiarioId && x.IndCierre == false).SaldoFinal;

            return Json(monto, JsonRequestBehavior.AllowGet);
        }

        public ActionResult TransferirBoveda(decimal pMonto, string pDescripcion)
        {
            var boveda = BovedaBL.Obtener(VendixGlobal.GetBovedaId());

            if (boveda.IndCierre == false)
            {
                var oficinaId = VendixGlobal.GetOficinaId();
                var pUsuarRegId = VendixGlobal.GetUsuarioId();
                var pCajaDiarioId = VendixGlobal.GetCajaDiarioId();               

                var rspta = CajaDiarioBL.TransferirSaldosBoveda(pMonto, pDescripcion, pCajaDiarioId, boveda.BovedaId, oficinaId, pUsuarRegId);

                return Json(rspta, JsonRequestBehavior.AllowGet);
            }

            return Json(false, JsonRequestBehavior.AllowGet);
        }

    }

}

