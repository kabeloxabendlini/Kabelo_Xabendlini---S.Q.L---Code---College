-- ============================================================
--  SHOPPING SYSTEM — Complete SQL Script
--  Covers: DDL | Cart ops | Checkout | Reporting | Functions
--  PostgreSQL syntax
-- ============================================================

CREATE DATABASE project_3_analysis;

-- ============================================================
--  PART 2 — CREATE TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS Products (
    id     SERIAL          NOT NULL,
    name   VARCHAR(100)    NOT NULL,
    price  DECIMAL(10,2)   NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS Users (
    user_id   SERIAL        NOT NULL,
    username  VARCHAR(80)   NOT NULL,
    CONSTRAINT pk_users    PRIMARY KEY (user_id),
    CONSTRAINT uq_username UNIQUE (username)
);

CREATE TABLE IF NOT EXISTS Cart (
    product_id  INT  NOT NULL,
    qty         INT  NOT NULL DEFAULT 1,
    CONSTRAINT pk_cart      PRIMARY KEY (product_id),
    CONSTRAINT fk_cart_prod FOREIGN KEY (product_id)
        REFERENCES Products (id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_cart_qty CHECK (qty > 0)
);

CREATE TABLE IF NOT EXISTS OrderHeader (
    order_id    SERIAL    NOT NULL,
    user_id     INT       NOT NULL,
    order_date  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_order_header PRIMARY KEY (order_id),
    CONSTRAINT fk_order_user   FOREIGN KEY (user_id)
        REFERENCES Users (user_id)
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS OrderDetails (
    order_id  INT  NOT NULL,
    prod_id   INT  NOT NULL,
    qty       INT  NOT NULL,
    CONSTRAINT pk_order_details PRIMARY KEY (order_id, prod_id),
    CONSTRAINT fk_od_order      FOREIGN KEY (order_id)
        REFERENCES OrderHeader (order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_od_product    FOREIGN KEY (prod_id)
        REFERENCES Products (id)
        ON UPDATE CASCADE,
    CONSTRAINT chk_od_qty       CHECK (qty > 0)
);

-- ============================================================
--  SEED DATA
-- ============================================================

-- OVERRIDING SYSTEM VALUE lets us supply our own SERIAL values
INSERT INTO Products (id, name, price)
OVERRIDING SYSTEM VALUE VALUES
    (1, 'Coke',  10.00),
    (2, 'Chips',  5.00);

INSERT INTO Users (user_id, username)
OVERRIDING SYSTEM VALUE VALUES
    (1, 'Arnold'),
    (2, 'Sheryl');

-- ============================================================
--  PART 3 — ADD ITEMS TO THE CART
--  PostgreSQL: IF...THEN...ELSE must live inside a function
--  or a DO block. We use DO $$ ... $$ for anonymous blocks.
-- ============================================================

-- Add Coke (product_id = 1) — not in cart yet → INSERT
SELECT 'CART BEFORE adding first Coke' AS step;
SELECT * FROM Cart;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM Cart WHERE product_id = 1) THEN
        UPDATE Cart SET qty = qty + 1 WHERE product_id = 1;
    ELSE
        INSERT INTO Cart (product_id, qty) VALUES (1, 1);
    END IF;
END $$;

SELECT 'CART AFTER adding Coke (qty should be 1)' AS step;
SELECT c.product_id, p.name, c.qty, p.price, (c.qty * p.price) AS line_total
FROM Cart c JOIN Products p ON c.product_id = p.id;

-- Add Coke again → UPDATE qty
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM Cart WHERE product_id = 1) THEN
        UPDATE Cart SET qty = qty + 1 WHERE product_id = 1;
    ELSE
        INSERT INTO Cart (product_id, qty) VALUES (1, 1);
    END IF;
END $$;

SELECT 'CART AFTER adding Coke again (qty should be 2)' AS step;
SELECT c.product_id, p.name, c.qty, p.price, (c.qty * p.price) AS line_total
FROM   Cart c JOIN Products p ON c.product_id = p.id;

-- Add Chips (product_id = 2) → INSERT
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM Cart WHERE product_id = 2) THEN
        UPDATE Cart SET qty = qty + 1 WHERE product_id = 2;
    ELSE
        INSERT INTO Cart (product_id, qty) VALUES (2, 1);
    END IF;
END $$;

SELECT 'CART AFTER adding Chips (2x Coke, 1x Chips)' AS step;
SELECT c.product_id, p.name, c.qty, p.price, (c.qty * p.price) AS line_total
FROM   Cart c JOIN Products p ON c.product_id = p.id;


-- ============================================================
--  PART 4 — REMOVE ITEMS FROM THE CART
-- ============================================================

-- Remove one Coke — qty > 1 → subtract 1
DO $$
BEGIN
    IF (SELECT qty FROM Cart WHERE product_id = 1) > 1 THEN
        UPDATE Cart SET qty = qty - 1 WHERE product_id = 1;
    ELSE
        DELETE FROM Cart WHERE product_id = 1;
    END IF;
END $$;

SELECT 'CART AFTER removing one Coke (qty should be 1)' AS step;
SELECT c.product_id, p.name, c.qty FROM Cart c JOIN Products p ON c.product_id = p.id;

-- Remove Coke again — qty = 1 → delete entire row
DO $$
BEGIN
    IF (SELECT qty FROM Cart WHERE product_id = 1) > 1 THEN
        UPDATE Cart SET qty = qty - 1 WHERE product_id = 1;
    ELSE
        DELETE FROM Cart WHERE product_id = 1;
    END IF;
END $$;

SELECT 'CART AFTER removing last Coke (only Chips remains)' AS step;
SELECT c.product_id, p.name, c.qty FROM Cart c JOIN Products p ON c.product_id = p.id;


-- ============================================================
--  PART 5 — CHECKOUT
-- ============================================================

-- Reset cart
DELETE FROM Cart;
INSERT INTO Cart (product_id, qty) VALUES (1, 2), (2, 1);

SELECT 'CART BEFORE first checkout' AS step;
SELECT c.product_id, p.name, c.qty FROM Cart c JOIN Products p ON c.product_id = p.id;

-- ---- ORDER 1: Arnold (user_id = 1) ----
DO $$
DECLARE
    v_order_id INT;
BEGIN
    -- A: Insert order header
    INSERT INTO OrderHeader (user_id, order_date)
    VALUES (1, '2015-04-15 15:30:00')
    RETURNING order_id INTO v_order_id;

    RAISE NOTICE 'Order 1 created - OrderID = %', v_order_id;

    -- B: Copy cart into order details
    INSERT INTO OrderDetails (order_id, prod_id, qty)
    SELECT v_order_id, product_id, qty FROM Cart;

    -- C: Clear the cart
    DELETE FROM Cart;
END $$;

SELECT 'ORDER DETAILS after first checkout' AS step;
SELECT * FROM OrderDetails;

SELECT 'CART after first checkout (should be empty)' AS step;
SELECT * FROM Cart;

-- ---- ORDER 2: Sheryl (user_id = 2) ----
INSERT INTO Cart (product_id, qty) VALUES (1, 1), (2, 3);

SELECT 'CART BEFORE second checkout' AS step;
SELECT c.product_id, p.name, c.qty FROM Cart c JOIN Products p ON c.product_id = p.id;

DO $$
DECLARE
    v_order_id INT;
BEGIN
    INSERT INTO OrderHeader (user_id, order_date)
    VALUES (2, NOW())
    RETURNING order_id INTO v_order_id;

    RAISE NOTICE 'Order 2 created — OrderID = %', v_order_id;

    INSERT INTO OrderDetails (order_id, prod_id, qty)
    SELECT v_order_id, product_id, qty FROM Cart;

    DELETE FROM Cart;
END $$;

SELECT 'CART after second checkout (should be empty)' AS step;
SELECT * FROM Cart;


-- ============================================================
--  REPORTING — SELECT with INNER JOINS
-- ============================================================

SELECT 'ALL ORDERS — inner join across 3 tables' AS report;
SELECT
    oh.order_id,
    u.username,
    oh.order_date,
    p.name                 AS product,
    od.qty,
    p.price,
    (od.qty * p.price)     AS line_total
FROM OrderHeader oh
INNER JOIN Users        u  ON oh.user_id  = u.user_id
INNER JOIN OrderDetails od ON oh.order_id = od.order_id
INNER JOIN Products     p  ON od.prod_id  = p.id
ORDER BY oh.order_id, p.name;

SELECT 'SINGLE ORDER — OrderID 1' AS report;
SELECT
    oh.order_id,
    u.username,
    oh.order_date,
    p.name                 AS product,
    od.qty,
    p.price,
    (od.qty * p.price)     AS line_total
FROM OrderHeader oh
INNER JOIN Users        u  ON oh.user_id  = u.user_id
INNER JOIN OrderDetails od ON oh.order_id = od.order_id
INNER JOIN Products     p  ON od.prod_id  = p.id
WHERE oh.order_id = 1;

SELECT 'ALL ORDERS for 15 Apr 2015' AS report;
SELECT
    oh.order_id,
    u.username,
    oh.order_date,
    p.name                 AS product,
    od.qty,
    p.price,
    (od.qty * p.price)     AS line_total
FROM OrderHeader oh
INNER JOIN Users        u  ON oh.user_id  = u.user_id
INNER JOIN OrderDetails od ON oh.order_id = od.order_id
INNER JOIN Products     p  ON od.prod_id  = p.id
WHERE oh.order_date::DATE = '2015-04-15'   -- ::DATE casts TIMESTAMP to DATE
ORDER BY oh.order_id;

SELECT 'ORDER TOTALS SUMMARY' AS report;
SELECT
    oh.order_id,
    u.username,
    oh.order_date,
    SUM(od.qty * p.price)  AS order_total
FROM OrderHeader oh
INNER JOIN Users        u  ON oh.user_id  = u.user_id
INNER JOIN OrderDetails od ON oh.order_id = od.order_id
INNER JOIN Products     p  ON od.prod_id  = p.id
GROUP BY oh.order_id, u.username, oh.order_date
ORDER BY oh.order_id;


-- ============================================================
--  BONUS — STORED FUNCTIONS (PostgreSQL uses PL/pgSQL)
--  PostgreSQL functions that modify data must return a value
--  and use LANGUAGE plpgsql
-- ============================================================

DROP FUNCTION IF EXISTS AddToCart(INT);
DROP FUNCTION IF EXISTS RemoveFromCart(INT);

-- AddToCart: inserts or increments qty, returns new qty
CREATE OR REPLACE FUNCTION AddToCart(p_product_id INT)
RETURNS INT AS $$
DECLARE
    v_qty INT := 0;
BEGIN
    SELECT qty INTO v_qty FROM Cart WHERE product_id = p_product_id;

    IF v_qty > 0 THEN
        UPDATE Cart SET qty = qty + 1 WHERE product_id = p_product_id;
        RETURN v_qty + 1;
    ELSE
        INSERT INTO Cart (product_id, qty) VALUES (p_product_id, 1);
        RETURN 1;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- RemoveFromCart: subtracts 1 or deletes row, returns remaining qty
CREATE OR REPLACE FUNCTION RemoveFromCart(p_product_id INT)
RETURNS INT AS $$
DECLARE
    v_qty INT := 0;
BEGIN
    SELECT qty INTO v_qty FROM Cart WHERE product_id = p_product_id;

    IF v_qty > 1 THEN
        UPDATE Cart SET qty = qty - 1 WHERE product_id = p_product_id;
        RETURN v_qty - 1;
    ELSIF v_qty = 1 THEN
        DELETE FROM Cart WHERE product_id = p_product_id;
        RETURN 0;
    ELSE
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
--  BONUS DEMO — calling the functions
--  In PostgreSQL, functions are called inside SELECT
-- ============================================================

DELETE FROM Cart;

SELECT 'FUNCTION DEMO — AddToCart' AS step;
SELECT AddToCart(1) AS coke_qty_after_add;    -- INSERT Coke, qty = 1
SELECT AddToCart(1) AS coke_qty_after_add;    -- UPDATE Coke, qty = 2
SELECT AddToCart(2) AS chips_qty_after_add;   -- INSERT Chips, qty = 1

SELECT 'Cart after function adds' AS step;
SELECT c.product_id, p.name, c.qty
FROM Cart c JOIN Products p ON c.product_id = p.id;s

SELECT 'FUNCTION DEMO — RemoveFromCart' AS step;
SELECT RemoveFromCart(1) AS coke_qty_after_remove;  -- qty 2 → 1
SELECT RemoveFromCart(1) AS coke_qty_after_remove;  -- qty 1 → 0 (deleted)

SELECT 'Cart after function removes (only Chips should remain)' AS step;
SELECT c.product_id, p.name, c.qty
FROM Cart c JOIN Products p ON c.product_id = p.id;

-- ============================================================
--  END OF SCRIPT
-- ============================================================