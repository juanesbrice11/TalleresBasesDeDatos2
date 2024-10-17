CREATE TABLE libros (
    isbn VARCHAR(13) PRIMARY KEY,
    descripcion XML
);

CREATE OR REPLACE PROCEDURE guardar_libro(p_isbn VARCHAR, p_descripcion XML)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM libros WHERE isbn = p_isbn) THEN
        RAISE EXCEPTION 'El ISBN ya existe en la tabla libros.';
    END IF;
    
    IF EXISTS (SELECT 1 FROM libros WHERE descripcion::text LIKE '%' || xpath('/libro/titulo/text()', p_descripcion::xml)[1]::text || '%') THEN
        RAISE EXCEPTION 'El título ya existe en la tabla libros.';
    END IF;
    
    INSERT INTO libros (isbn, descripcion) VALUES (p_isbn, p_descripcion);
END;
$$;

CREATE OR REPLACE PROCEDURE actualizar_libro(p_isbn VARCHAR, p_descripcion XML)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM libros WHERE isbn = p_isbn) THEN
        RAISE EXCEPTION 'El libro con el ISBN proporcionado no existe.';
    END IF;
    
    UPDATE libros
    SET descripcion = p_descripcion
    WHERE isbn = p_isbn;
END;
$$;

CREATE OR REPLACE FUNCTION obtener_autor_libro_por_isbn(p_isbn VARCHAR)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    autor TEXT;
BEGIN
    SELECT xpath('/libro/autor/text()', descripcion::xml)[1]::text
    INTO autor
    FROM libros
    WHERE isbn = p_isbn;

    IF autor IS NULL THEN
        RAISE EXCEPTION 'No se encontró el autor para el ISBN proporcionado.';
    END IF;

    RETURN autor;
END;
$$;

CREATE OR REPLACE FUNCTION obtener_autor_libro_por_titulo(p_titulo TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    autor TEXT;
BEGIN
    SELECT xpath('/libro/autor/text()', descripcion::xml)[1]::text
    INTO autor
    FROM libros
    WHERE xpath('/libro/titulo/text()', descripcion::xml)[1]::text = p_titulo;

    IF autor IS NULL THEN
        RAISE EXCEPTION 'No se encontró el autor para el título proporcionado.';
    END IF;

    RETURN autor;
END;
$$;

CREATE OR REPLACE FUNCTION obtener_libros_por_anio(p_anio INTEGER)
RETURNS TABLE(isbn VARCHAR, titulo TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT isbn, xpath('/libro/titulo/text()', descripcion::xml)[1]::text AS titulo
    FROM libros
    WHERE xpath('/libro/anio/text()', descripcion::xml)[1]::text::int = p_anio;
END;
$$;
