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

savepoint punto_de_restauracion;

update pedidos set cantidad = 1, valor_total_producto = 2500 where id = 1;
update pedidos set cantidad = 2, valor_total_producto = 2500 where id = 2;

update clientes set nombre = 'Andres' where identificacion = '1056124587';
update clientes set nombre = 'Alejandro' where identificacion = '1245784125';

update productos set stock = 6 where codigo = '2204';
update productos set stock = 2 where codigo = '3302';

delete from pedidos where cliente_id = '3332411524';
delete from clientes where identificacion = '3332411524';
delete from productos where codigo = '3302';

rollback to savepoint punto_de_restauracion;

commit;

