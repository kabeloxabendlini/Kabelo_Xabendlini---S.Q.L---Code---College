-- CREATE TABLE current_time_example (
--  time_id bigserial,
--  current_timestamp_col timestamp with time zone,
--  clock_timestamp_col timestamp with time zone
-- );

-- INSERT INTO current_time_example (current_timestamp_col, clock_timestamp_col)
--  (SELECT current_timestamp,
--  clock_timestamp()
--  FROM generate_series(1,1000));
-- SELECT * FROM current_time_example;

-- SHOW timezone;

-- SELECT * FROM pg_timezone_abbrevs;
-- SELECT * FROM pg_timezone_names;

-- SELECT * FROM pg_timezone_names
-- WHERE name LIKE 'Europe%';

-- SET timezone TO 'US/Pacific';
-- CREATE TABLE time_zone_test (
--  test_date timestamp with time zone
-- );

-- INSERT INTO time_zone_test VALUES ('2020-01-01 4:00');
-- SELECT test_date
-- FROM time_zone_test;
-- SET timezone TO 'US/Eastern';

-- SELECT test_date
-- FROM time_zone_test;

-- SELECT test_date AT TIME ZONE 'Asia/Seoul'
-- FROM time_zone_test;

-- CREATE TABLE nyc_yellow_taxi_trips_2016_06_01 (
--  trip_id bigserial PRIMARY KEY,
--  vendor_id varchar(1) NOT NULL,
--  tpep_pickup_datetime timestamp with time zone NOT NULL,
--  tpep_dropoff_datetime timestamp with time zone NOT NULL,
--  passenger_count integer NOT NULL,
--  trip_distance numeric(8,2) NOT NULL,
--  pickup_longitude numeric(18,15) NOT NULL,
--  pickup_latitude numeric(18,15) NOT NULL,
--  rate_code_id varchar(2) NOT NULL,
--  store_and_fwd_flag varchar(1) NOT NULL,
--  dropoff_longitude numeric(18,15) NOT NULL,
--  dropoff_latitude numeric(18,15) NOT NULL,
--  payment_type varchar(1) NOT NULL,
--  fare_amount numeric(9,2) NOT NULL,
--  extra numeric(9,2) NOT NULL,
--  mta_tax numeric(5,2) NOT NULL,
--  tip_amount numeric(9,2) NOT NULL,
--  tolls_amount numeric(9,2) NOT NULL,
--  improvement_surcharge numeric(9,2) NOT NULL,
--  total_amount numeric(9,2) NOT NULL
-- );

-- COPY nyc_yellow_taxi_trips_2016_06_01 (
--  vendor_id,
--  tpep_pickup_datetime,
--  tpep_dropoff_datetime,
--  passenger_count,
--  trip_distance,
--  pickup_longitude,
--  pickup_latitude,
--  rate_code_id,
--  store_and_fwd_flag,
--  dropoff_longitude,
--  dropoff_latitude,
--  payment_type,
--  fare_amount,
--  extra,
--  mta_tax,
--  tip_amount,
--  tolls_amount,
--  improvement_surcharge,
--  total_amount
--  )
 
-- FROM 'C:\S.Q.L\yellow_tripdata_2016_06_01.csv'
-- WITH (FORMAT CSV, HEADER, DELIMITER ',');

-- SELECT count(*) FROM nyc_yellow_taxi_trips_2016_06_01;

-- SET timezone TO 'US/Eastern';

-- SELECT
--  date_part('hour', tpep_pickup_datetime) AS trip_hour,
--  count(*)
-- FROM nyc_yellow_taxi_trips_2016_06_01
-- GROUP BY trip_hour
-- ORDER BY trip_hour;


-- COPY (
--   SELECT
--     date_part('hour', tpep_pickup_datetime) AS trip_hour,
--     count(*)
--   FROM nyc_yellow_taxi_trips_2016_06_01
--   GROUP BY trip_hour
--   ORDER BY trip_hour
-- )
-- TO 'C:\S.Q.L\hourly_pickups_2016_06_01.csv'
-- WITH (FORMAT CSV, HEADER, DELIMITER ',');

-- SELECT
--  date_part('hour', tpep_pickup_datetime) AS trip_hour,
--  percentile_cont(.5)
--  WITHIN GROUP (ORDER BY
--  tpep_dropoff_datetime - tpep_pickup_datetime) AS median_trip
-- FROM nyc_yellow_taxi_trips_2016_06_01
-- GROUP BY trip_hour
-- ORDER BY trip_hour;

-- SET timezone TO 'US/Central';
-- CREATE TABLE train_rides (
--  trip_id bigserial PRIMARY KEY,
--  segment varchar(50) NOT NULL,
--  departure timestamp with time zone NOT NULL,
--  arrival timestamp with time zone NOT NULL
-- );

-- INSERT INTO train_rides (segment, departure, arrival)
-- VALUES
--  ('Chicago to New York', '2017-11-13 21:30 CST', '2017-11-14 18:23 EST'),
--  ('New York to New Orleans', '2017-11-15 14:15 EST', '2017-11-16 19:32 CST'),
--  ('New Orleans to Los Angeles', '2017-11-17 13:45 CST', '2017-11-18 9:00 PST'),
--  ('Los Angeles to San Francisco', '2017-11-19 10:10 PST', '2017-11-19 21:24 PST'),
--  ('San Francisco to Denver', '2017-11-20 9:10 PST', '2017-11-21 18:38 MST'),
--  ('Denver to Chicago', '2017-11-22 19:10 MST', '2017-11-23 14:50 CST');
-- SELECT * FROM train_rides;

-- SELECT segment,
--  to_char(departure, 'YYYY-MM-DD HH12:MI a.m. TZ') AS departure,
--  arrival - departure AS segment_time
-- FROM train_rides;

-- SELECT segment,
--  arrival - departure AS segment_time,
--  sum(arrival - departure) OVER (ORDER BY trip_id) AS cume_time
-- FROM train_rides;

SELECT segment,
 arrival - departure AS segment_time,
 sum(date_part('epoch', (arrival - departure)))
 OVER (ORDER BY trip_id) * interval '1 second' AS cume_time
FROM train_rides;