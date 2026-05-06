-- =============================================================================
-- Practical SQL: Chapter 8 - Grouping and Aggregating
-- Try It Yourself - Solutions
-- =============================================================================
-- These exercises use two Public Library Survey (PLS) tables:
--   • pls_fy2014_pupld14a  (2014 survey data, aliased as pls14)
--   • pls_fy2009_pupld09a  (2009 survey data, aliased as pls09)
-- Libraries are matched across years using the shared key column: fscskey
-- =============================================================================


-- =============================================================================
-- EXERCISE 1
-- Percent Change in Technology Usage (gpterms & pitusr) Between 2009 and 2014
-- =============================================================================
-- Context:
--   Chapter 8 (Listing 8-13) showed percent change in library VISITS by state.
--   This exercise extends that pattern to two technology-related columns:
--     • gpterms : number of internet-connected computers available to the public
--     • pitusr  : number of public internet computer uses per year
--
-- Key technique:
--   • Negative sentinel values (e.g. -1, -3) indicate missing/suppressed data
--     in the PLS dataset, so WHERE clauses filter them out with >= 0
--   • NULLIF(..., 0) prevents division-by-zero when a 2009 sum is zero
--   • CAST to numeric(12,2) ensures decimal division instead of integer division
--   • Results are ordered by gpterms percent change (descending) so the
--     states with the greatest growth appear first
-- =============================================================================

-- SELECT
--     pls14.stabr,                          -- Two-letter state abbreviation

--     -- ---- gpterms (public internet computers) ----
--     sum(pls14.gpterms) AS gpterms_2014,   -- Total public computers in 2014
--     sum(pls09.gpterms) AS gpterms_2009,   -- Total public computers in 2009

--     -- Percent change formula: (new - old) / old * 100
--     -- NULLIF avoids division by zero if 2009 total was 0
--     round(
--         (CAST(sum(pls14.gpterms) AS numeric(12,2)) - sum(pls09.gpterms))
--         / NULLIF(sum(pls09.gpterms), 0) * 100,
--     2) AS gpterms_pct_chg,

--     -- ---- pitusr (public internet computer uses per year) ----
--     sum(pls14.pitusr) AS pitusr_2014,     -- Total uses in 2014
--     sum(pls09.pitusr) AS pitusr_2009,     -- Total uses in 2009

--     -- Same percent change formula applied to pitusr
--     round(
--         (CAST(sum(pls14.pitusr) AS numeric(12,2)) - sum(pls09.pitusr))
--         / NULLIF(sum(pls09.pitusr), 0) * 100,
--     2) AS pitusr_pct_chg

-- FROM pls_fy2014_pupld14a pls14
--      JOIN pls_fy2009_pupld09a pls09
--          ON pls14.fscskey = pls09.fscskey   -- Match each library across years

-- -- Exclude rows where either year uses a negative sentinel value
-- -- (negative values = missing/suppressed data in the PLS survey)
-- WHERE pls14.gpterms >= 0
--   AND pls09.gpterms >= 0
--   AND pls14.pitusr  >= 0
--   AND pls09.pitusr  >= 0

-- GROUP BY pls14.stabr                       -- One summary row per state
-- ORDER BY gpterms_pct_chg DESC;             -- Highest growth states first


-- =============================================================================
-- EXERCISE 2A
-- Lookup Table: Bureau of Economic Analysis (BEA) Region Codes
-- =============================================================================
-- Context:
--   The PLS tables include a column called obereg — a two-character BEA code
--   that groups each library agency into one of nine U.S. geographic regions.
--   Rather than displaying raw codes in results, we create a small lookup table
--   (obereg_codes) and JOIN it in the summary query to show readable region names.
--
-- Design notes:
--   • obereg is stored as varchar(2) to preserve the leading zero (e.g. '01')
--   • It is the PRIMARY KEY, guaranteeing one row per code and fast lookups
--   • The nine codes and names come from the official PLS survey documentation
-- =============================================================================

-- CREATE TABLE obereg_codes (
--     obereg  varchar(2)  CONSTRAINT obereg_key PRIMARY KEY,
--     region  text        NOT NULL
-- );

-- INSERT INTO obereg_codes (obereg, region)
-- VALUES
--     ('01', 'New England'),       -- CT ME MA NH RI VT
--     ('02', 'Mideast'),           -- DE DC MD NJ NY PA
--     ('03', 'Great Lakes'),       -- IL IN MI OH WI
--     ('04', 'Plains'),            -- IA KS MN MO NE ND SD
--     ('05', 'Southeast'),         -- AL AR FL GA KY LA MS NC SC TN VA WV
--     ('06', 'Southwest'),         -- AZ NM OK TX
--     ('07', 'Rocky Mountains'),   -- CO ID MT UT WY
--     ('08', 'Far West'),          -- AK CA HI NV OR WA
--     ('09', 'Outlying Areas');    -- GU MP PR VI


