CREATE TYPE lista_tel_t AS VARRAY(10) OF VARCHAR2(20);
/
CREATE TYPE direccion_t AS OBJECT (
	calle VARCHAR2(200),
	ciudad VARCHAR2(200),
	prov CHAR(2),
	codpos VARCHAR2(20)
) ;
/
CREATE TYPE clientes_t AS OBJECT (
	clinum NUMBER,
	clinomb VARCHAR2(200),
	direccion direccion_t,
	lista_tel lista_tel_t
) ;
/
CREATE TYPE item_t AS OBJECT (
	itemnum NUMBER,
	precio NUMBER,
	tasas NUMBER
) ;
/
CREATE TYPE linea_t AS OBJECT (
	linum NUMBER,
	item REF item_t,
	cantidad NUMBER,
	descuento NUMBER
) ;
/
CREATE TYPE lineas_pedido_t AS TABLE OF linea_t ;
/
CREATE TYPE ordenes_t AS OBJECT (
	ordnum NUMBER,
	cliente REF clientes_t,
	fechpedido DATE,
	fechentrega DATE,
	pedido lineas_pedido_t,
	direcentrega direccion_t
) ;
/
CREATE TABLE clientes_tab OF clientes_t
 (clinum PRIMARY KEY);
/
CREATE TABLE items_tab OF item_t
 (itemnum PRIMARY KEY) ;
/
CREATE TABLE ordenes_tab OF ordenes_t (
PRIMARY KEY (ordnum),
SCOPE FOR (cliente) IS clientes_tab
) NESTED TABLE pedido STORE AS pedidos_tab ;
/
ALTER TABLE pedidos_tab ADD (SCOPE FOR (item) IS items_tab) ;
/
-- ESTA INSTRUCCION FALLA (devuelve el error de que la columna no esta permitida aqui):
INSERT INTO clientes_tab
 VALUES (
 1, "Lola Caro",
 direccion_t("12 Calle Lisboa", "Nules", "CS", "12678"),
 lista_tel_t("415-555-1212")
 ) ;


