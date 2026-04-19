-- Question: 1

-- SELECT
--     tpep_pickup_datetime,
--     tpep_dropoff_datetime,
--     tpep_dropoff_datetime - tpep_pickup_datetime AS ride_length
-- FROM nyc_yellow_taxi_trips_2016_06_01
-- ORDER BY ride_length DESC;
	
-- Question: 2

-- SELECT
--     '2100-01-01 00:00:00' AT TIME ZONE 'America/New_York' AS new_york,
--     '2100-01-01 00:00:00' AT TIME ZONE 'America/New_York' 
--         AT TIME ZONE 'Europe/London'       AS london,
--     '2100-01-01 00:00:00' AT TIME ZONE 'America/New_York' 
--         AT TIME ZONE 'Africa/Johannesburg' AS johannesburg,
--     '2100-01-01 00:00:00' AT TIME ZONE 'America/New_York' 
--         AT TIME ZONE 'Europe/Moscow'       AS moscow,
--     '2100-01-01 00:00:00' AT TIME ZONE 'America/New_York' 
--         AT TIME ZONE 'Australia/Melbourne' AS melbourne;

	-- Question: 3

SELECT
    -- Trip time (in minutes) vs Total Amount
    round(
        corr(
            EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime)) / 60,
            total_amount
        )::numeric, 4
    ) AS trip_time_corr,

    round(
        regr_r2(
            EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime)) / 60,
            total_amount
        )::numeric, 4
    ) AS trip_time_r2,

    -- Trip distance vs Total Amount
    round(
        corr(trip_distance, total_amount)::numeric, 4
    ) AS trip_distance_corr,

    round(
        regr_r2(trip_distance, total_amount)::numeric, 4
    ) AS trip_distance_r2

FROM nyc_yellow_taxi_trips_2016_06_01
WHERE (tpep_dropoff_datetime - tpep_pickup_datetime) 
          BETWEEN '0 seconds' AND '3 hours';