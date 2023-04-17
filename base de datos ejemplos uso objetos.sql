-- Ejemplo de funcion que usaremos pasandole como parametro un atributo de un objeto
-- NOTA: Esta funcion no es metodo de ningun objeto!
CREATE OR REPLACE FUNCTION primera_mayuscula(par_cadena VARCHAR2) RETURN VARCHAR2 
AS
   primera_letra VARCHAR2(1);
   resto_palabra VARCHAR2(50);
   longitud_cadena NUMBER;
BEGIN
    longitud_cadena := LENGTH(par_cadena);
    primera_letra := SUBSTR(par_cadena,1,1);
    resto_palabra := SUBSTR(par_cadena,2,longitud_cadena-1);
	RETURN UPPER(primera_letra) || resto_palabra;
END;
-- Creacion del objeto direccion
CREATE OR REPLACE TYPE obj_direccion AS OBJECT (
	calle VARCHAR2(50)
);
-- Creacion de un objeto anidado
CREATE OR REPLACE TYPE obj_profe AS OBJECT (
    nombre VARCHAR2(10),
	domicilio obj_direccion
);
-- Ejemplos de utilizacion
DECLARE
   direccion1 obj_direccion;
   profesor1 obj_profe;
   profesor2 obj_profe;
BEGIN
   direccion1 := NEW obj_direccion('alcala 101');
   profesor1 := NEW obj_profe('Oscar',direccion1);
   -- Podemos modificar el atributo del objeto anidado
   profesor1.domicilio.calle := 'serrano';
   DBMS_OUTPUT.PUT_LINE('La calle del profe es: ' || profesor1.domicilio.calle);
   -- Otra forma de crear objetos con objetos anidados
   profesor2 := NEW obj_profe('Felipe',obj_direccion('zarzuela'));
   DBMS_OUTPUT.PUT_LINE('La calle del otro profe es: ' || profesor2.domicilio.calle);
   DBMS_OUTPUT.PUT_LINE('La calle en mayus es: ' || primera_mayuscula(direccion1.calle));
END;

