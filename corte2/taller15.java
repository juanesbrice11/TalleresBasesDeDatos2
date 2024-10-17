import java.sql.*;

public class taller15 {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5433/libros";
        String user = "postgres";
        String password = "Jeb11072004";

        try (Connection con = DriverManager.getConnection(url, user, password)) {
            
            System.out.println("---- Llamada a guardar_libro ----");
            guardarLibro(con, "9781234567890", "<libro><titulo>Nuevo Libro</titulo><autor>Autor Desconocido</autor><anio>2024</anio></libro>");
            
            System.out.println("---- Llamada a actualizar_libro ----");
            actualizarLibro(con, "9781234567890", "<libro><titulo>Nuevo Libro Actualizado</titulo><autor>Autor Actualizado</autor><anio>2024</anio></libro>");
            
            System.out.println("---- Llamada a obtener_autor_libro_por_isbn ----");
            String autorPorIsbn = obtenerAutorPorIsbn(con, "9781234567890");
            System.out.println("Autor por ISBN: " + autorPorIsbn);
            
            System.out.println("---- Llamada a obtener_autor_libro_por_titulo ----");
            String autorPorTitulo = obtenerAutorPorTitulo(con, "Nuevo Libro Actualizado");
            System.out.println("Autor por Título: " + autorPorTitulo);
            
            System.out.println("---- Llamada a obtener_libros_por_anio ----");
            obtenerLibrosPorAnio(con, 2024);

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void guardarLibro(Connection con, String isbn, String descripcionXml) throws SQLException {
        String sql = "{call guardar_libro(?, ?)}";
        try (CallableStatement stmt = con.prepareCall(sql)) {
            stmt.setString(1, isbn);
            stmt.setString(2, descripcionXml);
            stmt.execute();
            System.out.println("Libro guardado con ISBN: " + isbn);
        }
    }

    public static void actualizarLibro(Connection con, String isbn, String descripcionXml) throws SQLException {
        String sql = "{call actualizar_libro(?, ?)}";
        try (CallableStatement stmt = con.prepareCall(sql)) {
            stmt.setString(1, isbn);
            stmt.setString(2, descripcionXml);
            stmt.execute();
            System.out.println("Libro actualizado con ISBN: " + isbn);
        }
    }

    public static String obtenerAutorPorIsbn(Connection con, String isbn) throws SQLException {
        String sql = "{? = call obtener_autor_libro_por_isbn(?)}";
        try (CallableStatement stmt = con.prepareCall(sql)) {
            stmt.registerOutParameter(1, Types.VARCHAR);
            stmt.setString(2, isbn);
            stmt.execute();
            return stmt.getString(1);
        }
    }

    public static String obtenerAutorPorTitulo(Connection con, String titulo) throws SQLException {
        String sql = "{? = call obtener_autor_libro_por_titulo(?)}";
        try (CallableStatement stmt = con.prepareCall(sql)) {
            stmt.registerOutParameter(1, Types.VARCHAR);
            stmt.setString(2, titulo);
            stmt.execute();
            return stmt.getString(1);
        }
    }

    public static void obtenerLibrosPorAnio(Connection con, int anio) throws SQLException {
        String sql = "{call obtener_libros_por_anio(?)}";
        try (CallableStatement stmt = con.prepareCall(sql)) {
            stmt.setInt(1, anio);
            ResultSet rs = stmt.executeQuery();
            
            System.out.println("Libros del año " + anio + ":");
            while (rs.next()) {
                String isbn = rs.getString("isbn");
                String titulo = rs.getString("titulo");
                System.out.println("ISBN: " + isbn + ", Título: " + titulo);
            }
        }
    }
}
