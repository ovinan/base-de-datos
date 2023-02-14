-- Creamos dos tablas e introducimos valores
CREATE TABLE producto (
  id_producto   NUMBER(2) CONSTRAINT pk_producto PRIMARY KEY,
  nombre_producto VARCHAR2(10),
  descripcion_producto VARCHAR2(20)
);
CREATE TABLE pedido (
  id_pedido   VARCHAR2(10) CONSTRAINT pk_pedido PRIMARY KEY,
  id_producto NUMBER(2) CONSTRAINT pedido_producto_fk REFERENCES producto(id_producto)
);
INSERT INTO pedido values ('230214_001',99);
INSERT INTO producto (id_producto) values (99);
SELECT * from producto;
INSERT INTO pedido values ('230214_001',99);
SELECT * FROM pedido;

CREATE TABLE marca (
  id_marca NUMBER(2),
  nombre_marca VARCHAR2(10)
);
ALTER TABLE marca ADD CONSTRAINT pk_id_marca PRIMARY KEY (id_marca);

ALTER TABLE producto ADD id_marca NUMBER(2) CONSTRAINT producto_marca_fk REFERENCES marca(id_marca);

INSERT INTO producto (id_producto,id_marca) values (98,1);
INSERT INTO marca values (1,'Adidas');
INSERT INTO producto (id_producto,id_marca) values (98,1);
SELECT * FROM marca;

/* 
 Por defecto, si no se indica nada, la constraint es 
 ON DELETE RESTRICT, lo puedes probar con la siguientes consultas
 sobre las tablas marca y producto: dara error si existe alguna producto
 de esa marca, o lo mismo si intentamos borrar algun producto con un pedido.
 */
DELETE FROM marca;
DELETE FROM producto;

-- Si borramos la restriccion en PEDIDO, cambiandola a ON DELETE CASCADE...
ALTER TABLE pedido DROP CONSTRAINT pedido_producto_fk;

ALTER TABLE pedido 
  ADD CONSTRAINT pedido_producto_fk 
  FOREIGN KEY (id_producto) 
  REFERENCES producto(id_producto) 
  ON DELETE CASCADE;
-- ..si borramos un producto, tambien nos borra sus pedidos
SELECT * FROM producto;
SELECT * FROM pedido;
DELETE FROM producto WHERE id_producto=99;

-- Lista de todas las restricciones (constraints) en las tablas de usuarios
SELECT * FROM user_cons_columns;

-- Lista de todos los indices en las tablas de usuarios (version 1)
SELECT * FROM all_indexes WHERE table_name in (SELECT table_name FROM user_cons_columns);

-- Lista de todos los indices en las tablas de usuarios (version 2)
SELECT * FROM all_indexes WHERE tablespace_name='LIVESQL_USERS';

-- Creacion de un nuevo indice
CREATE INDEX producto_nombre_i ON producto(nombre_producto);

-- Podemos incluir restricciones sobre las tablas
-- Rangos de valores
ALTER TABLE marca ADD CONSTRAINT marca_mayor_cero CHECK (id_marca BETWEEN 1 AND 99);

INSERT INTO marca values (0,'Error');

-- Valores unicos
ALTER TABLE marca ADD CONSTRAINT nombres_no_repes UNIQUE (nombre_marca);

INSERT INTO marca values (2,'Adidas');

-- No nulos
ALTER TABLE marca MODIFY (nombre_marca VARCHAR2(10) CONSTRAINT nombre_no_vacio NOT NULL);

INSERT INTO marca (id_marca) values (2);

-- Tambien valores por defecto
ALTER TABLE producto MODIFY (nombre_producto VARCHAR2(10) DEFAULT 'Pte Nombre');

-- Creamos varios productos
INSERT INTO producto (id_producto,id_marca) values (97,1);
INSERT INTO producto (id_producto,id_marca) values (96,1);
INSERT INTO producto (id_producto) values (95);

select * from producto;


-- Usamos la tabla de productos para crear los pedidos a estos productos
-- (necesitaremos tambien la fecha y el numero de fila)
select sysdate,rownum,id_producto from producto;
-- Aplicamos el formato necesario
select to_char(sysdate,'YYMMDD')||'_'||lpad(rownum,3,'0'),id_producto from producto;
-- Hacemos el INSERT con la subconsulta
insert into pedido select to_char(sysdate,'YYMMDD')||'_'||lpad(rownum,3,'0'),id_producto from producto where id_producto <>98;

select * from pedido;

-- Ahora podemos hacer el JOIN para mostrar la marca de cada producto del pedido
select *
from pedido PE LEFT JOIN producto PR
ON PR.id_producto = PE.id_producto

-- Esta consulta da error pq no indicamos de que tabla queremos mostrar el id_producto
select id_pedido,id_producto, nvl(id_marca,0)
from pedido PE LEFT JOIN producto PR
ON PR.id_producto = PE.id_producto

select id_pedido,PR.id_producto, nvl(id_marca,0)
from pedido PE LEFT JOIN producto PR
ON PR.id_producto = PE.id_producto

-- Creamos una vista con el resultado de la consulta anterior
-- NOTA: Hay que indicar un alias para las columnas que sean un calculo o funcion
create view pedidos_marcas as (
    select id_pedido,PR.id_producto, nvl(id_marca,0) id_marca
    from pedido PE LEFT JOIN producto PR
    ON PR.id_producto = PE.id_producto
);

select * from pedidos_marcas;

-- Si insertamos un nuevo pedido..
INSERT INTO pedido values ('230214_999',98);

-- ..se actualiza automaticamente en la vista
select * from pedidos_marcas;

-- Otro ejemplo, de vista solo de los pedidos de una marca
create view pedidos_marca_1 as (
    select * from pedido where id_producto in (select id_producto from producto where id_marca=1)
);

select * from pedidos_marca_1;
