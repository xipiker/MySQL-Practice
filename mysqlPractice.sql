#> 1.取得每个部门最高薪水的人员名称。
select 
	e.deptno, max(e.sal) as maxsal 
from 
	emp e
group by 
	e.deptno
	
select 
	e.deptno, e.ename, t.maxsal, e.sal
from 
	t
join 
	emp e
on 
	t.deptno = e.deptno
where t.maxsal = e.sal 

select 
	e.deptno, e.ename, t.maxsal, e.sal
from 
	(select 
        e.deptno, max(e.sal) as maxsal 
    from 
        emp e
    group by 
        e.deptno) t
join 
	emp e
on 
	t.deptno = e.deptno
where t.maxsal = e.sal 
order by e.deptno
#> 2.哪些人的薪水在部门平均薪水之上。
select 
	e.deptno,avg(e.sal) as avgsal 
from emp e 
group by e.deptno

select 
	e.deptno, e.ename
from 
	(select 
			e.deptno,avg(e.sal) as avgsal 
		from emp e 
		group by e.deptno) t
join
	emp e 
on
	t.deptno = e.deptno
where e.sal > t.avgsal
#> 3.1 取得部门中所有人的平均薪水的等级。
select 
	t.deptno, t.avgsal, s.grade
from 
	(select 
			e.deptno,avg(e.sal) as avgsal 
		from emp e 
		group by e.deptno) t
join 
	salgrade s
on 
	t.avgsal between s.losal and s.hisal
	
#3.2 取得部门中所有人的平均的薪水等级。
select 
	e.deptno, e.ename, s.grade
from 
	emp e
join 
	salgrade s
on 
	e.sal between s.losal and s.hisal
order by e.deptno

select 
	t.deptno,avg(t.grade) avggrade
from 
	(select 
		e.deptno, e.ename, s.grade
	from 
		emp e
	join 
		salgrade s
	on 
		e.sal between s.losal and s.hisal) t
group by 
	t.deptno
	
#4.不准用组函数(MAX)，取得最高薪水(给出两种解决方案)。	
select sal from emp order by sal desc limit 1
select sal from emp where sal not in(
	select
		distinct a.sal
	from 
		emp a
	join 
		emp b
	on 
		a.sal < b.sal
)
#5.取得平均薪水最高的部门的部门编号。
select 
	e.deptno, avg(e.sal) as avgsal
from
	emp e
group by
	e.deptno

select 
	max(t.avgsal) as maxAvgSal 
from (
	select 
	e.deptno, avg(e.sal) as avgsal
from
	emp e
group by
	e.deptno
) t

select 
	e.deptno, avg(e.sal) as avgsal
from 
	emp e
group by 
	e.deptno
having avgsal = (select 
									max(t.avgsal) as maxAvgSal 
								from (
									select 
									e.deptno, avg(e.sal) as avgsal
								from
									emp e
								group by
									e.deptno
								) t)
#6.取得平均薪水最高的部门的部门名称
select 
	e.deptno, d.dname, avg(e.sal) as avgsal
from 
	emp e
join
    dept d
on 
    e.deptno = d.deptno
group by 
	e.deptno,d.dname
having avgsal = (select 
                    max(t.avgsal) as maxAvgSal 
                from (
                    select 
                    e.deptno, avg(e.sal) as avgsal
                from
                    emp e
                group by
                    e.deptno
                ) t)
#7.求平均薪水的等级最低的部门的部门名称
第一步:部门的平均薪水
select 
	e.deptno,d.dname, avg(e.sal) as avgsal
from 
	emp e
join
	dept d
on 
	e.deptno = d.deptno
group by 
	e.deptno, d.dname;
第二步:将以上的结果当成临时表t(deptno,avgsal)与salgrade表进行表连接:t.avgsal between s.local and s.hisal
select 
	t.deptno, t.dname, s.grade
from 
	(select 
		e.deptno,d.dname, avg(e.sal) as avgsal
	from 
		emp e
	join
		dept d
	on 
		e.deptno = d.deptno
	group by 
		e.deptno, d.dname) t
join 
	salgrade s
on 
	t.avgsal between s.losal and s.hisal
第三步:将以上查询结果当成一张临时表
select min(t.grade) as minGrade from (
	select 
		t.deptno, t.dname, s.grade
	from 
		(select 
			e.deptno,d.dname, avg(e.sal) as avgsal
		from 
			emp e
		join
			dept d
		on 
			e.deptno = d.deptno
		group by 
			e.deptno, d.dname) t
	join 
		salgrade s
	on 
		t.avgsal between s.losal and s.hisal
) t
第四步:
select 
	t.deptno, t.dname, s.grade
