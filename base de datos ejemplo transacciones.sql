/*
  EJEMPLOS BASICOS TRANSACCIONES ORACLE (livesql.oracle.com)

  NOTA: Al estar diseñados para ejecutarse en livesql.oracle.com,
  hay algunas diferencias respecto al Oracle instalado directamente
  en el PC. Una de ellas, es que para ver el funcionamiento correctamente,
  hay que ir seleccionando el codigo por bloques.
*/

/*
  BLOQUE 1: Transaccion creando tabla e introduciendo registros,
  se puede observar que al hacer el rollback, se pierden los
  ultimos registros creados desde el commit.
*/
SET TRANSACTION NAME 'TRANSACCION_PRUEBA';

COMMIT;

CREATE TABLE prueba(col1 number, col2 number);

INSERT INTO prueba VALUES (1,2);

SELECT * FROM prueba;

COMMIT;

INSERT INTO prueba VALUES (2,4);

INSERT INTO prueba VALUES (3,6);

-- El ROLLBACK deshace desde el COMMIT
ROLLBACK;

SELECT * FROM prueba;

/*
  BLOQUE 2: Transaccion creando registros, con puntos de salvado
  intermedios. Se puede observar que al hacer el rollback hasta el
  savepoint, se pierden los ultimos registros creados desde el commit.

  NOTA: Usamos el comando EXEC antes de SAVEPOINT porque estamos en LiveSQL.Oracle.com
*/

EXEC SAVEPOINT PUNTO_INTERMEDIO1;

INSERT INTO prueba VALUES (4,8);

SELECT * FROM prueba;

EXEC SAVEPOINT PUNTO_INTERMEDIO2;

INSERT INTO prueba VALUES (5,10);

SELECT * FROM prueba;

-- Elimina lo ultimo que se ha hecho
ROLLBACK TO SAVEPOINT PUNTO_INTERMEDIO2;

SELECT * FROM prueba;

INSERT INTO prueba VALUES (6,12);

-- Elimina hasta el punto indicado
ROLLBACK TO SAVEPOINT PUNTO_INTERMEDIO1;

SELECT * FROM prueba;

INSERT INTO prueba VALUES (7,14);

SELECT * FROM prueba;

ROLLBACK;

SELECT * FROM prueba;
