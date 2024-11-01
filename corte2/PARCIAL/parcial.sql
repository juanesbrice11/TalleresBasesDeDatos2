create type estado_enum as enum ('activo', 'inactivo');
create type tipo_tarjeta_enum as enum ('Visa', 'Mastercard');
create type categoria_producto as enum ('Celular', 'PC', 'Televisor');
create type estado_pago_enum as enum ('Exitoso', 'Fallido');

create table Usuarios (
	id serial primary key,
	nombre varchar(50) not null,
	direccion varchar(30) not null,
	email varchar(50) not null,
	fecha_registro date not null,
	estado estado_enum not null
);

create table Tarjetas (
	id serial primary key not null,
	numero_tarjeta varchar not null,
	fecha_expiracion date not null,
	cvv varchar not null,
	tipo_tarjeta tipo_tarjeta_enum not null 
);

create table Productos (
    id integer primary key,
    codigo_producto varchar not null,
    nombre varchar(50) not null,
    porcentaje_impuesto numeric not null,
    monto numeric not null
);

create table Pagos (
	id integer primary key not null,
	codigo_pago varchar not null,
	fecha date not null,
	estado estado_pago_enum not null,
	monto numeric not null,
	producto_id integer not null,
	usuario_id integer not null,
	
	foreign key (producto_id) references Productos(id),
	foreign key (usuario_id) references Usuarios(id)
);

insert into usuarios (nombre, direccion, email, fecha_registro, estado) values 
('juan pérez', 'calle 123', 'juan.perez@example.com', '2023-01-10', 'activo');

insert into usuarios (nombre, direccion, email, fecha_registro, estado) values 
('carla gómez', 'calle 456', 'carla.gomez@example.com', '2023-02-20', 'activo');

insert into usuarios (nombre, direccion, email, fecha_registro, estado) values 
('pedro martínez', 'calle 789', 'pedro.martinez@example.com', '2023-03-15', 'inactivo');

insert into tarjetas (numero_tarjeta, fecha_expiracion, cvv, tipo_tarjeta) values 
('4111111111111111', '2025-12-01', '123', 'visa');

insert into tarjetas (numero_tarjeta, fecha_expiracion, cvv, tipo_tarjeta) values 
('5500000000000004', '2024-11-01', '456', 'mastercard');

insert into tarjetas (numero_tarjeta, fecha_expiracion, cvv, tipo_tarjeta) values 
('4012888888881881', '2026-10-01', '789', 'visa');

insert into productos (id, codigo_producto, nombre, porcentaje_impuesto, monto) values 
(1, 'p001', 'smartphone', 0.18, 500.00);

insert into productos (id, codigo_producto, nombre, porcentaje_impuesto, monto) values 
(2, 'p002', 'laptop', 0.18, 1200.00);

insert into productos (id, codigo_producto, nombre, porcentaje_impuesto, monto) values 
(3, 'p003', 'televisor', 0.18, 800.00);


--Pregunta 1.1

create or replace function obtener_pagos_de_usuario(p_usuario_id integer, p_fecha date)
returns table (codigo_pago varchar, nombre_producto varchar, monto numeric, estado estado_pago_enum) as $$
begin
    return query
    select 
        p.codigo_pago,
        prod.nombre as nombre_producto,
        p.monto,
        p.estado
    from 
        pagos p
    join 
        productos prod on p.producto_id = prod.id
    where 
        p.usuario_id = p_usuario_id 
        and p.fecha = p_fecha;
end;
$$ language plpgsql;

select * from obtener_pagos_de_usuario(1, '2023-06-10');

--Pregunta 1.2

create or replace function obtener_tarjetas_con_pago_mayor_a_1000(p_usuario_id integer)
returns table (nombre_usuario varchar, email varchar, numero_tarjeta varchar, cvv varchar, tipo_tarjeta tipo_tarjeta_enum) as $$
begin
    return query
    select 
        u.nombre as nombre_usuario,
        u.email,
        t.numero_tarjeta,
        t.cvv,
        t.tipo_tarjeta
    from 
        pagos p
    join 
        usuarios u on p.usuario_id = u.id
    join 
        tarjetas t on u.id = p.usuario_id
    where 
        p.usuario_id = p_usuario_id 
        and p.monto > 1000;