-- =============================================================================
-- EXERCISE 2B
-- Percent Change in Library Visits Grouped by U.S. Region (with region names)
-- =============================================================================
-- Context:
--   Mirrors the state-level visit analysis from Listing 8-13, but aggregates
--   to the regional level by joining the obereg_codes lookup table.
--
-- Joins used:
--   1. pls14 INNER JOIN pls09   → matches the same library across both years
--   2. pls14 JOIN obereg_codes  → maps the raw obereg code to a region name
--
-- Filtering:
--   Visits use the same negative sentinel convention as other PLS columns,
--   so rows where either year's visits < 0 are excluded.
--
-- Result:
--   One row per region showing total visits in each year and the percent
--   change, ordered from largest decline to largest growth.
-- =============================================================================

-- SELECT
--     ob.region,                             -- Human-readable region name from lookup table

--     sum(pls14.visits) AS visits_2014,      -- Total visits across all agencies in region (2014)
--     sum(pls09.visits) AS visits_2009,      -- Total visits across all agencies in region (2009)

--     -- Percent change: negative result means visits declined over the period
--     round(
--         (CAST(sum(pls14.visits) AS numeric(12,2)) - sum(pls09.visits))
--         / NULLIF(sum(pls09.visits), 0) * 100,
--     2) AS visits_pct_chg

-- FROM pls_fy2014_pupld14a pls14
--      JOIN pls_fy2009_pupld09a pls09
--          ON pls14.fscskey = pls09.fscskey  -- Match same library across years

--      JOIN obereg_codes ob
--          ON pls14.obereg = ob.obereg        -- Swap raw code for readable region name

-- -- Filter out sentinel negative values for visits in both years
-- WHERE pls14.visits >= 0
--   AND pls09.visits >= 0

-- GROUP BY ob.region                         -- Aggregate to region level
-- ORDER BY visits_pct_chg DESC;              -- Largest growth → largest decline


-- =============================================================================
-- EXERCISE 3
-- Full Outer Join — Finding Agencies Present in One Table But Not the Other
-- =============================================================================
-- Context:
--   Chapter 6 introduced join types. A FULL OUTER JOIN returns ALL rows from
--   BOTH tables, filling in NULLs where there is no match on the join key.
--   This lets us identify:
--     • Libraries that existed in 2014 but NOT in 2009 (new agencies)
--     • Libraries that existed in 2009 but NOT in 2014 (closed/merged agencies)
--
-- Approach:
--   COALESCE picks the non-NULL value from whichever table has the record,
--   so fscskey and libname always display regardless of which side matched.
--   A CASE expression then labels each unmatched row with a human-readable status.
--   The WHERE clause restricts output to only the unmatched rows (IS NULL on
--   one side or the other).
--
-- Note on the commented-out queries above:
--   The two simpler commented queries each isolate ONE direction of mismatch
--   (only 2009 missing, or only 2014 missing). The combined query below handles
--   both directions in a single, cleaner result set.
-- =============================================================================

-- -- Simpler version: agencies in 2014 but missing from 2009
-- SELECT pls14.fscskey,
--        pls14.libname,
--        pls09.fscskey                        -- Will be NULL for unmatched rows
-- FROM pls_fy2014_pupld14a pls14
--      FULL OUTER JOIN pls_fy2009_pupld09a pls09
--          ON pls14.fscskey = pls09.fscskey
-- WHERE pls09.fscskey IS NULL                 -- Agencies not found in 2009
-- ORDER BY pls14.fscskey;

-- -- Simpler version: agencies in 2009 but missing from 2014
-- SELECT pls09.fscskey,
--        pls09.libname,
--        pls14.fscskey                        -- Will be NULL for unmatched rows
-- FROM pls_fy2014_pupld14a pls14
--      FULL OUTER JOIN pls_fy2009_pupld09a pls09
--          ON pls14.fscskey = pls09.fscskey
-- WHERE pls14.fscskey IS NULL                 -- Agencies not found in 2014
-- ORDER BY pls09.fscskey;


-- Combined version: all unmatched agencies from BOTH directions in one query
SELECT
    -- COALESCE returns the first non-NULL value, ensuring we always get an fscskey
    COALESCE(pls14.fscskey, pls09.fscskey) AS fscskey,

    -- Same logic for library name — use whichever side has the record
    COALESCE(pls14.libname, pls09.libname) AS libname,

    -- Label each row to clarify which survey year is missing this agency
    CASE
        WHEN pls09.fscskey IS NULL THEN 'Not in 2009'  -- New agency after 2009
        WHEN pls14.fscskey IS NULL THEN 'Not in 2014'  -- Agency closed/merged by 2014
    END AS status

FROM pls_fy2014_pupld14a pls14
     FULL OUTER JOIN pls_fy2009_pupld09a pls09
         ON pls14.fscskey = pls09.fscskey   -- Match libraries by their unique survey key

-- Keep only rows where at least one side has no match
WHERE pls14.fscskey IS NULL
   OR pls09.fscskey IS NULL

ORDER BY fscskey;   -- Alphabetical order by library key for easy scanning