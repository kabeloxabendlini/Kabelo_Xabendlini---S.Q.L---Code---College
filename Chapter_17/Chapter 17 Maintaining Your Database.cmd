Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

Install the latest PowerShell for new features and improvements! https://aka.ms/PSWindows

PS C:\Users\Admin> pg_ctl reload -D "C:/Program Files/PostgreSQL/18/data"
server signaled
PS C:\Users\Admin> pg_dump -d analysis -U user_name -Fc > analysis_backup.sql
Password:

pg_dump: error: connection to server at "localhost" (::1), port 5432 failed: FATAL:  password authentication failed for user "user_name"
PS C:\Users\Admin> ^C
PS C:\Users\Admin> pg_dump -d analysis -U user_name -Fc > analysis_backup.sql
Password:

pg_dump: error: connection to server at "localhost" (::1), port 5432 failed: FATAL:  password authentication failed for user "user_name"
PS C:\Users\Admin> pg_dump -d analysis -U user_name -Fc > analysis_backup.sql
Password:

pg_dump: error: connection to server at "localhost" (::1), port 5432 failed: FATAL:  password authentication failed for user "user_name"
PS C:\Users\Admin> pg_dump -d analysis -U postgres -Fc > analysis_backup.sql
Password:

PS C:\Users\Admin> pg_dump -t 'train_rides' -d analysis -U user_name -Fc > train_backup.sql
Password:

pg_dump: error: connection to server at "localhost" (::1), port 5432 failed: FATAL:  password authentication failed for user "user_name"
PS C:\Users\Admin> pg_dump -t 'train_rides' -d analysis -U postgres -Fc > train_backup.sql
Password:

PS C:\Users\Admin> pg_restore -C -d postgres -U postgres analysis_backup.sql
pg_restore: error: input file does not appear to be a valid archive
PS C:\Users\Admin> pg_restore -C -d postgres -U postgres analysis_backup.sql^C
PS C:\Users\Admin> Get-Item "$env:USERPROFILE\analysis_backup.sql" | Select-Object Length

  Length
  ------
81118548


PS C:\Users\Admin> Get-Item "$env:USERPROFILE\analysis_backup.sql" | Select-Object FullName

FullName
--------
C:\Users\Admin\analysis_backup.sql


PS C:\Users\Admin> pg_restore -C -d postgres -U postgres "C:\Users\Admin\analysis_backup.sql"
pg_restore: error: input file does not appear to be a valid archive
PS C:\Users\Admin> pg_dump -d analysis -U postgres -Fc -f "C:\Users\Admin\analysis_backup.dump"
Password:

PS C:\Users\Admin> Get-Item "C:\Users\Admin\analysis_backup.dump" | Select-Object FullName, Length

FullName                              Length
--------                              ------
C:\Users\Admin\analysis_backup.dump 40236196


PS C:\Users\Admin> pg_restore -C -d postgres -U postgres "C:\Users\Admin\analysis_backup.dump"
Password:

pg_restore: error: could not execute query: ERROR:  database "analysis" already exists
Command was: CREATE DATABASE analysis WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_South Africa.1252';


pg_restore: error: could not execute query: ERROR:  function "classify_max_temp" already exists with same argument types
Command was: CREATE FUNCTION public.classify_max_temp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 CASE
 WHEN NEW.max_temp >= 90 THEN
 NEW.max_temp_group := 'Hot';
 WHEN NEW.max_temp BETWEEN 70 AND 89 THEN
 NEW.max_temp_group := 'Warm';
 WHEN NEW.max_temp BETWEEN 50 AND 69 THEN
 NEW.max_temp_group := 'Pleasant';
 WHEN NEW.max_temp BETWEEN 33 AND 49 THEN
 NEW.max_temp_group := 'Cold';
 WHEN NEW.max_temp BETWEEN 20 AND 32 THEN
 NEW.max_temp_group := 'Freezing';
 ELSE NEW.max_temp_group := 'Inhumane';
 END CASE;
 RETURN NEW;
END;
$$;


pg_restore: error: could not execute query: ERROR:  function "percent_change" already exists with same argument types
Command was: CREATE FUNCTION public.percent_change(new_value numeric, old_value numeric, decimal_places integer DEFAULT 1) RETURNS numeric
    LANGUAGE sql IMMUTABLE STRICT
    AS $$SELECT round(
 ((new_value - old_value) / old_value) * 100, decimal_places
);$$;


