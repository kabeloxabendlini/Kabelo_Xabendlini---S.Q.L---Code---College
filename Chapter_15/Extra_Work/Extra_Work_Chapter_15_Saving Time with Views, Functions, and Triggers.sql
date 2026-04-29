-- -- Question: 1

-- -- Create the view
-- CREATE OR REPLACE VIEW nyc_taxi_trips_per_hour AS
-- SELECT
--     date_part('hour', tpep_pickup_datetime) AS trip_hour,
--     count(*) AS trips
-- FROM nyc_yellow_taxi_trips_2016_06_01
-- GROUP BY trip_hour
-- ORDER BY trip_hour;

-- -- Query the view
-- SELECT * FROM nyc_taxi_trips_per_hour;

-- -- Question: 2

-- -- Create the function
-- CREATE OR REPLACE FUNCTION rates_per_thousand(
--     observed_number numeric,
--     base_number numeric,
--     decimal_places integer
-- )
-- RETURNS numeric AS $$
-- BEGIN
--     RETURN round(
--         (observed_number / base_number) * 1000, 
--         decimal_places
--     );
-- END;
-- $$ LANGUAGE plpgsql;

-- -- Test it
-- SELECT rates_per_thousand(100, 50000, 2);
-- SELECT rates_per_thousand(6, 11000, 3);

-- Exercise 3

-- Step 1: Make sure the inspection_date column exists
ALTER TABLE meat_poultry_egg_inspect
ADD COLUMN IF NOT EXISTS inspection_date date;

-- Step 2: Create the trigger function
CREATE OR REPLACE FUNCTION set_inspection_date()
RETURNS trigger AS
$$
BEGIN
    NEW.inspection_date := now() + '6 months'::interval;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 3: Create the trigger
CREATE OR REPLACE TRIGGER inspection_date_trigger
BEFORE INSERT ON meat_poultry_egg_inspect
FOR EACH ROW
EXECUTE FUNCTION set_inspection_date();

-- Step 4: Test it by inserting a new facility
INSERT INTO meat_poultry_egg_inspect (
    est_number,
    company,
    city,
    st,
    zip)
VALUES (
    'V18677A',
    'New Test Facility',
    'Chicago',
    'IL',
    '60601');

-- Step 5: Verify the inspection date was auto-set
SELECT est_number, company, city, st, inspection_date
FROM meat_poultry_egg_inspect
WHERE est_number = 'V18677A';