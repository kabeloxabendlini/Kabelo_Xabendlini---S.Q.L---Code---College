-- Question: 1

-- ALTER TABLE meat_poultry_egg_inspect
-- ADD COLUMN meat_processing boolean;

-- ALTER TABLE meat_poultry_egg_inspect
-- ADD COLUMN poultry_processing boolean;

-- Verify the columns were added
-- SELECT meat_processing, poultry_processing
-- FROM meat_poultry_egg_inspect
-- LIMIT 5;

-- Question: 2

-- Set meat_processing = TRUE where activities contains 'Meat Processing'
-- UPDATE meat_poultry_egg_inspect
-- SET meat_processing = TRUE
-- WHERE activities ILIKE '%Meat Processing%';

-- Set poultry_processing = TRUE where activities contains 'Poultry Processing'
-- UPDATE meat_poultry_egg_inspect
-- SET poultry_processing = TRUE
-- WHERE activities ILIKE '%Poultry Processing%';

-- Verify your updates look correct
-- SELECT activities, meat_processing, poultry_processing
-- FROM meat_poultry_egg_inspect
-- WHERE meat_processing = TRUE
--    OR poultry_processing = TRUE
-- LIMIT 10;

-- Question: 3

-- Count plants for each activity
-- SELECT
--     COUNT(*) FILTER (WHERE meat_processing = TRUE) AS meat_processing_count,
--     COUNT(*) FILTER (WHERE poultry_processing = TRUE) AS poultry_processing_count
-- FROM meat_poultry_egg_inspect;

-- Bonus Content:

SELECT COUNT(*) AS both_activities_count
FROM meat_poultry_egg_inspect
WHERE meat_processing = TRUE
AND poultry_processing = TRUE;
