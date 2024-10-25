CREATE OR REPLACE FUNCTION guardar_factura(
    p_json_factura JSONB
)
RETURNS VOID AS $$
DECLARE
    total_factura NUMERIC;
    total_descuento NUMERIC;
BEGIN
    SELECT (p_json_factura->>'total_factura')::NUMERIC INTO total_factura;
    SELECT (p_json_factura->>'total_descuento')::NUMERIC INTO total_descuento;

    IF total_factura > 10000 THEN
        RAISE EXCEPTION 'El valor total de la factura no puede superar los 10,000 dólares';
    END IF;

    IF total_descuento > 50 THEN
        RAISE EXCEPTION 'El descuento máximo para una factura es de 50 dólares';
    END IF;

    INSERT INTO factura (descripcion)
    VALUES (p_json_factura);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION actualizar_factura_json(
    p_codigo_factura INTEGER,
    p_json_nuevo JSONB
)
RETURNS VOID AS $$
BEGIN
    UPDATE factura
    SET descripcion = p_json_nuevo
    WHERE codigo_factura = p_codigo_factura;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obtener_nombre_cliente(
    p_identificacion TEXT
)
RETURNS TEXT AS $$
DECLARE
    nombre_cliente TEXT;
BEGIN
    SELECT descripcion->>'nombre'
    INTO nombre_cliente
    FROM factura
    WHERE descripcion->>'identificacion' = p_identificacion;

    RETURN nombre_cliente;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obtener_facturas_por_cliente(
    p_identificacion TEXT
)
RETURNS TABLE(
    cliente JSONB,
    identificacion TEXT,
    direccion TEXT,
    codigo INTEGER,
    total_descuento NUMERIC,
    total_factura NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT descripcion->'cliente',
           descripcion->>'identificacion',
           descripcion->>'direccion',
           (descripcion->>'codigo')::INTEGER,
           (descripcion->>'total_descuento')::NUMERIC,
           (descripcion->>'total_factura')::NUMERIC
    FROM factura
    WHERE descripcion->>'identificacion' = p_identificacion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obtener_productos_por_factura(
    p_codigo_factura INTEGER
)
RETURNS TABLE(
    cantidad INTEGER,
    valor NUMERIC,
    nombre_producto TEXT,
    descripcion_producto TEXT,
    precio_producto NUMERIC,
    categorias_producto JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT (jsonb_array_elements(descripcion->'productos')->>'cantidad')::INTEGER,
           (jsonb_array_elements(descripcion->'productos')->>'valor')::NUMERIC,
           jsonb_array_elements(descripcion->'productos')->>'nombre',
           jsonb_array_elements(descripcion->'productos')->>'descripcion',
           (jsonb_array_elements(descripcion->'productos')->>'precio')::NUMERIC,
           jsonb_array_elements(descripcion->'productos')->'categorias'
    FROM factura
    WHERE codigo_factura = p_codigo_factura;
END;
$$ LANGUAGE plpgsql;
