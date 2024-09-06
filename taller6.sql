create table cliente (
    id serial primary key,
    nombre varchar(30) not null,
    email varchar(50) not null,
    direccion varchar(100) not null,
    telefono varchar(10) not null
);

create type servicio_estado as enum ('pago', 'no_pago', 'pendiente_pago');

create table servicios (
    id serial primary key,
    codigo varchar(7) not null,
    tipo varchar,
    monto integer not null,
    cuota float not null,
    intereses float not null,
    valor_total float not null,
    estado servicio_estado not null,
    cliente_id integer not null,
    foreign key (cliente_id) references cliente(id)
);

create table pagos (
    id serial primary key,
    codigo_transaccion varchar not null,
    fecha_pago date not null,
    total float not null,
    servicio_id integer not null,
    foreign key (servicio_id) references servicios(id)
);

create or replace procedure poblar_base_datos()
language plpgsql
as $$
declare
    cliente_nombre varchar(30);
    cliente_email varchar(50);
    cliente_direccion varchar(100);
    cliente_telefono varchar(10);
    
    servicio_codigo varchar(7);
    tipo_servicio varchar;
    monto_servicio integer;
    cuota_servicio float;
    intereses_servicio float;
    valor_total_servicio float;
    estado_servicio servicio_estado;
    cliente_id integer;
    
    pago_codigo_transaccion varchar;
    fecha_pago date;
    total_pago float;

    i int;
    j int;
begin

    for i in 1..50 loop
        cliente_nombre := 'carlitos ' || i;
        cliente_email := 'carlitos' || i || '@example.com';
        cliente_direccion := 'direccion ' || i;
        cliente_telefono := '300' || lpad(i::text, 7, '0');
        
        insert into cliente(nombre, email, direccion, telefono)
        values (cliente_nombre, cliente_email, cliente_direccion, cliente_telefono);
    end loop;

    for i in 1..150 loop
        servicio_codigo := 'svc' || lpad(i::text, 4, '0');
        tipo_servicio := case when (i % 3) = 0 then 'internet'
                              when (i % 3) = 1 then 'telefono'
                              else 'television'
                         end;
        monto_servicio := (random() * 1000 + 100)::int;
        cuota_servicio := (monto_servicio / 10.0);
        intereses_servicio := (random() * 5)::float;
        valor_total_servicio := monto_servicio + intereses_servicio;
        estado_servicio := case when (i % 3) = 0 then 'pago'
                                when (i % 3) = 1 then 'pendiente_pago'
                                else 'no_pago'
                           end;
        cliente_id := ((i - 1) % 50) + 1;
        
        insert into servicios(codigo, tipo, monto, cuota, intereses, valor_total, estado, cliente_id)
        values (servicio_codigo, tipo_servicio, monto_servicio, cuota_servicio, intereses_servicio, valor_total_servicio, estado_servicio, cliente_id);
    end loop;

    for j in 1..50 loop
        pago_codigo_transaccion := 'pay-' || lpad(j::text, 6, '0');
        fecha_pago := current_date - (random() * 365)::int;
        total_pago := (random() * 1000 + 100)::float;
        
        insert into pagos(codigo_transaccion, fecha_pago, total, servicio_id)
        values (pago_codigo_transaccion, fecha_pago, total_pago, ((j - 1) % 150) + 1);
    end loop;

end $$;

call poblar_base_datos();

