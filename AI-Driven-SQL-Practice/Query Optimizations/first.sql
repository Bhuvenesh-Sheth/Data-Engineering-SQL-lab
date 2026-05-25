

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

-- ============================================
-- Q4: IN vs EXISTS (with correct correlation!)
-- ============================================

-- Original IN query:
-- SELECT emp_name, salary FROM employees
-- WHERE emp_id IN (SELECT emp_id FROM monthly_sales
--                  WHERE sales_amount > 50000);

-- Optimized with EXISTS:
-- EXISTS is faster because it stops at first match
-- IN loads entire subquery result into memory first
SELECT e.emp_name, e.salary
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM monthly_sales m
    WHERE m.emp_id = e.emp_id          -- correlated condition!
    AND m.sales_amount > 50000
);
-- ============================================
-- Q5: TEMP TABLE FOR REUSE
-- ============================================

-- Create temp table ONCE with all needed columns
CREATE TEMPORARY TABLE top_earners AS
SELECT emp_id, emp_name, department, city, salary
FROM employees
WHERE salary > 80000;

-- Analysis 1: Count high earners per department
SELECT department, COUNT(*) AS earner_count
FROM top_earners
GROUP BY department;

-- Analysis 2: Average salary per city
SELECT city, ROUND(AVG(salary), 2) AS avg_salary
FROM top_earners
GROUP BY city;

-- Analysis 3: Analytics department only
SELECT emp_id, emp_name, salary
FROM top_earners
WHERE department = 'Analytics';

-- ============================================
-- Q6: WINDOW FUNCTION vs GROUP BY
-- ============================================

-- GROUP BY collapses rows — use when you need summary only:
-- SELECT department, AVG(salary) FROM employees GROUP BY department;

-- Window Function preserves all rows — use when you need
-- both individual data AND aggregate side by side:
SELECT
    emp_id,
    emp_name,
    department,
    salary,
    ROUND(AVG(salary) OVER (PARTITION BY department), 2) AS dept_avg_salary
FROM employees;

-- ============================================
-- Q7: FINAL BOSS — OPTIMIZED FRESHER QUERY
-- ============================================

-- Original bad query:
-- SELECT *
-- FROM employees e, monthly_sales m         -- Problem 1: old comma join syntax
-- WHERE e.emp_id = m.emp_id
-- AND YEAR(e.join_date) = 2023              -- Problem 2: function on indexed col
-- AND e.emp_id IN (SELECT emp_id            -- Problem 3: IN instead of EXISTS
--                  FROM monthly_sales
--                  WHERE sales_amount > 40000)
-- ORDER BY e.salary DESC;                   -- Problem 4: SELECT * wasteful

-- Fully optimized rewrite:
WITH emp_2023 AS (
    SELECT emp_id, emp_name, department, salary
    FROM employees
    WHERE join_date BETWEEN '2023-01-01' AND '2023-12-31'
),
high_sales AS (
    SELECT DISTINCT emp_id
    FROM monthly_sales
    WHERE sales_amount > 40000
)
SELECT
    e.emp_name,
    e.department,
    e.salary,
    m.month_name,
    m.sales_amount
FROM emp_2023 e
JOIN monthly_sales m ON e.emp_id = m.emp_id
WHERE EXISTS (
    SELECT 1 FROM high_sales h WHERE h.emp_id = e.emp_id
)
ORDER BY e.salary DESC;

-- EXPLAIN on final query:
EXPLAIN
WITH emp_2023 AS (
    SELECT emp_id, emp_name, department, salary
    FROM employees
    WHERE join_date BETWEEN '2023-01-01' AND '2023-12-31'
),
high_sales AS (
    SELECT DISTINCT emp_id
    FROM monthly_sales
    WHERE sales_amount > 40000
)
SELECT
    e.emp_name,
    e.department,
    e.salary,
    m.month_name,
    m.sales_amount
FROM emp_2023 e
JOIN monthly_sales m ON e.emp_id = m.emp_id
WHERE EXISTS (
    SELECT 1 FROM high_sales h WHERE h.emp_id = e.emp_id
)
ORDER BY e.salary DESC;
