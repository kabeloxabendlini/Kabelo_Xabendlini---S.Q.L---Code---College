-- ============================================================
-- Task 1 — Remove commas before suffixes & split into columns
-- ============================================================

-- Create a sample table to store names with suffixes
-- CREATE TABLE names (
--     id      serial PRIMARY KEY,   -- auto-incrementing ID (PostgreSQL)
--     name    varchar(100)          -- full name including suffix
-- );

-- Insert sample data with comma-separated suffixes
-- INSERT INTO names (name) VALUES
--     ('Alvarez, Jr.'),
--     ('Williams, Sr.'),
--     ('Johnson, III'),
--     ('Smith, Ph.D.'),
--     ('Davis, Jr.');

-- ------------------------------------------------------------
-- Option A: Remove comma using REPLACE()
-- Simple string replacement (less flexible but fast)
-- ------------------------------------------------------------
-- SELECT 
--     name,
--     REPLACE(name, ', ', ' ') AS name_no_comma  -- replaces ", " with space
-- FROM names;

-- ------------------------------------------------------------
-- Option B: Remove comma using regexp_replace()
-- More flexible (can handle patterns if needed)
-- ------------------------------------------------------------
-- SELECT 
--     name,
--     regexp_replace(name, ', ', ' ') AS name_no_comma
-- FROM names;

-- ------------------------------------------------------------
-- Option C: Split into separate columns (best structured solution)
-- ------------------------------------------------------------
-- SELECT 
--     name,

--     -- Extract everything BEFORE the comma (base name)
--     (regexp_match(name, '^(.+),'))[1] AS last_name,

--     -- Extract everything AFTER the comma + space (suffix)
--     (regexp_match(name, ',\s(.+)$'))[1] AS suffix

-- FROM names;



-- ============================================================
-- Task 2 — Count unique words (5+ characters) in a speech
-- ============================================================

-- ------------------------------------------------------------
-- Basic approach: split text into words and count distinct ones
-- ------------------------------------------------------------
-- SELECT 
--     COUNT(DISTINCT word) AS unique_words_5_plus
-- FROM (
--     SELECT 
--         regexp_split_to_table(speech_text, '\s+') AS word  -- split text into words
--     FROM president_speeches
--     WHERE speech_date = '1970-01-01'  -- target specific speech
-- ) AS words
-- WHERE length(word) >= 5;  -- only words with 5+ characters


-- ------------------------------------------------------------
-- BONUS: Clean punctuation before counting
-- Removes trailing commas and periods
-- ------------------------------------------------------------
-- SELECT 
--     COUNT(DISTINCT word) AS unique_words_5_plus_cleaned
-- FROM (
--     SELECT 
--         regexp_replace(
--             regexp_split_to_table(speech_text, '\s+'), -- split into words
--             '[,.]$',   -- regex: match comma or period at END of word
--             ''         -- replace with nothing
--         ) AS word
--     FROM president_speeches
--     WHERE speech_date = '1970-01-01'
-- ) AS words
-- WHERE length(word) >= 5;


-- ------------------------------------------------------------
-- Helper query: see available speeches and dates
-- ------------------------------------------------------------
-- SELECT 
--     president,
--     speech_date
-- FROM president_speeches
-- ORDER BY speech_date;



-- ============================================================
-- Task 3 — Compare ts_rank() vs ts_rank_cd()
-- ============================================================

-- ------------------------------------------------------------
-- Query 1: Use ts_rank_cd() (cover density ranking)
-- Gives higher scores when search terms appear close together
-- ------------------------------------------------------------
SELECT 
    president,
    speech_date,

    -- Cover density ranking (considers proximity of terms)
    ts_rank_cd(
        search_speech_text,
        to_tsquery('english', 'war & security & threat & enemy')
    ) AS rank_cd

FROM president_speeches

-- Filter rows that match the full-text search query
WHERE search_speech_text @@ 
      to_tsquery('english', 'war & security & threat & enemy')

-- Order by highest relevance score first
ORDER BY rank_cd DESC

-- Return top 5 most relevant speeches
LIMIT 5;



-- ------------------------------------------------------------
-- Query 2: Compare standard ranking vs cover density ranking
-- ------------------------------------------------------------
SELECT 
    president,
    speech_date,

    -- Standard ranking (term frequency-based)
    ts_rank(
        search_speech_text,
        to_tsquery('english', 'war & security & threat & enemy')
    ) AS rank_standard,

    -- Cover density ranking (term proximity-based)
    ts_rank_cd(
        search_speech_text,
        to_tsquery('english', 'war & security & threat & enemy')
    ) AS rank_cover_density

FROM president_speeches

-- Only include speeches matching the search query
WHERE search_speech_text @@ 
      to_tsquery('english', 'war & security & threat & enemy')

-- Sort by cover density score (more meaningful for phrase relevance)
ORDER BY rank_cover_density DESC

-- Limit results for easy comparison
LIMIT 5;