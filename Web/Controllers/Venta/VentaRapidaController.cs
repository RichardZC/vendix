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