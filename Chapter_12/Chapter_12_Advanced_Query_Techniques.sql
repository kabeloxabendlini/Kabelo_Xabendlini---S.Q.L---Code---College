-- SELECT geo_name,
--  state_us_abbreviation,
--  p0010001
-- FROM us_counties_2010
-- WHERE p0010001 >= (
--  SELECT percentile_cont(.9) WITHIN GROUP (ORDER BY p0010001)
--  FROM us_counties_2010
--  )
-- ORDER BY p0010001 DESC;

-- CREATE TABLE us_counties_2010_top10 AS
-- SELECT * FROM us_counties_2010;
-- DELETE FROM us_counties_2010_top10
-- WHERE p0010001 < (
--  SELECT percentile_cont(.9) WITHIN GROUP (ORDER BY p0010001)
--  FROM us_counties_2010_top10
--  );

-- SELECT round(calcs.average, 0) AS average,
--  calcs.median,
--  round(calcs.average - calcs.median, 0) AS median_average_diff
-- FROM (
--  SELECT avg(p0010001) AS average,
--  percentile_cont(.5)
--  WITHIN GROUP (ORDER BY p0010001)::numeric(10,1) AS median
--  FROM us_counties_2010
--  )
-- AS calcs;

-- SELECT census.state_us_abbreviation AS st,
--  census.st_population,
--  plants.plant_count,
--  round((plants.plant_count/census.st_population::numeric(10,1))*1000000, 1)
--  AS plants_per_million

-- FROM
--  (
--  SELECT st,
--  count(*) AS plant_count
--  FROM meat_poultry_egg_inspect
--  GROUP BY st
--  )
--  AS plants
-- JOIN
--  (
--  SELECT state_us_abbreviation,
--  sum(p0010001) AS st_population
--  FROM us_counties_2010
--  GROUP BY state_us_abbreviation
--  )
--  AS census
-- ON plants.st = census.state_us_abbreviation
-- ORDER BY plants_per_million DESC;

-- SELECT geo_name,
--  state_us_abbreviation AS st,
--  p0010001 AS total_pop,
--  (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
--  FROM us_counties_2010) AS us_median
-- FROM us_counties_2010;

-- SELECT geo_name,
--  state_us_abbreviation AS st,
--  p0010001 AS total_pop,
--  (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)

--  FROM us_counties_2010) AS us_median,
--  p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
--  FROM us_counties_2010) AS diff_from_median
-- FROM us_counties_2010
-- WHERE (p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
--  FROM us_counties_2010))
--  BETWEEN -1000 AND 1000;

-- SELECT first_name, last_name
-- FROM employees
-- WHERE id IN (
--  SELECT id
--  FROM retirees);

-- SELECT first_name, last_name
-- FROM employees
-- WHERE EXISTS (
--  SELECT id
--  FROM retirees
--  WHERE id = employees.id);

-- CREATE TABLE retirees (
--     emp_id bigint REFERENCES employees(emp_id),
--     retirement_date date
-- );

-- -- Then your original query works as intended:
-- SELECT first_name, last_name
-- FROM employees
-- WHERE emp_id IN (
--     SELECT emp_id
--     FROM retirees
-- );

-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'employees'
-- ORDER BY ordinal_position;

-- SELECT table_schema, table_name
-- FROM information_schema.tables
-- WHERE table_type = 'BASE TABLE'
-- AND table_schema NOT IN ('pg_catalog', 'information_schema')
-- ORDER BY table_schema, table_name;

-- CREATE TABLE retirees (
--     emp_id bigint REFERENCES employees(emp_id),
--     retirement_date date
-- );

-- -- Then your query, with correct column names:
-- SELECT first_name, last_name
-- FROM employees
-- WHERE NOT EXISTS (
--     SELECT emp_id
--     FROM retirees
--     WHERE retirees.emp_id = employees.emp_id
-- );

-- WITH
--  large_counties (geo_name, st, p0010001)
-- AS
--  (
--  SELECT geo_name, state_us_abbreviation, p0010001
--  FROM us_counties_2010
--  WHERE p0010001 >= 100000
--  )
-- SELECT st, count(*)
-- FROM large_counties
-- GROUP BY st
-- ORDER BY count(*) DESC;

-- SELECT state_us_abbreviation, count(*)
-- FROM us_counties_2010
-- WHERE p0010001 >= 100000
-- GROUP BY state_us_abbreviation
-- ORDER BY count(*) DESC;

