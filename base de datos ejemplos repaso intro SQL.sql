-- Comprobación restricciones creadas en el sistema (Diccionario de datos)
SELECT * FROM user_cons_columns;
/* Creación de la tabla alumnos, CON restricción de clave primaria
 NOTA 1: De esta forma, automáticamente el SGBD crea un índice
 NOTA 2: Además, también automáticamente, se crea la restricción de unicidad */
CREATE TABLE alumnos (
    dni VARCHAR2(9) NOT NULL CONSTRAINT alumnos_pk PRIMARY KEY,
    id_alumno NUMBER NOT NULL,
    nombre VARCHAR2 (10),
    apellidos VARCHAR2(40)
);
-- Creación de la tabla clase, SIN restricción de clave primaria
CREATE TABLE clase (
    id_clase NUMBER NOT NULL,
    nombre VARCHAR2(10)
);
-- Comprobación restricciones creadas automáticamente por el sistema
SELECT * FROM user_cons_columns;
-- Modificación de la tabla clase, para añadir la clave primaria
ALTER TABLE clase 
ADD CONSTRAINT clase_id_clase PRIMARY KEY (id_clase);
-- Modificación de la tabla alumnos, para incluir una restricción de unicidad
ALTER TABLE alumnos 
ADD CONSTRAINT alumnos_id_alumno UNIQUE (id_alumno);
-- Comprobación restricciones creadas en el sistema
SELECT * FROM user_cons_columns;
-- Añadir una clave foránea (por ejemplo por relación 1:N entre alumno y clase)
ALTER TABLE alumnos 
ADD id_clase_fk NUMBER NOT NULL 
CONSTRAINT alumnos_id_clase_fk REFERENCES clase(id_clase);
-- Comprobación restricciones creadas en el sistema
SELECT * FROM user_cons_columns;



-- Todos los registros (filas) de la tabla empleados
 SELECT * FROM hr.employees;
 
/* Salario mas alto, mas bajo, total y promedio de todos los empleados
 NOTA: Se estan usando funciones de agrupacion, sin ningun GROUP BY
 Esto solo es posible porque se esta tomando toda la tabla como un grupo
*/
SELECT
    MAX(salary) AS "Salario Máximo", 
    MIN(salary) AS "Salario Mínimo", 
    SUM(salary) AS "Salario Plantilla",
    AVG(salary) AS "Salario Promedio",
    TRUNC(AVG(salary)) AS "Salario Promedio truncado",
    ROUND(AVG(salary)) AS "Salario Promedio redondeado"
FROM hr.employees;

/* Misma informacion anterior, por codigo de departamento
   y ordenada por el salario promedio
*/
SELECT department_id,
    MAX(salary) AS "Salario Máximo", 
    MIN(salary) AS "Salario Mínimo", 
    SUM(salary) AS "Salario Plantilla",
    AVG(salary) AS "Salario Promedio",
    TRUNC(AVG(salary)) AS "Salario Promedio truncado",
    ROUND(AVG(salary)) AS "Salario Promedio redondeado"
FROM hr.employees
GROUP BY department_id
ORDER BY 5;

-- Cuantos empleados hay en cada departamento?
-- (ordenado por numero de empleados)
SELECT department_id, COUNT(*)
FROM hr.employees
GROUP BY department_id
ORDER BY 2;

-- Cuantos empleados hay en los departamentos
-- de mas de 2 personas?
SELECT department_id, COUNT(*)
FROM hr.employees
GROUP BY department_id
HAVING COUNT(*) >=2 
ORDER BY 2;

-- La siguiente consulta da error (pq la condicion de un grupo no se pone en el WHERE)
SELECT department_id, COUNT(*)
FROM hr.employees
WHERE COUNT(*) >=2 
GROUP BY department_id
ORDER BY 2;

/* Lista de los nombres y apellidos, en mayuscula
    de los empleados del departamento 50*/
SELECT first_name, last_name, email, UPPER(first_name), LOWER(last_name), INITCAP(email)
FROM hr.employees
WHERE department_id=50;

/* Concatene @mycompany.com a las direcciones de correo
   de los empleados del departamento 50 */
SELECT first_name, last_name, email, LOWER(email)||'@mycompany.com'
FROM hr.employees
WHERE department_id=50;

-- Muestre la antiguedad (en meses) de los empleados, ordenada descendente
SELECT employee_id, first_name, last_name, hire_date,MONTHS_BETWEEN(sysdate, hire_date)
FROM hr.employees
ORDER BY 4 DESC;

-- Muestra el año de contratacion de los empleados
SELECT employee_id, first_name, last_name, hire_date,EXTRACT(year FROM hire_date)
FROM hr.employees
ORDER BY 4 DESC;

/* Sabiendo que los dos primeros caracteres del campo JOB_ID son el nombre
 del departamento, muestra el nombre del departamento de los empleados */
SELECT employee_id, first_name, last_name, job_id,SUBSTR(job_id,1,2)
FROM hr.employees
ORDER BY 4 DESC;

-- Lista de los empleados sin comisiones
SELECT * 
FROM hr.employees
WHERE commission_pct IS NULL;

-- Lista de sueldo+comisiones de los empleados
-- NOTA: Esta consulta no funciona cuando la comision es NULL
SELECT employee_id, first_name, last_name, salary, commission_pct, salary+commission_pct 
FROM hr.employees;

-- Con la funcion NVL sustituimos el valor en caso de NULL
SELECT employee_id, first_name, last_name, salary, commission_pct, salary + NVL(commission_pct,0) 
FROM hr.employees;

-- Lista de sueldo+comisiones * sueldo de los empleados
SELECT employee_id, first_name, last_name, salary, commission_pct, commission_pct * salary, 
salary + NVL2(commission_pct,commission_pct * salary,0) 
FROM hr.employees;

-- Comparativa de las fechas y horas del sistema
SELECT sysdate AS "Fecha y hora sysdate sin formatear", 
    TO_CHAR(sysdate, 'DD-MM-YYYY HH24:MI:SS') AS "Fecha y hora  con sysdate formateado", 
    systimestamp "Fecha y hora del sistema con systimestamp"
FROM dual;


