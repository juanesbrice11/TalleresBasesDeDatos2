CREATE TABLE factura (
    codigo INT PRIMARY KEY,
    cliente VARCHAR(100),
    producto VARCHAR(100),
    valor_unitario DECIMAL(10, 2),
    valor_total DECIMAL(10, 2),
    numero_fe BIGINT
);

CREATE SEQUENCE seq_codigo_factura
START WITH 1 
INCREMENT BY 1; 


CREATE SEQUENCE seq_facturacion_electronica
START WITH 100 
INCREMENT BY 100; 

INSERT INTO factura (codigo, cliente, producto, valor_unitario, valor_total, numero_fe)
VALUES 
(nextval('seq_codigo_factura'), 'Cliente 1', 'Producto A', 500.00, 1000.00, nextval('seq_facturacion_electronica')),
(nextval('seq_codigo_factura'), 'Cliente 2', 'Producto B', 700.00, 1400.00, nextval('seq_facturacion_electronica')),
(nextval('seq_codigo_factura'), 'Cliente 3', 'Producto C', 300.00, 600.00, nextval('seq_facturacion_electronica')),
(nextval('seq_codigo_factura'), 'Cliente 4', 'Producto D', 900.00, 1800.00, nextval('seq_facturacion_electronica')),
(nextval('seq_codigo_factura'), 'Cliente 5', 'Producto E', 1000.00, 2000.00, nextval('seq_facturacion_electronica')),
(nextval('seq_codigo_factura'), 'Cliente 6', 'Producto F', 600.00, 1200.00, nextval('seq_facturacion_electronica')),
(nextval('seq_codigo_factura'), 'Cliente 7', 'Producto G', 800.00, 1600.00, nextval('seq_facturacion_electronica')),
(nextval('seq_codigo_factura'), 'Cliente 8', 'Producto H', 400.00, 800.00, nextval('seq_facturacion_electronica')),
(nextval('seq_codigo_factura'), 'Cliente 9', 'Producto I', 200.00, 400.00, nextval('seq_facturacion_electronica')),
(nextval('seq_codigo_factura'), 'Cliente 10', 'Producto J', 1200.00, 2400.00, nextval('seq_facturacion_electronica'));