from 
	(select 
		e.deptno,d.dname, avg(e.sal) as avgsal
	from 
		emp e
	join
		dept d
	on 
		e.deptno = d.deptno
	group by 
		e.deptno, d.dname) t
join 
	salgrade s
on 
	t.avgsal between s.losal and s.hisal
where 
 s.grade = (
	select min(t.grade) as minGrade from (
		select 
			t.deptno, t.dname, s.grade
		from 
			(select 
				e.deptno,d.dname, avg(e.sal) as avgsal
			from 
				emp e
			join
				dept d
			on 
				e.deptno = d.deptno
			group by 
				e.deptno, d.dname) t
		join 
			salgrade s
		on 
			t.avgsal between s.losal and s.hisal
	) t
 )
# 8.取得比普通员工(员工代码没有在mgr上出现的)的最高薪水还要高的经理人名称。
# 第一步:找出mgr有哪些人
select distinct mgr from emp where mgr is not null 
# 第二步:除第一步以外全部都是普通员工(注意:not in 不会自动忽略空值，in会自动忽略空值)
select 
	max(sal) as maxSal 
from 
	emp 
where 
	empno not in(select distinct mgr from emp where mgr is not null)
# 第三步:比最高薪水还要高的经理人名称
select 
	ename 
from 
	emp 
where sal > (
	select 
		max(sal) as maxSal 
	from 
		emp 
	where 
		empno not in(select distinct mgr from emp where mgr is not null)
)
# 9.取得薪水最高的前五名员工
select * from emp order by sal desc limit 0,5

# 10.取得薪水最高的第六到第十员工
select * from emp order by sal desc limit 5,10

# 11.取得最后入职的5名职员
select * from emp order by hiredate desc limit 5

# 12.取得每个薪水等级有多少员工
# 第一步:查询出每个员工的薪水等级
select 
	e.ename, s.grade
from
	emp e
join 
	salgrade s
on 
	e.sal between s.losal and s.hisal
order by 
	s.grade

# 第二步:将以上查询结果当成临时表t(ename, grade)，按照t.ename进行count函数运算
select 
	t.grade, count(t.ename) as totalEmp
from 
	(
		select 
			e.ename, s.grade
		from
			emp e
		join 
			salgrade s
		on 
			e.sal between s.losal and s.hisal
		order by 
			s.grade
	) t
	group by 
		t.grade

# 14.查询所有员工及领导的名字(主要是所有这个关键字，所以使用外链接)
select 
	e.ename, b.ename as leaderName
from 
	emp e 
left join 
	emp b
on 
	e.mgr = b.empno
# 15.列出受雇日期早于其直接上级的所有员工编号、姓名、部门名称
select 
	d.dname,
	e.empno,
	e.ename
from 
	emp e
join 
	emp b
on 
	e.mgr = b.empno
join 
	dept d 
on 
	e.deptno = d.deptno
where 
	e.hiredate < b.hiredate
	
# 16.列出部门名称和这些部门的员工信息，同时列出那些没有员工的部门
select 
	d.dname,
	e.*
from 
	emp e
right join 
	dept d
on 
	e.deptno = d.deptno

	
# 17.列出至少有5个员工的所有部门。
# 第一步:先求出每个部门的员工数量
select
	e.deptno, count(e.ename) as totalEmp
from 
	emp e
group by 
	e.deptno
having 
	totalEmp >= 5
	
# 18.列出薪水比'SMITH'多的所有员工信息
# 第一步:
select sal from emp where ename = 'SMITH'
# 第二步:
select * from emp where sal > (select sal from emp where ename = 'SMITH')

# 19.列出所有'CLEAK'(办事员)的姓名及部门名称，部门人数。
# 第一步:列出所有'CLEAK'(办事员)的姓名及部门名称
select 
	d.deptno, d.dname, e.ename
from 
	emp e
join 
	dept d
on 
	e.deptno = d.deptno
where 
	e.job = 'CLERK'
# 第二步:求出每个部门的员工数量
select 
	e.deptno, count(e.ename) as totalEmp
from 
	emp e
group by 
	e.deptno
# 第三步:将以上两步进行组合
select 
	t1.deptno, t1.dname, t1.ename, t2.totalEmp
from 
	(
		select 
			d.deptno, d.dname, e.ename
		from 
			emp e
		join 
			dept d
		on 
			e.deptno = d.deptno
		where 
			e.job = 'CLERK'
	) t1
join 
	(
		select 
			e.deptno, count(e.ename) as totalEmp
		from 
			emp e
		group by 
			e.deptno
	) t2
on 
	t1.deptno = t2.deptno
# 20.列出最低薪水大于1500的各种工作及从事此工作的全部雇员人数
# 第一步:先求出每种工作岗位的最低薪水大于1500的员工
select 
	e.job, min(e.sal) as minSal
from 
	emp e
