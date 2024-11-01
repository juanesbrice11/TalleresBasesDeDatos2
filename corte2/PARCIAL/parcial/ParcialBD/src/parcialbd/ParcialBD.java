package conexionbd;

import java.math.BigDecimal;
import java.sql.*;

public class ParcialBD {

    public static void main(String[] args) {
        try {
            Class.forName("org.postgresql.Driver");
            Connection conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5433/postgres", "postgres", "Jeb11072004");

            CallableStatement obtenerTarjetas = conexion.prepareCall("{? = call obtener_tarjetas_con_detalle_usuario(?)}");
            CallableStatement obtenerPagosMenores = conexion.prepareCall("{? = call obtener_pagos_menores_a_1000(?)}");

            obtenerTarjetas.registerOutParameter(1, Types.VARCHAR);
            obtenerTarjetas.setInt(2, 1); 

            obtenerPagosMenores.registerOutParameter(1, Types.VARCHAR);
            obtenerPagosMenores.setDate(2, Date.valueOf("2023-09-01")); 

            obtenerTarjetas.execute();
            obtenerPagosMenores.execute();

            String resultadoTarjetas = obtenerTarjetas.getString(1);
            String resultadoPagos = obtenerPagosMenores.getString(1);

            System.out.println("Detalles de las tarjetas: " + resultadoTarjetas);
            System.out.println("Pagos menores a 1000: " + resultadoPagos);

            obtenerTarjetas.close();
            obtenerPagosMenores.close();
            conexion.close();

        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
}