pg_restore: error: could not execute query: ERROR:  function "rates_per_thousand" already exists with same argument types
Command was: CREATE FUNCTION public.rates_per_thousand(observed_number numeric, base_number numeric, decimal_places integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN round(
        (observed_number / base_number) * 1000,
        decimal_places
    );
END;
$$;


pg_restore: error: could not execute query: ERROR:  function "record_if_grade_changed" already exists with same argument types
Command was: CREATE FUNCTION public.record_if_grade_changed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.grade <> OLD.grade THEN
    INSERT INTO grades_history (
      student_id,
      course_id,
      change_time,
      course,
      old_grade,
      new_grade)
    VALUES (
      NEW.student_id,
      NEW.course_id,
      now(),
      NEW.course,
      OLD.grade,
      NEW.grade);
  END IF;
  RETURN NEW;
END;
$$;


pg_restore: error: could not execute query: ERROR:  function "set_inspection_date" already exists with same argument types
Command was: CREATE FUNCTION public.set_inspection_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.inspection_date := now() + '6 months'::interval;
    RETURN NEW;
END;
$$;


pg_restore: error: could not execute query: ERROR:  function "update_personal_days" already exists with same argument types
Command was: CREATE FUNCTION public.update_personal_days() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
 UPDATE teachers
 SET personal_days =
 CASE WHEN (now() - hire_date) BETWEEN '5 years'::interval
 AND '10 years'::interval THEN 4
 WHEN (now() - hire_date) > '10 years'::interval THEN 5
 ELSE 3
 END;
 RAISE NOTICE 'personal_days updated!';
END;
$$;


pg_restore: error: could not execute query: ERROR:  relation "albums" already exists
Command was: CREATE TABLE public.albums (
    album_id bigint NOT NULL,
    album_catalog_code character varying(100) NOT NULL,
    album_title text NOT NULL,
    album_artist text NOT NULL,
    album_release_date date,
    album_genre character varying(40),
    album_description text
);


pg_restore: error: could not execute query: ERROR:  relation "albums_album_id_seq" already exists
Command was: CREATE SEQUENCE public.albums_album_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


pg_restore: error: could not execute query: ERROR:  relation "animal_types" already exists
Command was: CREATE TABLE public.animal_types (
    type_id integer NOT NULL,
    common_name character varying(100) NOT NULL,
    scientific_name character varying(150),
    classification character varying(50),
    diet character varying(50),
    habitat character varying(100),
    conservation_status character varying(50)
);


pg_restore: error: could not execute query: ERROR:  relation "animal_types_type_id_seq" already exists
Command was: CREATE SEQUENCE public.animal_types_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


pg_restore: error: could not execute query: ERROR:  relation "animals" already exists
Command was: CREATE TABLE public.animals (
    animal_id integer NOT NULL,
    name character varying(100),
    type_id integer NOT NULL,
    date_of_birth date,
    sex character varying(10),
    arrival_date date,
    health_status character varying(100),
    enclosure_number character varying(50)
);


pg_restore: error: could not execute query: ERROR:  relation "animals_animal_id_seq" already exists
Command was: CREATE SEQUENCE public.animals_animal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


pg_restore: error: could not execute query: ERROR:  relation "char_data_types" already exists
Command was: CREATE TABLE public.char_data_types (
    varchar_column character varying(10),
    char_column character(10),
    text_column text
);


pg_restore: error: could not execute query: ERROR:  relation "check_constraint_example" already exists
Command was: CREATE TABLE public.check_constraint_example (
    user_id bigint NOT NULL,
    user_role character varying(50),
    salary integer,
    CONSTRAINT check_role_in_list CHECK (((user_role)::text = ANY ((ARRAY['Admin'::character varying, 'Staff'::character varying])::text[]))),
    CONSTRAINT check_salary_not_zero CHECK ((salary > 0))
);


pg_restore: error: could not execute query: ERROR:  relation "check_constraint_example_user_id_seq" already exists
Command was: CREATE SEQUENCE public.check_constraint_example_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


pg_restore: error: could not execute query: ERROR:  relation "us_counties_2000" already exists
Command was: CREATE TABLE public.us_counties_2000 (
    geo_name character varying(90),
    state_us_abbreviation character varying(2),
    state_fips character varying(2),
    county_fips character varying(3),
    p0010001 integer,
    p0010002 integer,
    p0010003 integer,
    p0010004 integer,
    p0010005 integer,
    p0010006 integer,
    p0010007 integer,
    p0010008 integer,
    p0010009 integer,
    p0010010 integer,
    p0020002 integer,
    p0020003 integer
);


pg_restore: error: could not execute query: ERROR:  relation "us_counties_2010" already exists
Command was: CREATE TABLE public.us_counties_2010 (
    geo_name character varying(90),
    state_us_abbreviation character varying(2),
    summary_level character varying(3),
    region smallint,
    division smallint,
    state_fips character varying(2),
    county_fips character varying(3),
    area_land bigint,
    area_water bigint,
    population_count_100_percent integer,
    housing_unit_count_100_percent integer,
    internal_point_lat numeric(10,7),
    internal_point_lon numeric(10,7),
    p0010001 integer,
    p0010002 integer,
    p0010003 integer,
    p0010004 integer,
    p0010005 integer,
    p0010006 integer,
    p0010007 integer,
    p0010008 integer,
    p0010009 integer,
    p0010010 integer,
    p0010011 integer,
    p0010012 integer,
    p0010013 integer,
    p0010014 integer,
    p0010015 integer,
    p0010016 integer,
    p0010017 integer,
    p0010018 integer,
    p0010019 integer,
    p0010020 integer,
    p0010021 integer,
    p0010022 integer,
    p0010023 integer,
    p0010024 integer,
    p0010025 integer,
    p0010026 integer,
    p0010047 integer,
    p0010063 integer,
    p0010070 integer,
    p0020001 integer,
    p0020002 integer,
    p0020003 integer,
    p0020004 integer,
    p0020005 integer,
    p0020006 integer,
    p0020007 integer,
    p0020008 integer,
    p0020009 integer,
    p0020010 integer,
    p0020011 integer,
    p0020012 integer,
    p0020028 integer,
    p0020049 integer,
    p0020065 integer,
    p0020072 integer,
    p0030001 integer,
    p0030002 integer,
    p0030003 integer,
    p0030004 integer,
    p0030005 integer,
    p0030006 integer,
    p0030007 integer,
    p0030008 integer,
    p0030009 integer,
    p0030010 integer,
    p0030026 integer,
    p0030047 integer,
    p0030063 integer,
    p0030070 integer,
    p0040001 integer,
    p0040002 integer,
    p0040003 integer,
    p0040004 integer,
    p0040005 integer,
    p0040006 integer,
    p0040007 integer,
    p0040008 integer,
    p0040009 integer,
    p0040010 integer,
    p0040011 integer,
    p0040012 integer,
    p0040028 integer,
    p0040049 integer,
    p0040065 integer,
    p0040072 integer,
    h0010001 integer,
    h0010002 integer,
    h0010003 integer
);


pg_restore: error: could not execute query: ERROR:  relation "county_pop_change_2010_2000" already exists
Command was: CREATE VIEW public.county_pop_change_2010_2000 AS
 SELECT c2010.geo_name,
    c2010.state_us_abbreviation AS st,
    c2010.state_fips,
    c2010.county_fips,
    c2010.p0010001 AS pop_2010,
    c2000.p0010001 AS pop_2000,
    round(((((c2010.p0010001)::numeric(8,1) - (c2000.p0010001)::numeric) / (c2000.p0010001)::numeric) * (100)::numeric), 1) AS pct_change_2010_2000
   FROM (public.us_counties_2010 c2010
     JOIN public.us_counties_2000 c2000 ON ((((c2010.state_fips)::text = (c2000.state_fips)::text) AND ((c2010.county_fips)::text = (c2000.county_fips)::text))))
  ORDER BY c2010.state_fips, c2010.county_fips;


pg_restore: error: could not execute query: ERROR:  relation "crime_reports" already exists
Command was: CREATE TABLE public.crime_reports (
    crime_id bigint NOT NULL,
    date_1 timestamp with time zone,
    date_2 timestamp with time zone,
    street character varying(250),
    city character varying(100),
    crime_type character varying(100),
    description text,
    case_number character varying(50),
    original_text text NOT NULL
);


pg_restore: error: could not execute query: ERROR:  relation "crime_reports_crime_id_seq" already exists
Command was: CREATE SEQUENCE public.crime_reports_crime_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


pg_restore: error: could not execute query: ERROR:  relation "current_time_example" already exists
Command was: CREATE TABLE public.current_time_example (
    time_id bigint NOT NULL,
    current_timestamp_col timestamp with time zone,
    clock_timestamp_col timestamp with time zone
);


pg_restore: error: could not execute query: ERROR:  relation "current_time_example_time_id_seq" already exists
Command was: CREATE SEQUENCE public.current_time_example_time_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


pg_restore: error: could not execute query: ERROR:  relation "date_time_types" already exists
Command was: CREATE TABLE public.date_time_types (
    timestamp_column timestamp with time zone,
    interval_column interval
);


pg_restore: error: could not execute query: ERROR:  relation "delivery_routes" already exists
Command was: CREATE TABLE public.delivery_routes (
    route_id integer NOT NULL,
    driver_id integer NOT NULL,
    store_name character varying(100) NOT NULL,
    route_date date NOT NULL
);


pg_restore: error: could not execute query: ERROR:  relation "delivery_routes_route_id_seq" already exists
Command was: CREATE SEQUENCE public.delivery_routes_route_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


pg_restore: error: could not execute query: ERROR:  relation "departments" already exists
Command was: CREATE TABLE public.departments (
    dept_id bigint NOT NULL,
    dept character varying(100),
    city character varying(100)
);


pg_restore: error: could not execute query: ERROR:  relation "departments_dept_id_seq" already exists
Command was: CREATE SEQUENCE public.departments_dept_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


pg_restore: error: could not execute query: ERROR:  relation "drivers" already exists
Command was: CREATE TABLE public.drivers (
    driver_id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    hire_date date NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


pg_restore: error: could not execute query: ERROR:  relation "drivers_driver_id_seq" already exists
Command was: CREATE SEQUENCE public.drivers_driver_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


pg_restore: error: could not execute query: ERROR:  relation "eagle_watch" already exists
Command was: CREATE TABLE public.eagle_watch (
    observed_date date,
    eagles_seen integer
);


pg_restore: error: could not execute query: ERROR:  relation "employees" already exists
Command was: CREATE TABLE public.employees (
    emp_id bigint NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    salary integer,
    dept_id integer
);
