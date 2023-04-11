-- Crear la tabla con la que le daremos persistencia a los objetos en la base de datos
CREATE TABLE tabla_alumno (
    dni_alumno VARCHAR2(9) PRIMARY KEY,
    nombre_alumno VARCHAR2(50) NOT NULL,
    apellidos_alumno VARCHAR2(100),
    nota_alumno NUMBER(2)
);

-- Crear el tipo objeto (especificacion) con sus atributos y la declaracion de sus metodos (y opcionalmente, constructores)
CREATE OR REPLACE TYPE objeto_alumno AS OBJECT (
    -- Declaracion de atributos
	nombre VARCHAR2(50),
	apellidos VARCHAR2(100),
	dni VARCHAR2(9),
	calificacion NUMBER(2),
    -- Declaracion de metodos
    -- Declaracion de constructor explicito (solo con 3 parametros!)
	CONSTRUCTOR FUNCTION objeto_alumno(p_nombre VARCHAR2, p_apellidos VARCHAR2, p_dni VARCHAR2) RETURN SELF AS RESULT,
    -- Declaracion de otros metodos
	MEMBER PROCEDURE insertar_alumno,
	MEMBER PROCEDURE mostrar_alumno
);

-- Cuerpo del objeto
CREATE OR REPLACE TYPE BODY objeto_alumno AS
	CONSTRUCTOR FUNCTION objeto_alumno(p_nombre VARCHAR2, p_apellidos VARCHAR2, p_dni VARCHAR2) RETURN SELF AS RESULT IS
	 BEGIN
		DBMS_OUTPUT.PUT_LINE('Constructor ejecutado');
		SELF.nombre := p_nombre;
		SELF.apellidos := p_apellidos;
		SELF.dni := p_dni;
		SELF.calificacion := 0;
		RETURN;
	END;
    -- Procedimiento para dotar de persistencia al objeto
    -- MUY IMPORTANTE: La tabla tiene que existir previamente!
	MEMBER PROCEDURE insertar_alumno IS
	 BEGIN
		INSERT INTO tabla_alumno VALUES(dni, nombre, apellidos, calificacion);
	 END insertar_alumno;

	MEMBER PROCEDURE mostrar_alumno IS
	 BEGIN
		DBMS_OUTPUT.PUT_LINE('Nombre: ' || nombre);        
		DBMS_OUTPUT.PUT_LINE('Apellidos: ' || apellidos);
		DBMS_OUTPUT.PUT_LINE('DNI: ' || dni);
		DBMS_OUTPUT.PUT_LINE('Nota media: ' || calificacion);
	 END mostrar_alumno;
END;

-- Ejemplos
DECLARE
	mi_objeto_alumno1 objeto_alumno;
	mi_objeto_alumno2 objeto_alumno;
BEGIN
    -- Ejemplo de uso con el constructor implicito/por defecto (4 atributos)
    mi_objeto_alumno1 := objeto_alumno('Albert','Einstein','11111111',10);
    -- Desde PL/SQL tambien podemos acceder a los atributos del objeto creado
	DBMS_OUTPUT.PUT_LINE('Nombre desde PL/SQL: ' || mi_objeto_alumno1.nombre);
	mi_objeto_alumno1.mostrar_alumno;
	mi_objeto_alumno1.insertar_alumno;
    -- Ejemplo de uso con el constructor explicito (3 atributos)
    mi_objeto_alumno2 := objeto_alumno('Isaac','Newton','22222222');
    -- Desde PL/SQL tambien podemos acceder a los atributos del objeto creado
	DBMS_OUTPUT.PUT_LINE('Nota desde PL/SQL: ' || mi_objeto_alumno2.calificacion);
	mi_objeto_alumno2.mostrar_alumno();
	mi_objeto_alumno2.insertar_alumno;	
	-- En un entorno con una unica sesion y conexion, no es necesario el COMMIT
	--COMMIT;
END;

SELECT * FROM tabla_alumno;
