-- ============================================================
-- Step 1 — Create a new database
-- ============================================================

CREATE DATABASE project_demo_analysis;

-- Connect to the newly created database (psql command-line only)
\c project_demo_analysis



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

-- This table represents a general "person" entity.
-- It will be inherited by employee and customer.
-- person_id is a true PRIMARY KEY here — child tables inherit
-- the COLUMN but NOT the constraint (PostgreSQL inheritance behaviour).
CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    address   address_type
);



-- ============================================================
-- Step 4 — Create child tables using inheritance
-- ============================================================

-- WHY THE FK ERROR HAPPENED:
-- PostgreSQL INHERITS copies columns but NOT constraints (PK, UNIQUE).
-- So customer.person_id is just a plain INT — no uniqueness guarantee.
-- PostgreSQL refuses to use it as an FK target for that reason.
--
-- FIX: Explicitly declare person_id as PRIMARY KEY on each child table,
-- and reuse the parent's sequence so IDs stay globally unique.

CREATE TABLE employee (
    person_id INT PRIMARY KEY DEFAULT nextval('person_person_id_seq'),
    salary    NUMERIC
) INHERITS (person);

CREATE TABLE customer (
    person_id      INT PRIMARY KEY DEFAULT nextval('person_person_id_seq'),
    loyalty_points INTEGER
) INHERITS (person);



-- ============================================================
-- Step 5 — Create a related table with a foreign key
-- ============================================================

-- Now that customer.person_id has an explicit PRIMARY KEY,
-- this REFERENCES will succeed.
--
-- ALTERNATIVE: reference person(person_id) instead — works
-- because the parent table always has the PK constraint.
CREATE TABLE orders (
    order_id    SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customer(person_id),  -- now valid
    order_date  DATE
);



-- ============================================================
-- Step 6 — Insert sample data
-- ============================================================

-- Insert a customer using the composite address type
-- ROW(...) constructs the address_type value inline
INSERT INTO customer (full_name, address, loyalty_points)
VALUES (
    'Kabelo Xabendlini',
    ROW('123 Main St', 'Durban', '4001'),
    150
);

-- Insert another customer so we have data for the orders below
INSERT INTO customer (full_name, address, loyalty_points)
VALUES (
    'Thabo Nkosi',
    ROW('88 Beach Rd', 'Cape Town', '8001'),
    320
);

-- Insert an employee record
INSERT INTO employee (full_name, address, salary)
VALUES (
    'Jane Smith',
    ROW('45 West Rd', 'Johannesburg', '2000'),
    50000
);

-- Insert a second employee
INSERT INTO employee (full_name, address, salary)
VALUES (
    'Sipho Dlamini',
    ROW('12 Oak Ave', 'Pretoria', '0001'),
    62000
);

-- Insert orders linked to the customers
-- Note: person_id values are auto-assigned from the shared sequence.
-- Kabelo will have person_id = 1, Thabo = 2 (assuming clean DB).
INSERT INTO orders (customer_id, order_date) VALUES (1, '2025-01-15');
INSERT INTO orders (customer_id, order_date) VALUES (1, '2025-03-22');
INSERT INTO orders (customer_id, order_date) VALUES (2, '2025-04-10');
INSERT INTO orders (customer_id, order_date) VALUES (2, '2025-09-19');
INSERT INTO orders (customer_id, order_date) VALUES (2, '2025-12-05');


-- ============================================================
-- Step 7 — Query inherited data
-- ============================================================

-- Querying the parent table returns ALL rows from person
-- AND all child tables (employee + customer) combined
SELECT * FROM person;

-- ONLY excludes child table rows —
-- returns only rows inserted directly into person (none in our case)
SELECT * FROM ONLY person;

-- Query just customers
SELECT * FROM customer;

-- Query just employees
SELECT * FROM employee;

-- Join orders back to customer to see full order history
SELECT
    o.order_id,
    c.full_name          AS customer_name,
    (c.address).city     AS customer_city,   -- access composite field with ()
    c.loyalty_points,
    o.order_date
FROM orders o
JOIN customer c ON o.customer_id = c.person_id
ORDER BY o.order_date;



-- ============================================================
-- Step 8 — Create a custom function (adds behaviour)
-- ============================================================

-- Function calculates a 10% bonus from salary
-- $$ ... $$ is the PL/pgSQL function body delimiter
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
FROM employee
ORDER BY salary DESC;



-- ============================================================
-- Step 10 — Access individual fields of the composite type
-- ============================================================

-- To read a specific field from address_type, wrap the column in ()
-- then dot-access the field name
SELECT
    full_name,
    (address).street      AS street,
    (address).city        AS city,
    (address).postal_code AS postal_code
FROM person;   -- returns both employees and customers



-- ============================================================
-- QUICK REFERENCE — PostgreSQL inheritance FK rules
-- ============================================================
--
-- RULE 1: INHERITS copies columns, NOT constraints.
--         Always re-declare PRIMARY KEY on child tables.
--
-- RULE 2: To keep IDs globally unique across parent + children,
--         share the parent's sequence:
--         DEFAULT nextval('person_person_id_seq')
--
-- RULE 3: SELECT * FROM parent   → includes all child rows
--         SELECT * FROM ONLY parent → excludes child rows
--
-- RULE 4: Composite type fields are accessed with:
--         (column_name).field_name   e.g. (address).city
--
-- ============================================================