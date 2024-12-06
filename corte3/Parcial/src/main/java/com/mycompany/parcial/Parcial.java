/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 */

package com.mycompany.parcial;

import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Accumulators;
import com.mongodb.client.model.Aggregates;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import com.mongodb.client.AggregateIterable;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoClient;

import java.util.Arrays;
import java.util.Scanner;
import org.bson.Document;


public class Parcial {
    
    private static final String uri = "mongodb://localhost:27017";
    private static final MongoClient mongoClient = MongoClients.create(uri);
    private static final MongoDatabase database = mongoClient.getDatabase("Parcial");
    private static final MongoCollection<org.bson.Document> collectionProductos = database.getCollection("productos");
    private static final MongoCollection<org.bson.Document> collectionPedidos = database.getCollection("pedidos");
    private static final MongoCollection<org.bson.Document> collectionDetalles = database.getCollection("detalle_pedidos");
    private static final MongoCollection<org.bson.Document> collectionReservas = database.getCollection("reservas");

    private static final RedSocial redSocial = new RedSocial("bolt://localhost:7687", "neo4j", "123");
    
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int opcion = 0;

        do {
            System.out.println("==== Menú Principal ====");
            System.out.println("1. Ejecutar Punto 1");
            System.out.println("2. Ejecutar Punto 2");
            System.out.println("3. Ejecutar Punto 3");
            System.out.println("4. Ejecutar Punto 4");
            System.out.println("5. Ejecutar Punto 5");
            System.out.println("6. Salir");
            System.out.print("Seleccione una opción: ");
            
            opcion = scanner.nextInt();
            
            switch (opcion) {
                case 1 -> Punto1();
                case 2 -> Punto2();
                case 3 -> Punto3();
                case 4 -> Punto4();
                case 5 -> Punto5();
                case 6 -> System.out.println("Salir");
                default -> System.out.println("Opción no válida.");
            }
        } while (opcion != 6);

