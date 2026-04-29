-- Q: Create a procedure that shows ALL employees
--    with their department names.

-- ❌ My attempt (spelling mistake!)
DELIMINTER $$              -- ❌ extra N!
CREATE PROCEDURE emp_dept()
BEGIN
    SELECT e.name, d.dept_name
    FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id;
END $$

-- ✅ Correct version
DELIMITER $$               -- ✅ correct spelling!

CREATE PROCEDURE emp_dept()
BEGIN
    SELECT
        e.name      AS employee_name,
        d.dept_name AS department
    FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
    ORDER BY d.dept_name, e.name;
END $$

DELIMITER ;                -- ✅ restore delimiter!

CALL emp_dept();           -- ✅ call it!

-- 💎 Optimal version
DELIMITER $$

CREATE PROCEDURE emp_dept()
BEGIN
    SELECT
        e.emp_id,
        e.name          AS employee_name,
        d.dept_name     AS department,
        d.location      AS dept_location,
        e.salary        AS salary
    FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
    ORDER BY d.dept_name, e.salary DESC;
END $$

DELIMITER ;

CALL emp_dept();

-- 💡 Rules learned:
-- DELIMITER spelling: D-E-L-I-M-I-T-E-R (no N!)
-- Always restore DELIMITER ; at end!
-- Procedure structure: DELIMITER→CREATE→BEGIN→END→DELIMITER→CALL

-- Q: Create a procedure that accepts dept_id
--    and returns all employees in that department.

-- ❌ My attempt (parameter same name as column!)
DELIMITER $$
CREATE PROCEDURE dept_list(IN dept_id INT)
BEGIN
    SELECT name FROM employees
    WHERE dept_id = dept_id;   -- ❌ ambiguous!
END $$
DELIMITER ;
CALL dept_list(3);

-- ✅ Correct version (p_ prefix fix!)
DELIMITER $$

CREATE PROCEDURE dept_list(IN p_dept_id INT)
BEGIN
    SELECT
        e.name      AS employee_name,
        e.salary    AS salary
    FROM employees e
    WHERE e.dept_id = p_dept_id    -- ✅ clear!
    ORDER BY e.name;
END $$

DELIMITER ;

CALL dept_list(3);

-- 💎 Optimal version (with existence check!)
DELIMITER $$

CREATE PROCEDURE dept_list(IN p_dept_id INT)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM departments
        WHERE dept_id = p_dept_id
    ) THEN
        SELECT 'Department not found!' AS message;
    ELSE
        SELECT
            e.name        AS employee_name,
            e.salary      AS salary,
            d.dept_name   AS department
        FROM employees e
        JOIN departments d ON e.dept_id = d.dept_id
        WHERE e.dept_id = p_dept_id
        ORDER BY e.salary DESC;
    END IF;
END $$

DELIMITER ;

CALL dept_list(3);

-- 💡 Rules learned:
-- Always use p_ prefix for parameters!
-- Avoids ambiguity between column and parameter!
-- p_dept_id = parameter, dept_id = column → clear!
-- IN/OUT/INOUT only for PROCEDURES not functions!

-- Q: Create a procedure that accepts dept_id
--    and returns COUNT of employees in that dept.

-- ❌ My attempt (same param/column name issue!)
DELIMITER $$
CREATE PROCEDURE get_emp_count(IN dept_id INT, OUT emp_count INT)
BEGIN
    SELECT COUNT(*) INTO emp_count
    FROM employees
    WHERE dept_id = dept_id;    -- ❌ ambiguous!
END $$
DELIMITER ;
CALL get_emp_count(3, @count);
SELECT @count;

-- ✅ Correct version
DELIMITER $$

CREATE PROCEDURE get_emp_count(
    IN  p_dept_id   INT,
    OUT p_emp_count INT
)
BEGIN
    SELECT COUNT(*) INTO p_emp_count
    FROM employees
    WHERE dept_id = p_dept_id;  -- ✅ clear!
END $$

DELIMITER ;

CALL get_emp_count(3, @count);
SELECT @count AS employee_count;

-- 💎 Optimal version (multiple OUT params!)
DELIMITER $$

CREATE PROCEDURE get_emp_count(
    IN  p_dept_id    INT,
    OUT p_emp_count  INT,
    OUT p_avg_salary DECIMAL(10,2)
)
BEGIN
    SELECT
        COUNT(*),
        AVG(salary)
    INTO
        p_emp_count,
        p_avg_salary
    FROM employees
    WHERE dept_id = p_dept_id;
END $$

DELIMITER ;

CALL get_emp_count(3, @count, @avg_sal);
SELECT
    @count   AS employee_count,
    @avg_sal AS avg_salary;

