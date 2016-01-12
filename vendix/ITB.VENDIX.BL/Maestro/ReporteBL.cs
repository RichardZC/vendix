using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ITB.VENDIX.BE;

namespace ITB.VENDIX.BL
{
    public class ReporteBL
    {
        
        public static List<ReporteListaPrecioGeneral> ListarReporteListaPrecio(int? pMarcaId,bool indDescuento, bool pIndPuntos)
        {
            var filtro = "Estado";
            using (var db = new VENDIXEntities())
            {
                
                if (pMarcaId.HasValue)
                    filtro += " && Articulo.Modelo.MarcaId = " + pMarcaId.Value.ToString();
                if (indDescuento)
                    filtro += " && Descuento > 0";
                if (pIndPuntos)
                    filtro += " && PuntosCanje > 0 ";

                var qry = db.ListaPrecio.Where(filtro).Select(
                    x => new ReporteListaPrecioGeneral
                             {
                                 ArticuloId = x.ArticuloId,
                                 TipoArticulo = x.Articulo.TipoArticulo.Denominacion,
                                 ArticuloDes = x.Articulo.Denominacion,
                                 Monto = x.Monto.Value,
                                 Descuento = x.Descuento,
                                 PuntosCanje = x.PuntosCanje
                             }).OrderBy(x=>x.TipoArticulo);
                return qry.ToList();
            }
        }
        public static List<usp_ReporteStock_Result> ListarReporteStockGeneral(int? pOficinaId)
        {
            using (var db = new VENDIXEntities())
            {
                return db.usp_ReporteStock(pOficinaId).ToList();
            }
        }
        public static List<usp_RptCredito_Result> ListarReporteCredito(int? pOficinaId,DateTime pFechaIni, DateTime pFechaFin)
        {
            using (var db = new VENDIXEntities())
            {
                return db.usp_RptCredito(pOficinaId,pFechaIni, pFechaFin).ToList();
            }
        }
        public static List<usp_RptRentabilidadVenta_Result> ListarReporteRentabilidadVenta(DateTime pFechaIni, DateTime pFechaFin, bool indContado, bool indCredito, int? pOficinaId)
        {
            using (var db = new VENDIXEntities())
            {
                return db.usp_RptRentabilidadVenta(pFechaIni, pFechaFin, indContado, indCredito, pOficinaId).ToList();
            }
        }
    }

    public class ReporteListaPrecioGeneral:ListaPrecio
    {
        public string TipoArticulo { get; set; }
        public string ArticuloDes { get; set; }
    }
    
}
