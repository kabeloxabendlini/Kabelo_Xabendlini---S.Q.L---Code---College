-- COPY movies (id, movie, actor)
-- FROM 'C:/S.Q.L/movies.txt'
-- WITH (
--     FORMAT CSV,
--     HEADER,
--     DELIMITER ':',
--     QUOTE '#'
-- );

-- -- First verify the data looks right
-- SELECT geo_name, state_us_abbreviation, housing_unit_count_100_percent
-- FROM us_counties_2010
-- ORDER BY housing_unit_count_100_percent DESC
-- LIMIT 20;

-- -- Then export to CSV
-- COPY (
--     SELECT geo_name, state_us_abbreviation, housing_unit_count_100_percent
--     FROM us_counties_2010
--     ORDER BY housing_unit_count_100_percent DESC
--     LIMIT 20
-- )
-- TO 'C:/S.Q.L/top_20_housing_counties.csv'
-- WITH (FORMAT CSV, HEADER);

-- This is the correct answer for the exercise.
-- The file is fictional, so the COPY will always fail.
-- What matters is the WITH syntax:

-- CREATE TABLE movies (
--     id integer,
--     movie varchar(100),
--     actor varchar(100)
-- );

-- COPY movies (id, movie, actor)
-- FROM 'C:/S.Q.L/movies.txt'
-- WITH (
--     FORMAT CSV,
--     HEADER,
--     DELIMITER ':',   -- handles the colon separator between columns
--     QUOTE '#'        -- handles #Mission: Impossible# wrapping
-- );

-- -- Step 3: Verify the data loaded
-- SELECT * FROM movies;

-- Preview first
-- SELECT geo_name, state_us_abbreviation, housing_unit_count_100_percent
-- FROM us_counties_2010
-- ORDER BY housing_unit_count_100_percent DESC
-- LIMIT 20;

-- Then export
-- copy (
--     SELECT geo_name, state_us_abbreviation, housing_unit_count_100_percent
--     FROM us_counties_2010
--     ORDER BY housing_unit_count_100_percent DESC
--     LIMIT 20
-- ) TO 'C:/S.Q.L/top_20_housing_counties.csv' WITH (FORMAT CSV, HEADER);