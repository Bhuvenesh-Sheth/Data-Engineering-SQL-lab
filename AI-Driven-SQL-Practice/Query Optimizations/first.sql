

-- ============================================
-- Q1: CREATING INDEXES
-- ============================================

-- Single column indexes
CREATE INDEX idx_dept ON employees(department);
CREATE INDEX idx_city ON employees(city);

-- Composite index (department + city together)
CREATE INDEX idx_dept_city ON employees(department, city);

-- Query that best uses composite index:
SELECT emp_name, salary
FROM employees
WHERE department = 'Analytics' AND city = 'Pune';

--

 ============================================
-- Q2: EXPLAIN + REWRITING SLOW QUERY
-- ============================================

-- Original slow query (avoid YEAR() on indexed column):
-- SELECT * FROM employees WHERE YEAR(join_date) = 2023;
-- Problem 1: SELECT * fetches unnecessary columns
-- Problem 2: YEAR() function disables index on join_date

-- EXPLAIN on bad query:
EXPLAIN SELECT * FROM employees WHERE YEAR(join_date) = 2023;

-- Optimized query:
SELECT emp_id, emp_name, join_date
FROM employees
WHERE join_date BETWEEN '2023-01-01' AND '2023-12-31';

-- EXPLAIN on good query:
EXPLAIN SELECT emp_id, emp_name, join_date
FROM employees
WHERE join_date BETWEEN '2023-01-01' AND '2023-12-31';

-- ============================================
-- Q3: FILTER BEFORE JOIN USING CTE
-- ============================================

-- Original slow query:
-- SELECT * FROM employees e
-- JOIN monthly_sales m ON e.emp_id = m.emp_id
-- WHERE e.city = 'Pune';

-- Optimized: filter employees first, then join smaller set
WITH pune_employees AS (
    SELECT emp_id, emp_name, department, city
    FROM employees
    WHERE city = 'Pune'
)
SELECT
    p.emp_name,
    p.department,
    m.month_name,
    m.sales_amount
FROM pune_employees p
JOIN monthly_sales m ON p.emp_id = m.emp_id;