-- WITH
--  counties (st, population) AS
--  (SELECT state_us_abbreviation, sum(population_count_100_percent)
--  FROM us_counties_2010
--  GROUP BY state_us_abbreviation),
--  plants (st, plants) AS
--  (SELECT st, count(*) AS plants
--  FROM meat_poultry_egg_inspect
--  GROUP BY st)

-- SELECT counties.st,
--  population,

--  plants,
--  round((plants/population::numeric(10,1)) * 1000000, 1) AS per_million
-- FROM counties JOIN plants
-- ON counties.st = plants.st
-- ORDER BY per_million DESC;

-- WITH us_median AS
--  (SELECT percentile_cont(.5)
--  WITHIN GROUP (ORDER BY p0010001) AS us_median_pop
--  FROM us_counties_2010)
-- SELECT geo_name,
--  state_us_abbreviation AS st,
--  p0010001 AS total_pop,
--  us_median_pop,
--  p0010001 - us_median_pop AS diff_from_median
-- FROM us_counties_2010 CROSS JOIN us_median
-- WHERE (p0010001 - us_median_pop)
--  BETWEEN -1000 AND 1000

-- CREATE EXTENSION tablefunc;

-- CREATE TABLE ice_cream_survey (
--  response_id integer PRIMARY KEY,
--  office varchar(20),
--  flavor varchar(20)
-- );

-- COPY ice_cream_survey
-- FROM 'C:\S.Q.L\ice_cream_survey.csv'
-- WITH (FORMAT CSV, HEADER);

-- SELECT *
-- FROM ice_cream_survey
-- LIMIT 5;

-- SELECT * FROM crosstab('SELECT office,
--  flavor,
-- count(*)
--  FROM ice_cream_survey
--  GROUP BY office, flavor
--  ORDER BY office',

--  'SELECT flavor
--  FROM ice_cream_survey
--  GROUP BY flavor
--  ORDER BY flavor')

-- AS (office varchar(20),
--  chocolate bigint,
--  strawberry bigint,
--  vanilla bigint);

-- CREATE TABLE temperature_readings (
--  reading_id bigserial,
--  station_name varchar(50),
--  observation_date date,
--  max_temp integer,
--  min_temp integer
-- );

-- COPY temperature_readings
--  (station_name, observation_date, max_temp, min_temp)
-- FROM 'C:\S.Q.L\temperature_readings.csv'
-- WITH (FORMAT CSV, HEADER);

-- SELECT * FROM crosstab('SELECT
--  station_name,
--  date_part(''month'', observation_date),
--  percentile_cont(.5)
--  WITHIN GROUP (ORDER BY max_temp)
--  FROM temperature_readings
--  GROUP BY station_name,
--  date_part(''month'', observation_date)
--  ORDER BY station_name',

--  'SELECT month
--  FROM generate_series(1,12) month')

-- AS (station varchar(50),
--  jan numeric(3,0),
--  feb numeric(3,0),
--  mar numeric(3,0),
--  apr numeric(3,0),
--  may numeric(3,0),
--  jun numeric(3,0),
--  jul numeric(3,0),
--  aug numeric(3,0),
--  sep numeric(3,0),
--  oct numeric(3,0),
--  nov numeric(3,0),
--  dec numeric(3,0)
-- );

-- SELECT max_temp,
--  CASE WHEN max_temp >= 90 THEN 'Hot'
--  WHEN max_temp BETWEEN 70 AND 89 THEN 'Warm'
--  WHEN max_temp BETWEEN 50 AND 69 THEN 'Pleasant'
--  WHEN max_temp BETWEEN 33 AND 49 THEN 'Cold'
--  WHEN max_temp BETWEEN 20 AND 32 THEN 'Freezing'
--  ELSE 'Inhumane'
--  END AS temperature_group
-- FROM temperature_readings;

WITH temps_collapsed (station_name, max_temperature_group) AS
 (SELECT station_name,
 CASE WHEN max_temp >= 90 THEN 'Hot'
 WHEN max_temp BETWEEN 70 AND 89 THEN 'Warm'
 WHEN max_temp BETWEEN 50 AND 69 THEN 'Pleasant'
 WHEN max_temp BETWEEN 33 AND 49 THEN 'Cold'
 WHEN max_temp BETWEEN 20 AND 32 THEN 'Freezing'
 ELSE 'Inhumane'
 END
 FROM temperature_readings)
SELECT station_name, max_temperature_group, count(*)
FROM temps_collapsed
GROUP BY station_name, max_temperature_group
ORDER BY station_name, count(*) DESC;