-- SELECT school, first_name, last_name
-- FROM teachers
-- ORDER BY school ASC, last_name ASC;

-- SELECT *
-- FROM teachers
-- WHERE first_name LIKE 'S%'
--   AND salary > 40000;

SELECT 
    first_name,
    last_name,
    salary,
    hire_date,
    RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM teachers
WHERE hire_date >= '2010-01-01';