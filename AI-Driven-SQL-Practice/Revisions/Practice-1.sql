-- Q: Show total budget per department
--    only where budget is over 5 lakhs.

-- ❌ My attempt (space in alias, missing table alias!)
SELECT d.dept_name, SUM(p.budget) AS Dept_ budget
FROM departments d
JOIN projects ON d.dept_id = p.dept_id
GROUP BY d.dept_name
HAVING Dept_ budget > 500000;

-- ✅ Correct version
SELECT d.dept_name, SUM(p.budget) AS dept_budget
FROM departments d
JOIN projects p ON d.dept_id = p.dept_id  -- alias p added!
GROUP BY d.dept_name
HAVING SUM(p.budget) > 500000;            -- full expression!

-- 💎 Optimal version
SELECT
    d.dept_name,
    SUM(p.budget)           AS dept_budget,
    COUNT(p.project_id)     AS total_projects,
    ROUND(AVG(p.budget), 2) AS avg_project_budget
FROM departments d
JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_name
HAVING SUM(p.budget) > 500000
ORDER BY dept_budget DESC;

-- 💡 Rules learned:
-- No spaces in aliases! use_underscore ✅
-- HAVING uses full expression not alias!
-- WHERE filters rows, HAVING filters groups!
-- SQL order: FROM→JOIN→WHERE→GROUP BY→HAVING→SELECT→ORDER BY

-- Q: Find clients whose city is NOT
--    in any employee work location.

-- ❌ My attempt (column name typo!)
SELECT client_name FROM clients
WHERE city NOT IN (
    SELECT locations FROM departments  -- ❌ extra 's'!
);

-- ✅ Correct version
SELECT client_name FROM clients
WHERE city NOT IN (
    SELECT location FROM departments
    WHERE location IS NOT NULL         -- NULL safety!
);

-- 💎 Optimal version (NOT EXISTS — safer + faster!)
SELECT c.client_name, c.city
FROM clients c
WHERE NOT EXISTS (
    SELECT 1 FROM departments d
    WHERE d.location = c.city
);

-- 💡 NOT IN vs NOT EXISTS:
-- NOT IN fails silently with NULLs!
-- NOT EXISTS handles NULLs safely!
-- Large datasets → always prefer NOT EXISTS!
-- Q: Show departments where average salary
--    is between 40,000 and 80,000.

-- ❌ My attempt (semicolon in CTE, dept_id missing,
--               HAVING without GROUP BY!)
WITH avg_dept AS (
    SELECT AVG(salary) AS "Average Salary"
    FROM employees
    GROUP BY dept_id;                          -- ❌ semicolon!
)
SELECT d.dept_name, ad."Average Salary"
FROM departments d
JOIN avg_dept AS ad ON d.dept_id = ad.dept_id
HAVING "Average Salary" BETWEEN 40000 AND 80000; -- ❌

-- ✅ Correct version
WITH avg_dept AS (
    SELECT
        dept_id,                               -- include for JOIN!
        AVG(salary) AS avg_salary              -- no spaces in alias!
    FROM employees
    GROUP BY dept_id                           -- no semicolon!
)
SELECT d.dept_name, ad.avg_salary
FROM departments d
JOIN avg_dept ad ON d.dept_id = ad.dept_id
WHERE ad.avg_salary BETWEEN 40000 AND 80000    -- WHERE not HAVING!
ORDER BY ad.avg_salary DESC;

-- 💎 Optimal version (full dept stats!)
WITH dept_stats AS (
    SELECT
        dept_id,
        AVG(salary)   AS avg_salary,
        MIN(salary)   AS min_salary,
        MAX(salary)   AS max_salary,
        COUNT(emp_id) AS employee_count
    FROM employees
    GROUP BY dept_id
)
SELECT
    d.dept_name,
    ROUND(ds.avg_salary, 2) AS avg_salary,
    ds.min_salary,
    ds.max_salary,
    ds.employee_count
FROM departments d
JOIN dept_stats ds ON d.dept_id = ds.dept_id
WHERE ds.avg_salary BETWEEN 40000 AND 80000
ORDER BY ds.avg_salary DESC;

-- 💡 Rules learned:
-- No semicolons inside CTEs!
-- Always include JOIN column in CTE SELECT!
-- No spaces in aliases!
-- CTE already grouped → use WHERE not HAVING!

