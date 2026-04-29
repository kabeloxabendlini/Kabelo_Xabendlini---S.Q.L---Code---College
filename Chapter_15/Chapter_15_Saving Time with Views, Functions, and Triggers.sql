-- CREATE OR REPLACE VIEW nevada_counties_pop_2010 AS
--  SELECT geo_name,
--  state_fips,
--  county_fips,
--  p0010001 AS pop_2010
--  FROM us_counties_2010
--  WHERE state_us_abbreviation = 'NV'
--  ORDER BY county_fips

-- SELECT * FROM nevada_counties_pop_2010
-- LIMIT 5; 

-- CREATE OR REPLACE VIEW county_pop_change_2010_2000 AS
--  SELECT c2010.geo_name,
--  c2010.state_us_abbreviation AS st,
--  c2010.state_fips,
--  c2010.county_fips,
--  c2010.p0010001 AS pop_2010,
--  c2000.p0010001 AS pop_2000,
--  round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
--  / c2000.p0010001 * 100, 1 ) AS pct_change_2010_2000
--  FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
--  ON c2010.state_fips = c2000.state_fips
--  AND c2010.county_fips = c2000.county_fips
--  ORDER BY c2010.state_fips, c2010.county_fips;

-- SELECT geo_name,
--  st,
--  pop_2010,
--  pct_change_2010_2000
-- FROM county_pop_change_2010_2000
-- WHERE st = 'NV'
-- LIMIT 5;

-- CREATE OR REPLACE VIEW employees_tax_dept AS
--  SELECT emp_id,
--  first_name,
--  last_name,
--  dept_id
--  FROM employees
--  WHERE dept_id = 1
--  ORDER BY emp_id
--  WITH LOCAL CHECK OPTION;

-- INSERT INTO employees_tax_dept (first_name, last_name, dept_id)
-- VALUES ('Suzanne', 'Legere', 1);

-- INSERT INTO employees_tax_dept (first_name, last_name, dept_id)
-- VALUES ('Jamil', 'White', 2);

-- SELECT * FROM employees_tax_dept;

-- SELECT * FROM employees;

-- UPDATE employees_tax_dept
-- SET last_name = 'Le Gere'
-- WHERE emp_id = 5;

-- SELECT * FROM employees_tax_dept; 

-- DELETE FROM employees_tax_dept
-- WHERE emp_id = 5;

-- CREATE OR REPLACE FUNCTION
--  percent_change(new_value numeric,
--  old_value numeric,
--  decimal_places integer DEFAULT 1)
--  RETURNS numeric AS
--  'SELECT round(
--  ((new_value - old_value) / old_value) * 100, decimal_places
-- );'
--   LANGUAGE SQL
--   IMMUTABLE
--   RETURNS NULL ON NULL INPUT;

-- SELECT percent_change(110, 108, 2);

-- SELECT c2010.geo_name,
--  c2010.state_us_abbreviation AS st,
--  c2010.p0010001 AS pop_2010,
--  percent_change(c2010.p0010001, c2000.p0010001) AS pct_chg_func,
--  round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
--  / c2000.p0010001 * 100, 1 ) AS pct_chg_formula
--  FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
--  ON c2010.state_fips = c2000.state_fips
--  AND c2010.county_fips = c2000.county_fips

-- ORDER BY pct_chg_func DESC
-- LIMIT 5;

-- ALTER TABLE teachers ADD COLUMN personal_days integer;

-- SELECT first_name,
--  last_name,
--  hire_date,
--  personal_days
-- FROM teachers;

-- CREATE OR REPLACE FUNCTION update_personal_days()
-- RETURNS void AS $$
-- BEGIN
--  UPDATE teachers
--  SET personal_days =
--  CASE WHEN (now() - hire_date) BETWEEN '5 years'::interval
--  AND '10 years'::interval THEN 4
--  WHEN (now() - hire_date) > '10 years'::interval THEN 5
--  ELSE 3
--  END;
--  RAISE NOTICE 'personal_days updated!';
-- END;
-- $$ LANGUAGE plpgsql;

-- SELECT update_personal_days();

-- -- Step 1: Call the function
-- SELECT update_personal_days();

-- -- Step 2: Query the table to see the results
-- SELECT id, first_name, last_name, hire_date, personal_days
-- FROM teachers;

-- CREATE EXTENSION plpython3u;

-- CREATE EXTENSION plpythonu;

