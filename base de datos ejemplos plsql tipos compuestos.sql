-- EJEMPLO DE DECLARACION DE TIPO DE DATOS REGISTRO Y ERROR EN LA ASIGNACION
DECLARE
  -- Definimos los tipos de datos registro
  TYPE registro_alumno IS RECORD(
    codigo INTEGER(2),
    carnet VARCHAR(10),
    nombre VARCHAR(10)
  );
  TYPE registro_persona IS RECORD(
    codigo INTEGER(2),
    carnet VARCHAR(10),
    nombre VARCHAR(10)
  );
  -- Declaramos las variables de los tipos definidos
  Francisco registro_alumno;
  Paco registro_persona;
BEGIN
  Francisco := Paco; -- Error, porque son de distinto tipo
END;

-- EJEMPLO DE DECLARACION DE TIPO REGISTRO USANDO ROWTYPE
-- Primero creamos la tabla en la que se basa ROWTYPE
CREATE TABLE alumno (
    id_alumno NUMBER(2) PRIMARY KEY,
    dni_alumno VARCHAR2(10),
    nombre_alumno VARCHAR2(10) NOT NULL    
);
-- A continuacion ya podemos definir el tipo registro basado en esa tabla
DECLARE
  -- Creamos una variable que pueda contener una fila de la tabla alumno
  -- NOTA: La tabla alumno tiene que existir!
  var_fila_alumno alumno%ROWTYPE;

  -- Otra forma es crear un nuevo tipo de dato fila_alumno, y despues una variable
  SUBTYPE fila_alumno IS alumno%ROWTYPE;
  var_tipo_fila fila_alumno; -- La variable var_tipo_fila es del nuevo tipo
  
-- Creamos una variable que pueda contener la columna dni de la tabla alumno
  var_dni_alumno alumno.dni_alumno%TYPE;
BEGIN
    var_fila_alumno := var_tipo_fila; -- No devuelve error
END;

-- EJEMPLO SELECT INTO
-- Para asegurar que la consulta devuelve algun resultado (y solo uno), insertamos valores
INSERT INTO alumno (id_alumno, nombre_alumno) 
    SELECT student_id-700, first_name 
    FROM AD.AD_STUDENT_DETAILS;
-- Ejemplo SELECT INTO
DECLARE
    -- Declaramos una variable con el tipo de la fila de la tabla
    alumno_buscado alumno%ROWTYPE;
BEGIN
    -- Ejecutamos una consulta y guardamos el registro en la variable
    -- NOTA: La consulta solo puede devolver 1 fila
    SELECT * 
      INTO alumno_buscado 
      FROM alumno 
      WHERE id_alumno=20;
    -- Mostramos el resultado
    DBMS_OUTPUT.PUT_LINE('Datos del alumno buscado: ' || alumno_buscado.id_alumno || ' - ' || alumno_buscado.nombre_alumno); 
END;

-- EJEMPLO CURSOR IMPLICITO
-- Recorremos las 5 primeras filas de la tabla, con un cursor explicito
DECLARE
    -- Declaracion del cursor
    CURSOR cursor_alumnos IS
	SELECT id_alumno, nombre_alumno FROM alumno;
    -- Declaracion de las variables donde almacenaremos lo leido en el cursor
    codigo NUMBER(2);
    nombre VARCHAR2(10);
BEGIN
    OPEN cursor_alumnos;
    FOR contador IN 1..5 LOOP
        FETCH cursor_alumnos INTO codigo, nombre; 
		DBMS_OUTPUT.PUT_LINE(codigo || ' - ' || nombre); 
    END LOOP;
    CLOSE cursor_alumnos;
END;

-- Rehaciendo el ejemplo del cursor implicito, pero con ROWTYPE
-- Recorremos las 5 primeras filas de la tabla, con un cursor explicito
DECLARE
    -- Declaracion del cursor
    CURSOR cursor_alumnos IS
	SELECT * FROM alumno;
    -- Declaracion de las variables donde almacenaremos lo leido en el cursor
    fila_alumno alumno%ROWTYPE;
BEGIN
    OPEN cursor_alumnos;
    FOR contador IN 1..5 LOOP
        FETCH cursor_alumnos INTO fila_alumno; 
		DBMS_OUTPUT.PUT_LINE(fila_alumno.id_alumno || ' - ' || fila_alumno.nombre_alumno); 
    END LOOP;
    CLOSE cursor_alumnos;
END;

-- EJEMPLO ATRIBUTOS DE LOS CURSORES
-- Recorremos TODAS las filas de la tabla, con un cursor explicito
DECLARE
    -- Declaracion del cursor
    CURSOR cursor_alumnos IS
	SELECT * FROM alumno;
    -- Declaracion de las variables donde almacenaremos lo leido en el cursor
    fila_alumno alumno%ROWTYPE;
BEGIN
  OPEN cursor_alumnos;
  LOOP
    FETCH cursor_alumnos INTO fila_alumno; 
    DBMS_OUTPUT.PUT_LINE('Fila ' || cursor_alumnos%ROWCOUNT || ' - ' ||fila_alumno.id_alumno || ' - ' || fila_alumno.nombre_alumno); 
    EXIT WHEN (cursor_alumnos%NOTFOUND);
  END LOOP;
  CLOSE cursor_alumnos;
