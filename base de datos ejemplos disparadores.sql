-- EJEMPLO DE DECLARACION DE TRIGGER
-- Primero creamos la tabla sobre la que basaremos el trigger
CREATE TABLE alumno (
    id_alumno NUMBER(2) PRIMARY KEY,
    dni_alumno VARCHAR2(10),
    nombre_alumno VARCHAR2(10) NOT NULL    
);
-- Creamos tambien la tabla en la que almacenaremos info desde el trigger
CREATE TABLE historicoAlumnos(
    operacion VARCHAR2(100),
    fecha DATE DEFAULT SYSDATE -- Por defecto tendra la fecha y hora del dia
);
-- Creamos el trigger
CREATE OR REPLACE TRIGGER auditoriaCambiosAlumnos
BEFORE UPDATE ON alumno
FOR EACH ROW
BEGIN
    IF (:OLD.id_alumno = :NEW.id_alumno) THEN
    	IF (:OLD.dni_alumno = :NEW.dni_alumno) THEN
    		INSERT INTO historicoAlumnos(operacion) 
    			VALUES (USER || ' ha modificado el nombre alumno del valor ' || :OLD.nombre_alumno || ' al valor ' || :NEW.nombre_alumno);    
    	ELSE
        	INSERT INTO historicoAlumnos(operacion) 
            	VALUES (USER ||' ha modificado el dni alumno del valor ' || :OLD.dni_alumno || ' al valor ' || :NEW.dni_alumno);
    	END IF;
	ELSE
    	INSERT INTO historicoAlumnos(operacion) 
        	VALUES (USER ||' ha modificado el id alumno del valor ' || :OLD.id_alumno || ' al valor ' || :NEW.id_alumno);
	END IF;
END;
-- Hacemos la carga inicial de datos de la tabla
INSERT INTO alumno (id_alumno, nombre_alumno) 
    SELECT student_id-700, first_name 
    FROM AD.AD_STUDENT_DETAILS;
-- Comprobamos que el trigger no se ha activado con el INSERT
SELECT * FROM historicoAlumnos;
-- Hacemos una modificacion en la tabla
UPDATE alumno SET dni_alumno='11111111-1' WHERE id_alumno=10;
-- Comprobamos la activacion del trigger
SELECT operacion,TO_CHAR(fecha, 'DD/MM/YY HH:MI') FROM historicoAlumnos;
-- Hacemos otra modificacion
UPDATE alumno SET dni_alumno='11111111-A' WHERE id_alumno=10;
-- Comprobamos la activacion
SELECT operacion,TO_CHAR(fecha, 'DD/MM/YY HH:MI') FROM historicoAlumnos;
-- Hacemos una modificacion masiva para comprobar FOR EACH ROW del trigger
UPDATE alumno SET dni_alumno = RPAD(id_alumno,10,id_alumno); -- Repetimos el ID del alumno 10 veces
-- Comprobamos la activacion
SELECT operacion,TO_CHAR(fecha, 'DD/MM/YY HH:MI') FROM historicoAlumnos;

-- EJEMPLOS IF INSERTING E IF UPDATING E IF DELETING
-- Borramos la tabla de log e historico
DROP TABLE historicoAlumnos;
-- Creamos una nueva estructura
CREATE TABLE historicoAlumnos(
    usuario VARCHAR2(20) DEFAULT USER,
    operacion VARCHAR2(10),
    identificador NUMBER(4),
    valor_antiguo VARCHAR2(10),
    valor_nuevo VARCHAR2(10),
    fecha DATE DEFAULT SYSDATE -- Por defecto tendra la fecha y hora del dia
);
-- Modificamos tambien el trigger
CREATE OR REPLACE TRIGGER auditoriaCambiosAlumnos
AFTER UPDATE OR INSERT OR DELETE ON alumno
FOR EACH ROW
BEGIN
    IF DELETING THEN 
		INSERT INTO historicoAlumnos(operacion, identificador, valor_antiguo, valor_nuevo) VALUES ('BORRADO', :OLD.id_alumno, 'FILA', NULL);    
	ELSIF INSERTING THEN
        INSERT INTO historicoAlumnos(operacion, identificador,valor_antiguo, valor_nuevo) VALUES ('CREACION', :NEW.id_alumno,NULL, 'FILA'); 
	ELSE
        IF (:OLD.id_alumno = :NEW.id_alumno) THEN
        	IF (:OLD.dni_alumno = :NEW.dni_alumno) THEN
	        	INSERT INTO historicoAlumnos(operacion, identificador,valor_antiguo, valor_nuevo) VALUES ('MOD.NOMBRE', :OLD.id_alumno, :OLD.nombre_alumno, :NEW.nombre_alumno);
        	ELSE
	        	INSERT INTO historicoAlumnos(operacion, identificador,valor_antiguo, valor_nuevo) VALUES ('MOD.DNI', :OLD.id_alumno, :OLD.dni_alumno, :NEW.dni_alumno);
        	END IF;
    	ELSE
	        INSERT INTO historicoAlumnos(operacion, identificador,valor_antiguo, valor_nuevo) VALUES ('MOD.ID', :OLD.id_alumno, :OLD.id_alumno, :NEW.id_alumno);         
    	END IF;
	END IF;
END;
-- Actualizamos, borramos e insertamos datos de la tabla alumno
UPDATE alumno SET dni_alumno = id_alumno;

DELETE FROM alumno WHERE id_alumno=10;

INSERT INTO alumno VALUES(10,NULL,'10');
-- Comprobamos como ha quedado en la tabla historica
SELECT * FROM historicoAlumnos;

-- EJEMPLO TRIGGER INSTEAD OF
-- Creamos la vista
CREATE VIEW nombresDnisAlumnos AS
SELECT dni_alumno, nombre_alumno FROM alumno WHERE dni_alumno IS NOT NULL;
-- Comprobamos el contenido de la vista
SELECT * FROM nombresDnisAlumnos;
-- Devuelve un error
INSERT INTO nombresDnisAlumnos (dni_alumno, nombre_alumno) VALUES ('99','OSCAR');
-- Creamos el trigger para incluir en el codigo el valor que falta
CREATE OR REPLACE TRIGGER insertarNombreDniAlumno
INSTEAD OF INSERT ON nombresDnisAlumnos
BEGIN
    INSERT INTO alumno (id_alumno, nombre_alumno, dni_alumno)
    	VALUES(TO_NUMBER(:NEW.dni_alumno), :NEW.nombre_alumno, :NEW.dni_alumno);
END;
-- Comprobamos como ha quedado en la tabla historica
SELECT * FROM historicoAlumnos;
