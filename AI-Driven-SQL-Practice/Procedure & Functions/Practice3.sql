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

-- Q5

DELIMITER $$
Create function calc_tax(p_salary decimal(10,2))
returns DECIMAL(10,2)
deterministic 
begin 
    declare tax_value DECIMAL(10,2);
    set tax_value = p_salary * 0.20;
return tax_value;
end $$
DELIMITER ;

select cal_tax(500000);
-- Q6

delimiter $$ 
create function get_grade(p_salary decimal(10,2))
returns varchar(5)
deterministic 
begin
    return(case
    when p_salary > 80000 then 'A'
    when p_salary > 60000 then 'B'
    when p_salary > 40000 then 'C'
    else 'D'
    end);

end $$
delimiter ;
    select cal_tax(500000);

-- Q7
DELIMITER $$
Create function calc_tax(p_salary decimal(10,2))
returns DECIMAL(10,2)
deterministic 
begin 
    declare tax_value DECIMAL(10,2);
    set tax_value = p_salary * 0.20;
return tax_value;
end $$
DELIMITER ;

delimiter $$ 
create function get_grade(p_salary decimal(10,2))
returns varchar(5)
deterministic 
begin
    return(case
    when p_salary > 80000 then 'A'
    when p_salary > 60000 then 'B'
    when p_salary > 40000 then 'C'
    else 'D'
    end);

end $$
delimiter ;

DELIMITER $$

CREATE PROCEDURE show_emp_tax_grade()
BEGIN
    SELECT
        e.name                    AS employee_name,
        e.salary                  AS salary,
        calc_tax(e.salary)        AS tax_amount,
        get_grade(e.salary)       AS grade,
        d.dept_name               AS department
    FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
    ORDER BY e.salary DESC;
END $$

DELIMITER ;

CALL show_emp_tax_grade();


-- Q8

DELIMITER $$

CREATE PROCEDURE emp_full_profile(IN p_emp_id INT)
BEGIN
    -- Step 1: Declare variables separately!
    DECLARE emp_sal  DECIMAL(10,2);
    DECLARE emp_name VARCHAR(100);
    DECLARE emp_dept VARCHAR(100);
    DECLARE join_dt  DATE;

    -- Step 2: Store raw values using INTO!
    SELECT
        e.name,
        e.salary,
        d.dept_name,
        e.join_date
    INTO
        emp_name,
        emp_sal,
        emp_dept,
        join_dt
    FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
    WHERE e.emp_id = p_emp_id;

    -- Step 3: Final SELECT using functions!
    SELECT
        emp_name                                AS employee_name,
        emp_dept                                AS department,
        emp_sal                                 AS salary,
        calc_tax(emp_sal)                       AS tax_amount,
        get_grade(emp_sal)                      AS grade,
        DATE_FORMAT(join_dt, '%d-%m-%Y')        AS join_date,
        ROUND(DATEDIFF(CURDATE(), join_dt)/365, 1) AS experience_years;
END $$

DELIMITER ;

CALL emp_full_profile(1);
