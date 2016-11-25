using ITB.VENDIX.BE;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Objects;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITB.VENDIX.BL
{
    public class TransferenciaBL : Repositorio<Transferencia>
    {

        public static bool AgregarTransferenciaSerie(Transferencia t , List<int> series) {

            foreach (var c in series)
                t.SerieArticulo.Add(new SerieArticulo { SerieArticuloId = c });

            using ( var db= new VENDIXEntities()) {

                if (t.TransferenciaId == 0)
                {
                    db.Entry(t).State = EntityState.Added;
                }
                else
                {
                    db.Database.ExecuteSqlCommand(
                        "DELETE FROM TransferenciaSerie WHERE TransferenciaId = @id",
                        new SqlParameter("id", t.TransferenciaId)
                    );

                    var serieBK = t.SerieArticulo;

                    t.SerieArticulo = null;
                    db.Entry(t).State = EntityState.Modified;
                    t.SerieArticulo = serieBK;
                }

                foreach (var c in t.SerieArticulo)
                    db.Entry(c).State = EntityState.Unchanged;

                db.SaveChanges();

            }


            return true;
        }




        public class EntradaSalida
        {
            public int TansferenciaId { get; set; }
            public string AlmacenDestino { get; set; }         
            public DateTime Fecha { get; set; }
            public string Estado { get; set; }

        }






        public static List<EntradaSalida> LstTransferenciaJGrid(GridDataRequest request, ref int pTotalItems)
        {
            string clave = request.DataFilters().Count > 0 ? request.DataFilters()["Buscar"] : string.Empty;
            int almacenId = int.Parse(request.DataFilters()["Almacen"]);
            int articuloId = int.Parse(request.DataFilters()["BuscarxArticuloId"]);

            using (var db = new VENDIXEntities())
            {
                //db.Configuration.ProxyCreationEnabled = false;
                //db.Configuration.LazyLoadingEnabled = false;
                //db.Configuration.ValidateOnSaveEnabled = false;
                IQueryable<EntradaSalida> qry;
               
                    qry = from tra in db.Transferencia
                          where tra.AlmacenDestinoId == almacenId || tra.AlmacenOrigenId == almacenId // mejorar qry
                          select new EntradaSalida
                          {
                              TansferenciaId= tra.TransferenciaId,
                              AlmacenDestino = tra.Almacen1.Denominacion,
                              Fecha = tra.Fecha,
                              Estado = tra.Estado
                          };
                    if (clave != string.Empty)
                    {
                        DateTime fecha;
                        qry = DateTime.TryParse(clave, out fecha)
                            ? qry.Where(x => EntityFunctions.TruncateTime(x.Fecha) == fecha.Date)
                            : qry.Where("Tags.Contains(\"" + clave + "\")");
                    }
            
                

                pTotalItems = qry.Count();
                return qry.OrderBy(request.sidx + " " + request.sord)
                    .Skip((request.page - 1) * request.rows).Take(request.rows).ToList();
            }
        }

    }
}
