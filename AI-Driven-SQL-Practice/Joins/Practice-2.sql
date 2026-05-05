## Q1 — INNER JOIN Basic ✅ +10 XP

```sql
-- Q: Show all employee names with their department names.

SELECT e.name, d.dept_name 
FROM employees e 
JOIN departments d ON e.dept_id = d.dept_id;
```

---

## Q2 — INNER JOIN + Filter ✅ +9 XP

```sql
-- Q: Show employees from 'Technology' department only.

SELECT e.name, d.dept_name, e.salary 
FROM employees e 
JOIN departments d ON e.dept_id = d.dept_id 
WHERE d.dept_name = 'Technology';

-- ✅ Note: Always use single quotes for strings
```

---

## Q3 — LEFT JOIN ✅ +13 XP

```sql
-- Q: Show ALL departments even if they have no employees.

SELECT d.dept_name, e.name 
FROM departments d 
LEFT JOIN employees e ON d.dept_id = e.dept_id;

-- ✅ Note: departments on LEFT = all depts shown
-- NULL appears where no employee exists
```

---

## Q4 — RIGHT JOIN ⚠️ +7 XP

```sql
-- Q: Show ALL employees even if no department assigned.

-- ❌ My attempt (missing table name after RIGHT JOIN)
SELECT d.dept_name, e.name 
FROM departments AS d 
RIGHT JOIN ON d.dept_id = e.dept_id;

-- ✅ Correct version
SELECT d.dept_name, e.name 
FROM departments d
RIGHT JOIN employees e ON d.dept_id = e.dept_id;

-- 💡 Pro tip: RIGHT JOIN = flip tables + use LEFT JOIN
SELECT d.dept_name, e.name 
FROM employees e
LEFT JOIN departments d ON d.dept_id = e.dept_id;
```

---

## Q5 — 3-Table JOIN ✅ +13 XP

```sql
-- Q: Show employee names, project names and their roles.

-- ❌ My attempt (typo: "project" instead of "projects")
SELECT e.name, p.project_name, ep.role 
FROM employees e 
JOIN emp_projects ep ON e.emp_id = ep.emp_id 
JOIN project p ON p.project_id = ep.project_id;

-- ✅ Correct version
SELECT e.name, p.project_name, ep.role 
FROM employees e 
JOIN emp_projects ep ON e.emp_id = ep.emp_id 
JOIN projects p ON p.project_id = ep.project_id;

-- 💡 emp_projects = bridge table connecting both sides
```

---

## Q6 — JOIN + GROUP BY + ORDER BY ✅ +14 XP

```sql
-- Q: How many employees are in each department? 
--    Order by highest count first.

-- ❌ My attempt (typo: "cout" instead of "count")
SELECT d.dept_name, COUNT(e.emp_id) AS count 
FROM departments d 
JOIN employees e ON d.dept_id = e.dept_id 
GROUP BY d.dept_name 
ORDER BY cout DESC;

-- ✅ Correct + professional version
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d 
JOIN employees e ON d.dept_id = e.dept_id 
GROUP BY d.dept_name 
ORDER BY employee_count DESC;

-- 💡 Avoid using reserved words as aliases (count→employee_count)
-- 💡 COUNT(column) skips NULLs, COUNT(*) counts everything
```

---

## Q7 — SELF JOIN 💎 FLAWLESS +15 XP

```sql
-- Q: Show each employee with their manager's name.

SELECT e.name AS employee_name, m.name AS manager_name
FROM employees AS e 
INNER JOIN employees AS m ON e.manager_id = m.emp_id;

-- 💡 Same table, two aliases (e = employee, m = manager)
-- 💡 INNER JOIN hides employees with no manager (top bosses)

-- ✅ Bonus: Show ALL employees including top bosses
SELECT e.name AS employee_name, m.name AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;
-- manager_name = NULL for top-level managers
```

---

## Q8 — Mixed LEFT JOIN (3 Tables) ⚠️ +7 XP

```sql
-- Q: Show all clients with project names and departments.
--    Include clients even if project details are missing.

-- ❌ My attempt (missing table names after LEFT JOIN)
SELECT c.client_name, p.project_name, d.dept_name 
FROM clients AS c 
LEFT JOIN c.project_id = p.project_id 
LEFT JOIN p.dept_id = d.dept_id;

-- ✅ Correct version
SELECT c.client_name, p.project_name, d.dept_name
FROM clients c
LEFT JOIN projects p ON c.project_id = p.project_id

  
```sql
-- Q: Show all employee names with their department names.

SELECT e.name, d.dept_name 
FROM employees e 
JOIN departments d ON e.dept_id = d.dept_id;
```

---
LEFT JOIN departments d ON p.dept_id = d.dept_id;

