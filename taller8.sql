create table usuarios(
	id varchar primary key,
	nombre varchar not null,
	edad integer not null,
	email varchar
);

create table factura(
	id varchar primary key,
	fecha date not null,
	producto varchar not null,
	cantidad integer not null,
	valor_unitario numeric not null,
	valor_total numeric not null,
	usuario_id varchar not null,
	
	foreign key (usuario_id) references usuarios(id)
);

create or replace procedure poblar_tablas()
language plpgsql
as $$
declare
    i integer;
begin
    for i in 1..50 loop
        insert into usuarios (id, nombre, edad, email) values ('u' || lpad(cast(i as text), 3, '0'), 'usuario ' || cast(i as text), 20 + (i % 50), 'usuario' || cast(i as text) || '@example.com');
    end loop;

    for i in 1..50 loop
        insert into factura (id, fecha, producto, cantidad, valor_unitario, valor_total, usuario_id) values ('f' || lpad(cast(i as text), 3, '0'), current_date - (i * interval '1 day'), 'producto ' || cast(i as text), (i % 10) + 1, 50.00 + (i % 20)::numeric, (50.00 + (i % 20)::numeric) * ((i % 10) + 1), 'u' || lpad(cast((i % 50) + 1 as text), 3, '0'));
    end loop;

    commit;
end;
$$;

call poblar_tablas();

create or replace procedure prueba_producto_vacio(
    p_id varchar, p_fecha date, p_producto varchar, p_cantidad integer, p_valor_unitario numeric, p_valor_total numeric, p_usuario_id varchar
)
language plpgsql
as $$
begin
    begin
        insert into factura (id, fecha, producto, cantidad, valor_unitario, valor_total, usuario_id)
        values (p_id, p_fecha, p_producto, p_cantidad, p_valor_unitario, p_valor_total, p_usuario_id);
        
        commit;
    exception
        when others then
            raise notice 'error al insertar la factura: %', sqlerrm;
            rollback;
    end;
end;
$$;


call prueba_producto_vacio();

create or replace procedure prueba_identificacion_unica(p_id varchar, p_nombre varchar, p_edad integer, p_email varchar)
language plpgsql
as $$
declare
    nuevo_id varchar;
    max_id varchar;
begin
    insert into usuarios (id, nombre, edad, email) values (p_id, p_nombre, p_edad, p_email);
    commit;
    return;
exception
    when others then
        raise notice 'error de unicidad: %', sqlerrm;
        select max(id) into max_id from usuarios;
        nuevo_id := coalesce('u' || lpad(cast((cast(substring(max_id from 2) as integer) + 1) as text), 3, '0'), 'u001');
        begin
            insert into usuarios (id, nombre, edad, email) values (nuevo_id, p_nombre, p_edad, p_email);
            commit;
        exception
            when others then
                raise notice 'error al insertar el usuario con nuevo id %: %', nuevo_id, sqlerrm;
                rollback;
        end;
end;
$$;

call prueba_identificacion_unica();

create or replace procedure prueba_cliente_debe_existir(p_id varchar, p_fecha date, p_producto varchar, p_cantidad integer, p_valor_unitario numeric, p_valor_total numeric, p_usuario_id varchar)
language plpgsql
as $$
declare
	v_usuario_no_existente varchar;
begin
	insert into factura (id, fecha, producto, cantidad, valor_unitario, valor_total, usuario_id) 
	values (p_id, p_fecha, p_producto, p_cantidad, p_valor_unitario, p_valor_total, p_usuario_id);
	v_usuario_no_existente := coalesce('u' || lpad(cast((cast(substring(max_id from 2) as integer) + 1) as text), 3, '0'), 'u001');
	insert into factura (id, fecha, producto, cantidad, valor_unitario, valor_total, usuario_id) 
	values (p_id, p_fecha, p_producto, p_cantidad, p_valor_unitario, p_valor_total, v_usuario_no_existente);
	commit;
exception
	when others then
		raise notice 'Error al inesrtar la factura %', SQLERRM;
	rollback;
end;
$$;

call prueba_cliente_debe_existir('f051', current_date, 'Producto 51', 5, 100.00, 500.00, 'u001');