        scanner.close();
    }
    
    public static void Punto1(){
        
        
        CrearProducto("Producto001", "Camiseta de algodón", "Camiseta 1000% algodon, disponible en varios colores", 15.99, 200);       
        CrearPedido("Pedido001", "Cliente001", "2024-12-02T14:00:00Z", "Enviado",31.98);
        CrearDetallePedido("Detalle001","Detalle001", "Producto001", 2, 15.99);
        
        actualizarProducto("Producto001", "precio", 200.00);
        actualizarPedido("Pedido001", "estado", "Pendiente");
        actualizarDetallePedido("Detalle001", "cantidad", 6);
        
        System.out.println("Creaciones:");
        
        leerDetallesPedidos();
        leerPedidos();
        leerProductos();
        
        eliminarPedido("Pedido001");
        eliminarDetallePedido("Detalle001");
        eliminarProducto("Producto001");
        
        //aqui ya no aparecen pedidos ya que estan eliminados
        leerDetallesPedidos();
        leerPedidos();
        leerProductos();

        
    }
    
    /// INICIO PUNTO 1
    
    public static void CrearProducto(String id, String nombre, String descripcion, double precio, int stock){
        Document producto = new Document( "_id",id)
        .append("Nombre", nombre)
        .append("Descripcion", descripcion)
        .append("Precio",precio)
        .append("Stock", stock);
        collectionProductos.insertOne(producto);
    }
    
    public static void leerProductos() {
        FindIterable<Document> productos = collectionProductos.find();
        System.out.println("Productos:");
        for (Document producto : productos) {
            System.out.println(producto.toJson());
        }
    }
    
    public static void actualizarProducto(String id, String campo, Object valor) {
        collectionProductos.updateOne(Filters.eq("_id", id), new Document("$set", new Document(campo, valor)));
    }
    
    
    public static void eliminarProducto(String id) {
        collectionProductos.deleteOne(Filters.eq("_id", id));
    }
    
    public static void leerPedidos() {
        FindIterable<Document> pedidos = collectionPedidos.find();
        System.out.println("Pedidos:");
        for (Document pedido : pedidos) {
            System.out.println(pedido.toJson());
        }
    }
    
    
        public static void CrearPedido(String id, String cliente, String fecha_pedido, String estado, double total){
        Document producto = new Document( "_id",id)
        .append("cliente", cliente)
        .append("fecha_pedido", fecha_pedido)
        .append("estado", estado)
        .append("total", total);
        collectionPedidos.insertOne(producto);
    }
        
    public static void actualizarPedido(String id, String campo, Object valor) {
        collectionPedidos.updateOne(Filters.eq("_id", id), new Document("$set", new Document(campo, valor)));
    }
    
    public static void eliminarPedido(String id) {
        collectionPedidos.deleteOne(Filters.eq("_id", id));
    }
    
        
    public static void leerDetallesPedidos() {
        FindIterable<Document> detalles = collectionDetalles.find();
        System.out.println("Detalles de Pedidos:");
        for (Document detalle : detalles) {
            System.out.println(detalle.toJson());
        }
    }
    
    
    public static void CrearDetallePedido(String id, String pedido_id, String producto_id, int cantidad, double precio_unitario){
        Document producto = new Document( "_id",id)
        .append("pedido_id", pedido_id)
        .append("producto_id", producto_id)
        .append("cantidad", cantidad)
        .append("precio_unitario", precio_unitario);
        collectionDetalles.insertOne(producto);
    }
    
    public static void actualizarDetallePedido(String id, String campo, Object valor) {
        collectionDetalles.updateOne(Filters.eq("_id", id), new Document("$set", new Document(campo, valor)));
    }
    
    public static void eliminarDetallePedido(String id) {
        collectionDetalles.deleteOne(Filters.eq("_id", id));
    }
    
    /// FIN PUNTO 1 ///
    
    //Punto 2
    
    public static void Punto2(){
        obtenerProductosConPrecioMayorA20();
        obtenerPedidosMayorA100();
        obtenerPedidosConDetalleProducto("Producto001");
    }
    
    
    
    public static void obtenerProductosConPrecioMayorA20() {
        System.out.println("Productos con precio mayor a $20:");
        collectionProductos.find(Filters.gt("precio", 20)).forEach(producto -> leerProducto(producto));
    }

    public static void obtenerPedidosMayorA100() {
        System.out.println("Pedidos con total mayor a $100:");
        collectionPedidos.find(Filters.gt("total", 100)).forEach(pedido -> leerPedido(pedido));
    }

    private static void leerProducto(Document producto) {
        System.out.println("Producto: ");
        System.out.println("Id: " + producto.getString("_id"));
        System.out.println("Nombre: " + producto.getString("nombre"));
        System.out.println("Descripción: " + producto.getString("descripcion"));
        System.out.println("Precio: " + producto.getDouble("precio"));
        System.out.println("Stock: " + producto.getInteger("stock"));
    }



    private static void leerPedido(Document pedido) {
        System.out.println("ID: " + pedido.getString("_id"));
        System.out.println("Cliente: " + pedido.getString("cliente"));
        System.out.println("Fecha del pedido: " + pedido.getString("fecha_pedido"));
        System.out.println("Estado: " + pedido.getString("estado"));
        System.out.println("Total: " + pedido.getDouble("total"));
    }

    public static void obtenerPedidosConDetalleProducto(String productoId) {
        System.out.println("Pedidos con detalles que contienen el producto: " + productoId);
        collectionDetalles.find(Filters.eq("producto_id", productoId)).forEach(detalle -> {
            String pedidoId = detalle.getString("pedido_id");
            Document pedido = collectionPedidos.find(Filters.eq("_id", pedidoId)).first();
            if (pedido != null) {
                leerPedido(pedido);
            }
        });
    }
    
    /// FIN PUNTO 2

    ///PUNTO 3
    
    public static void Punto3(){
        crearReserva("reserva001", "Ana Gómez", "ana.gomez@example.com", "+54111223344", "Calle Ficticia 123, Buenos Aires, Argentina", 
           "Suite", 101, 200.00, 2, "Suite con vista al mar, cama king size, baño privado y balcón.", "2024-12-15T14:00:00Z", 
            "2024-12-18T12:00:00Z",740.00, "Pagado", "Tarjeta de Crédito", "2024-11-30T10:00:00Z"
        );
        
        leerReservas();
        
        actualizarReserva("reserva001", 750.00, "Pendiente", "2024-12-01T10:00:00Z" );
        
        leerReservas();

        eliminarReserva("reserva001");
        
        eliminarReserva("reserva001");

    }
    
    public static void crearReserva(String id, String nombreCliente, String correoCliente, String telefonoCliente, 
                                    String direccionCliente, String tipoHabitacion, int numeroHabitacion, 
                                    double precioNoche, int capacidad, String descripcionHabitacion, 
                                    String fechaEntrada, String fechaSalida, double total, 
                                    String estadoPago, String metodoPago, String fechaReserva) {

        Document cliente = crearCliente(nombreCliente, correoCliente, telefonoCliente, direccionCliente);
        Document habitacion = crearHabitacion(tipoHabitacion, numeroHabitacion, precioNoche, capacidad, descripcionHabitacion);

        Document reserva = new Document("_id", id)
                .append("cliente", cliente)
                .append("habitacion", habitacion)
                .append("fecha_entrada", fechaEntrada)
                .append("fecha_salida", fechaSalida)
                .append("total", total)
                .append("estado_pago", estadoPago)
                .append("metodo_pago", metodoPago)
                .append("fecha_reserva", fechaReserva);

        collectionReservas.insertOne(reserva);
        System.out.println("Reserva creada exitosamente.");
    }

    private static Document crearCliente(String nombre, String correo, String telefono, String direccion) {
        return new Document("nombre", nombre)
                .append("correo", correo)
                .append("telefono", telefono)
                .append("direccion", direccion);
    }

    private static Document crearHabitacion(String tipo, int numero, double precioNoche, int capacidad, String descripcion) {
        return new Document("tipo", tipo)
                .append("numero", numero)
                .append("precio_noche", precioNoche)
                .append("capacidad", capacidad)
                .append("descripcion", descripcion);
    }

    public static void leerReservas() {
        System.out.println("\nReservas en la base de datos:");
        for (Document reserva : collectionReservas.find()) {
            System.out.println("ID Reserva: " + reserva.getString("_id"));
            System.out.println("Cliente: " + reserva.get("cliente"));
            System.out.println("Habitación: " + reserva.get("habitacion"));
            System.out.println("Fecha Entrada: " + reserva.getString("fecha_entrada"));
            System.out.println("Fecha Salida: " + reserva.getString("fecha_salida"));
            System.out.println("Total: " + reserva.getDouble("total"));
            System.out.println("Estado de Pago: " + reserva.getString("estado_pago"));
        }
    }

    public static void actualizarReserva(String id, double nuevoTotal, String nuevoEstadoPago, String nuevaFechaReserva) {
        collectionReservas.updateOne(
            Filters.eq("_id", id),
            Updates.combine(
                Updates.set("total", nuevoTotal),
                Updates.set("estado_pago", nuevoEstadoPago),
                Updates.set("fecha_reserva", nuevaFechaReserva)
            )
        );
        System.out.println("Reserva actualizada exitosamente.");
    }

    public static void eliminarReserva(String id) {
        collectionReservas.deleteOne(Filters.eq("_id", id));
        System.out.println("Reserva eliminada exitosamente.");
    }
    
    
    //Punto 4
    
    public static void Punto4(){
        obtenerHabitacionesReservadasTipoSencillas();
        obtenerSumatoriaTotalReservasPagadas();
        obtenerReservasPorPrecioNocheMayorA100();
    }
    
    public static void obtenerHabitacionesReservadasTipoSencillas() {
    System.out.println("Habitaciones Reservadas de tipo sencilla");
    for (Document reserva : collectionReservas.find(Filters.eq("habitacion.tipo", "Sencilla"))) {
        System.out.println("ID Reserva: " + reserva.getString("_id"));
        System.out.println("Cliente: " + reserva.get("cliente"));
        System.out.println("Habitación: " + reserva.get("habitacion"));
        System.out.println("Fecha Entrada: " + reserva.getString("fecha_entrada"));
        System.out.println("Fecha Salida: " + reserva.getString("fecha_salida"));
        }
    }
    
    public static void obtenerSumatoriaTotalReservasPagadas() {
    AggregateIterable<Document> resultado = collectionReservas.aggregate(Arrays.asList(
        Aggregates.match(Filters.eq("estado_pago", "Pagado")), 
        Aggregates.group(null, Accumulators.sum("total_pagado", "$total")) 
    ));

        for (Document doc : resultado) {
            System.out.println("Sumatoria total de las reservas pagadas: " + doc.getDouble("total_pagado"));
        }
    }

        public static void obtenerReservasPorPrecioNocheMayorA100() {
            System.out.println("Reservas de habitaciones con precio noche mayor a 100 dólares:");
            for (Document reserva : collectionReservas.find(Filters.gt("habitacion.precio_noche", 100))) {
                System.out.println("Id Reserva: " + reserva.getString("_id"));
                System.out.println("Cliente: " + reserva.get("cliente"));
                System.out.println("Habitación: " + reserva.get("habitacion"));
                System.out.println("Fecha Entrada: " + reserva.getString("fecha_entrada"));
                System.out.println("Fecha Salida: " + reserva.getString("fecha_salida"));
                System.out.println("Total: " + reserva.getDouble("total"));
            }
    }

    public static void Punto5(){
        redSocial.crearPersona("Juansito", "juansito@example.com", 22, "Manizales");
        redSocial.crearPersona("Pedrito", "pedrito@example.com", 19, "Manizales");

        redSocial.crearRelacionComentario("Juansito", "Pedrito", "Relacion creada");

        redSocial.close();
    }
}