-- 💡 Rules learned:
-- OUT parameter stores result to @variable!
-- SELECT col INTO var → stores value in variable!
-- CALL proc(value, @var) → @var gets OUT result!
-- SELECT @var → see the output after CALL!
-- Multiple INTO → comma separated variables!

-- Q: Create a procedure accepting emp_id
--    returning salary category:
--    Above 70k=High, 40k-70k=Medium, Below 40k=Low

-- ❌ My attempt (3 issues!)
DELIMITER $$
CREATE PROCEDURE sal_category(IN emp_id INT)
BEGIN
    DECLARE emp_sal DECIMAL(10,2);
    SELECT salary INTO emp_sal
    FROM employees
    WHERE emp_id = emp_id;         -- ❌ ambiguous!
    IF emp_sal > 70000 THEN
        SELECT 'High Salary' AS category;
    ELSEIF emp_sal > 4000 THEN     -- ❌ typo! 40000!
        SELECT 'Medium Salary' AS category;
    ELSE
        SELECT 'Low Salary' AS category;
    END IF;
END $$
DELIMITER;                         -- ❌ missing space!

-- ✅ Correct version
DELIMITER $$

CREATE PROCEDURE sal_category(IN p_emp_id INT)
BEGIN
    DECLARE emp_sal DECIMAL(10,2);

    SELECT salary INTO emp_sal
    FROM employees
    WHERE emp_id = p_emp_id;       -- ✅ clear!

    IF emp_sal > 70000 THEN
        SELECT 'High Salary'   AS category;
    ELSEIF emp_sal > 40000 THEN    -- ✅ 40000!
        SELECT 'Medium Salary' AS category;
    ELSE
        SELECT 'Low Salary'    AS category;
    END IF;
END $$

DELIMITER ;                        -- ✅ space!

CALL sal_category(1);

-- 💎 Optimal version (full report + bonus!)
DELIMITER $$

CREATE PROCEDURE sal_category(IN p_emp_id INT)
BEGIN
    DECLARE emp_sal   DECIMAL(10,2);
    DECLARE emp_name  VARCHAR(100);
    DECLARE dept_name VARCHAR(100);

    SELECT e.salary, e.name, d.dept_name
    INTO emp_sal, emp_name, dept_name
    FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
    WHERE e.emp_id = p_emp_id;

    SELECT
        emp_name                  AS employee_name,
        dept_name                 AS department,
        emp_sal                   AS salary,
        CASE
            WHEN emp_sal > 70000 THEN 'High Salary 🔥'
            WHEN emp_sal > 40000 THEN 'Medium Salary 💰'
            ELSE                      'Low Salary 📈'
        END                       AS category,
        ROUND(emp_sal * 0.10, 2)  AS bonus_amount;
END $$

DELIMITER ;

CALL sal_category(1);

-- 💡 Rules learned:
-- DECLARE must be FIRST inside BEGIN!
-- SELECT col INTO var to store value!
-- IF → ELSEIF → ELSE → END IF structure!
-- DELIMITER ; needs space before semicolon!
-- Always double check threshold numbers!

-- Q: Create a function that accepts salary
--    and returns annual bonus (10% of salary).

-- ❌ My attempt (3 issues!)
DELIMITER $$
CREATE FUNCTION get_ann_bonus(IN salary DECIMAL(10,2))
--                            ^^ ❌ IN keyword in function!
RETURNS DECIMAL(10,2)
NOT DETERMINISTIC          -- ❌ fixed calc = DETERMINISTIC!
BEGIN
    DECLARE bonus DECIMAL(10,2)  -- ❌ missing semicolon!
    SET bonus = salary * 0.10;
    RETURN bonus;
END $$
DELIMITER ;

SELECT get_ann_bonus(289800) AS Totalbonus;

-- ✅ Correct version
DELIMITER $$

CREATE FUNCTION get_ann_bonus(p_salary DECIMAL(10,2))
--                            ^^^^^^^^ no IN keyword!
RETURNS DECIMAL(10,2)
DETERMINISTIC                    -- ✅ fixed calculation!
BEGIN
    DECLARE bonus DECIMAL(10,2); -- ✅ semicolon!
    SET bonus = p_salary * 0.10;
    RETURN bonus;
END $$

DELIMITER ;

SELECT get_ann_bonus(289800) AS total_bonus;
-- Returns: 28980.00 ✅

-- 💎 Optimal version (flexible bonus %!)
DELIMITER $$

