alter user taller6plsql quota unlimited on users;

create table clientes(
    id_cliente varchar(30) primary key,
    nombre_cliente varchar(30) not null,
    edad_cliente integer,
    correo_cliente varchar(30) not null
);

create table productos(
    id_producto varchar(30) primary key,
    nombre_producto varchar(30) not null,
    cantidad_stock integer,
    precio_unitario float
);

create table facturas(
    id_factura varchar(30) primary key,
    fecha_factura date not null,
    cantidad_producto integer,
    total_factura float,
    estado_pedido varchar(20) check (estado_pedido in ('pago', 'no pago', 'pendiente')),
    id_producto varchar(30) not null,
    id_cliente varchar(30) not null,
    foreign key(id_producto) references productos(id_producto),
    foreign key(id_cliente) references clientes(id_cliente)
);

insert into clientes (id_cliente, nombre_cliente, edad_cliente, correo_cliente) values ('c001', 'lucas', 30, 'lucas@example.com');
insert into clientes (id_cliente, nombre_cliente, edad_cliente, correo_cliente) values ('c002', 'ana', 25, 'ana@example.com');
insert into productos (id_producto, nombre_producto, cantidad_stock, precio_unitario) values ('p001', 'café', 100, 3000);
insert into productos (id_producto, nombre_producto, cantidad_stock, precio_unitario) values ('p002', 'té', 200, 1500);
insert into facturas (id_factura, fecha_factura, cantidad_producto, total_factura, estado_pedido, id_producto, id_cliente) values ('f001', to_date('2024/09/16', 'yyyy/mm/dd'), 5, 15000, 'pago', 'p001', 'c001');
insert into facturas (id_factura, fecha_factura, cantidad_producto, total_factura, estado_pedido, id_producto, id_cliente) values ('f002', to_date('2024/09/16', 'yyyy/mm/dd'), 10, 15000, 'no pago', 'p002', 'c002');

create or replace procedure verificar_inventario(
    v_id_producto in varchar,
    v_cantidad_comprada in number
)
is
    v_stock_actual number := 0;
begin
    select cantidad_stock into v_stock_actual from productos where id_producto = v_id_producto;

    if v_cantidad_comprada > v_stock_actual then
        dbms_output.put_line('no hay suficiente stock de este producto');
    else
        dbms_output.put_line('hay suficiente stock disponible');
    end if;
end;

call verificar_inventario('p001', 3);
