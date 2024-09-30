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

--Taller 5 parte 1

begin
	for v_nombre_producto, v_stock_actual in select nombre, stock from productos
	loop
		raise notice 'El nombre del producto es %', v_nombre_producto;
		raise notice 'El stock actual del producto es: %', v_stock_actual;
		total_stock := total_stock + v_stock_actual;
	end loop;
	raise notice 'El stock total es: %', total_stock;
end;
$$;

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

create table auditorias(
	id serial primary key,
	fecha_inicio date not null,
	fecha_final date not null,
	factura_id varchar not null,
	pedido_estado pedido_estado_enum not null,
	
	foreign key (factura_id) references facturas(id)
);

--Taller 5 parte 2

create or replace procedure generar_auditoria(
	fecha_inicio date,
	fecha_final date
)
LANGUAGE plpgsql
AS $$
DECLARE 
	id_factura varchar,
	fecha_factura date,
    v_pedido_estado pedido_estado_enum
BEGIN
	for id_factura, fecha_factura, v_pedido_estado in select id, Fecha, pedido_estado from facturas
	loop 
		if Fecha between fecha_inicio AND fecha_final:
			insert into auditorias (fecha_inicio, fecha_final, factura_id, pedido_estado) values (fecha_inicio, fecha_final, id_factura, v_pedido_estado);
		end if;
	end loop;
END;
$$;

--Taller 5 parte 3

create or replace procedure simular_ventas_mes()
language plpgsql
as$$
declare 
	v_dia integer := 1;
	v_identificación varchar;
begin
	while dia<= 30 loop
		--for clientes
		--dentro del for insert a facturas
	end loop
end

create or replace procedure calcular_stock_total()
language plpgsql
as $$
declare 
	total_stock integer := 0;
	v_stock_actual integer;
	v_nombre_producto varchar;
	
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

-- Secuencia para facturas
CREATE SEQUENCE facturas_id_seq
    START WITH 4
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Procedimiento para simular ventas de un mes
CREATE OR REPLACE PROCEDURE simular_ventas_mes()
LANGUAGE plpgsql
AS $$
DECLARE 
	v_dia INTEGER := 1;
	v_identificacion VARCHAR(10);
	v_cantidad INTEGER;
	v_valor_total NUMERIC;
 	v_producto_id VARCHAR(10);
 	v_id_factura VARCHAR;
 	v_fecha DATE;
 	v_stock_actual INTEGER;
BEGIN
	
	WHILE v_dia <= 30 LOOP
		
		FOR v_identificacion IN (SELECT identificacion FROM clientes) LOOP
			
			SELECT codigo, stock INTO v_producto_id, v_stock_actual 
			FROM productos 
			ORDER BY RANDOM() LIMIT 1;
			
			v_cantidad := FLOOR(RANDOM() * 3) + 1;
			IF v_stock_actual >= v_cantidad THEN
				SELECT valor_unitario INTO v_valor_total 
				FROM productos WHERE codigo = v_producto_id;
				v_valor_total := v_cantidad * v_valor_total;
				
				v_id_factura := nextval('facturas_id_seq')::VARCHAR;
				v_fecha := CURRENT_DATE - INTERVAL '1 month' + INTERVAL '1 day' * v_dia;
				
				
				INSERT INTO facturas (id, fecha, cantidad_valor_total, pedido_estado, producto_id, cliente_id) 
				VALUES (v_id_factura, v_fecha, v_valor_total, 'PENDIENTE', v_producto_id, v_identificacion);
				
				UPDATE productos 
				SET stock = stock - v_cantidad 
				WHERE codigo = v_producto_id;
			END IF;
		END LOOP;
		v_dia := v_dia + 1;
	END LOOP;
END;
$$;

CALL simular_ventas_mes();




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