group by 
	e.job
having 
	minSal > 1500;
# 第二步:各种工作及从事此工作的全部雇员人数
select 
	e.job, min(e.sal) as minSal, count(e.ename) as totalEmp
from 
	emp e
group by 
	e.job
having 
	minSal > 1500;
# 21.列出在部门'SALES'<销售部>工作的员工的姓名，假定不知道销售部的部门编号。
select ename from emp where deptno = (
	select deptno from dept where dname = 'SALES'
)
# 22.列出薪金高于公司平均薪水的所有员工，所在部门、上级领导、雇员的工资等级。
# 第一步:求出公司的平均薪水
select avg(sal) as avgSal from emp
# 第二步:组合
select 
	d.dname,
	e.ename,
	b.ename as leaderName,
	s.grade
from 
	emp e
join 
	dept d
on 
	e.deptno = d.deptno
left join 
	emp b
on 
	e.mgr = b.empno
join 
	salgrade s
on 
	e.sal between s.losal and s.hisal
where 
	e.sal > (select avg(sal) as avgSal from emp)
# 23.列出与'SCOTT'从事相同工作的所有员工及部门名称
# 第一步:查询出SCOTT的工作岗位
select job from emp where ename = 'SCOTT'
# 第二步:
select 
	d.dname,
	e.*
from 
	emp e
join 
	dept d
on
	e.deptno = d.deptno
where 
	e.job = (select job from emp where ename = 'SCOTT')
# 24.列出薪金等于部门30中员工的薪金的其他员工的姓名和薪资
# 第一步:列出薪金等于部门30中员工的薪金
select distinct sal from emp where deptno = 30
# 第二步:其他员工的姓名和薪资
select ename, sal from emp where sal in(select distinct sal from emp where deptno = 30) and deptno <> 30

# 25.列出薪金高于在部门30工作的所有员工的薪资的员工姓名和薪资、部门名称
# 第一步:先找出部门30的最高薪水
select max(sal) as maxsal from emp where deptno = 30
select 
	d.dname,
	e.ename,
	e.sal
from 
	emp e
join 
	dept d
on 
	e.deptno = d.deptno
where 
	e.sal > (select max(sal) as maxsal from emp where deptno = 30)
# 26.列出在每个部门工作的员工数量、平均工资和平均服务期限
# to_days(日期类型)->天数
# 获取数据库的系统当前时间的函数是:now()
select ename, (to_days(now()) - to_days(hiredate))/365 as serveryear from emp;
select avg((to_days(now()) - to_days(hiredate))/365) as avgserveryear from emp;
select 
	e.deptno,
	count(e.ename) as totalEmp,
	avg(e.sal) as avgSal,
	avg((to_days(now()) - to_days(hiredate))/365) as avgserveryear
from 
	emp e
group by 
	e.deptno
	
# 27.列出所有员工的姓名、部门名称和工资。
select 
	d.dname,
	e.ename,
	e.sal
from 
	emp e
right join 
	dept d
on 
	e.deptno = d.deptno
	
# 28.列出所有部门的详情信息和人数。
select 
	d.deptno, d.dname, d.loc, count(e.ename) as totalEmp
from 
	emp e
right join 
	dept d
on 
	e.deptno = d.deptno
group by 
	d.deptno, d.dname, d.loc
# 29.列出各种工资的最低工资及从事此工作的雇员姓名。
# 第一步:列出各种工资的最低工资
select 
	e.job, min(e.sal) as minsal
from 
	emp e
group by 
	e.job
# 第二步:将以上查询结果当成临时表t(job, minsal)
select 
	e.ename
from 
	emp e
join 
	(select 
			e.job, min(e.sal) as minsal
		from 
			emp e
		group by 
			e.job) t
on 
	e.job = t.job
where 
	e.sal = t.minsal
# 30.列出各个部门MANAGER的最低薪水。
select 
	e.deptno, min(e.sal) as minSal
from 
	emp e
where 
	e.job = 'MANAGER'
group by 
	e.deptno
# 31.列出所有员工的年工资，按年薪从低到高排序
select ename, (sal + ifnull(comm, 0)) * 12 as yearSal from emp order by yearsal asc
# 32.求出员工领导的薪水超过3000的员工名称和领导名称
select 
	e.ename,
	b.ename as leaderName
from 
	emp e
join 
	emp b
on 
	e.mgr = b.empno
where 
	b.sal > 3000
	
# 33.求部门名称中带'S'字符的部门员工的工资合计、部门人数。
select 
	d.dname,
	sum(e.sal) as sumSal,
	count(e.ename) as totalEmp
	from 
		emp e
	join 
		dept d
	on 
		e.deptno = d.deptno
	where 
		d.dname like '%S%'
	group by 
		d.dname