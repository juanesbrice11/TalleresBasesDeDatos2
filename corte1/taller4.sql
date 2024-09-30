create table clientes (
	identificacion varchar(10) primary key,
	nombre varchar(30) not null,
	edad integer not null,
	correo varchar(50) not null
);

create table productos (
	codigo varchar(10) primary key,
	nombre varchar(30) not null,
	stock integer null,
	valor_unitario float not null
);


create table pedidos(
	id serial primary key,
	fecha date not null,
	cantidad integer not null,
	valor_total_producto float not null,
	producto_id varchar(10),
	cliente_id varchar(10),
	
	foreign key (producto_id) references productos(codigo),
	foreign key (cliente_id) references clientes(identificacion)
);

CREATE TYPE pedido_estado_enum AS ENUM ('PENDIENTE', 'BLOQUEADO', 'ENTREGADO');

drop table facturas;

create table facturas(
	id varchar primary key,
	Fecha date not null,
	cantidad_valor_total float not null,
	pedido_estado pedido_estado_enum NOT NULL,
	producto_id varchar(10),
	cliente_id varchar(10),
	
	foreign key (producto_id) references productos(codigo),
	foreign key (cliente_id) references clientes(identificacion)
);

create or replace procedure verificar_stock(
	p_producto_id varchar(10),
	p_cantidad integer
)
LANGUAGE plpgsql
AS $$
DECLARE 
    v_stock integer;
BEGIN
	select stock into v_stock from productos where codigo = p_producto_id;
	if v_stock >= p_cantidad then
		raise notice 'Hay suficiente stock disponible';
	else 
		raise notice 'No hay stock diponible del producto';
	end if;
END;
$$;

rollback;


CALL verificar_stock('2204', 10);

create or replace procedure actualizar_estado_pedido(
	p_factura_id varchar,
	p_nuevo_estado varchar
)
language plpgsql
as $$
declare 
	v_estado_actual varchar;
begin
	
	select pedido_estado into v_estado_actual from facturas where id = p_factura_id;

	IF v_estado_actual = 'ENTREGADO' THEN
		RAISE NOTICE 'EL PEDIDO YA FUE ENTREGADO';
	ELSE
		UPDATE facturas SET pedido_estado = p_nuevo_estado WHERE id = p_factura_id;
		RAISE NOTICE 'Estado actualizado';
	END IF;
end;
$$

insert into facturas (id, fecha, cantidad_valor_total, pedido_estado, producto_id, cliente_id) values ('1', '2024-09-02', 7000, 'ENTREGADO', '2204', '1056124587');

UPDATE facturas SET pedido_estado = 'PENDIENTE' WHERE id = '1';

call actualizar_estado_pedido('1', 'ENTREGADO');

begin;

insert into clientes (identificacion, nombre, edad, correo) values ('1056124587', 'Sancho', 22, 'sancho@gmail.com');
insert into clientes (identificacion, nombre, edad, correo) values ('1245784125', 'Pedro', 22, 'pedro@gmail.com');
insert into clientes (identificacion, nombre, edad, correo) values ('3332411524', 'Alejandra', 22, 'alejandra@gmail.com');

insert into productos(codigo, nombre, stock, valor_unitario) values ('2204', 'CocaCola', 4, 2500);
insert into productos(codigo, nombre, stock, valor_unitario) values ('3302', 'Pan', 4, 2000);
insert into productos(codigo, nombre, stock, valor_unitario) values ('5508', 'Arepas', 4, 1000);

insert into pedidos(fecha, cantidad, valor_total_producto, producto_id, cliente_id) 
values ('2024-08-23', 3, 7500, '2204', '1056124587');
insert into pedidos(fecha, cantidad, valor_total_producto, producto_id, cliente_id) 
values ('2024-08-23', 2, 2000, '5508', '3332411524');
insert into pedidos(fecha, cantidad, valor_total_producto, producto_id, cliente_id) 
values ('2024-08-23', 2, 2000, '5508', '3332411524');

commit;



