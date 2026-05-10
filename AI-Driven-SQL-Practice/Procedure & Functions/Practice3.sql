--Q2
DELIMITER $$

CREATE PROCEDURE get_by_location(
    IN p_cityname VARCHAR(50)     -- p_ prefix!
)
BEGIN
    SELECT dept_name
    FROM departments
    WHERE location = p_cityname;  -- clear!
END $$

DELIMITER ;

CALL get_by_location('Pune');

--Q3
DELIMITER $$

CREATE PROCEDURE get_max_salary(
    IN  p_dept_id   INT,
    OUT p_max_salary DECIMAL(10,2)   -- DECIMAL not INT!
)
BEGIN
    SELECT MAX(salary) INTO p_max_salary
    FROM employees
    WHERE dept_id = p_dept_id;       -- no GROUP BY!
END $$

DELIMITER ;

-- Call it!
CALL get_max_salary(3, @max_sal);
SELECT @max_sal AS max_salary;       -- see result!


-- Q4

-- APPROACH 1: Using OUT parameter (stores result!)
DELIMITER $$

CREATE PROCEDURE budget_check(
    IN  p_project_id INT,
    OUT p_status     VARCHAR(50)
)
BEGIN
    DECLARE proj_budget DECIMAL(15,2);

    SELECT budget INTO proj_budget    -- store budget first!
    FROM projects
    WHERE project_id = p_project_id;

    IF proj_budget > 500000 THEN      -- then categorise!
        SET p_status = 'High Budget';
    ELSEIF proj_budget > 200000 THEN
        SET p_status = 'Medium Budget';
    ELSE
        SET p_status = 'Low Budget';
    END IF;
END $$

DELIMITER ;

CALL budget_check(1, @status);
SELECT @status AS budget_category;   -- see result!

-- APPROACH 2: Direct SELECT with CASE (simpler!)
DELIMITER $$

CREATE PROCEDURE budget_check(
    IN p_project_id INT
)
BEGIN
    SELECT
        project_name,
        budget,
        CASE
            WHEN budget > 500000 THEN 'High Budget 🔥'
            WHEN budget > 200000 THEN 'Medium Budget 💰'
            ELSE                      'Low Budget 📈'
        END AS budget_category
    FROM projects
    WHERE project_id = p_project_id;
END $$

DELIMITER ;

CALL budget_check(1);   -- shows full result directly!
