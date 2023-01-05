-- Lista de empleados
SELECT * FROM scott.emp;

-- Lista de departamentos
SELECT * FROM scott.dept;

-- CRUCE ENTRE EMPLEADOS Y DEPARTAMENTOS, DE DEPARTAMENTOS CUYO CÓDIGO SEA MAYOR O IGUAL QUE 30
-- NOTA: El departamento de Operaciones (codigo de departamento 40) no tiene empleados.

-- CASO 1: (INNER) JOIN
-- En el resultado no debe aparecer el departamento de Operaciones
-- Formato no-ANSI
SELECT d.dname,
       e.ename
FROM   scott.dept d, scott.emp e
WHERE  d.deptno = e.deptno
AND    d.deptno >= 30
ORDER BY 1,2;

-- Formato ANSI (recordar que poner INNER JOIN es opcional)
SELECT d.dname,
       e.ename
FROM   scott.dept d
       JOIN scott.emp e ON d.deptno = e.deptno
WHERE  d.deptno >= 30
ORDER BY 1,2;

-- CASO 2: LEFT JOIN ENTRE DEPARTAMENTOS Y EMPLEADOS
-- En el resultado aparecera el departamento de Operaciones
-- Formato no-ANSI
SELECT d.dname,
       e.ename
FROM   scott.dept d, scott.emp e
WHERE  d.deptno = e.deptno (+)
AND    d.deptno >= 30
ORDER BY 1,2;

-- Formato ANSI (recordar que poner OUTER es opcional)
SELECT d.dname,
       e.ename
FROM   scott.dept d
       LEFT OUTER JOIN scott.emp e ON d.deptno = e.deptno
WHERE  d.deptno >= 30
ORDER BY 1,2;

-- CASO 3: RIGHT JOIN 
-- En el formato no-ANSI, no importa el orden (es lo mismo LEFT que RIGHT join)
-- Formato ANSI:
-- Si no cambiamos el orden de las tablas, el resultado sera diferente
-- (porque tendra mas peso la tabla Empleados, y no mostrara los Departamentos sin empleados)
SELECT d.dname,
       e.ename
FROM   scott.dept d
       RIGHT JOIN scott.emp e ON d.deptno = e.deptno
WHERE  d.deptno >= 30
ORDER BY 1,2;
-- Para obtener el mismo resultado, habra que invertir el orden de las tablas en el RIGHT JOIN
-- (dandole mas peso a la tabla de Departamentos)
SELECT d.dname,
       e.ename
FROM   scott.emp e
       RIGHT JOIN scott.dept d ON e.deptno = d.deptno 
WHERE  d.deptno >= 30
ORDER BY 1,2;

-- PARA LOS SIGUIENTES EJEMPLOS HEMOS CAMBIADO LAS CONULTAS, SIN FILTRAR POR EL NUMERO DE DEPARTAMENTO

-- CASO 4: FULL (OUTER) JOIN
-- Combina las filas de las dos tablas: si hay cruce, se muestra, si algun lado no tiene valores, los muestra tambien.
-- Formato NO ANSI:
SELECT d.dname,
       e.ename
FROM   scott.emp e, scott.dept d 
WHERE e.deptno = d.deptno (+)
UNION ALL
SELECT d.dname,
       e.ename
FROM   scott.dept d, scott.emp e 
WHERE d.deptno = e.deptno (+)
AND e.ename IS NULL
ORDER BY 1,2;

-- Formato ANSI:
SELECT d.dname,
       e.ename
FROM   scott.emp e
       FULL OUTER JOIN scott.dept d ON e.deptno = d.deptno
ORDER BY 1,2;

-- CASO 5: CROSS  JOIN
-- Es un producto cartesiano, por lo que no se indican condiciones en el join,
-- y se combinan todos los datos
-- Formato NO ANSI:
SELECT d.dname,
       e.ename
FROM   scott.emp e, scott.dept d
ORDER BY 1,2;

-- Formato ANSI:
SELECT d.dname,
       e.ename
FROM   scott.emp e
       CROSS JOIN scott.dept d
ORDER BY 1,2;

-- CASO 6: NATURAL  JOIN
-- Es una variante del INNER JOIN: las columnas ha cruzar se determinan automaticamente por su nombre.
-- Formato NO ANSI: No se puede hacer este tipo de consulta en formato no ANSI
-- Formato ANSI:
SELECT dname,
       ename
FROM   scott.emp
       NATURAL JOIN scott.dept
ORDER BY 1,2;
