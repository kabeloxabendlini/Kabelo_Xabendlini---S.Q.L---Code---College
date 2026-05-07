-- CREATE DATABASE project_demo_analysis;

-- \c project_demo_analysis

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customer;

-- ============================================================
-- Step 2 — Define a custom composite type (object-like structure)
-- ============================================================

-- This acts like a "class" for storing structured address data
CREATE TYPE address_type AS (
    street      VARCHAR(100),
    city        VARCHAR(50),
    postal_code VARCHAR(10)
);



-- ============================================================
-- Step 3 — Create a base table (parent table)
-- ============================================================

-- This table represents a general "person" entity
-- It will be inherited by other tables
CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    address   address_type
);



-- ============================================================
-- Step 4 — Create child tables using inheritance
-- ============================================================

-- Employee table inherits all columns from person
-- Adds a salary attribute specific to employees
CREATE TABLE employee (
    salary NUMERIC
) INHERITS (person);

-- Customer table inherits all columns from person
-- Adds loyalty points specific to customers
CREATE TABLE customer (
    person_id      INT PRIMARY KEY DEFAULT nextval('person_person_id_seq'),
    loyalty_points INTEGER
) INHERITS (person);


-- ============================================================
-- Step 5 — Create a related table with a foreign key
-- ============================================================

-- Orders table references customers
-- Demonstrates relationships between tables
CREATE TABLE orders (
    order_id    SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customer(person_id),
    order_date  DATE
);

SELECT conname, contype 
FROM pg_constraint 
WHERE conrelid = 'customer'::regclass;

-- ============================================================
-- Step 6 — Insert sample data
-- ============================================================

-- Insert a customer record using the composite address type
INSERT INTO customer (full_name, address, loyalty_points)
VALUES (
    'Kabelo Xabendlini',
    ROW('123 Main St', 'Durban', '4001'),  -- structured address input
    150
);

INSERT INTO customer (full_name, address, loyalty_points)
VALUES (
    'Kabelo Xabendlini',
    ROW('1875 Van Niekerk street', 'Margate', '4275'),  -- structured address input
    150
);

-- Insert an employee record
INSERT INTO employee (full_name, address, salary)
VALUES (
    'Jane Smith',
    ROW('45 West Rd', 'Johannesburg', '2000'),
    50000
);

INSERT INTO employee (full_name, address, salary)
VALUES (
    'Sipho Dlamini',
    ROW('12 Oak Ave', 'Pretoria', '0001'),
    62000
);

-- ============================================================
-- Step 7 — Query inherited data
-- ============================================================

-- Querying the parent table returns ALL rows
-- from person + all child tables (employee, customer)
SELECT * FROM person;

-- Use ONLY to exclude child tables
-- This returns only rows inserted directly into person
SELECT * FROM ONLY person;



-- ============================================================
-- Step 8 — Create a custom function (adds behavior)
-- ============================================================

-- Function calculates a 10% bonus from salary
CREATE OR REPLACE FUNCTION bonus(salary NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN salary * 0.10;
END;
$$ LANGUAGE plpgsql;



-- ============================================================
-- Step 9 — Use the function in a query
-- ============================================================

-- Retrieve employee names, salaries, and calculated bonuses
SELECT 
    full_name, 
    salary, 
    bonus(salary) AS calculated_bonus
FROM employee;

INSERT INTO orders (customer_id, order_date) VALUES (4, '2025-01-15');
INSERT INTO orders (customer_id, order_date) VALUES (4, '2025-03-22');
INSERT INTO orders (customer_id, order_date) VALUES (3, '2025-04-10');
INSERT INTO orders (customer_id, order_date) VALUES (3, '2025-09-19');
INSERT INTO orders (customer_id, order_date) VALUES (3, '2025-12-05');

SELECT person_id, full_name FROM customer;

SELECT 
    o.order_id,
    c.full_name   AS customer_name,
    o.order_date
FROM orders o
JOIN customer c ON o.customer_id = c.person_id
ORDER BY o.order_date;