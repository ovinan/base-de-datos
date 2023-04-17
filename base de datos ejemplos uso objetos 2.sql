-- Creamos un tipo de objeto
CREATE OR REPLACE TYPE tipo_obj_comida AS OBJECT(
    nombre VARCHAR2(100)
)NOT FINAL;

-- Comparacion VARCHAR
DECLARE
	comida1 VARCHAR2(100):= 'Pollo';
	comida2 VARCHAR2(100):= 'Merluza';
BEGIN
    IF (comida1 < comida2) THEN
        DBMS_OUTPUT.PUT_LINE('El nombre del 1er objeto comida es anterior al 2o');
    ELSE
        DBMS_OUTPUT.PUT_LINE('El nombre del 1er objeto comida es anterior al 2o');
    END IF;
END;

-- Comparacion objetos: devolver error pq no hay metodo MAP ni ORDER
DECLARE
	comida1 tipo_obj_comida := tipo_obj_comida('Pollo');
	comida2 tipo_obj_comida := tipo_obj_comida('Merluza');
BEGIN
    DBMS_OUTPUT.PUT_LINE('El 1er objeto comida es:' || comida1.nombre);
    DBMS_OUTPUT.PUT_LINE('El 2o objeto comida es:' || comida2.nombre);
	-- Comparando objetos:
    IF (comida1 < comida2) THEN
        DBMS_OUTPUT.PUT_LINE('El nombre del 1er objeto comida es anterior al 2o');
    ELSE
        DBMS_OUTPUT.PUT_LINE('El nombre del 1er objeto comida es anterior al 2o');
    END IF;
END;

-- Ejemplo creando un metodo MEMBER
CREATE OR REPLACE TYPE tipo_obj_comida AS OBJECT(
    nombre VARCHAR2(100),
	MAP MEMBER FUNCTION func_map_comida RETURN VARCHAR2
)NOT FINAL;

CREATE OR REPLACE TYPE BODY tipo_obj_comida AS
	MAP MEMBER FUNCTION func_map_comida RETURN VARCHAR2 IS
	 BEGIN
	    -- Para ordenar los objetos usaremos el orden alfabetico
		RETURN nombre;
	 END;
END;

-- Comparacion objetos
DECLARE
	comida1 tipo_obj_comida := tipo_obj_comida('Pollo');
	comida2 tipo_obj_comida := tipo_obj_comida('Merluza');
BEGIN
    DBMS_OUTPUT.PUT_LINE('El 1er objeto comida es:' || comida1.nombre);
    DBMS_OUTPUT.PUT_LINE('El 2o objeto comida es:' || comida2.nombre);
	-- Comparando objetos:
    IF (comida1 < comida2) THEN
        DBMS_OUTPUT.PUT_LINE('El nombre del 1er objeto comida es anterior al 2o');
    ELSE
        DBMS_OUTPUT.PUT_LINE('El nombre del 1er objeto comida es anterior al 2o');
    END IF;
END;

-- Volvemos a crear el tipo de objeto COMIDA para ejemplos de herencia con metodos
CREATE OR REPLACE TYPE tipo_obj_comida AS OBJECT(
    nombre VARCHAR2(100),
    MEMBER FUNCTION calorias RETURN NUMBER,
	MAP MEMBER FUNCTION func_map_comida RETURN VARCHAR2
)NOT FINAL;

CREATE OR REPLACE TYPE BODY tipo_obj_comida AS
    MEMBER FUNCTION calorias RETURN NUMBER IS
     BEGIN
        -- Simulamos que las calorias son el num de letras del nombre
    	RETURN LENGTH(nombre);
     END;
	MAP MEMBER FUNCTION func_map_comida RETURN VARCHAR2 IS
	 BEGIN
	    -- Para ordenar los objetos usaremos el orden alfabetico
		RETURN nombre;
	 END;
END;

-- Creamos el tipo de objeto POSTRE como subtipo de COMIDA:
-- Todo POSTRE sera una COMIDA, pero toda COMIDA es un postre
CREATE OR REPLACE TYPE tipo_obj_postre UNDER tipo_obj_comida(
   ingredientes VARCHAR2(50),
   instrucciones VARCHAR2(100)
)NOT FINAL;

-- Esta instruccion dara error, pq el supertipo ya tiene un
-- metodo MAP.
CREATE OR REPLACE TYPE tipo_obj_tarta UNDER tipo_obj_postre(
	diametro NUMBER,
    ORDER MEMBER FUNCTION func_order(par_obj_tarta tipo_obj_tarta) RETURN NUMBER
);

-- Este podria ser un ejemplo de objeto con metodo ORDER
-- (no funcionara por el error en la instruccion anterior)
-- Si se quieren borrar los tipos para corregir el error, ver nota al final.
CREATE OR REPLACE TYPE tipo_obj_tarta AS
	ORDER MEMBER FUNCTION func_order(par_obj_tarta tipo_obj_tarta) RETURN NUMBER
	 BEGIN
		-- Utilizaremos el atributo DIAMETRO para ordenar
		IF SELF.diametro < par_obj_tarta.diametro THEN RETURN -1;
		ELSIF SELF.diametro > par_obj_tarta.diametro THEN RETURN 1;
		ELSE 
			RETURN 0;
		END IF;
	 END;
END;

-- Podemos continuar con el ejemplo sin borrar los tipos y sin crear el ORDER
CREATE OR REPLACE TYPE tipo_obj_tarta UNDER tipo_obj_postre(
	diametro NUMBER
);

DECLARE
	comida1 tipo_obj_comida := tipo_obj_comida('Pollo');
	postre1 tipo_obj_postre := tipo_obj_postre('Fresas con nata','Fresas, nata','1.Fresas, 2.Nata');
	tarta1 tipo_obj_tarta := tipo_obj_tarta('Tarta de la abuela','Chocolate, galletas', '1.Galletas, 2.Chocolate',25);
	calorias_tarta NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('El 1er objeto comida es:' || comida1.nombre || ', con las calorias:' || comida1.calorias);
	-- Accedemos a un atributo del objeto PADRE (o SUPERTIPO) desde uno de los SUBTIPOS
    DBMS_OUTPUT.PUT_LINE('Postre: Nombre como alimento: ' || postre1.nombre || ' Atributos como postre: ' || postre1.ingredientes);
	-- Accedemos a un metodo del objeto PADRE (o SUPERTIPO) desde uno de los SUBTIPOS
	calorias_tarta := (tarta1 AS tipo_obj_comida).calorias;
    DBMS_OUTPUT.PUT_LINE('Tarta: ' || tarta1.nombre || ' Calorias usando el metodo SUPERTIPO:' || calorias_tarta);
END;


-- NOTA:
-- Si intentasemos borrar los tipos de objetos, para cambiar la definicion
-- del supertipo, Oracle no lo permite porque hay herencia.
-- Hay que borrarlos en el orden inverso a como fueron creados.
DROP TYPE tipo_obj_tarta;

DROP TYPE tipo_obj_postre;

DROP TYPE tipo_obj_comida;
