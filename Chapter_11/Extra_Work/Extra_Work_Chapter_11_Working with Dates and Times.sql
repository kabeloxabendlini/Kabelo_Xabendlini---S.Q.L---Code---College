-- =============================================================================
-- Practical SQL: Chapter 12 - Working with Dates and Times
-- Try It Yourself - Solutions
-- =============================================================================
-- These exercises use the nyc_yellow_taxi_trips_2016_06_01 table, which
-- contains New York City yellow taxi trip records for June 1, 2016.
--
-- Key columns used:
--   • tpep_pickup_datetime  : timestamp when the trip started
--   • tpep_dropoff_datetime : timestamp when the trip ended
--   • trip_distance         : distance of the trip in miles
--   • total_amount          : total fare charged to the passenger
--
-- The goal is to practice:
--   • Calculating intervals between timestamps
--   • Converting timestamps across multiple time zones
--   • Using statistical functions (corr, regr_r2) on time-derived values
-- =============================================================================


-- =============================================================================
-- EXERCISE 1
-- Calculate the Length of Each Taxi Ride
-- =============================================================================
-- Context:
--   Subtracting two timestamps in PostgreSQL returns an INTERVAL — a duration
--   expressed as hours, minutes, and seconds (e.g. '00:43:22').
--   Ordering by ride_length DESC surfaces the longest trips first, which is
--   useful for spotting outliers (e.g. trips lasting many hours).
--
-- Key technique:
--   • tpep_dropoff_datetime - tpep_pickup_datetime produces the interval
--     directly; no special function is needed for simple duration arithmetic
--   • Aliasing the result as ride_length makes the output column readable
-- =============================================================================

-- Show each trip's pickup time, dropoff time, and calculated duration,
-- sorted longest ride first
-- SELECT
--     tpep_pickup_datetime,
--     tpep_dropoff_datetime,
--     tpep_dropoff_datetime - tpep_pickup_datetime AS ride_length
-- FROM nyc_yellow_taxi_trips_2016_06_01
-- ORDER BY ride_length DESC;


-- =============================================================================
-- EXERCISE 2
-- Convert a Future Timestamp Across Multiple World Time Zones
-- =============================================================================
-- Context:
--   AT TIME ZONE converts a timestamp to a specific time zone. Chaining two
--   AT TIME ZONE expressions converts FROM one zone INTO another, making it
--   straightforward to display the same moment in multiple cities at once.
--
--   The chosen timestamp (2100-01-01 00:00:00) is a convenient future midnight
--   in New York used as a fixed reference point for the conversions.
--
-- Time zones selected and their UTC offsets (standard time):
--   • America/New_York    — UTC-5  (base reference point)
--   • Europe/London       — UTC+0  (5 hours ahead of New York)
--   • Africa/Johannesburg — UTC+2  (7 hours ahead of New York)
--   • Europe/Moscow       — UTC+3  (8 hours ahead of New York)
--   • Australia/Melbourne — UTC+11 (16 hours ahead of New York)
--
-- Key technique:
--   • Using IANA timezone names (e.g. 'America/New_York') rather than fixed
--     offsets (e.g. 'UTC-5') is preferred because IANA names automatically
--     account for daylight saving time rules
-- =============================================================================

-- Display the same New York midnight moment expressed in five world cities
-- SELECT
--     '2100-01-01 00:00:00' AT TIME ZONE 'America/New_York' AS new_york,

--     -- Chain a second AT TIME ZONE to convert into the target city's local time
--     '2100-01-01 00:00:00' AT TIME ZONE 'America/New_York'
--         AT TIME ZONE 'Europe/London'       AS london,

--     '2100-01-01 00:00:00' AT TIME ZONE 'America/New_York'
--         AT TIME ZONE 'Africa/Johannesburg' AS johannesburg,

--     '2100-01-01 00:00:00' AT TIME ZONE 'America/New_York'
--         AT TIME ZONE 'Europe/Moscow'       AS moscow,

--     '2100-01-01 00:00:00' AT TIME ZONE 'America/New_York'
--         AT TIME ZONE 'Australia/Melbourne' AS melbourne;


-- =============================================================================
-- EXERCISE 3
-- Correlation and R² Between Ride Duration / Distance and Total Fare
-- =============================================================================
-- Context:
--   This exercise explores which factor — trip TIME or trip DISTANCE — is a
--   stronger predictor of the total fare charged.
--
--   Two statistical measures are calculated for each predictor:
--     • corr()    : Pearson correlation coefficient (-1 to +1)
--                   +1 = perfect positive linear relationship
--                    0 = no linear relationship
--                   -1 = perfect negative linear relationship
--     • regr_r2() : R-squared (coefficient of determination, 0 to 1)
--                   Represents the proportion of variance in total_amount
--                   that is explained by the predictor variable
--
-- Key techniques:
--   • EXTRACT(EPOCH FROM interval) converts the timestamp difference into
--     total seconds; dividing by 60 gives minutes, which is more intuitive
--   • ::numeric cast is required before round() because corr() and regr_r2()
--     return double precision, which round() does not accept directly
--   • The WHERE clause filters out data-quality outliers:
--       - Trips with 0 or negative duration (data entry errors or reversals)
--       - Trips longer than 3 hours (extreme outliers that skew correlations)
--     Using BETWEEN '0 seconds' AND '3 hours' compares intervals directly,
--     which is cleaner than converting to seconds in the WHERE clause
-- =============================================================================

WITH trip_data AS (
    SELECT
        -- Trip duration in minutes
        DATEDIFF(SECOND, tpep_pickup_datetime, tpep_dropoff_datetime) / 60.0 AS trip_minutes,
        trip_distance,
        total_amount
    FROM nyc_yellow_taxi_trips_2016_06_01
    WHERE DATEDIFF(SECOND, tpep_pickup_datetime, tpep_dropoff_datetime)
          BETWEEN 0 AND 10800 -- 3 hours = 10800 seconds
),

stats AS (
    SELECT
        COUNT(*) AS n,
        AVG(trip_minutes) AS avg_time,
        AVG(trip_distance) AS avg_distance,
        AVG(total_amount) AS avg_fare,

        SUM(trip_minutes * total_amount) AS sum_xy_time,
        SUM(trip_minutes * trip_minutes) AS sum_x2_time,

        SUM(trip_distance * total_amount) AS sum_xy_distance,
        SUM(trip_distance * trip_distance) AS sum_x2_distance,

        SUM(total_amount * total_amount) AS sum_y2
    FROM trip_data
)

SELECT
    -- Correlation: trip time vs fare
    (sum_xy_time - n * avg_time * avg_fare) /
    SQRT((sum_x2_time - n * avg_time * avg_time) *
         (sum_y2 - n * avg_fare * avg_fare)) AS trip_time_corr,

    -- Correlation: trip distance vs fare
    (sum_xy_distance - n * avg_distance * avg_fare) /
    SQRT((sum_x2_distance - n * avg_distance * avg_distance) *
         (sum_y2 - n * avg_fare * avg_fare)) AS trip_distance_corr

FROM stats;