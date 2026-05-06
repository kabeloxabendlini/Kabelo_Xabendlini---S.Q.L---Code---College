-- ============================================================
-- Step 1 — Create a new database
-- ============================================================

CREATE DATABASE ordbms_demo;

-- Connect to the newly created database (psql command-line only)
\c ordbms_demo



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
    person_id SERIAL PRIMARY KEY,   -- auto-incrementing unique ID
    full_name VARCHAR(100),         -- person's full name
    address   address_type          -- custom composite type
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
    loyalty_points INTEGER
) INHERITS (person);



-- ============================================================
-- Step 5 — Create a related table with a foreign key
-- ============================================================

-- Orders table references customers
-- Demonstrates relationships between tables
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,                    -- unique order ID
    customer_id INT REFERENCES customer(person_id), -- link to customer
    order_date DATE                                 -- date of the order
);



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

-- Insert an employee record
INSERT INTO employee (full_name, address, salary)
VALUES (
    'Jane Smith',
    ROW('45 West Rd', 'Johannesburg', '2000'),
    50000
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