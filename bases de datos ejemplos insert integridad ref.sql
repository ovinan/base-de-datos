/*
 REPASO JOINS, SUBCONSULTAS Y FUNCIONES DE AGREGADO (UNION, INTERSECT, MINUS,..)
 REQUISITOS: USAREMOS EL ESQUEMA HR DE LA BASE DE DATOS LIVESQL.ORACLE.COM
*/

-- Estructura de la tabla de empleados
DESC hr.employees;

SELECT * FROM hr.employees;

SELECT MAX(salary) AS "Salario Máximo", 
    MIN(salary) AS "Salario Mínimo", 
    SUM(salary) AS "Salario Planilla",
    ROUND(AVG(salary)) AS "Salario Promedio"
FROM hr.employees;

-- Sueldo medio por puesto
SELECT job_id,
    ROUND(AVG(salary)) AS "Salario Promedio"
FROM hr.employees
GROUP BY job_id
ORDER BY 2 DESC;

-- Cruce (Join, Composicion) con la tabla de puestos, para saber el nombre de cada puesto
-- Que pasa si hacemos un select de dos tablas, sin condiciones
-- 107 registros tiene la tabla de empleados
SELECT COUNT(*) FROM hr.employees;

-- 19 registros tiene la tabla de puestos
SELECT COUNT(*) FROM hr.jobs;

-- 2033 registros tiene la tabla de empleados x puestos: es el producto cartesiano
SELECT COUNT(*) FROM (SELECT * FROM hr.employees, hr.jobs);

-- En el producto cartesiano, muchas de las filas en realidad no tienen sentido (no estan relacionadas).
-- Por ejemplo, si hubiera puestos que no tienen ningun empleado.
-- El producto cartesiano cruza todas las posibilidades.
SELECT * FROM hr.employees, hr.jobs;

-- Ejemplo subconsulta: hay algun puesto que no tenga ningun empleado?
SELECT COUNT(*) 
FROM hr.jobs 
WHERE job_id NOT IN (SELECT job_id FROM hr.employees);

-- Metodo 1: FILTRAR SIN Join
SELECT *
FROM hr.employees E, hr.jobs J
WHERE J.job_id = E.job_id;

-- Contamos el resultado: 107 registros
SELECT COUNT(*) FROM (
    SELECT *
    FROM hr.employees E, hr.jobs J
    WHERE J.job_id = E.job_id
);

-- Metodo 2: FILTRAR CON Join
SELECT * 
FROM hr.employees E JOIN hr.jobs J
    ON J.job_id = E.job_id;

-- Contamos el resultado: 107 registros
SELECT COUNT(*) FROM (
    SELECT * 
    FROM hr.employees E JOIN hr.jobs J
        ON J.job_id = E.job_id
);

-- Volviendo a la consulta de salario medio por puesto
SELECT J.job_title, salary 
FROM hr.employees E JOIN hr.jobs J
    ON J.job_id = E.job_id;

-- Agrupando la consulta de salario medio por puesto
SELECT J.job_title, ROUND(AVG(salary)) 
FROM hr.employees E JOIN hr.jobs J
    ON J.job_id = E.job_id
GROUP BY J.job_title;

-- Ejemplo de UNION de consultas
-- Primero comparamos si tienen la misma estructura
DESC hr.employees;

DESC scott.emp;

SELECT employee_id, first_name FROM hr.employees
UNION
SELECT empno, ename FROM scott.emp;

-- Para identificar de que tabla vienen cada uno
SELECT employee_id, first_name, 'HR' FROM hr.employees
UNION
SELECT empno, ename, 'SCOTT' FROM scott.emp;

-- Ejemplo de agregado y subconsulta en el FROM
SELECT grupo, count(numero)
FROM
    (SELECT employee_id numero, first_name nombre, 'HR' grupo FROM hr.employees
    UNION
    SELECT empno numero, ename nombre, 'SCOTT' grupo FROM scott.emp) supertabla
GROUP BY grupo;

-- Otro ejemplo de subconsulta, para ver si hay valores repetidos entre las 2 tablas
SELECT 'Numero de IDs de HR en SCOTT', count(*)
FROM hr.employees WHERE employee_id IN (select empno FROM scott.emp)
UNION
SELECT 'Numero de IDs de SCOTT en HR', count(*)
FROM scott.emp WHERE empno IN (select employee_id FROM hr.employees)

-- Comprobacion
SELECT 'Datos HR' origen,MIN(employee_id) minimo, MAX(employee_id) maximo
FROM hr.employees
UNION
SELECT 'Datos EMP',MIN(empno), MAX(empno)
FROM scott.emp;


