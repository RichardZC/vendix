using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using System.Web.Security;
using ITB.VENDIX.BL;
using ITB.VENDIX.BE;

namespace Web.Controllers
{
    public class HomeController : Controller
    {
       
        public ActionResult Index()
        {
           
           return View("Index");
        }
        [AllowAnonymous]
        public ActionResult Login(string mensaje="")
        {
            ViewBag.cboOficina = new SelectList(OficinaBL.Listar(x => x.Estado), "OficinaId", "Denominacion");
            ViewBag.mensaje = mensaje;
            return View("Login");
        }
        

        [AllowAnonymous]
        public ActionResult Autenticar()
        {
            string login = Request.Form["login_name"].Trim();
            string pass = Request.Form["login_pw"].Trim();
            int oficinaId = int.Parse(Request.Form["cboOficina"]);
            var usuarioOficina = UsuarioOficinaBL.Listar(x => x.Usuario.NombreUsuario == login && x.Usuario.ClaveUsuario == pass
                                         && x.OficinaId == oficinaId && x.Estado && x.Usuario.Estado, null, "Usuario,Oficina").FirstOrDefault();
            if (usuarioOficina != null )
            {
                FormsAuthentication.SetAuthCookie(login, true);

                VendixGlobal<int>.Crear("UsuarioOficinaId", usuarioOficina.UsuarioOficinaId);

                VendixGlobal<int>.Crear("BovedaId", BovedaBL.Obtener(x => x.OficinaId == oficinaId).BovedaId);
                //usuario asginado a oficina
                var usuarioAsignadoId =
                    OficinaBL.Obtener(x => x.OficinaId == usuarioOficina.OficinaId && x.Estado).UsuarioAsignadoId;

                VendixGlobal<int>.Crear("UsuarioIdAsignadoOficina", usuarioAsignadoId);
                //
                
                VendixGlobal<int>.Crear("UsuarioId", usuarioOficina.UsuarioId);
                VendixGlobal<string>.Crear("NombreUsuario", usuarioOficina.Usuario.NombreUsuario);
                VendixGlobal<string>.Crear("NombreOficina", usuarioOficina.Oficina.Denominacion);
                VendixGlobal<int>.Crear("OficinaId", usuarioOficina.OficinaId);
                VendixGlobal<List<usp_MenuLst_Result>>.Crear("Menu", MenuBL.ListaMenuDinamico());

                //System.Web.HttpContext.Current.Cache.Insert("Menu", MenuBL.ListaMenuDinamico());
                //var x = HttpRuntime.Cache.Get("Menu") as List<usp_MenuLst_Result>;
                
            
                return RedirectToAction("Index");
            }
            return RedirectToAction("Login",new{mensaje="Usuario o Clave Incorrecto"});
        }
        [AllowAnonymous]
        public ActionResult LogOff()
        {
            FormsAuthentication.SignOut();
            FormsAuthentication.RedirectToLoginPage();
            return RedirectToAction("Login");
        }
        [AllowAnonymous]
        public ActionResult ListarOficina()
        {
            return Json(new SelectList(OficinaBL.Listar(x => x.Estado), "OficinaId", "Denominacion"), JsonRequestBehavior.AllowGet);
        }
    }
}