end;
$$ language plpgsql;

select * from obtener_tarjetas_con_pago_mayor_a_1000(1);

--Pregunta 2.1

create or replace function obtener_tarjetas_con_detalle_usuario(p_usuario_id integer) returns varchar as $$ 
declare tarjeta_record record; 
resultado varchar := ''; 
tarjeta_cursor cursor for select t.numero_tarjeta, t.fecha_expiracion, u.nombre, u.email from tarjetas t join usuarios u on u.id = p_usuario_id; 
begin 
    open tarjeta_cursor; 
    loop 
        fetch tarjeta_cursor into tarjeta_record; 
        exit when not found; 
        resultado := resultado || 'Número de tarjeta: ' || tarjeta_record.numero_tarjeta || ', Fecha de expiración: ' || tarjeta_record.fecha_expiracion || ', Nombre: ' || tarjeta_record.nombre || ', Email: ' || tarjeta_record.email || '; '; 
    end loop; 
    close tarjeta_cursor; 
    return resultado; 
end; $$ language plpgsql;

select obtener_tarjetas_con_detalle_usuario(1);

--Pregunta 2.2

create or replace function obtener_pagos_menores_a_1000(p_fecha date) returns varchar as $$ 
declare 
    pago_record record; 
    resultado varchar := ''; 
    pago_cursor cursor for select p.monto, p.estado, prod.nombre as nombre_producto, prod.porcentaje_impuesto, u.direccion as usuario_direccion, u.email from pagos p join productos prod on p.producto_id = prod.id join usuarios u on p.usuario_id = u.id where p.fecha = p_fecha and p.monto < 1000; 
begin 
    open pago_cursor; 
    loop 
        fetch pago_cursor into pago_record; 
        exit when not found; 
        resultado := resultado || 'Monto: ' || pago_record.monto || ', Estado: ' || pago_record.estado || ', Nombre Producto: ' || pago_record.nombre_producto || ', Porcentaje Impuesto: ' || pago_record.porcentaje_impuesto || ', Dirección Usuario: ' || pago_record.usuario_direccion || ', Email: ' || pago_record.email || '; '; 
    end loop; 
    close pago_cursor; 
    return resultado; 
end; $$ language plpgsql;

--Pregunta 3.1

create or replace function validaciones_producto()
returns trigger as $$
begin
    if (new.monto <= 0 or new.monto >= 20000) then
        raise exception 'El monto debe ser mayor a 0 y menor a 20000.';
    end if;

    if (new.porcentaje_impuesto <= 0.01 or new.porcentaje_impuesto > 0.20) then
        raise exception 'El porcentaje de impuesto debe ser mayor a 1%% y menor o igual a 20%%.';
    end if;

    return new;
end;
$$ language plpgsql;

create trigger antes_insertar_producto
before insert on productos
for each row
execute procedure validaciones_producto();

--Pregunta 4.1

CREATE SEQUENCE codigo_producto_seq
START WITH 5
INCREMENT BY 5;

INSERT INTO Productos (codigo_producto, nombre, porcentaje_impuesto, monto)
VALUES 
    (CAST(nextval('codigo_producto_seq') AS varchar), 'tablet', 0.18, 1500),
    (CAST(nextval('codigo_producto_seq') AS varchar), 'laptop', 0.18, 1000),
    (CAST(nextval('codigo_producto_seq') AS varchar), 'auriculares', 0.18, 500);

--Pregunta 4.2 

CREATE SEQUENCE codigo_pago_seq
START WITH 1
INCREMENT BY 100;

INSERT INTO Pagos (codigo_pago, fecha, estado, monto, producto_id, usuario_id)
VALUES 
    (nextval('codigo_pago_seq'), '2023-09-01', 'Exitoso', 500.00, 1, 1),
    (nextval('codigo_pago_seq'), '2023-09-05', 'Fallido', 1200.00, 2, 2),
    (nextval('codigo_pago_seq'), '2023-09-10', 'Exitoso', 700.00, 3, 3);   
