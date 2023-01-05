
select *  
from scott.emp
;

select empno as numero_empleado, ename nombre_empleado,  
    job cargo, mgr numero_jefe, hiredate "fecha de contratacion",  
    sal sueldo, comm comision, deptno departamento 
from scott.emp empleados
;

select job 
from scott.emp 
group by job
;

select ename 
from scott.emp 
group by job
;

select job,count(*) 
from scott.emp 
group by job
;

select deptno,job,count(*) 
from scott.emp 
group by job, deptno
;

select deptno,extract(year from hiredate) as antiguedad,count(*) 
from scott.emp 
group by deptno,extract(year from hiredate) 
order by 1 asc
;

select deptno,count(*) 
from scott.emp 
group by job, deptno 
having extract(year from hiredate)>1981
;

select deptno,extract(year from hiredate) as antiguedad,count(*) 
from scott.emp 
where job <> 'MANAGER' 
group by deptno,extract(year from hiredate) 
having deptno > 10 
order by 1 asc
;



select * from co.order_items
;

SELECT line_item_id linea, product_id producto, unit_price precio unitario, quantity cantidad  
FROM co.order_items
;

SELECT line_item_id "linea", product_id "producto", unit_price "precio unitario", quantity "cantidad"  
FROM co.order_items
;

SELECT line_item_id "linea", product_id "producto", unit_price "precio unitario", quantity "cantidad", unit_price * quantity "total"  
FROM co.order_items
;

SELECT line_item_id "linea",   
    product_id "producto",   
    unit_price "precio unitario",   
    quantity "cantidad",   
    unit_price * quantity AS "total"  
FROM CO.ORDER_ITEMS
;

SELECT line_item_id || product_id "Producto",   
    unit_price "Precio unitario",   
    quantity "Cantidad",   
    unit_price * quantity AS "Total"  
FROM CO.ORDER_ITEMS
;

SELECT line_item_id & product_id "Producto",   
    unit_price "Precio unitario",   
    quantity "Cantidad",   
    unit_price * quantity AS "Total"  
FROM CO.ORDER_ITEMS
;

SELECT line_item_id && product_id "Producto",   
    unit_price "Precio unitario",   
    quantity "Cantidad",   
    unit_price * quantity AS "Total"  
FROM CO.ORDER_ITEMS
;

SELECT * FROM CO.CUSTOMERS
;

SELECT full_name || email_address "Cliente" FROM CO.CUSTOMERS
;

SELECT full_name || "-" || email_address "Cliente" FROM CO.CUSTOMERS
;

SELECT product_id "Codigo Producto",   
    unit_price "Precio unitario",   
    quantity "Cantidad",   
    line_item_id "Descuento",  
    unit_price * quantity AS "Total SIN descuento",  
    unit_price * quantity - line_item_id AS "Total CON descuento"  
FROM CO.ORDER_ITEMS
;

SELECT MOD(9,2) FROM DUAL
;

SELECT MOD(9,2) "Resto" FROM DUAL
;

SELECT ROUND(9.66,1) FROM DUAL
;

SELECT TRUNC(9.66,1) FROM DUAL
;

SELECT CEIL(9.66) FROM DUAL
;

select sysdate-3 from dual
;

select to_char(sysdate, 'DD-MM-YYYY HH24:MI:SS') as "Fecha y hora del sistema (obtenido con sysdate)", 
	systimestamp "Fecha y hora en formato timestamp"
from dual
;
