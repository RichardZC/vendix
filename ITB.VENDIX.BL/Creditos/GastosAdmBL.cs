using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ITB.VENDIX.BE;

namespace ITB.VENDIX.BL
{
    public class GastosAdmBL : Repositorio<GastosAdm>
    {
        public static decimal CalcularGastosAdm(decimal pImporte)
        {
            decimal gastos = 0;
            var lstgastos = Listar(x => x.Estado && x.MontoMinimo < pImporte && x.MontoMaximo >= pImporte);
            
            foreach (var item in lstgastos)
            {
                if (item.IndPorcentaje)
                    gastos += pImporte*(item.Valor/100);
                else
                    gastos += item.Valor;
            }
            return Math.Round(gastos, 2);
        }
    }
}
