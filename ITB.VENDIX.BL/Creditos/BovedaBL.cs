using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;
using ITB.VENDIX.BE;

namespace ITB.VENDIX.BL
{
    public class BovedaBL: Repositorio<Boveda>
    {
        public static List<BovedaMov> LstBovedaMovJGrid(GridDataRequest request, ref int pTotalItems)
        {
            //string filterExpression = string.Empty;

            var oficinaid = VendixGlobal.GetOficinaId();
            using (var db = new VENDIXEntities())
            {
                var bovedaid = db.Boveda.First(x => x.OficinaId == oficinaid && x.IndCierre == false).BovedaId;

                IQueryable<BovedaMov> query = db.BovedaMov.Where(x => x.BovedaId == bovedaid);
                //if (!String.IsNullOrEmpty(filterExpression))
                //    query = query.Where(filterExpression);

                pTotalItems = query.Count();
                return query.OrderBy(request.sidx + " " + request.sord)
                    .Skip((request.page - 1) * request.rows).Take(request.rows).ToList();
            }
        }

        public  static bool Cerrar()
        {
            var oficinaid = VendixGlobal.GetOficinaId();
            using (var scope = new TransactionScope())
            {
                try
                {
                    using (var db = new VENDIXEntities())
                    {
                        var boveda = db.Boveda.First(x => x.OficinaId == oficinaid && x.IndCierre==false);
                        boveda.IndCierre = true;
                        boveda.FechaFinOperacion = DateTime.Now;
                        Actualizar(db,boveda);

                        Crear(db,new Boveda()
                                  {
                                      OficinaId = oficinaid,
                                      SaldoInicial = boveda.SaldoFinal,
                                      Entradas = 0,
                                      Salidas = 0,
                                      SaldoFinal = boveda.SaldoFinal,
                                      FechaIniOperacion = DateTime.Now,
                                      IndCierre = false
                                  });
                        db.SaveChanges();
                    }
                    scope.Complete();
                    return true;
                }
                catch (Exception)
                {
                    scope.Dispose();
                    return false;
                }
            }
        }

        
 
    }
}
