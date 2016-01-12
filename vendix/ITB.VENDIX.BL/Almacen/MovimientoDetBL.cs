using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ITB.VENDIX.BE;

namespace ITB.VENDIX.BL
{
    public class MovimientoDetBL:Repositorio<MovimientoDet>
    {
        public static bool EliminarDetalle(int pMovimientoDetId)
        {
            using (var db = new VENDIXEntities())
            {
                db.usp_EliminarMovimientoDet(pMovimientoDetId);
                return true;
            }
        }

        public static bool CrearDetalle(int pMovimientoId, int pMovimientoDetId, int pArticuloId, bool pIndAutogenerar, 
                                    string pListaSerie, int pCantidad, bool pIndCorrelativo, decimal pPrecioUnitario, decimal pDescuento, int pMedida)
        {
            using (var db = new VENDIXEntities())
            {
                db.usp_CrearMovimientoDet(pMovimientoId, pMovimientoDetId, pArticuloId, pIndAutogenerar,  pListaSerie, pCantidad,
                                          pIndCorrelativo, pPrecioUnitario, pDescuento, pMedida);
            }
            return true;
        }
    }
}
