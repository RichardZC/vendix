using ITB.VENDIX.BE;
using System;
using System.Collections.Generic;
using System.Data;
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

    }
}
