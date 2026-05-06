-- =============================================================================
-- Practical SQL: Chapter 9 - Inspecting and Modifying Data
-- Try It Yourself - Solutions
-- =============================================================================
-- These exercises use the meat_poultry_egg_inspect table, which contains
-- data from the USDA Food Safety and Inspection Service (FSIS) listing
-- meat, poultry, and egg processing facilities across the United States.
--
-- The goal is to practice:
--   • Adding new columns to an existing table (ALTER TABLE)
--   • Populating those columns conditionally (UPDATE ... WHERE)
--   • Querying and verifying changes using filters and aggregates
-- =============================================================================


-- =============================================================================
-- EXERCISE 1
-- Add Boolean Columns to Flag Processing Activity Types
-- =============================================================================
-- Context:
--   The existing 'activities' column contains free-text descriptions of what
--   each facility does (e.g. "Meat Processing", "Poultry Processing", etc.).
--   Rather than parsing that text every time we query, we add two dedicated
--   boolean columns so activity types can be filtered and counted efficiently.
--
-- Design notes:
--   • Both columns default to NULL (not FALSE) until explicitly set in Ex. 2,
--     which lets us distinguish "not yet evaluated" from a confirmed FALSE
--   • ALTER TABLE ... ADD COLUMN is non-destructive — existing rows and data
--     are untouched; new columns simply appear with NULL in every existing row
-- =============================================================================

-- Add a boolean column to flag facilities that perform meat processing
-- ALTER TABLE meat_poultry_egg_inspect
-- ADD COLUMN meat_processing boolean;

-- Add a boolean column to flag facilities that perform poultry processing
-- ALTER TABLE meat_poultry_egg_inspect
-- ADD COLUMN poultry_processing boolean;

-- Verify both columns now exist and are present (values will be NULL at this stage)
-- SELECT meat_processing, poultry_processing
-- FROM meat_poultry_egg_inspect
-- LIMIT 5;


-- =============================================================================
-- EXERCISE 2
-- Populate the Boolean Columns Based on the 'activities' Text Field
-- =============================================================================
-- Context:
--   Now that the columns exist, we use UPDATE ... WHERE to set them to TRUE
--   for any facility whose 'activities' field mentions the relevant activity.
--
-- Key technique:
--   • ILIKE is used instead of LIKE so the match is case-insensitive —
--     this guards against inconsistent capitalisation in the source data
--     (e.g. "meat processing", "MEAT PROCESSING", "Meat Processing" all match)
--   • The wildcard % on both sides matches the keyword anywhere in the string,
--     since 'activities' may list multiple activities in one field
--   • Rows that do NOT match are left as NULL (not set to FALSE), which
--     preserves the distinction between "confirmed no" and "not evaluated"
-- =============================================================================

-- Set meat_processing = TRUE for any facility listing 'Meat Processing'
-- in its activities field (case-insensitive match)
-- UPDATE meat_poultry_egg_inspect
-- SET meat_processing = TRUE
-- WHERE activities ILIKE '%Meat Processing%';

-- Set poultry_processing = TRUE for any facility listing 'Poultry Processing'
-- UPDATE meat_poultry_egg_inspect
-- SET poultry_processing = TRUE
-- WHERE activities ILIKE '%Poultry Processing%';

-- Verify the updates: show activities alongside both flags for matching rows
-- A correct result will show TRUE in at least one boolean column per row
-- SELECT activities, meat_processing, poultry_processing
-- FROM meat_poultry_egg_inspect
-- WHERE meat_processing = TRUE
--    OR poultry_processing = TRUE
-- LIMIT 10;


-- =============================================================================
-- EXERCISE 3
-- Count Facilities by Processing Activity Type
-- =============================================================================
-- Context:
--   With the boolean columns populated, we can now aggregate efficiently
--   without re-parsing the free-text 'activities' column each time.
--
-- Key technique:
--   • COUNT(*) FILTER (WHERE ...) is a PostgreSQL aggregate filter — it counts
--     only the rows that satisfy the condition, in a single pass over the table
--   • This is cleaner and more efficient than using multiple subqueries or
--     separate SELECT statements for each activity type
--   • NULL values in the boolean columns are automatically excluded by the
--     FILTER, so only TRUE rows are counted (as intended)
-- =============================================================================

-- Count the total number of facilities for each processing type side by side
-- SELECT
--     COUNT(*) FILTER (WHERE meat_processing = TRUE)    AS meat_processing_count,
--     COUNT(*) FILTER (WHERE poultry_processing = TRUE) AS poultry_processing_count
-- FROM meat_poultry_egg_inspect;


-- =============================================================================
-- BONUS
-- Count Facilities That Perform BOTH Meat and Poultry Processing
-- =============================================================================
-- Context:
--   A natural follow-up question after Exercise 3 — how many facilities are
--   dual-purpose, handling both meat and poultry on the same site?
--
-- This uses a simple AND condition rather than FILTER, since we need both
-- flags to be TRUE simultaneously on the same row. The result is a single
-- count showing the overlap between the two activity types.
-- =============================================================================

-- Count facilities where BOTH boolean flags are TRUE simultaneously
SELECT COUNT(*) AS both_activities_count
FROM meat_poultry_egg_inspect
WHERE meat_processing = TRUE
  AND poultry_processing = TRUE;