
```sql
-- Q: Show all employee names with their department names.

SELECT e.name, d.dept_name 
FROM employees e 
JOIN departments d ON e.dept_id = d.dept_id;
```

---