-- Q: Show employees whose salary is higher
--    than their manager's salary.

-- ❌ My attempt (wrong JOIN syntax!)
SELECT e.name, e.salary,
[m.name FROM employees e
JOIN employees on m
WHERE e.salary > m.salary
AND e.manager_id = m.emp_id;]

-- ✅ Correct version
SELECT
    e.name   AS employee_name,
    e.salary AS employee_salary,
    m.name   AS manager_name
FROM employees e
JOIN employees m ON e.manager_id = m.emp_id  -- SELF JOIN!
WHERE e.salary > m.salary;

-- 💎 Optimal version (shows salary difference!)
SELECT
    e.name              AS employee_name,
    e.salary            AS employee_salary,
    m.name              AS manager_name,
    m.salary            AS manager_salary,
    (e.salary-m.salary) AS salary_difference
FROM employees e
JOIN employees m ON e.manager_id = m.emp_id
WHERE e.salary > m.salary
ORDER BY salary_difference DESC;

-- 💡 SELF JOIN rules:
-- Same table, two different aliases!
-- e = employee perspective
-- m = manager perspective
-- ON e.manager_id = m.emp_id → the link!
-- No square brackets in SQL! []
-- Q: Find departments that have
--    more than 3 employees.

-- ❌ My attempt (not correlated — returns multiple rows!)
SELECT dept_name FROM departments
WHERE (
    SELECT COUNT(emp_id) FROM employees
    GROUP BY dept_id          -- ❌ returns multiple rows!
) > 3;

-- ✅ Correct version (correlated subquery!)
SELECT d.dept_name
FROM departments d
WHERE (
    SELECT COUNT(emp_id)
    FROM employees e
    WHERE e.dept_id = d.dept_id  -- 👈 correlation link!
) > 3;

-- 💎 Optimal version (CTE — better performance!)
WITH dept_count AS (
    SELECT
        dept_id,
        COUNT(emp_id) AS emp_count
    FROM employees
    GROUP BY dept_id
)
SELECT
    d.dept_name,
    dc.emp_count
FROM departments d
JOIN dept_count dc ON d.dept_id = dc.dept_id
WHERE dc.emp_count > 3
ORDER BY dc.emp_count DESC;

-- 💡 Correlated vs Non-Correlated:
-- Non-correlated → runs ONCE, fixed result
-- Correlated     → runs ONCE PER ROW!
-- Correlation = inner query references outer column!
-- WHERE e.dept_id = d.dept_id ← this is correlation!
-- CTE version calculates ONCE → better performance!
-- Q: Show employees working more than 1 year
--    with experience in years as decimal.