CREATE FUNCTION get_ann_bonus(
    p_salary    DECIMAL(10,2),
    p_bonus_pct DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE bonus DECIMAL(10,2);
    SET bonus = p_salary * (p_bonus_pct / 100);
    RETURN ROUND(bonus, 2);
END $$

DELIMITER ;

SELECT
    name,
    salary,
    get_ann_bonus(salary, 10) AS bonus_10_pct,
    get_ann_bonus(salary, 15) AS bonus_15_pct
FROM employees;

-- 💡 Rules learned:
-- Functions DON'T use IN/OUT/INOUT keywords!
-- Just: param_name datatype
-- DETERMINISTIC = same input, same output always!
-- NOT DETERMINISTIC = output changes (CURDATE, RAND)
-- DECLARE needs semicolon at end!
-- Use function in SELECT like any SQL function!

-- Q: Create a function accepting join_date
--    and returning years of experience.

-- ❌ My attempt (3 issues!)
DELIMITER $$
CREATE FUNCTION get_emp_bonus(IN join_date DATE)
--                            ^^ ❌ IN keyword!
RETURNS DECIMAL(5,2)
NOT DETERMINISTIC
BEGIN
    DECLARE exp_diff DECIMAL(5,2);
    SET exp_diff = DATEDIFF(CURDATE(), join_date)/365;
    RETURNS exp_diff;    -- ❌ RETURNS not RETURN inside!
END $$
DELIMITER ;

SELECT get_emp_bonus(2024-04-02) AS YearExperience;
--                   ^^^^^^^^^^ ❌ date not quoted!
-- SQL reads 2024-04-02 as math = 2018! 😱

-- ✅ Correct version
DELIMITER $$

CREATE FUNCTION get_experience(p_join_date DATE)
RETURNS DECIMAL(5,2)
NOT DETERMINISTIC              -- ✅ CURDATE changes daily!
BEGIN
    DECLARE exp_diff DECIMAL(5,2);
    SET exp_diff = DATEDIFF(CURDATE(), p_join_date)/365;
    RETURN ROUND(exp_diff, 2); -- ✅ RETURN not RETURNS!
END $$

DELIMITER ;

SELECT get_experience('2024-04-02') AS years_experience;
--                    ^           ^ ✅ quoted!

-- 💎 Optimal version (leap year + seniority!)
DELIMITER $$

CREATE FUNCTION get_experience(p_join_date DATE)
RETURNS DECIMAL(5,2)
NOT DETERMINISTIC
BEGIN
    DECLARE exp_years DECIMAL(5,2);
    SET exp_years = ROUND(
        DATEDIFF(CURDATE(), p_join_date) / 365.25, 2
        -- 365.25 accounts for leap years! 💎
    );
    RETURN exp_years;
END $$

DELIMITER ;

SELECT
    name,
    DATE_FORMAT(join_date, '%d-%m-%Y') AS joined_on,
    get_experience(join_date)          AS exp_years,
    CASE
        WHEN get_experience(join_date) < 1 THEN 'Fresher'
        WHEN get_experience(join_date) < 3 THEN 'Junior'
        WHEN get_experience(join_date) < 5 THEN 'Mid-Level'
        ELSE                                   'Senior'
    END                                AS seniority
FROM employees
ORDER BY exp_years DESC;

-- 💡 Rules learned:
-- RETURNS (with S) = declaration line at TOP!
-- RETURN  (no S)   = inside BEGIN to send value!
-- Dates ALWAYS in single quotes: '2024-04-02'!
-- Without quotes: 2024-04-02 = math = 2018! 😱
-- 365.25 more accurate than 365 for leap years!
-- NOT DETERMINISTIC when CURDATE() used inside!

/*Q7 — Procedure + Function Combined | 60 XP 
Scenario: "Create a function for bonus calculation (10%). Then create a procedure that shows all employees with their
name, salary, bonus amount!"*/

-- STEP 1: Create function first!
DELIMITER $$
    
CREATE FUNCTION get_emp_bonus(p_salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE emp_bonus DECIMAL(10,2);
    SET emp_bonus = ROUND(p_salary * 0.10, 2);
    RETURN emp_bonus;
END $$

DELIMITER ;

-- STEP 2: Create procedure that USES function!
DELIMITER $$

CREATE PROCEDURE all_emp_bonus()    -- no OUT needed!
BEGIN
    SELECT
        e.name                        AS employee_name,
        e.salary                      AS salary,
        get_emp_bonus(e.salary)       AS bonus_amount
    FROM employees e;                 -- function called here!
END $$                                -- ✅ END $$ present!

DELIMITER ;                           -- ✅ space!

-- STEP 3: Call it!
CALL all_emp_bonus();                 -- ✅ semicolon!
