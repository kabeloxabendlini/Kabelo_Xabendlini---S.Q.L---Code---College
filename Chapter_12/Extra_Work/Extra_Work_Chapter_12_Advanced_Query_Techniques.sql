-- ============================================================
-- Task 1: Waikiki max daily temperatures grouped into 7 ranges
-- ============================================================

-- Create a Common Table Expression (CTE) to group temperatures
-- into labeled ranges for easier aggregation
-- WITH temps_collapsed (station_name, max_temperature_group) AS
-- (
--     SELECT 
--         station_name,
        
--         -- Categorize max_temp into defined buckets
--         CASE 
--             WHEN max_temp >= 90              THEN '90 or more'
--             WHEN max_temp BETWEEN 88 AND 89  THEN '88-89'
--             WHEN max_temp BETWEEN 86 AND 87  THEN '86-87'
--             WHEN max_temp BETWEEN 84 AND 85  THEN '84-85'
--             WHEN max_temp BETWEEN 82 AND 83  THEN '82-83'
--             WHEN max_temp BETWEEN 80 AND 81  THEN '80-81'
--             ELSE '79 or less'
--         END AS max_temperature_group

--     FROM temperature_readings

--     -- Filter to only include Waikiki station data
--     WHERE station_name = 'WAIKIKI 717.2 HI US'
    
--     -- Exclude rows where max_temp is NULL
--     AND max_temp IS NOT NULL
-- )

-- Aggregate results: count how many readings fall into each group
-- SELECT 
--     station_name,
--     max_temperature_group,
--     COUNT(*) AS frequency

-- FROM temps_collapsed

-- Group by station and temperature bucket
-- GROUP BY station_name, max_temperature_group

-- Order results by highest frequency first
-- ORDER BY frequency DESC;



-- ============================================================
-- Task 2: Crosstab (Pivot Table)
-- Flavor as rows, Office as columns
-- ============================================================

-- Ensure the tablefunc extension is available (PostgreSQL only)
CREATE EXTENSION IF NOT EXISTS tablefunc;

-- Perform crosstab transformation
SELECT *
FROM crosstab(

    -- --------------------------------------------------------
    -- Source query (row_name, category, value)
    -- flavor  → becomes row identifier
    -- office  → becomes column categories
    -- count(*) → values inside the table
    -- --------------------------------------------------------
    '
    SELECT 
        flavor,
        office,
        COUNT(*) AS total_votes
    FROM ice_cream_survey
    GROUP BY flavor, office
    ORDER BY flavor
    ',

    -- --------------------------------------------------------
    -- Category query
    -- Defines the columns (must match output definition order)
    -- --------------------------------------------------------
    '
    SELECT DISTINCT office
    FROM ice_cream_survey
    ORDER BY office
    '

)

-- ------------------------------------------------------------
-- Define the structure of the resulting pivot table
-- IMPORTANT:
-- - First column = row identifier
-- - Remaining columns = categories (must match order above)
-- ------------------------------------------------------------
AS (
    flavor   VARCHAR(20),  -- Row label (each ice cream flavor)
    downtown BIGINT,       -- Count for Downtown office
    midtown  BIGINT,       -- Count for Midtown office
    uptown   BIGINT        -- Count for Uptown office
);