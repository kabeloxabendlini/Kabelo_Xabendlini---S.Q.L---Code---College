-- -- Task 1 — Remove Commas Before Suffixes & Split into Separate Column
-- -- First, create a sample table to work with
-- CREATE TABLE names (
--     id      serial PRIMARY KEY,
--     name    varchar(100)
-- );

-- INSERT INTO names (name) VALUES
--     ('Alvarez, Jr.'),
--     ('Williams, Sr.'),
--     ('Johnson, III'),
--     ('Smith, Ph.D.'),
--     ('Davis, Jr.');

-- -- Option A: Using REPLACE() to remove the comma
-- SELECT name,
--        REPLACE(name, ', ', ' ') AS name_no_comma
-- FROM names;

-- -- Option B: Using regexp_replace() for more control
-- SELECT name,
--        regexp_replace(name, ', ', ' ') AS name_no_comma
-- FROM names;

-- -- Option C: Split name and suffix into SEPARATE columns
-- SELECT name,
--        -- Everything before the comma = the base name
--        (regexp_match(name, '^(.+),'))[1]         AS last_name,
--        -- Everything after the comma and space = the suffix
--        (regexp_match(name, ',\s(.+)$'))[1]        AS suffix
-- FROM names;

-- -- Task 2 — Count Unique Words of 5+ Characters in a State of the Union Address
-- -- Basic count of unique words with 5 or more characters
-- SELECT count(DISTINCT word) AS unique_words_5_plus
-- FROM (
--     SELECT regexp_split_to_table(speech_text, '\s+') AS word
--     FROM president_speeches
--     WHERE speech_date = '1970-01-01'   -- replace with your target speech date
-- ) AS words
-- WHERE length(word) >= 5;

-- -- BONUS: Strip trailing commas and periods before counting
-- SELECT count(DISTINCT word) AS unique_words_5_plus_cleaned
-- FROM (
--     SELECT regexp_replace(
--                regexp_split_to_table(speech_text, '\s+'),
--                '[,.]$',   -- removes comma or period at end of word
--                ''
--            ) AS word
--     FROM president_speeches
--     WHERE speech_date = '1970-01-01'   -- replace with your target speech date
-- ) AS words
-- WHERE length(word) >= 5;

-- -- To see which speech dates are available, run this first:
-- SELECT president, speech_date
-- FROM president_speeches
-- ORDER BY speech_date;

-- Task 3 — Rewrite Listing 13-25 Using ts_rank_cd() Instead of ts_rank()
-- Original Listing 13-25 used ts_rank() -- this uses ts_rank_cd() instead
SELECT president,
       speech_date,
       ts_rank_cd(search_speech_text,        -- changed from ts_rank to ts_rank_cd
                  to_tsquery('english', 'war & security & threat & enemy'))
                  AS rank_cd                 -- renamed alias for clarity
FROM president_speeches
WHERE search_speech_text @@
      to_tsquery('english', 'war & security & threat & enemy')
ORDER BY rank_cd DESC
LIMIT 5;

Run BOTH side by side to compare results:
SELECT president,
       speech_date,
       ts_rank(search_speech_text,
               to_tsquery('english', 'war & security & threat & enemy'))
               AS rank_standard,
       ts_rank_cd(search_speech_text,
                  to_tsquery('english', 'war & security & threat & enemy'))
                  AS rank_cover_density
FROM president_speeches
WHERE search_speech_text @@
      to_tsquery('english', 'war & security & threat & enemy')
ORDER BY rank_cover_density DESC
LIMIT 5;