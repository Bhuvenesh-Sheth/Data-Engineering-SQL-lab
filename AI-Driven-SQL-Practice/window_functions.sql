

--5) 
select emp_id, month_name, sale_amount, LEAD(sale_amount) over( partition by emp_id) as next_month_sales,
CASE
    when LEAD(sale_amount) over( partition by emp_id) > sale_amount then 'UP'
    when LEAD(sale_amount) over( partition by emp_id) < sale_amount then 'DOWN'
    else 'END'
end as tread
from monthly_sales;

--Q6)
select month_name, sales_amount, sum(sales_amount) over (order by month_num asec) as running_total from monthly_sales;

--Q7)
select emp_name,department, salary, avg(salary) over (partition by department ) as dept_avg, 
  sum(salary) over (partition by department) as dept_total, 
  if(salary > (avg(salary) over (partition by department ) as dept_avg),'ABOVE','BELOW') as vs_avg
from monthly_sales;

--q8)

with sal_percent as(
  select salary /sum(salary) over (partition by department) * 100 as emp_dept_percent from employees;
),

  liimit as(
  select name,salary, dense_rank(salary partition by department order by desc) as dept_rank from employees;
)
  
select name,department,salary, dense_rank(salary) over (partition by department) as sal_rank, 
  sum(salary) over (partition by department order by salary desc) as sum_total, 
