

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
