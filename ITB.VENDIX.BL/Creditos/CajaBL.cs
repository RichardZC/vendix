using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ITB.VENDIX.BE;

namespace ITB.VENDIX.BL
{
    public class CajaBL : Repositorio<Caja>
    {
        public static List<CajaDiarioOficina> LstCajaDiarioOficina()
        {
            var oficina = VendixGlobal.GetOficinaId();
            using (var db = new VENDIXEntities())
            {
                var query = from c in db.CajaDiario
                            where c.Caja.OficinaId == oficina && c.TransBoveda == false
                            select new CajaDiarioOficina
                                       {
                                           CajaDiarioId = c.CajaId,
                                           NombreCaja = c.Caja.Denominacion,
                                           IndCierre = c.IndCierre,
                                           Cajero = c.Usuario.Persona.NombreCompleto,
                                           FechaIniOperacion = c.FechaIniOperacion,
                                           FechaFinOperacion = c.FechaFinOperacion,
                                           SaldoInicial = c.SaldoInicial,
                                           Entradas = c.Entradas,
                                           Salidas = c.Salidas,
                                           SaldoFinal = c.SaldoFinal
                                       };
                return query.ToList();
            }
        }
        
        public static List<usp_UsuariosNoAsignadosCaja_Result> ListaUsuariosNoAsignado()
        {
            using (var db = new VENDIXEntities())
            {
                return db.usp_UsuariosNoAsignadosCaja(VendixGlobal.GetOficinaId()).ToList();
            }
        }
        
       //public static List<ItemCombo> ListaCajas()
       // {
       //     using (var db = new VENDIXEntities())
       //     {
       //         var query = from c in db.Caja
       //                     where c.Estado && c.IndAbierto == false
       //                     select new ItemCombo
       //                     {
       //                         id = c.CajaId,
       //                         value = c.Denominacion
       //                     };
       //         return query.ToList();
       //     }
       // }

    }

    public class CajaDiarioOficina : CajaDiario
    {
        public string NombreCaja { get; set; }
        public string Cajero { get; set; }
    }
}
