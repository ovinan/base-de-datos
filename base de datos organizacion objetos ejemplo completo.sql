/*

 EJEMPLO COMPLETO DE TABLAS DE TIPOS DE OBJETOS CON HERENCIA, SOBREESCRITURA (OVERRIDE) DE METODOS

 NOTA: Este ejemplo se puede ejecutar todo a la vez, no hay que ir paso por paso.
*/
-- Creacion del supertipo
-- NOTA: La superclase es la que tiene el metodo MAP
CREATE OR REPLACE TYPE tipo_obj_persona AS OBJECT (
 nombre VARCHAR2(20),
 apellidos VARCHAR2(50),
 edad NUMBER,
 MAP MEMBER FUNCTION get_edad RETURN NUMBER,
 MEMBER FUNCTION show RETURN VARCHAR2
) NOT FINAL;
/
CREATE OR REPLACE TYPE BODY tipo_obj_persona AS
 MAP MEMBER FUNCTION get_edad RETURN NUMBER IS
 BEGIN
   RETURN edad;
 END;
 MEMBER FUNCTION show RETURN VARCHAR2 IS
 BEGIN
   RETURN ' Nombre: ' || nombre || ' , edad: ' || TO_CHAR(edad);
 END;
END;
/
-- Creacion de un subtipo, con override del metodo show
-- NOTA: No indicamos nada, por lo que el tipo de objeto sera FINAL
CREATE OR REPLACE TYPE tipo_obj_empleado UNDER tipo_obj_persona (
    num_empleado NUMBER, 
    trabajo VARCHAR2(30),
    OVERRIDING MEMBER FUNCTION show RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY tipo_obj_empleado AS
  OVERRIDING MEMBER FUNCTION show RETURN VARCHAR2 IS
  BEGIN
    -- Observar como se invoca al metodo del supertipo
    RETURN (SELF AS tipo_obj_persona).show|| ' -- Numero empleado: ' 
           || TO_CHAR(num_empleado) || ', Trabajo: ' || trabajo ;
  END; 
END;
/
-- Creacion de otro subtipo, que usaremos para seguir con la herencia
-- NOTA: Tambien se hace override del metodo show
CREATE TYPE tipo_obj_estudiante UNDER tipo_obj_persona (
   num_estudiante NUMBER,
   estudios VARCHAR2(30),
   OVERRIDING MEMBER FUNCTION show RETURN VARCHAR2
) NOT FINAL;
/
CREATE TYPE BODY tipo_obj_estudiante AS
 OVERRIDING MEMBER FUNCTION show RETURN VARCHAR2 IS
 BEGIN
    RETURN (self AS tipo_obj_persona).show || ' -- Estudios: ' || estudios ;
 END;
END;
-- Creacion de otro subtipo (tambien con override)
/
CREATE TYPE tipo_obj_estudiante_tparcial UNDER tipo_obj_estudiante (
  horas NUMBER,
  OVERRIDING MEMBER FUNCTION show RETURN VARCHAR2);
/
CREATE TYPE BODY tipo_obj_estudiante_tparcial AS
  OVERRIDING MEMBER FUNCTION show RETURN VARCHAR2 IS
  BEGIN
    RETURN (SELF AS tipo_obj_persona).show|| ' -- Estudios: ' || estudios ||
           ', Horas: ' || TO_CHAR(horas);
  END; 
END;
/
-- Creacion de la tabla de objetos
CREATE TABLE tabla_obj_personas OF tipo_obj_persona;
-- Creamos en la base de datos los objetos de supertipo y subtipos
INSERT INTO tabla_obj_personas 
  VALUES (tipo_obj_persona('Oscar', 'Vinan', 47));

INSERT INTO tabla_obj_personas 
  VALUES (tipo_obj_estudiante('Albert','Einstein', 45, 
	1, 'Fisica'));

INSERT INTO tabla_obj_personas 
  VALUES (tipo_obj_empleado('Bill', 'Gates', 30,
	1, 'Microsoft'));

INSERT INTO tabla_obj_personas  
  VALUES (tipo_obj_estudiante_tparcial('Bob', 'Dylan', 25, 
	14, 'Literatura', 20));

-- Ejemplo de consulta basica, accediendo a los atributos del supertipo
SELECT * FROM tabla_obj_personas p;
-- Ejemplo de consulta basica, ejecutando un metodo
-- NOTA: En cada objeto, se ejecuta la version segun el tipo de objeto
SELECT p.show() FROM tabla_obj_personas p;

-- Ejemplo de consulta AVANZADA filtrando por el tipo de objeto
SELECT * FROM tabla_obj_personas p WHERE TREAT(VALUE(p) AS tipo_obj_empleado) IS NOT NULL;

-- Ejemplo de utilizacion de VALUE para acceder a cada objeto de la tabla
-- (en este caso, usando un cursor para recorrer la tabla)
DECLARE
  CURSOR cursor_personas IS SELECT VALUE(p) FROM tabla_obj_personas p;
    un_objeto_persona tipo_obj_persona;
BEGIN
  OPEN cursor_personas;  
  LOOP
    FETCH cursor_personas INTO un_objeto_persona;    
    EXIT WHEN cursor_personas%NOTFOUND;
    -- Aquí puedes hacer cualquier operación con la persona actual
    -- (por ejemplo, acceso a los atributos o invocar metodos)
    DBMS_OUTPUT.PUT_LINE('Nombre y apellidos (como atributos): ' || un_objeto_persona.nombre || ' ' || un_objeto_persona.apellidos);
    DBMS_OUTPUT.PUT_LINE('Datos del objeto (invocando el metodo): ' || un_objeto_persona.show());
  END LOOP;  
  CLOSE cursor_personas;
END;
