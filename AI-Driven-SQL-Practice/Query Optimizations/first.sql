

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