-- EJEMPLOS DE LLAMADAS A METODOS
-- NOTA: Como hay dependencias entre los objetos, para poder modificar su definicion
-- hay que borrarlos antes. Para ello hay que borrarlos en orden contrario a su creacion
DROP TYPE obj_profe;
DROP TYPE obj_direccion;
-- Creacion del objeto direccion
CREATE OR REPLACE TYPE obj_direccion AS OBJECT (
	calle VARCHAR2(50),
    numero NUMBER(2),
    MEMBER PROCEDURE actualizaCalle(par_nombre VARCHAR2),
    MEMBER FUNCTION obtenerNumero RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY obj_direccion AS
    MEMBER PROCEDURE actualizaCalle(par_nombre VARCHAR2) IS
     BEGIN
		SELF.calle := par_nombre;
     END;
    MEMBER FUNCTION obtenerNumero RETURN NUMBER IS
     BEGIN
        RETURN numero;
     END;
END;
/
-- Creacion de un objeto anidado
CREATE OR REPLACE TYPE obj_profe AS OBJECT (
    nombre VARCHAR2(10),
    salario NUMBER,
	domicilio obj_direccion,
    MEMBER FUNCTION obtenerDireccion RETURN obj_direccion
);
/
CREATE OR REPLACE TYPE BODY obj_profe AS
    MEMBER FUNCTION obtenerDireccion RETURN obj_direccion IS
     BEGIN
        RETURN domicilio;
     END;
END;
/
-- Ejemplos de utilizacion
DECLARE
  direccion1 obj_direccion;
  profesor1 obj_profe;
  portal NUMBER;
BEGIN
  direccion1 := NEW obj_direccion('alcala',10);
  -- Ejecucion de la funcion de un objeto
  DBMS_OUTPUT.PUT_LINE('Numero calle objeto direccion: ' || direccion1.obtenerNumero());
  -- Ejecucion de un metodo con parametros
  direccion1.actualizaCalle('serrano');
  -- Instanciamos un objeto anidado
  profesor1 := obj_profe('Oscar',500,obj_direccion('bernabeu',1));
  -- Ejecucion del metodo de un objeto anidado
  profesor1.domicilio.actualizaCalle('puerta del sol');
  DBMS_OUTPUT.PUT_LINE('La calle del profe es: ' || profesor1.domicilio.calle);
END;


-- EJEMPLOS METODOS STATIC
CREATE OR REPLACE TYPE obj_direccion_es AS OBJECT (
    calle VARCHAR2(50),
    numero NUMBER(2),
    STATIC FUNCTION pais RETURN VARCHAR2,
    MEMBER PROCEDURE actualizaCalle(par_nombre VARCHAR2),
    MEMBER FUNCTION obtenerNumero RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY obj_direccion_es AS
    STATIC FUNCTION pais RETURN VARCHAR2 IS
     BEGIN
	-- Devolveremos siempre ES como codigo de pais
    	RETURN 'ES';
     END;
    MEMBER PROCEDURE actualizaCalle(par_nombre VARCHAR2) IS
     BEGIN
        SELF.calle := par_nombre;
     END;
    MEMBER FUNCTION obtenerNumero RETURN NUMBER IS
     BEGIN
        RETURN numero;
     END;
END;

DECLARE
   nueva_direccion obj_direccion_es;
BEGIN
   -- Incluso antes de crear ningun objeto DIRECCION, podemos acceder a su metodo STATIC
   DBMS_OUTPUT.PUT_LINE('El pais es: ' || obj_direccion_es.pais);
   -- La siguiente instruccion, por otro lado, dara error, pq no hay ningun objeto creado
   -- DBMS_OUTPUT.PUT_LINE('El pais es: ' || obj_direccion_es.calle);
   nueva_direccion := obj_direccion_es('alcala',10);
   -- La siguiente instruccion tambien dara error: 
   -- los metodos estaticos son a nivel de tipo de objeto, no de instancia
   --DBMS_OUTPUT.PUT_LINE('El pais es: ' || nueva_direccion.pais);
END;

-- HERENCIA
CREATE OR REPLACE TYPE persona AS OBJECT (
  dni VARCHAR2(9),
  nombre VARCHAR2 (20),
  apellidos VARCHAR2 (50),
  -- Usaremos una funcion para mostrar info
  MEMBER FUNCTION info RETURN VARCHAR2
) NOT FINAL;

CREATE OR REPLACE TYPE BODY persona AS
 MEMBER FUNCTION info RETURN VARCHAR2 IS
  BEGIN
    RETURN 'DNI: ' || dni || ', Nombre: ' || nombre;
  END;
END;

-- Definimos el objeto ESTUDIANTE a partir del objeto persona
-- IMPORTANTE: Eso quiere decir que al crearlo hay que indicar sus
-- atributos
CREATE OR REPLACE TYPE estudiante UNDER persona(
  num_matricula INTEGER(6),
  ciclo VARCHAR(50)
) FINAL;

DECLARE
  var_estudiante estudiante := 
    estudiante('11111111A','Isaac','Newton',123456,'DAM');
  info_persona VARCHAR2(100);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Alumno: '|| var_estudiante.dni || ' Matricula: '
     || var_estudiante.num_matricula);
  info_persona := (var_estudiante AS persona).info;
  DBMS_OUTPUT.PUT_LINE('La persona es '|| info_persona);
END;


-- EJEMPLO METODO MAP
CREATE OR REPLACE TYPE profesor AS OBJECT (
	nombre VARCHAR2(50),
	apellidos VARCHAR2(100),
	dni VARCHAR2(9),
	salario INTEGER(5),
	asignatura VARCHAR2(50),
	MAP MEMBER FUNCTION ordenProfes RETURN VARCHAR2
) ;

CREATE OR REPLACE TYPE BODY profesor AS
	MAP MEMBER FUNCTION ordenProfes RETURN VARCHAR2 IS
	 BEGIN
		-- Utilizaremos el atributo DNI para ordenar
		RETURN (dni);
	END ordenProfes;
END;

DECLARE
    profe1 profesor := profesor('Isaac','Newton','11111111A',0,'Fisica');
    profe2 profesor := profesor('Bill','Gates','2222222A',0,'Informatica');
BEGIN
    IF profe1 > profe2 THEN
    	DBMS_OUTPUT.PUT_LINE('El profe1 es MAYOR ');
    ELSE 
		DBMS_OUTPUT.PUT_LINE('El profe2 es MAYOR (o son iguales) ');
    END IF;
END;

-- EJEMPLO METODO ORDER
CREATE OR REPLACE TYPE profesor AS OBJECT (
	nombre VARCHAR2(50),
	apellidos VARCHAR2(100),
	dni VARCHAR2(9),
	salario INTEGER(5),
	asignatura VARCHAR2(50),
	ORDER MEMBER FUNCTION ordenProfes (p profesor)RETURN INTEGER
) ;

CREATE OR REPLACE TYPE BODY profesor AS
	ORDER MEMBER FUNCTION ordenProfes (p profesor) RETURN INTEGER IS
	 BEGIN
       -- Utilizaremos el atributo DNI para ordenar
	   IF (SELF.dni) < (p.dni) THEN RETURN -1;
	   ELSIF (SELF.dni) > (p.dni) THEN RETURN 1;
	   ELSE RETURN 0;
	   END IF;
	END ordenProfes;
END;

DECLARE
    profe1 profesor := profesor('Isaac','Newton','11111111A',0,'Fisica');
    profe2 profesor := profesor('Bill','Gates','2222222A',0,'Informatica');
BEGIN
    IF profe1 > profe2 THEN
    	DBMS_OUTPUT.PUT_LINE('El profe1 es MAYOR ');
    ELSE 
		DBMS_OUTPUT.PUT_LINE('El profe2 es MAYOR (o son iguales) ');
    END IF;
END;
