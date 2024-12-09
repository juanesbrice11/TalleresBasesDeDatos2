package com.mycompany.taller19;

import org.bson.Document;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import static com.mongodb.client.model.Filters.*;
import static com.mongodb.client.model.Updates.*;
import com.mongodb.client.MongoClients;
import java.util.Arrays;

public class Taller19 {

    private static final String URI = "mongodb://localhost:27017";
    private static final String DATABASE_NAME = "taller19";

    public static void main(String[] args) {
        MongoClient mongoClient = MongoClients.create(URI);
        MongoDatabase database = mongoClient.getDatabase(DATABASE_NAME);

        insertCategorias(database);
        insertComentarios(database);
        insertProductos(database);

        updateProductos(database);
        updateComentarios(database);
        updateCategorias(database);
        eliminarCategorias(database);

        mostrarProductosConPrecioMayor(database, 10);
        mostrarProductosPorCategoriaYPrecio(database, "Libros", 50);
    }

    private static void insertCategorias(MongoDatabase database) {
        MongoCollection<Document> collection = database.getCollection("categorias");
        Document cat1 = new Document("categoria_id", 1).append("nombre_categoria", "Libros");
        Document cat2 = new Document("categoria_id", 2).append("nombre_categoria", "Juguetes");
        Document cat3 = new Document("categoria_id", 3).append("nombre_categoria", "Muebles");
        collection.insertMany(Arrays.asList(cat1, cat2, cat3));
        System.out.println("Categorías insertadas.");
    }

    private static void insertComentarios(MongoDatabase database) {
        MongoCollection<Document> collection = database.getCollection("comentarios");
        Document com1 = new Document("comentario_id", 1).append("texto", "Muy interesante").append("cliente", "Carlos");
        Document com2 = new Document("comentario_id", 2).append("texto", "Divertido").append("cliente", "Maria");
        Document com3 = new Document("comentario_id", 3).append("texto", "Muy cómodo").append("cliente", "Pedro");
        collection.insertMany(Arrays.asList(com1, com2, com3));
        System.out.println("Comentarios insertados.");
    }

    private static void insertProductos(MongoDatabase database) {
        MongoCollection<Document> collection = database.getCollection("productos");
        Document prod1 = new Document("producto_id", 1)
                .append("nombre", "novela")
                .append("descripcion", "Novela de misterio")
                .append("precio", 15)
                .append("categoria", new Document("categoria_id", 1).append("nombre_categoria", "Libros"))
                .append("comentarios", Arrays.asList(
                        new Document("comentario_id", 1).append("texto", "Muy interesante"),
                        new Document("comentario_id", 2).append("texto", "Divertido")));
        collection.insertMany(Arrays.asList(prod1));
        System.out.println("Productos insertados.");
    }

    private static void updateProductos(MongoDatabase database) {
        MongoCollection<Document> collection = database.getCollection("productos");
        collection.updateOne(eq("producto_id", 1), set("descripcion", "Novela de misterio con giros inesperados"));
        System.out.println("Productos actualizados.");
    }

    private static void updateComentarios(MongoDatabase database) {
        MongoCollection<Document> collection = database.getCollection("productos");
        collection.updateOne(eq("comentarios.comentario_id", 1), set("comentarios.$.texto", "Muy interesante y atrapante"));
        System.out.println("Comentarios actualizados.");
    }

    private static void updateCategorias(MongoDatabase database) {
        MongoCollection<Document> collection = database.getCollection("productos");
        collection.updateOne(eq("categoria.categoria_id", 1), set("categoria.nombre_categoria", "Libros de ficción"));
        System.out.println("Categorías actualizadas.");
    }

    private static void eliminarCategorias(MongoDatabase database) {
        MongoCollection<Document> collection = database.getCollection("categorias");
        collection.deleteOne(eq("categoria_id", 3));
        System.out.println("Categoría eliminada.");
    }

    private static void mostrarProductosConPrecioMayor(MongoDatabase database, int precio) {
        MongoCollection<Document> collection = database.getCollection("productos");
        MongoCursor<Document> cursor = collection.find(gt("precio", precio)).iterator();
        System.out.println("Productos con precio mayor a " + precio + ":");
        while (cursor.hasNext()) {
            System.out.println(cursor.next().toJson());
        }
    }

    private static void mostrarProductosPorCategoriaYPrecio(MongoDatabase database, String categoria, int precio) {
        MongoCollection<Document> collection = database.getCollection("productos");
        MongoCursor<Document> cursor = collection.find(and(eq("categoria.nombre_categoria", categoria), gt("precio", precio))).iterator();
        System.out.println("Productos en categoría '" + categoria + "' con precio mayor a " + precio + ":");
        while (cursor.hasNext()) {
            System.out.println(cursor.next().toJson());
        }
    }
}
