select *  
from scott.emp;

select job 
from scott.emp 
group by job;

select ename 
from scott.emp 
group by job;

select job,count(*) 
from scott.emp 
group by job;

select deptno,job,count(*) 
from scott.emp 
group by job, deptno;

select deptno,extract(year from hiredate) as antiguedad,count(*) 
from scott.emp 
group by deptno,extract(year from hiredate) 
order by 1 asc;

select deptno,count(*) 
from scott.emp 
group by job, deptno 
having extract(year from hiredate)>1981;

select deptno,extract(year from hiredate) as antiguedad,count(*) 
from scott.emp 
where job <> 'MANAGER' 
group by deptno,extract(year from hiredate) 
having deptno > 10 
order by 1 asc;

