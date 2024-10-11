create type estado as enum ('pendiente', 'en ruta', 'entregado');

create table "tallercursores".envios (
	id varchar not null,
	fecha_envio date null,
	destino varchar null,
	observacion varchar null,
	estadoP estado null, 	
	constraint envios_pk primary key (id)
);

create or replace procedure "tallercursores".poblar()
language plpgsql
as $$
declare
    i integer;
    estado_arr estado[] := array['pendiente', 'en ruta', 'entregado'];
begin
    for i in 1..50 loop
        insert into "tallercursores".envios (id, fecha_envio, destino, observacion, estadoP)
        values (
            'envio_' || i,                       
            current_date + (i % 10),              
            'destino_' || i,                      
            'observacion_' || i,                  
            estado_arr[i % 3 + 1]                 
        );
    end loop;
end $$;

call "tallercursores".poblar();

create or replace procedure "tallercursores".primera_fase_envio()
language plpgsql
as $$
declare
	v_cursor cursor for select id from "tallercursores".envios where estadoP = 'pendiente';
	v_id varchar;
begin
	open v_cursor;
	loop
		fetch v_cursor into v_id;
		exit when not found;
		update "tallercursores".envios set observacion='primera etapa del envio', estadoP='en ruta' where id = v_id;		
	end loop;
	close v_cursor;
	raise notice 'actualización envio exitosa.';
end;
$$;

call "tallercursores".primera_fase_envio();

create or replace procedure "tallercursores".ultima_fase_envio(p_fecha_actual date)
language plpgsql
as $$
declare
	v_cursor cursor for select id, fecha_envio from "tallercursores".envios where estadoP = 'en ruta';
	v_id varchar;
	v_fecha date;
begin
	open v_cursor;
	loop
		fetch v_cursor into v_id, v_fecha;
		exit when not found;
		if p_fecha_actual - v_fecha > 5 then
			update "tallercursores".envios set observacion='envio realizado satisfactoriamente', estadoP='entregado' where id = v_id;		
		end if;
	end loop;
	close v_cursor;
	raise notice 'actualización envio exitosa.';
end;
$$;

call "tallercursores".ultima_fase_envio('2022/01/01');
