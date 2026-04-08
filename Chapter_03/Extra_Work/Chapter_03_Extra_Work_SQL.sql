-- CREATE TABLE mileage_log (
--     log_id       SERIAL          PRIMARY KEY,
--     driver_id    INT             NOT NULL,
--     log_date     DATE            NOT NULL,
--     miles_driven NUMERIC(4,1)    NOT NULL  -- e.g. 123.4, max 999.9
-- );

-- INSERT INTO mileage_log (driver_id, log_date, miles_driven) VALUES
--     (1, '2024-06-01', 102.3),
--     (2, '2024-06-01', 75.0),
--     (3, '2024-06-01', 999.9),   -- Maximum allowed value
--     (1, '2024-06-02', 88.5),
--     (2, '2024-06-02', 0.1);     -- Minimum meaningful value

-- CREATE TABLE drivers (
--     driver_id   SERIAL          PRIMARY KEY,
--     first_name  VARCHAR(50)     NOT NULL,
--     last_name   VARCHAR(50)     NOT NULL,
--     hire_date   DATE            NOT NULL,
--     is_active   BOOLEAN         NOT NULL DEFAULT TRUE
-- );

-- INSERT INTO drivers (first_name, last_name, hire_date) VALUES
--     ('Sipho',      'Nkosi',      '2021-03-15'),
--     ('Thandiwe',   'Dlamini',    '2019-07-22'),
--     ('Lungelo',    'Mthembu',    '2023-01-10'),
--     ('Nomvula',    'Zulu',       '2020-11-05'),
--     ('Bhekani',    'Cele',       '2022-08-30');

-- SELECT driver_id,
--        last_name  || ', ' || first_name AS full_name,
--        hire_date
-- FROM   drivers
-- ORDER  BY last_name, first_name;

-- CREATE TABLE delivery_routes (
--     route_id    SERIAL      PRIMARY KEY,
--     driver_id   INT         NOT NULL REFERENCES drivers(driver_id),
--     store_name  VARCHAR(100) NOT NULL,
--     route_date  DATE        NOT NULL
-- );

-- INSERT INTO delivery_routes (driver_id, store_name, route_date) VALUES
--     (1, 'Pick n Pay Musgrave',      '2024-06-01'),
--     (2, 'Checkers Pavilion',        '2024-06-01'),
--     (3, 'Woolworths Gateway',       '2024-06-01'),
--     (1, 'Spar Umhlanga Ridge',      '2024-06-02'),
--     (2, 'Pick n Pay Ballito',       '2024-06-02');

-- CREATE TABLE raw_date_strings (
--     id          SERIAL       PRIMARY KEY,
--     date_text   TEXT         NOT NULL
-- );
 
 -- INSERT INTO raw_date_strings (date_text) VALUES
 --    ('04/01/2017'),   -- Valid: 1 April 2017
 --    ('12/25/2023'),   -- Valid: 25 December 2023
 --    ('4//2017'),      -- INVALID: missing day — will fail on CAST
 --    ('07/04/2024');   -- Valid: 4 July 2024

--  SELECT
--     id,
--     date_text,
--     CASE
--         WHEN date_text ~ '^\d{1,2}/\d{1,2}/\d{4}$'
--             THEN TO_TIMESTAMP(date_text, 'MM/DD/YYYY')
--         ELSE NULL   -- Malformed strings return NULL instead of crashing
--     END AS converted_timestamp
-- FROM raw_date_strings
-- ORDER BY id;

SELECT
    d.driver_id,
    d.first_name || ' ' || d.last_name  AS driver_name,
    m.log_date,
    m.miles_driven
FROM   drivers      d
JOIN   mileage_log  m ON m.driver_id = d.driver_id
ORDER  BY m.log_date, d.last_name;
 