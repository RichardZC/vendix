using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ITB.VENDIX.BE;

namespace ITB.VENDIX.BL
{
    public class ClienteBL : Repositorio<Cliente>
    {
        public static List<ItemCombo> BuscarCliente(string pClave)
        {
            using (var db = new VENDIXEntities())
            {
                var qry = (from p in db.Persona
                          join c in db.Cliente on p.PersonaId equals c.PersonaId
                          where c.Estado && (p.NombreCompleto.Contains(pClave) || p.NumeroDocumento.Contains(pClave))
                          orderby p.NombreCompleto
                          select new ItemCombo { id = p.PersonaId, value = p.NumeroDocumento + " " + p.NombreCompleto }).Take(10);
                return qry.ToList();
            }
        }
        public static List<ItemCombo> BuscarPersona(string pClave)
        {
            using (var db = new VENDIXEntities())
            {
                var qry = from p in db.Persona
                          where p.Estado && (p.NombreCompleto.Contains(pClave) || p.NumeroDocumento.Contains(pClave))
                          orderby p.NombreCompleto
                          select new ItemCombo { id = p.PersonaId, value = p.NumeroDocumento + " " + p.NombreCompleto };
                return qry.ToList();
            }
        }


        public static List<Cliente> LstClienteJGrid(GridDataRequest request, ref int pTotalItems)
        {
            string filterExpression = string.Empty;

            if (request.DataFilters()["Buscar"] != string.Empty)
                filterExpression = 
                    "Persona.NombreCompleto.Contains( \"" + request.DataFilters()["Buscar"] + "\") || Persona.NumeroDocumento.Contains( \"" + request.DataFilters()["Buscar"] + "\")";
            using (var db = new VENDIXEntities())
            {
                IQueryable<Cliente> query = db.Cliente.Include("Persona");
                if (!String.IsNullOrEmpty(filterExpression))
                    query = query.Where(filterExpression);

                pTotalItems = query.Count();

                return query.OrderBy(request.sidx + " " + request.sord)
                    .Skip((request.page - 1)*request.rows).Take(request.rows).ToList();
            }
        }
    }
}