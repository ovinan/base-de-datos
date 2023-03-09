/*
	CREACION DE TABLAS PARA UN DIAGRAMA ENTIDAD RELACION CON UNA ENTIDAD ALUMNO QUE SE MATRICULA EN
	VARIAS ASIGNATURAS, QUE A SU VEZ SON IMPARTIDAS POR UN PROFESOR.
	NOTA: Si se crean claves foraneas o ajenas, el orden de creacion de las tablas es importante,
	ya que no se pueden crear dichas claves si no existen previamente las tablas a las que se refieren.
	Por ejemplo, en nuestro caso no podemos crear la tabla ASIGNATURA si no existe antes la tabla
	PROFESOR.
*/

-- NOTA: id_alumno y dni_alumno son claves candidatas, id_alumno es la clave principal.
CREATE TABLE alumno (
    id_alumno NUMBER(2) PRIMARY KEY,
    dni_alumno VARCHAR2(10),
    nombre_alumno VARCHAR2(10) NOT NULL    
);
  
CREATE TABLE profesor(
    id_profe NUMBER(2) PRIMARY KEY,
    nombre_profe VARCHAR2(10),
    titulacion VARCHAR2(10)
);

-- NOTA: id_profe es una clave foranea o ajena.
CREATE TABLE asignatura(
    cod_asignatura NUMBER(2) PRIMARY KEY,    
    nombre_asignatura VARCHAR2(10),
    id_profe NUMBER(2) CONSTRAINT id_profe_fk REFERENCES profesor(id_profe)
);

-- NOTA: La clave foranea tambien se puede crear de forma simplificada
CREATE TABLE matricula(
    id_alumno NUMBER(2) REFERENCES alumno (id_alumno),
    cod_asignatura NUMBER(2) REFERENCES asignatura(cod_asignatura),
    fecha_matricula DATE
);

/* EJEMPLOS DE INSERCION, MODIFICACION Y BORRADO DE DATOS MEDIANTE SQL */
INSERT INTO profesor VALUES (1, 'Steve Jobs', 'Ingeniero');

INSERT INTO profesor (id_profe, nombre_profe, titulacion) VALUES (2, 'Bill Gates', 'Doctor');

INSERT INTO profesor VALUES (3, 'Steve Jobs', NULL);

SELECT * from profesor;

INSERT INTO asignatura VALUES(1,'BD DAM',1);

INSERT INTO asignatura VALUES(2,'BD DAW',1);

INSERT INTO asignatura (cod_asignatura, nombre_asignatura) VALUES(3,'PROGRAM.');

INSERT INTO asignatura (cod_asignatura, nombre_asignatura,id_profe) VALUES(4,'PROG.MOVIL',3);

-- Comprobacion de la modificacion realizada
SELECT * from asignatura;

UPDATE profesor SET titulacion=NULL WHERE id_profe=2;

-- Comprobacion de la modificacion realizada
SELECT * from profesor;

DELETE FROM profesor WHERE id_profe=2;

/* EJEMPLOS DE INSERCION, MODIFICACION Y BORRADO DE DATOS MEDIANTE SUBCONSULTAS */

-- Comprobacion de datos origen
SELECT * FROM AD.AD_STUDENT_DETAILS;

INSERT INTO alumno (id_alumno, nombre_alumno) SELECT student_id, first_name FROM AD.AD_STUDENT_DETAILS;

INSERT INTO alumno (id_alumno, nombre_alumno) SELECT student_id-700, first_name FROM AD.AD_STUDENT_DETAILS;

-- Comprobacion de la modificacion realizada
SELECT * from alumno;

UPDATE alumno SET id_alumno = id_alumno / 10;

-- Comprobacion de la modificacion realizada
SELECT * from alumno;

/* EJEMPLOS RESTRICCIONES SOBRE TABLAS */
ALTER TABLE alumno ADD CONSTRAINT dnis_no_repes UNIQUE (dni_alumno);

ALTER TABLE profesor MODIFY (nombre_profe VARCHAR2(10) CONSTRAINT nombre_profe_not_null  NOT NULL);

ALTER TABLE matricula ADD CONSTRAINT matricula_mayor_2000 CHECK (fecha_matricula BETWEEN TO_DATE('01-01-2000', 'dd-mm-yyyy') AND TO_DATE('31-12-9999', 'dd-mm-yyyy'));

/* EJEMPLO NVL */
SELECT nombre_alumno, dni_alumno, NVL(dni_alumno,'00000000-0') as dni_procesado
FROM alumno;

