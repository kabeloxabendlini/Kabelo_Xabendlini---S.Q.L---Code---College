-- -- Task 1: Waikiki max daily temps reclassified into 7 groups
-- WITH temps_collapsed (station_name, max_temperature_group) AS
--     (SELECT station_name,
--             CASE WHEN max_temp >= 90            THEN '90 or more'
--                  WHEN max_temp BETWEEN 88 AND 89 THEN '88-89'
--                  WHEN max_temp BETWEEN 86 AND 87 THEN '86-87'
--                  WHEN max_temp BETWEEN 84 AND 85 THEN '84-85'
--                  WHEN max_temp BETWEEN 82 AND 83 THEN '82-83'
--                  WHEN max_temp BETWEEN 80 AND 81 THEN '80-81'
--                  ELSE '79 or less'
--             END
--      FROM temperature_readings
--      WHERE station_name = 'WAIKIKI 717.2 HI US'   -- limit to Waikiki only
--        AND max_temp IS NOT NULL)                    -- max daily temps only

-- SELECT station_name,
--        max_temperature_group,
--        count(*) AS frequency
-- FROM temps_collapsed
-- GROUP BY station_name, max_temperature_group
-- ORDER BY frequency DESC;

-- Task 2: Flipped crosstab — flavor as rows, office as columns
-- First make sure the extension is installed:
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT *
FROM crosstab(
    -- First subquery: flavor is now the ROW, office is now the CATEGORY
    'SELECT flavor,
            office,
            count(*)
     FROM ice_cream_survey
     GROUP BY flavor, office
     ORDER BY flavor',

    -- Second subquery: offices are now the column categories
    'SELECT DISTINCT office
     FROM ice_cream_survey
     ORDER BY office'
)
AS (
    flavor      varchar(20),   -- row identifier (was office)
    downtown    bigint,        -- column categories (were flavors)
    midtown     bigint,
    uptown      bigint
);