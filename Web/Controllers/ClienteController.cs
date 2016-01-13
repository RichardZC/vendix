using System;
using System.Linq;
using System.Web.Mvc;
using ITB.VENDIX.BE;
using ITB.VENDIX.BL;

namespace Web.Controllers
{
    public class ClienteController : Controller
    {
        public ActionResult Index()
        {
            ViewBag.cboOcupacion = new SelectList(OcupacionBL.Listar(x => (bool)x.Estado), "OcupacionId", "Denominacion");
            return View();
        }
        public ActionResult ListarCliente(GridDataRequest request)
        {
            int totalRecords = 0;
            var lstGrd = ClienteBL.LstClienteJGrid(request, ref totalRecords);

            var productsData = new
            {
                total = (int)Math.Ceiling((float)totalRecords / (float)request.rows),
                page = request.page,
                records = totalRecords,
                rows = (from item in lstGrd
                        select new
                        {
                            id = item.ClienteId,
                            cell = new string[] { 
                                                    item.ClienteId.ToString(),
                                                    item.Persona.NombreCompleto,
                                                    item.Persona.TipoDocumento + " " + item.Persona.NumeroDocumento,
                                                    item.Persona.EmailPersonal,
                                                    item.Persona.Celular1,
                                                    item.Persona.Direccion,
                                                    item.Estado.ToString(),
                                                    item.ClienteId.ToString() + "," + (item.Estado ? "1":"0")
                                                }
                        }
                       ).ToArray()
            };
            return Json(productsData, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult GuardarCliente(int pClienteId,string pTipoPersona, string pNombre, string pApePaterno, string pApeMaterno,
                                        string pNumeroDocumento, bool pSexoM, string pEmail, string pCelular1, string pCelular2,
                                        DateTime? pFechaNacimiento, string pDireccion, DateTime pFechaCaptacion, int? pOcupacionId,
                                        string pCalificacion, decimal? pMontoInscripcion, bool pActivo)
        {
            var persona = new Persona();
            var cliente = new Cliente();
            
            if (pClienteId > 0)
            {
                cliente = ClienteBL.Obtener(pClienteId);
                persona = PersonaBL.Obtener(cliente.PersonaId);
            }

            pNombre = pNombre.ToUpper();
            if (pTipoPersona == "N")
            {
                pApePaterno = pApePaterno.ToUpper();
                pApeMaterno = pApeMaterno.ToUpper();
                persona.NombreCompleto = pApePaterno + " " + pApeMaterno + ", " + pNombre;
                persona.TipoDocumento = "DNI";
            
            }
            else
            {
                pApePaterno = string.Empty;
                pApeMaterno = string.Empty;
                persona.NombreCompleto = pNombre;
                persona.TipoDocumento = "RUC";
            }

            persona.TipoPersona = pTipoPersona;
            persona.Nombre = pNombre;
            persona.ApePaterno = pApePaterno;
            persona.ApeMaterno = pApeMaterno;
            persona.NumeroDocumento = pNumeroDocumento;
            persona.Sexo = pSexoM ? "M" : "F";
            persona.EmailPersonal = pEmail;
            persona.Celular1 = pCelular1;
            persona.Celular2 = pCelular2;
            persona.FechaNacimiento = pFechaNacimiento;
            persona.Direccion = pDireccion;
            persona.Estado = pActivo;

            if (pClienteId == 0)
                PersonaBL.Crear(persona);
            else
                PersonaBL.Actualizar(persona);

            cliente.PersonaId = persona.PersonaId;
            cliente.FechaRegistro = DateTime.Now;
            cliente.FechaCaptacion = pFechaCaptacion;
            cliente.ActividadEconId = pOcupacionId;
            cliente.Calificacion = pCalificacion;
            cliente.Inscripcion = pMontoInscripcion.Value;
            cliente.IndPagoInscripcion = false;
            cliente.Estado = pActivo;
            if (pClienteId == 0)
                ClienteBL.Crear(cliente);
            else
                ClienteBL.Actualizar(cliente);
            
            return Json(true, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ObtenerClientePersona(int pClienteId)
        {
            var cliente = ClienteBL.Listar(x => x.ClienteId == pClienteId).FirstOrDefault();
            var persona = PersonaBL.Listar(x => x.PersonaId == cliente.PersonaId).FirstOrDefault();
            
            return Json(new
            {
                Cliente = cliente,
                Persona = persona,
                Sexo = persona.Sexo != "F" ? "true" : "false",
                FNacimiento = persona.FechaNacimiento != null ? persona.FechaNacimiento.Value.ToShortDateString() : string.Empty,
                FCaptacion = cliente.FechaCaptacion != null ? cliente.FechaCaptacion.Value.ToShortDateString() : string.Empty
            }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ExistePersonaDocumento(string pDocumento)
        {

            var persona = PersonaBL.Listar(x => x.NumeroDocumento == pDocumento).FirstOrDefault();
            if (persona == null)
                return Json(false, JsonRequestBehavior.AllowGet);
            return Json(true, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult Activar(int pid)
        {
            var oCliente = ClienteBL.Obtener(pid);
            oCliente.Estado = !oCliente.Estado;
            ClienteBL.Actualizar(oCliente);
            return Json(true);
        }

        public JsonResult BuscarCliente(string term)
        {
            return Json(ClienteBL.BuscarCliente(term), JsonRequestBehavior.AllowGet);
        }


        //public JsonResult BuscarDemo(string term)
        //{
        //    var results = PersonaBL.Listar(s => term == null || s.NombreCompleto.ToLower().Contains(term.ToLower()))
        //        .Select(x => new { id = x.PersonaId, value = x.NombreCompleto }).Take(5).ToList();

        //    return Json(results.ToList(), JsonRequestBehavior.AllowGet);
        //}


        public JsonResult BuscarPersona(string term)
        {
            return Json(ClienteBL.BuscarPersona(term), JsonRequestBehavior.AllowGet);
        }
    }
}
