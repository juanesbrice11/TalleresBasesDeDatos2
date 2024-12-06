/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.parcial;

import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.Driver;
import org.neo4j.driver.GraphDatabase;
import org.neo4j.driver.Session;

public class RedSocial {
    private final Driver driver;

    // Constructor para inicializar la conexión a la base de datos
    public RedSocial(String uri, String user, String password) {
        driver = GraphDatabase.driver(uri, AuthTokens.basic(user, password));
    }

    // Cerrar el driver cuando se termine de usar
    public void close() {
        driver.close();
    }

    // Método para crear un nodo Persona
    public void crearPersona(String nombre, String correo, int edad, String ciudad) {
        try (Session session = driver.session()) {
            session.writeTransaction(tx -> {
                tx.run("CREATE (:Persona {nombre: $nombre, correo: $correo, edad: $edad, ciudad: $ciudad})",
                        org.neo4j.driver.Values.parameters(
                                "nombre", nombre,
                                "correo", correo,
                                "edad", edad,
                                "ciudad", ciudad
                        ));
                return null;
            });
            System.out.println("Persona creada: " + nombre);
        }
    }

    // Método para crear una relación Comentario entre dos personas
    public void crearRelacionComentario(String nombre1, String nombre2, String descripcion) {
        try (Session session = driver.session()) {
            session.writeTransaction(tx -> {
                tx.run("MATCH (p1:Persona {nombre: $nombre1}), (p2:Persona {nombre: $nombre2}) " +
                        "CREATE (p1)-[:COMENTARIO {descripcion: $descripcion}]->(p2)",
                        org.neo4j.driver.Values.parameters(
                                "nombre1", nombre1,
                                "nombre2", nombre2,
                                "descripcion", descripcion
                        ));
                return null;
            });
            System.out.println("Relación comentario creada: " + nombre1 + " -> " + nombre2);
        }
    }
    
}