-- ❌ My attempt (extra commas in CAST!)
WITH experience AS (
    SELECT emp_id,
           DATEDIFF(CURDATE(), join_date)/365 AS exp
    FROM employees
)
SELECT e.name,
       CAST(e.salary, AS DECIMAL(10,2),  -- ❌ commas!
       ex.exp
FROM employees e
JOIN experience ex ON e.emp_id = ex.emp_id
WHERE exp > 1;

-- ✅ Correct version
WITH experience AS (
    SELECT
        emp_id,
        DATEDIFF(CURDATE(), join_date)/365 AS exp
    FROM employees
)
SELECT
    e.name,
    CAST(e.salary AS DECIMAL(10,2)) AS salary,  -- no commas!
    ROUND(ex.exp, 1)                AS experience_years
FROM employees e
JOIN experience ex ON e.emp_id = ex.emp_id
WHERE ex.exp > 1
ORDER BY ex.exp DESC;

-- 💎 Optimal version (seniority labels!)
WITH experience AS (
    SELECT
        emp_id,
        ROUND(DATEDIFF(CURDATE(), join_date)/365, 1) AS exp_years,
        DATE_FORMAT(join_date, '%d-%m-%Y')           AS join_date
    FROM employees
)
SELECT
    e.name,
    CAST(e.salary AS DECIMAL(10,2)) AS salary,
    ex.exp_years                    AS experience_years,
    ex.join_date                    AS joined_on,
    CASE
        WHEN ex.exp_years < 1 THEN 'Fresher'
        WHEN ex.exp_years < 3 THEN 'Junior'
        WHEN ex.exp_years < 5 THEN 'Mid-Level'
        ELSE                       'Senior'
    END                             AS seniority
FROM employees e
JOIN experience ex ON e.emp_id = ex.emp_id
WHERE ex.exp_years > 1
ORDER BY ex.exp_years DESC;

-- 💡 CAST syntax rule:
-- CAST(column AS datatype)  ✅
-- No commas inside CAST!
-- Space before AS not comma!
-- Q: Find employees working on projects
--    with budget ABOVE average project budget.

-- ⚠️ My attempt (used dept connection instead
--               of emp_projects bridge table!)
SELECT e.name, p.project_name, p.budget
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN projects p ON p.dept_id = d.dept_id       -- ⚠️
WHERE p.budget > (SELECT AVG(budget) FROM projects);

-- ✅ Correct version (via emp_projects bridge!)
SELECT e.name, p.project_name, p.budget
FROM employees e
JOIN emp_projects ep ON e.emp_id = ep.emp_id
JOIN projects p ON ep.project_id = p.project_id
WHERE p.budget > (
    SELECT AVG(budget) FROM projects
)
ORDER BY p.budget DESC;

-- 💎 Optimal version (shows role + difference!)
SELECT
    e.name                                    AS employee_name,
    p.project_name,
    p.budget,
    ep.role,
    (p.budget -
    (SELECT AVG(budget) FROM projects))       AS above_avg_by
FROM employees e
JOIN emp_projects ep ON e.emp_id = ep.emp_id
JOIN projects p ON ep.project_id = p.project_id
WHERE p.budget > (
    SELECT AVG(budget) FROM projects
)
ORDER BY p.budget DESC;

-- 💡 Key distinction:
-- "Working ON project" = emp_projects bridge table!
-- "Dept has project"   = dept_id link!
-- Always re-read question carefully! 🔍
-- Q: Find most experienced employee per department
--    Show name, dept, formatted join date, experience.

-- ❌ My attempt (semicolon in CTE, wrong table
--               in subquery, CTEs not used!)
WITH mini AS (
    SELECT MIN(join_date) AS exp
    FROM employees
    GROUP BY dept_id;              -- ❌ semicolon!
)
match AS (                         -- ❌ missing comma!
    SELECT name FROM employees e
    WHERE join_date IN (
        SELECT exp FROM employees  -- ❌ wrong table!
    )
    GROUP BY dept_id               -- ❌ wrong place!
)
SELECT e.name, d.dept_name,
       DATE_FORMAT(join_date, '%d-%m-%Y') AS Joining_Date
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id; -- ❌ CTEs unused!

-- ✅ Correct version
WITH mini AS (
    SELECT
        dept_id,                   -- include for JOIN!
        MIN(join_date) AS earliest_date
    FROM employees
    GROUP BY dept_id               -- no semicolon!
),                                 -- comma not semicolon!
match_emp AS (
    SELECT e.emp_id, e.name, e.dept_id, e.join_date
    FROM employees e
    JOIN mini m ON e.dept_id = m.dept_id
    WHERE e.join_date = m.earliest_date  -- match date!
)
SELECT
    me.name,
    d.dept_name,
    DATE_FORMAT(me.join_date, '%d-%m-%Y')        AS joining_date,
    ROUND(DATEDIFF(CURDATE(),me.join_date)/365,1) AS experience_years
FROM match_emp me
JOIN departments d ON me.dept_id = d.dept_id
ORDER BY experience_years DESC;

-- 💎 Optimal version (Window Function preview!)
WITH most_experienced AS (
    SELECT
        e.name,
        e.dept_id,
        e.join_date,
        ROUND(DATEDIFF(CURDATE(),e.join_date)/365,1) AS exp_years,
        ROW_NUMBER() OVER(
            PARTITION BY e.dept_id
            ORDER BY e.join_date ASC
        ) AS rank_num
    FROM employees e
)
SELECT
    me.name,
    d.dept_name,
    DATE_FORMAT(me.join_date,'%d-%m-%Y') AS joining_date,
    me.exp_years                         AS experience_years
FROM most_experienced me
JOIN departments d ON me.dept_id = d.dept_id
WHERE me.rank_num = 1
ORDER BY me.exp_years DESC;

-- 💡 Rules learned:
-- Comma between CTEs, no second WITH!
-- No semicolons inside CTEs!
-- Subquery must reference correct table!
-- Always use CTEs in main query!
-- ROW_NUMBER() OVER(PARTITION BY) = Window preview!