/*
 OPCIONES PARA EL TRATAMIENTO DE LOS DATOS: INSERCION, ACTUALIZACION Y BORRADO DE REGISTROS
 REQUISITOS: USAREMOS EL ESQUEMA SCOTT DE LA BASE DE DATOS LIVESQL.ORACLE.COM
*/

-- Borramos las tablas, por si existen de alguna ejecucion anterior
drop table empleados;

drop table departamentos;

-- Creamos las tablas
CREATE TABLE departamentos (
  num_departamento   NUMBER(2) CONSTRAINT pk_departamentos PRIMARY KEY,
  nombre_departamento VARCHAR2(14),
  ciudad        VARCHAR2(13)
);

CREATE TABLE empleados (
  num_empleado   NUMBER(4) CONSTRAINT pk_empleados PRIMARY KEY,
  nombre_empleado VARCHAR2(10),
  puesto           VARCHAR2(9),
  num_jefe    NUMBER(4),
  fecha_contrato      DATE,
  sueldo        NUMBER(7,2),
  commision    NUMBER(7,2),
  num_departamento NUMBER(2) CONSTRAINT emp_departmento_id_fk REFERENCES departamentos(num_departamento)
);

-- Insertar valores especificando los nombres de las columnas
INSERT INTO departamentos (num_departamento, nombre_departamento, ciudad) VALUES (90,'INFORMATICA','SEVILLA');

-- Insertar valores sin indicar las columnas
-- NOTA: El problema surgiria si la estructura de la tabla cambiase
INSERT INTO departamentos VALUES (95,'I+D','MALAGA');

-- Comprobamos que la tabla DEPT del esquema SCOTT tiene la misma estructura
DESC scott.dept;

SELECT * FROM scott.dept;

-- Insertar valores usando una subconsulta
INSERT INTO departamentos SELECT * FROM scott.dept;

SELECT * FROM departamentos;

INSERT INTO empleados SELECT * FROM scott.emp;

-- Actualizar valores
UPDATE departamentos SET ciudad='CADIZ' WHERE nombre_departamento='INFORMATICA';

SELECT * FROM departamentos;

-- Actualizar valores usando una subconsulta
UPDATE departamentos SET ciudad= (SELECT ciudad FROM departamentos WHERE nombre_departamento='I+D') 
WHERE num_departamento >= 90;

SELECT * FROM departamentos;

-- Empleados de cada departamento
-- NOTA: Al hacer LEFT JOIN salen tb los departamentos sin empleado
SELECT nombre_departamento, nombre_empleado
FROM departamentos D LEFT JOIN empleados E
    ON d.num_departamento = e.num_departamento;

-- Agrupamos para tener el num de empleados
SELECT nombre_departamento, COUNT(E.num_empleado)
FROM departamentos D LEFT JOIN empleados E
    ON d.num_departamento = e.num_departamento
GROUP BY nombre_departamento;

INSERT INTO empleados (num_empleado, nombre_empleado, num_departamento) VALUES (9999,'Oscar',90);

-- Aunque no hemos puesto restriccion de integridad referencial,
-- (ON DELETE XXXX) no deja borrar porque existe la restriccion
-- de clave foranea.
DELETE FROM departamentos WHERE num_departamento = 90;

-- Si borrarmos la restriccion..
ALTER TABLE empleados DROP CONSTRAINT emp_departmento_id_fk;

-- ..ya nos permite borrar el registro del departamento
DELETE FROM departamentos WHERE num_departamento = 90;
-- ...pero no borra al empleado:
SELECT * FROM empleados WHERE num_departamento=90;

-- Si volvemos a crear el departamento
INSERT INTO departamentos (num_departamento, nombre_departamento, ciudad) VALUES (90,'INFORMATICA','SEVILLA');

-- ..y creamos nuevamente la restriccion del borrado en cascada
ALTER TABLE empleados 
  ADD CONSTRAINT emp_departamento_id_fk 
  FOREIGN KEY (num_departamento) 
  REFERENCES departamentos(num_departamento) 
  ON DELETE CASCADE;

-- ..podremos borrar el departamento:
DELETE FROM departamentos WHERE num_departamento = 90;
--  ..y automaticamente nos borra el empleado:
-- IMPORTANTE: Como lo hace automaticamente, a veces esto es peligroso, ya que
-- sin querer podemos borrar elementos que no queremos. Por este motivo, en
-- muchas empresas no se habilita esta integridad referencial automatica
SELECT * FROM empleados WHERE num_departamento=90;