END;

-- EJEMPLO CURSORES IMPLICITOS
-- Creacion de la tabla
CREATE TABLE profesor(
    id_profe NUMBER(2) PRIMARY KEY,
    nombre_profe VARCHAR2(10),
    titulacion VARCHAR2(10)
);

-- Creacion / carga de una fila en la tabla
INSERT INTO profesor VALUES (1, 'Steve Jobs', 'Ingeniero');

-- Ejemplo de utilizar atributos de un cursor, para un cursor implicito
BEGIN
    UPDATE profesor SET nombre_profe='Oscar' WHERE id_profe=99;
    IF SQL%NOTFOUND THEN
      DBMS_OUTPUT.PUT_LINE('Registro no encontrado');  
    END IF;
END;

-- EJEMPLO ACTUALIZACION DE DATOS USANDO CURSORES (CURSOR...FOR UPDATE)
-- Version con bucle LOOP
DECLARE
    -- Declaracion del cursor
    CURSOR cursor_alumnos IS SELECT * FROM alumno
    	FOR UPDATE OF dni_alumno NOWAIT;
    -- Declaracion de las variables donde almacenaremos lo leido en el cursor
    fila_alumno alumno%ROWTYPE;
BEGIN
  OPEN cursor_alumnos;
  LOOP
    FETCH cursor_alumnos INTO fila_alumno; 
	UPDATE alumno SET dni_alumno = fila_alumno.id_alumno 
        WHERE id_alumno = fila_alumno.id_alumno;
	DBMS_OUTPUT.PUT_LINE('Actualizado el DNI del alumno '||fila_alumno.id_alumno || ' con el valor: ' || fila_alumno.id_alumno); 
    EXIT WHEN (cursor_alumnos%NOTFOUND);
  END LOOP;
  CLOSE cursor_alumnos;
END;

-- Otra version con el bucle FOR, que permite simplificar el proceso
DECLARE
    -- Declaracion del cursor
    CURSOR cursor_alumnos IS SELECT * FROM alumno
	FOR UPDATE OF dni_alumno NOWAIT;
BEGIN
    -- NOTA: Podemos recorrer el cursor con el FOR sin variables!
    -- La variable implicita es del tipo ROWTYPE
    -- Ademas no hay que hacer OPEN ni CLOSE del cursor
    FOR fila_alumno IN cursor_alumnos LOOP
	UPDATE alumno SET dni_alumno = fila_alumno.id_alumno 
		WHERE id_alumno = fila_alumno.id_alumno;
	DBMS_OUTPUT.PUT_LINE('Actualizado el DNI del alumno '||fila_alumno.id_alumno || ' con el valor: ' || fila_alumno.id_alumno); 
    END LOOP;
END;

-- EJEMPLO VARRAYs
DECLARE
    --Creamos un VARRAY con máximo 5 elementos
    TYPE tipo_varray IS VARRAY(5) OF VARCHAR2(10);    
    --Declaramos una variable del tipo array
    variable_varray   tipo_varray;
    --CURSOR con los nombres de todos los alumnos
    CURSOR  cursor_nombres_alumnos IS
        SELECT nombre_alumno
        FROM alumno;
    contador_alumnos NUMBER(1) :=  1;
BEGIN
    -- Inicializamos la variable de tipo array, para poder usarla
    variable_varray := tipo_varray();
    -- Recorremos el cursor, y copiamos al array
    FOR i IN cursor_nombres_alumnos LOOP
        variable_varray.EXTEND;
        variable_varray(contador_alumnos) := i.nombre_alumno;
        -- Limitamos el LOOP al limite del array
        EXIT WHEN cursor_nombres_alumnos%ROWCOUNT  > variable_varray.LIMIT -1;  
        contador_alumnos := contador_alumnos + 1;
    END LOOP;

    --Validamos que haya elementos en el array:
    IF variable_varray.COUNT  > 0 THEN
        --De no haber Registros el LOOP a continuación daría error.
        --Esto porque los métodos FIRST y LAST tendrían valores nulos.
        DBMS_OUTPUT.PUT_LINE('Contenido del array: ');
        FOR i IN  variable_varray.FIRST..variable_varray.LAST LOOP
            DBMS_OUTPUT.PUT_LINE(variable_varray(i));
        END LOOP;
    END IF;
END;

-- EJERCICIO: REHACER EL SIGUIENTE CODIGO, SIN USAR ROWTYPE, PERO USANDO TYPE
-- Recorremos las 5 primeras filas de la tabla, con un cursor explicito
DECLARE
    -- Declaracion del cursor
    CURSOR cursor_alumnos IS
	SELECT * FROM alumno;
    -- Declaracion de las variables donde almacenaremos lo leido en el cursor
    fila_alumno alumno%ROWTYPE;
BEGIN
    OPEN cursor_alumnos;
    FOR contador IN 1..5 LOOP
        FETCH cursor_alumnos INTO fila_alumno; 
		DBMS_OUTPUT.PUT_LINE(fila_alumno.id_alumno || ' - ' || fila_alumno.nombre_alumno); 
    END LOOP;
    CLOSE cursor_alumnos;
END;
