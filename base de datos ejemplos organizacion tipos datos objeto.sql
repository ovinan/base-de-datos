-- Creacion del tipo objeto
CREATE OR REPLACE TYPE obj_alumno AS OBJECT (
	nombre VARCHAR2(50),
	apellidos VARCHAR2(100),
    edad NUMBER
);

-- Creacion del tipo ARRAY desde SQL: CREATE OR REPLACE TYPE...
CREATE OR REPLACE TYPE array_alumnos IS VARRAY(3) OF obj_alumno;

-- Creamos tambien una tabla con un tipo de datos coleccion de objetos
CREATE TABLE tabla_array_objetos_alumnos(
    centro VARCHAR2(25),
    alumnos_matriculados array_alumnos
);

-- Ejemplo de la insercion de datos en una tabla que tiene colecciones de objetos
-- NOTA: Oracle crea automaticamente el constructor por defecto para el tipo de coleccion
INSERT INTO tabla_array_objetos_alumnos VALUES ('MEDAC Sevilla',array_alumnos(obj_alumno('Leo','DaVinci',47),obj_alumno('Tomas', 'Edison',30)));
INSERT INTO tabla_array_objetos_alumnos VALUES ('MEDAC Malaga',array_alumnos(obj_alumno('Pablo','Picasso',25),obj_alumno('Galileo', 'Galilei',30)));

-- Consulta de datos desde SQL: Con los datos tipo coleccion tenemos menos posibilidades de manejo
SELECT * FROM tabla_array_objetos_alumnos;

-- Ejemplo de utilizacion en un VARRAY, en una tabla anidada y en una tabla SQL
DECLARE
    -- Objeto que usaremos para recoger el resultado de la consulta SQL de la tabla
	listado_alumnos array_alumnos;
    -- Ejemplo de declaracion de tipo VARRAY con elementos objeto
	-- NOTA: El tipo lo creamos antes, por SQL
    var_array_alumnos array_alumnos := array_alumnos(
    	obj_alumno('Alberto','Einstein',47),
    	obj_alumno('Isaac', 'Newton',30)
    );
	-- Ejemplo de creacion de tipo de tabla anidada desde PL/SQL: TYPE...
	TYPE tabla_alumnos IS TABLE OF obj_alumno;
	-- La inicializamos vacia (NULL)
    var_tabla_alumnos tabla_alumnos := tabla_alumnos();
BEGIN
    -- Acceso a la informacion de la tabla, desde PLSQL, y volcarlo a una variable de tipo objeto
    SELECT alumnos_matriculados INTO listado_alumnos FROM tabla_array_objetos_alumnos WHERE centro LIKE '%Sevilla%';
    DBMS_OUTPUT.PUT_LINE('Resultado de la consulta SQL:');
    -- Bucle para recorrer el resultado de la consulta
    FOR i IN listado_alumnos.FIRST .. listado_alumnos.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || listado_alumnos(i).nombre ||
                             ', Apellido(s): ' || listado_alumnos(i).apellidos ||
                             ', Edad: ' || listado_alumnos(i).edad);    
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Pasamos a recorrer el VARRAY:');
    -- Bucle para recorrer el array y copiar a la tabla anidada
    FOR i IN var_array_alumnos.FIRST .. var_array_alumnos.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || var_array_alumnos(i).nombre ||
                             ', Apellido(s): ' || var_array_alumnos(i).apellidos ||
                             ', Edad: ' || var_array_alumnos(i).edad);    
		-- Creamos un nuevo elemento en la tabla anidada
		var_tabla_alumnos.EXTEND;
		var_tabla_alumnos(i) := var_array_alumnos(i);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Pasamos a recorrer la tabla anidada:');
	-- Bucle para recorrer la tabla anidada
    FOR i IN var_tabla_alumnos.FIRST .. var_tabla_alumnos.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || var_tabla_alumnos(i).nombre ||
                             ', Apellido(s): ' || var_tabla_alumnos(i).apellidos ||
                             ', Edad: ' || var_tabla_alumnos(i).edad);    
    END LOOP;
END;

-- Creacion de una tabla de objetos
CREATE TABLE TablaAlumnos OF obj_alumno;

CREATE TYPE libro AS OBJECT (
  titulo VARCHAR2(100),
  propietario obj_alumno
);

-- Creacion de una tabla, con un atributo tipo objeto
CREATE TABLE libros (
  id_libro NUMBER PRIMARY KEY,
  info_libro libro
);

DECLARE
   a1 obj_alumno;
   a2 obj_alumno;
   l1 libro;
BEGIN
   a1 := NEW obj_alumno('Leo','DaVinci',47);
   a2 := NEW obj_alumno('Galileo', 'Galilei',30);
   -- Insercion de registros en la tabla TABLAALUMNOS de objetos OBJ_ALUMNO
   INSERT INTO TablaAlumnos VALUES (a1);
   INSERT INTO TablaAlumnos VALUES (a2);
   -- Insertar registros en tabla LIBROS, que tenia atributo objeto libro
   l1 := NEW libro('Mona Lisa',a1);
   INSERT INTO libros VALUES (10, l1);
   INSERT INTO libros VALUES (20, libro('Manual Windows', obj_alumno('Bill','Gates',19)));
END;

-- Consulta de todos los campos del objeto
SELECT * from TablaAlumnos;

-- Con esta consulta no se pueden visualizar los datos de los objetos
SELECT * FROM libros;

-- Con el alias accedemos a los atributos del objeto
SELECT l.info_libro.propietario.nombre FROM libros l;

-- Modificacion de datos con tablas de objetos
UPDATE TablaAlumnos 
    SET nombre = 'Leonardo' 
    WHERE nombre = 'Leo';

-- Modificacion de datos con tabla con columnas tipo objeto
UPDATE libros l 
    SET l.info_libro.propietario.nombre = 'Leonardo' 
    WHERE l.info_libro.propietario.nombre = 'Leo';

-- Borrado de datos con tablas de objetos
DELETE FROM tablaalumnos WHERE nombre = 'Leo'

-- Borrado de datos con tabla con columnas tipo objeto
DELETE FROM libros l WHERE l.info_libro.propietario.nombre = 'Leonardo';

-- La consulta devuelve los objetos completos (no se muestra por pantalla)
SELECT VALUE(a1) FROM TablaAlumnos a1 WHERE a1.nombre LIKE '%Leo%'

-- Creamos otra tabla de alumnos
CREATE TABLE TablaAlumnos_Master OF obj_alumno;

-- La sentencia copia los objetos completos
INSERT INTO TablaAlumnos_Master SELECT VALUE(a) FROM TablaAlumnos a;

-- Esta sentencia compara los objetos completos
SELECT * FROM TablaAlumnos a1 JOIN TablaAlumnos_Master a2 ON VALUE(a1)=VALUE(a2);

-- Uso de VALUE con SELECT INTO para almacenar objetos en variables PL/SQL
DECLARE
    variable obj_alumno;
BEGIN
    -- Introducimos un registro para la prueba
    INSERT INTO TablaAlumnos VALUES('Cristobal','Colon',31);
    -- Volcamos el objeto de la tabla, en la variable, usando SELECT INTO
	-- Importante, la consulta debe devolver 1 unico resultado
	SELECT VALUE(a1) INTO variable FROM TablaAlumnos a1 WHERE a1.edad=31;
	DBMS_OUTPUT.PUT_LINE('Nombre: ' || variable.nombre);
END;