/* EJEMPLO BUCLE PL/SQL */
BEGIN
	FOR contador_alumno IN 1..8 LOOP
    	-- NOTA: Observar que utilizamos la funcion CURRENT_DATE de SQL
		INSERT INTO matricula (id_alumno,cod_asignatura,fecha_matricula) VALUES (contador_alumno,1, CURRENT_DATE);
	END LOOP;
END;

SELECT * FROM matricula;

-- Ejemplo de actualizacion mediante subconsulta
UPDATE matricula SET cod_asignatura = 2 
WHERE id_alumno IN (SELECT id_alumno FROM alumno WHERE nombre_alumno LIKE 'N%')

-- Ejemplo de borrado mediante subconsulta
DELETE FROM matricula
WHERE id_alumno IN (SELECT id_alumno FROM alumno WHERE nombre_alumno LIKE 'R%')

SELECT * FROM matricula;

-- EJEMPLO SUBCONSULTA: Profesores que no imparten ninguna asignatura
-- NOTA: Hay que utilizar la funcion NVL porque sino los valores nulos desvirtuan el resultado
SELECT * FROM profesor WHERE id_profe NOT IN (SELECT NVL(id_profe,99) FROM asignatura) 

-- EJEMPLO SUBCONSULTA: Asignaturas sin profesor
SELECT * FROM asignatura WHERE id_profe IS NULL

-- EJEMPLO INNER JOIN: Nombres de profes y asignaturas que imparten
SELECT nombre_profe, nombre_asignatura
FROM profesor P JOIN asignatura A
ON p.id_profe = a.id_profe

-- EJEMPLO LEFT JOIN: Nombres de profes y asignaturas que imparten
-- NOTA: Al ser LEFT JOIN, mostrara tambien profes sin asignaturas
SELECT nombre_profe, nombre_asignatura
FROM profesor P LEFT JOIN asignatura A
ON p.id_profe = a.id_profe

-- EJEMPLO RIGHT JOIN: Nombres de profes y asignaturas que imparten
-- NOTA: Al ser RIGHT JOIN, mostrara tambien asignaturas sin profes
SELECT nombre_profe, nombre_asignatura
FROM profesor P RIGHT JOIN asignatura A
ON p.id_profe = a.id_profe

-- Al crear la clave ajena, automaticamente Oracle impedirá borrar registros padre con hijos
-- En nuestro caso, por ejemplo, profesores con cursos. 
DELETE FROM profesor where nombre_profe='Oscar'

-- Borramos la restriccion cuyo codigo nos indica el mensaje de error
ALTER TABLE asignatura DROP CONSTRAINT id_profe_fk;

-- Modificamos la restriccion de clave ajena en la tabla hija, para que haga borrado en cascada
ALTER TABLE asignatura 
  ADD CONSTRAINT id_profe_fk_cascada
  FOREIGN KEY (id_profe) 
  REFERENCES profesor(id_profe) 
  ON DELETE CASCADE;

-- Sigue dando error, en este caso porque el borrado en cascada afecta a una asignatura que tiene alumnos
DELETE FROM profesor WHERE nombre_profe='Oscar';

-- Buscamos si hay algun profesor con asignaturas pero sin alumnos
SELECT id_profe FROM asignatura WHERE cod_asignatura NOT IN (SELECT cod_asignatura FROM matricula);

-- Este registro si que lo deja borrar
DELETE FROM profesor WHERE id_profe=3;

-- EJEMPLO FUNCIONES AGREGADO Y SUBCONSULTAS: Todos los nombres de persona en la base de datos
SELECT nombre_alumno FROM alumno
UNION
SELECT nombre_profe FROM profesor

-- Preparacion de datos para el siguiente ejemplo
INSERT INTO profesor VALUES (4, 'JACK', NULL);

INSERT INTO asignatura (cod_asignatura, nombre_asignatura,id_profe) VALUES(5,'PROCESOS',4);

INSERT INTO matricula (id_alumno, cod_asignatura) VALUES (2,5);

-- EJEMPLO SUBCONSULTA: Datos de los alumnos que se llamen igual que algun profesor
SELECT *
FROM alumno A
WHERE EXISTS(
    SELECT P.id_profe
	FROM profesor P
	WHERE P.nombre_profe = A.nombre_alumno);

-- EJEMPLO SUBCONSULTA: Datos de los alumnos de las asignaturas de BD
SELECT *
FROM alumno A,
    (SELECT id_alumno, fecha_matricula
	FROM matricula
	WHERE cod_asignatura = (SELECT cod_asignatura FROM asignatura WHERE nombre_asignatura='BD DAM')) BD
WHERE BD.id_alumno = A.id_alumno
