﻿using System;
using System.Data;
using System.Collections.Generic;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;
using ITB.VENDIX.BE;


namespace ITB.VENDIX.BL
{
    public class OrdenVentaBL:Repositorio<OrdenVenta>
    {
        public static List<OrdenVentaBuscar> LstOrdenesVentaJGrid(GridDataRequest request, ref int pTotalItems)
        {

            var sClave = request.DataFilters()["Buscar"];
            var sfiltro = bool.Parse(request.DataFilters()["Entregado"]) ? "Estado==\"ENT\" || Estado==\"ANU\"" : "Estado==\"PEN\" || Estado==\"ENV\"";
            
            using (var db = new VENDIXEntities())
            {
                IQueryable<OrdenVentaBuscar> query =
                    from ov in db.OrdenVenta
                    join c in db.Credito on ov.OrdenVentaId equals c.OrdenVentaId into gj from subpet in gj.DefaultIfEmpty()
                    select new OrdenVentaBuscar
                               {
                                   OrdenVentaId = ov.OrdenVentaId,
                                   FechaReg = ov.FechaReg,
                                   Cliente = ov.Persona.NombreCompleto,
                                   TotalNeto = ov.TotalNeto,
                                   TotalDescuento = ov.TotalDescuento,
                                   TipoVenta = ov.TipoVenta,
                                   Estado = ov.Estado,
                                   Tags = SqlFunctions.StringConvert((double) ov.OrdenVentaId) + " " + ov.Persona.NombreCompleto,
                                   EstadoCredito = (subpet == null ? String.Empty : subpet.Estado)
                               };
                query = query.Where(sfiltro);

                if (sClave != string.Empty)
                {
                    DateTime fecha;
                    query = DateTime.TryParse(sClave, out fecha) 
                        ? query.Where(x => EntityFunctions.TruncateTime(x.FechaReg) == fecha.Date) 
                        : query.Where("Tags.Contains(\"" + sClave + "\")");
                }

                pTotalItems = query.Count();
                return query.OrderBy(request.sidx + " " + request.sord)
                    .Skip((request.page - 1) * request.rows).Take(request.rows).ToList();
            }
        }


        

        public static bool EnviarOrdenVentaCredito(int pOrdenVentaId)
        {
            var orden = Obtener(pOrdenVentaId);
            var glosa = string.Empty;
            decimal inicial = orden.TotalNeto * (decimal)0.15;
            decimal montocredito = orden.TotalNeto - inicial;
            int productoId = 1;
            var gastosadm = GastosAdmBL.CalcularGastosAdm(montocredito);
            var lstdes =
                OrdenVentaDetBL.Listar(x => x.Estado && x.OrdenVentaId == orden.OrdenVentaId).Select(x => x.Descripcion)
                    .ToList();
            for (int i = 0; i < lstdes.Count; i++)
            {
                glosa += lstdes[i];
                if (i != lstdes.Count - 1)
                    glosa += ", " + Environment.NewLine;
            }
            var oCredito = new Credito
                               {
                                   OficinaId = VendixGlobal.GetOficinaId(),
                                   PersonaId = orden.PersonaId,
                                   Descripcion = glosa,
                                   MontoProducto = orden.TotalNeto,
                                   MontoInicial = inicial,
                                   MontoCredito = montocredito,
                                   ProductoId = productoId,
                                   MontoGastosAdm = gastosadm,
                                   Estado = "CRE",
                                   FormaPago = "D",
                                   NumeroCuotas = 26,
                                   InteresMensual = 7,
                                   FechaPrimerPago = DateTime.Now,
                                   FechaVencimiento = DateTime.Now,
                                   FechaReg = DateTime.Now,
                                   UsuarioRegId = VendixGlobal.GetUsuarioId(),
                                   OrdenVentaId = pOrdenVentaId
                               };
            
            using (var scope = new TransactionScope())
            {
                try
                {
                    CreditoBL.Crear(oCredito);
                    orden.Estado = "ENV";
                    orden.TipoVenta = "CRE";
                    Actualizar(orden);

                    scope.Complete();
                }
                catch (Exception ex)
                {
                    scope.Dispose();
                    throw new Exception(ex.InnerException.Message);
                }
            }
            return true;
        }

        public static bool EnviarOrdenVentaContado(int pOrdenVentaId)
        {
            var orden = Obtener(pOrdenVentaId);
            orden.Estado = "ENV";
            orden.TipoVenta = "CON";
            Actualizar(orden);

            //var cxc = new CuentaxCobrar()
            //              {
            //                  PersonaId = orden.PersonaId,
            //                  Operacion = "CON",
            //                  Origen = "ORDEN " + pOrdenVentaId.ToString(),
            //                  Monto = orden.TotalNeto,
            //                  Estado = "PEN",
            //                  FechaReg = DateTime.Now,
            //                  UsuarioRegId = VendixGlobal.GetUsuarioId()
            //              };
            
            //using (var scope = new TransactionScope())
            //{
            //    try
            //    {
            //        //CuentaxCobrarBL.Crear(cxc);
            //        //orden.CuentaxCobrarId = cxc.CuentaxCobrarId;
            //        orden.Estado = "ENV";
            //        orden.IndContado = true;
            //        orden.IndCredito = false;
            //        Actualizar(orden);
                    
            //        scope.Complete();
            //    }
            //    catch (Exception ex)
            //    {
            //        scope.Dispose();
            //        throw new Exception(ex.InnerException.Message);
            //    }
            //}
            return true;
        }

        public static int EliminarOrdenVenta(int pOrdenVentaId)
        {
            using (var scope = new TransactionScope())
            {
                try
                {
                    int ret;
                    using (var db = new VENDIXEntities())
                    {
                        ret = db.usp_OrdenVenta_Del(pOrdenVentaId, 0);
                    }

                    scope.Complete();
                    return ret;
                }
                catch (Exception ex)
                {
                    scope.Dispose();
                    throw new Exception(ex.InnerException.Message);
                }
            }
        }

        public class OrdenVentaBuscar : OrdenVenta
        {
            public string Cliente { get; set; }
            public string Tags { get; set; }
            public string EstadoCredito { get; set; }
        }
    }
}