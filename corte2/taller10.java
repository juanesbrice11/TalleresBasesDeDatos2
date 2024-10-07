
package conexionbd;
import java.math.BigDecimal;
import java.sql.*;


public class ConexionBD {

    public static void main(String[] args) {
       try {
            Class.forName("org.postgresql.Driver");
            Connection conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5433/postgres","postggres","Jeb11072004");
            
            CallableStatement generarAuditoria = conexion.prepareCall("call taller5.generar_auditoria(?,?)");
            CallableStatement simularVentasMes = conexion.prepareCall("call taller5.simular_ventas_mes()");

            
            generarAuditoria.setDate(1, java.sql.Date.valueOf("2024-01-05"));
            generarAuditoria.setDate(2, java.sql.Date.valueOf("2024-11-02"));
            
            
            CallableStatement transaccionesTotalMes = conexion.prepareCall("{ call taller6.transacciones_total_mes(?,?) }");
            CallableStatement serviciosNoPagados = conexion.prepareCall("{ call taller6.servicios_no_pagados(?) }");
            
            serviciosNoPagados.setString(1, "401");
            
            generarAuditoria.execute();
            simularVentasMes.execute();

            ResultSet resultadoTransacciones = transaccionesTotalMes.executeQuery();
            ResultSet serviciosSinPagar = serviciosNoPagados.executeQuery();
            BigDecimal totalTransacciones = new BigDecimal(0);
            BigDecimal totalServiciosSinPagar = new BigDecimal(0);
            while(resultadoTransacciones.next()){
               totalTransacciones = resultadoTransacciones.getBigDecimal(1);
            }
            while (serviciosSinPagar.next()) {
                totalServiciosSinPagar = serviciosSinPagar.getBigDecimal(1);
               
            }
            System.out.println(totalTransacciones);
            System.out.println(totalServiciosSinPagar);
            
            generarAuditoria.close();
            simularVentasMes.close();
            transaccionesTotalMes.close();
            serviciosNoPagados.close();
            conexion.close();

            
        } catch (Exception e) {
            System.out.println("Error "+ e.getMessage());
        }
    }
    
}