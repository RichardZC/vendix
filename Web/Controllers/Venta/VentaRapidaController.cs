using ITB.VENDIX.BL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Web.Controllers.Venta
{
    public class VentaRapidaController : Controller
    {
        // GET: VentaRapida
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult ObtenerArticulo(string pCodigo)
        {
            var art = ArticuloBL.Obtener(x => x.CodArticulo == pCodigo , "ListaPrecio");
            if (art == null || art.ListaPrecio.Count==0)
                return Json(null, JsonRequestBehavior.AllowGet);


            return Json(new
            {
                CodArticulo = art.CodArticulo,
                Denominacion = art.Denominacion,
                PrecioVenta = art.ListaPrecio.First().Monto            
            }, JsonRequestBehavior.AllowGet);
        }

    }
}
        [HttpPost]
        public JsonResult RealizarPedido(int pClienteId, List<OrdenVentaBL.Pedido> pPedidos)
        {
            var ordenventaid = OrdenVentaBL.RealizarPedido(pClienteId,pPedidos);
            return Json(ordenventaid);
        }
    }
    //public class Pedido
    //{
    //    public int ArticuloId { get; set; }
    //    public string Denominacion { get; set; }
    //    public int Cantidad { get; set; }
    //    public decimal Precio { get; set; }
    //}
}