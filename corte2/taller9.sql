create table empleados (
	identificacion serial primary key,
	nombre varchar not null,
	tipo_contrato int not null,
	
	foreign key (tipo_contrato) references tipo_contrato(id)
)

create table tipo_contrato (
	id serial primary key,
	descripcion varchar not null,
	cargo varchar null,
	salario_total numeric not null
)

create table conceptos(
	codigo serial primary key,
	nombre varchar check (nombre in ('salario','horas_extras','prestaciones','impuestos')),
	porcentaje numeric
)

create table nomina(
	id serial primary key,
	mes varchar check (mes in ('01','02','03','04','05','06','07','08','09','10','11','12')),
	año varchar,
	fecha_pago date,
	total_devengado numeric,
	total_deducciones numeric,
	total numeric,
	cliente_id int,
	foreign key (cliente_id) references empleados(identificacion)
)


create table detalles_nomina(
	id serial primary key,
	valor numeric,
	concepto_id int,
	nomina_id int,
	foreign key (concepto_id) references conceptos(codigo),
	foreign key (nomina_id) references nomina(id)
)

CREATE OR REPLACE FUNCTION poblar_tipo_contrato()
RETURNS VOID AS $$
BEGIN
    INSERT INTO tipo_contrato (descripcion, cargo, salario_total)
    VALUES 
    ('Contrato 1', 'Cargo 1', 3000),
    ('Contrato 2', 'Cargo 2', 3500),
    ('Contrato 3', 'Cargo 3', 4000),
    ('Contrato 4', 'Cargo 4', 4500),
    ('Contrato 5', 'Cargo 5', 5000),
    ('Contrato 6', 'Cargo 6', 5500),
    ('Contrato 7', 'Cargo 7', 6000),
    ('Contrato 8', 'Cargo 8', 6500),
    ('Contrato 9', 'Cargo 9', 7000),
    ('Contrato 10', 'Cargo 10', 7500);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION poblar_empleados()
RETURNS VOID AS $$
BEGIN
    INSERT INTO empleados (nombre, tipo_contrato)
    VALUES 
    ('Empleado 1', 1),
    ('Empleado 2', 2),
    ('Empleado 3', 3),
    ('Empleado 4', 4),
    ('Empleado 5', 5),
    ('Empleado 6', 6),
    ('Empleado 7', 7),
    ('Empleado 8', 8),
    ('Empleado 9', 9),
    ('Empleado 10', 10);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION poblar_conceptos()
RETURNS VOID AS $$
BEGIN
    INSERT INTO conceptos (nombre, porcentaje)
    VALUES 
    ('salario', 50),
    ('horas_extras', 10),
    ('prestaciones', 8),
    ('impuestos', 5),
    ('salario', 55),
    ('horas_extras', 15),
    ('prestaciones', 9),
    ('impuestos', 6),
    ('salario', 60),
    ('horas_extras', 12);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION poblar_nomina()
RETURNS VOID AS $$
BEGIN
    INSERT INTO nomina (mes, año, fecha_pago, total_devengado, total_deducciones, total, cliente_id)
    VALUES 
    ('01', '2023', '2023-01-31', 10000, 2000, 8000, 1),
    ('02', '2023', '2023-02-28', 11000, 2200, 8800, 2),
    ('03', '2023', '2023-03-31', 12000, 2400, 9600, 3),
    ('04', '2023', '2023-04-30', 13000, 2600, 10400, 4),
    ('05', '2023', '2023-05-31', 14000, 2800, 11200, 5),
    ('06', '2023', '2023-06-30', 15000, 3000, 12000, 6),
    ('07', '2023', '2023-07-31', 16000, 3200, 12800, 7),
    ('08', '2023', '2023-08-31', 17000, 3400, 13600, 8),
    ('09', '2023', '2023-09-30', 18000, 3600, 14400, 9),
    ('10', '2023', '2023-10-31', 19000, 3800, 15200, 10);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION poblar_detalles_nomina()
RETURNS VOID AS $$
BEGIN
    INSERT INTO detalles_nomina (valor, concepto_id, nomina_id)
    VALUES 
    (500, 1, 1),
    (300, 2, 1),
    (400, 3, 2),
    (250, 4, 3),
    (600, 1, 4),
    (350, 2, 5),
    (450, 3, 6),
    (270, 4, 7),
    (550, 1, 8),
    (370, 2, 9);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION crear_contrato(
    p_descripcion VARCHAR,
    p_cargo VARCHAR,
    p_salario_total NUMERIC
)
RETURNS TABLE (id INT, descripcion VARCHAR, cargo VARCHAR, salario_total NUMERIC) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM tipo_contrato WHERE cargo = p_cargo) THEN
        RAISE EXCEPTION 'El cargo % ya existe, debe ser único.', p_cargo;
    ELSE
        INSERT INTO tipo_contrato (descripcion, cargo, salario_total)
        VALUES (p_descripcion, p_cargo, p_salario_total)
        RETURNING id, descripcion, cargo, salario_total;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION crear_empleado(
    p_nombre VARCHAR,
    p_tipo_contrato INT
)
RETURNS TABLE (identificacion INT, nombre VARCHAR, tipo_contrato INT) AS $$
BEGIN
    INSERT INTO empleados (nombre, tipo_contrato)
    VALUES (p_nombre, p_tipo_contrato)
    RETURNING identificacion, nombre, tipo_contrato;
END;
$$ LANGUAGE plpgsql;
