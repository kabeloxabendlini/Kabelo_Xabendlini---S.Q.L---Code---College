-- ============================================================
-- Question 1 — Create a view for NYC taxi trips per hour
-- ============================================================

-- Create or replace a view that aggregates trips by pickup hour
-- CREATE OR REPLACE VIEW nyc_taxi_trips_per_hour AS
-- SELECT
--     date_part('hour', tpep_pickup_datetime) AS trip_hour,  -- extract hour (0–23)
--     COUNT(*) AS trips                                      -- count number of trips
-- FROM nyc_yellow_taxi_trips_2016_06_01
-- GROUP BY trip_hour                                         -- group by hour of day
-- ORDER BY trip_hour;                                        -- sort results chronologically

-- Query the view to see results
-- SELECT * FROM nyc_taxi_trips_per_hour;



-- ============================================================
-- Question 2 — Create a reusable rate calculation function
-- ============================================================

-- Function calculates rate per 1,000 units
-- Example: crime rate per 1,000 people, incidents per 1,000, etc.
-- CREATE OR REPLACE FUNCTION rates_per_thousand(
--     observed_number NUMERIC,     -- numerator (e.g., number of events)
--     base_number NUMERIC,         -- denominator (e.g., population)
--     decimal_places INTEGER      -- number of decimal places to round to
-- )
-- RETURNS NUMERIC AS $$
-- BEGIN
--     RETURN ROUND(
    (observed_number / NULLIF(base_number, 0)) * 1000,
    decimal_places -- round to specified decimal places     
    --     NULLIF prevents division by zero by returning NULL if base_number is 0
-- );
-- END;
-- $$ LANGUAGE plpgsql;

-- Test the function with sample values
-- SELECT rates_per_thousand(100, 50000, 2);  -- expected: 2.00
-- SELECT rates_per_thousand(6, 11000, 3);    -- expected: 0.545



-- ============================================================
-- Exercise 3 — Trigger to auto-set inspection date
-- ============================================================

-- ------------------------------------------------------------
-- Step 1: Ensure the inspection_date column exists
-- Adds the column only if it doesn’t already exist
-- ------------------------------------------------------------
ALTER TABLE meat_poultry_egg_inspect
ADD COLUMN IF NOT EXISTS inspection_date DATE;


-- ------------------------------------------------------------
-- Step 2: Create a trigger function
-- This function runs BEFORE INSERT and sets inspection_date
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_inspection_date()
RETURNS TRIGGER AS
$$
BEGIN
    -- Set inspection_date to current timestamp + 6 months
    NEW.inspection_date := NOW() + '6 months'::interval;

    -- Return the modified row to be inserted
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ------------------------------------------------------------
-- Step 3: Create the trigger
-- Executes the function for each inserted row
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER inspection_date_trigger
BEFORE INSERT ON meat_poultry_egg_inspect
FOR EACH ROW
EXECUTE FUNCTION set_inspection_date();


-- ------------------------------------------------------------
-- Step 4: Test the trigger by inserting a new record
-- inspection_date should be auto-filled
-- ------------------------------------------------------------
INSERT INTO meat_poultry_egg_inspect (
    est_number,
    company,
    city,
    st,
    zip
)
VALUES (
    'V18677A',
    'New Test Facility',
    'Chicago',
    'IL',
    '60601'
);


-- ------------------------------------------------------------
-- Step 5: Verify the trigger worked
-- The inspection_date should be current date + 6 months
-- ------------------------------------------------------------
SELECT 
    est_number,
    company,
    city,
    st,
    inspection_date
FROM meat_poultry_egg_inspect
WHERE est_number = 'V18677A';