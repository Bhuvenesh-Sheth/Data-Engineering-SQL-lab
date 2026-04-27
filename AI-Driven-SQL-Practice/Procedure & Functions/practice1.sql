/* Q1 — Basic Procedure | 30 XP
Scenario: "Create a procedure that shows ALL employees with their department names!" */

DELIMITER $$                     -- ✅ correct spelling!

CREATE PROCEDURE emp_dept()
BEGIN
    SELECT 
        e.name      AS employee_name,
        d.dept_name AS department
    FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
    ORDER BY d.dept_name, e.name;
END $$

DELIMITER ;                      -- ✅ restore delimiter!

CALL emp_dept();                 -- ✅ call it!

/* Q2 — Procedure with IN Parameter | 30 XP
Scenario: "Create a procedure that accepts a department ID and returns all employees in that department!" */

DELIMITER $$

CREATE PROCEDURE dept_list(IN p_dept_id INT)
BEGIN
    SELECT 
        e.name        AS employee_name,
        e.salary      AS salary
    FROM employees e
    WHERE e.dept_id = p_dept_id
    ORDER BY e.name;
END $$

DELIMITER ;

CALL dept_list(3);

/* Q3 — Procedure with OUT Parameter | 40 XP
Scenario: "Create a procedure that accepts dept_id and returns the COUNT of employees in that department!" */

DELIMITER $$

CREATE PROCEDURE get_emp_count(
    IN  p_dept_id   INT,       -- p_ prefix!
    OUT p_emp_count INT
)
BEGIN
    SELECT COUNT(*) INTO p_emp_count
    FROM employees
    WHERE dept_id = p_dept_id;  -- clear now! ✅
END $$

DELIMITER ;

CALL get_emp_count(3, @count);
SELECT @count AS employee_count;

/* Q4 — Procedure with IF ELSE | 40 XP
Scenario: "Create a procedure that accepts emp_id and prints salary category: Above 70k = High, 40k-70k = Medium, Below 40k = Low!" */

DELIMITER $$

CREATE PROCEDURE sal_category(IN p_emp_id INT)
BEGIN
    DECLARE emp_sal DECIMAL(10,2);

    SELECT salary INTO emp_sal
    FROM employees
    WHERE emp_id = p_emp_id;      -- ✅ clear!

    IF emp_sal > 70000 THEN
        SELECT 'High Salary'   AS category;
    ELSEIF emp_sal > 40000 THEN   -- ✅ 40000!
        SELECT 'Medium Salary' AS category;
    ELSE
        SELECT 'Low Salary'    AS category;
    END IF;
END $$

DELIMITER ;                       -- ✅ space!

CALL sal_category(1);