-- CREATE EXTENSION IF NOT EXISTS plpython3u;

-- SELECT trim_county('Jefferson County');

-- -- Step 1: Create the function
-- CREATE OR REPLACE FUNCTION trim_county(input_string text)
-- RETURNS text AS $$
--   import re
--   cleaned = re.sub(r' County', '', input_string)
--   return cleaned
-- $$ LANGUAGE plpython3u;

-- SELECT geo_name,
--  trim_county(geo_name)
-- FROM us_counties_2010
-- ORDER BY state_fips, county_fips
-- LIMIT 5

--  CREATE TABLE grades (
--  student_id bigint,
--  course_id bigint,
--  course varchar(30) NOT NULL,
--  grade varchar(5) NOT NULL,
-- PRIMARY KEY (student_id, course_id)
-- );

-- INSERT INTO grades
-- VALUES
--  (1, 1, 'Biology 2', 'F'),
--  (1, 2, 'English 11B', 'D'),
--  (1, 3, 'World History 11B', 'C'),
--  (1, 4, 'Trig 2', 'B');
 
-- CREATE TABLE grades_history (
--  student_id bigint NOT NULL,
--  course_id bigint NOT NULL,
--  change_time timestamp with time zone NOT NULL,
--  course varchar(30) NOT NULL,
--  old_grade varchar(5) NOT NULL,
--  new_grade varchar(5) NOT NULL,
-- PRIMARY KEY (student_id, course_id, change_time)
-- );

-- CREATE OR REPLACE FUNCTION record_if_grade_changed()
-- RETURNS trigger AS
-- $$
-- BEGIN
--   IF NEW.grade <> OLD.grade THEN
--     INSERT INTO grades_history (
--       student_id,
--       course_id,
--       change_time,
--       course,
--       old_grade,
--       new_grade)
--     VALUES (
--       OLD.student_id,
--       OLD.course_id,
--       now(),
--       OLD.course,
--       OLD.grade,
--       NEW.grade);
--   END IF;
--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- UPDATE grades
-- SET grade = 'C'
-- WHERE student_id = 1 AND course_id = 1;
--  (OLD.student_id,
--  OLD.course_id,
--  now(),
--  OLD.course,
--  OLD.grade,
--  NEW.grade);
--  END IF;
--  RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- CREATE OR REPLACE TRIGGER grades_change_trigger
-- BEFORE UPDATE ON grades
-- FOR EACH ROW
-- EXECUTE FUNCTION record_if_grade_changed();

-- UPDATE grades
-- SET grade = 'C'
-- WHERE student_id = 1 AND course_id = 1;

-- SELECT * FROM grades_history;

-- SELECT student_id,
--  change_time,
--  course,
--  old_grade,
--  new_grade
-- FROM grades_history;

-- CREATE TABLE temperature_test (
--  station_name varchar(50),
--  observation_date date,
--  max_temp integer,
--  min_temp integer,
--  max_temp_group varchar(40),
-- PRIMARY KEY (station_name, observation_date)
-- );

-- CREATE OR REPLACE FUNCTION classify_max_temp()
--  RETURNS trigger AS
-- $$
-- BEGIN
--  CASE
--  WHEN NEW.max_temp >= 90 THEN
--  NEW.max_temp_group := 'Hot';
--  WHEN NEW.max_temp BETWEEN 70 AND 89 THEN
--  NEW.max_temp_group := 'Warm';
--  WHEN NEW.max_temp BETWEEN 50 AND 69 THEN
--  NEW.max_temp_group := 'Pleasant';
--  WHEN NEW.max_temp BETWEEN 33 AND 49 THEN
--  NEW.max_temp_group := 'Cold';
--  WHEN NEW.max_temp BETWEEN 20 AND 32 THEN
--  NEW.max_temp_group := 'Freezing';
--  ELSE NEW.max_temp_group := 'Inhumane';
--  END CASE;
--  RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- CREATE TRIGGER temperature_insert
--  BEFORE INSERT
--  ON temperature_test
--  FOR EACH ROW
--  EXECUTE PROCEDURE classify_max_temp();

INSERT INTO temperature_test (station_name, observation_date, max_temp, min_temp)
VALUES
  ('North Station', '2019-01-19', 10, -3),
  ('North Station', '2019-03-20', 28, 19),
  ('North Station', '2019-05-02', 65, 42),
  ('North Station', '2019-08-09', 93, 74);

SELECT * FROM temperature_test;