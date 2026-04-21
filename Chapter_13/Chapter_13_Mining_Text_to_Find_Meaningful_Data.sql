-- SELECT char_length(trim(' Pat '));

-- SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '\d{4}');

-- CREATE TABLE crime_reports (
--  crime_id bigserial PRIMARY KEY,
--  date_1 timestamp with time zone,
--  date_2 timestamp with time zone,
--  street varchar(250),
--  city varchar(100),
--  crime_type varchar(100),
--  description text,
--  case_number varchar(50),
--  original_text text NOT NULL
-- );

-- COPY crime_reports (original_text)
-- FROM 'C:\S.Q.L\crime_reports.csv'
-- WITH (FORMAT CSV, HEADER OFF, QUOTE '"');

-- SELECT crime_id,
--  regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}')
-- FROM crime_reports;

-- SELECT crime_id,
--  regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}', 'g')
-- FROM crime_reports;

-- SELECT crime_id,
--  regexp_match(original_text, '-\d{1,2}\/\d{1,2}\/\d{2}')
-- FROM crime_reports;

-- SELECT crime_id,
--  regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})')
-- FROM crime_reports;

-- SELECT
--  regexp_match(original_text, '(?:C0|SO)[0-9]+') AS case_number,
--  regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}') AS date_1,
--  regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.*):') AS crime_type,
--  regexp_match(original_text, '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n')
--  AS city
-- FROM crime_reports;

-- SELECT
--     crime_id,
--     (regexp_match(original_text, '(?:C0|SO)[0-9]+'))[1]
--     AS case_number
-- FROM crime_reports;

-- UPDATE crime_reports
-- SET date_1 = to_timestamp(
--     (regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1]
--     || ' ' ||
--     (regexp_match(original_text, '\/\d{2}\n(\d{4})'))[1],
--     'MM/DD/YY HH24MI'        -- tells PostgreSQL exactly how to read the string
-- )
-- AT TIME ZONE 'US/Eastern';

-- SELECT crime_id,
--        date_1,
--        original_text
-- FROM crime_reports;

-- UPDATE crime_reports
-- SET date_1 = to_timestamp(
--         (regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1]
--         || ' ' ||
--         (regexp_match(original_text, '\/\d{2}\n(\d{4})'))[1],
--         'MM/DD/YY HH24MI'
--     ) AT TIME ZONE 'US/Eastern',

--     date_2 = CASE
--         -- No second date, but has end time (e.g. 2100-0900)
--         WHEN regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})') IS NULL
--         AND  regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})') IS NOT NULL
--         THEN to_timestamp(
--                 (regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1]
--                 || ' ' ||
--                 (regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})'))[1],
--                 'MM/DD/YY HH24MI'
--              ) AT TIME ZONE 'US/Eastern'

--         -- Has both a second date and an end time
--         WHEN regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})') IS NOT NULL
--         AND  regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})') IS NOT NULL
--         THEN to_timestamp(
--                 (regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})'))[1]
--                 || ' ' ||
--                 (regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})'))[1],
--                 'MM/DD/YY HH24MI'
--              ) AT TIME ZONE 'US/Eastern'

--         ELSE NULL
--     END,
--     street      = (regexp_match(original_text,
--                     'hrs.\n(\d+ .+(?:Sq.|Plz.|Dr.|Ter.|Rd.))'))[1],
--     city        = (regexp_match(original_text,
--                     '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n'))[1],
--     crime_type  = (regexp_match(original_text,
--                     '\n(?:\w+ \w+|\w+)\n(.*):'))[1],
--     description = (regexp_match(original_text,
--                     ':\s(.+)(?:C0|SO)'))[1],
--     case_number = (regexp_match(original_text,
--                     '(?:C0|SO)[0-9]+'))[1];

-- SELECT crime_id,
--        date_1,
--        date_2,
--        street,
--        city,
--        crime_type,
--        description,
--        case_number
-- FROM crime_reports;

-- SELECT date_1,
--  street,
--  city,
--  crime_type
-- FROM crime_reports;

-- SELECT geo_name
-- FROM us_counties_2010
-- WHERE geo_name ~* '(.+lade.+|.+lare.+)'
-- ORDER BY geo_name;
-- SELECT geo_name
-- FROM us_counties_2010
-- WHERE geo_name ~* '.+ash.+' AND geo_name !~ 'Wash.+'
-- ORDER BY geo_name;

-- SELECT regexp_replace('05/12/2018', '\d{4}', '2017');
-- SELECT regexp_split_to_table('Four,score,and,seven,years,ago', ',');

-- SELECT regexp_split_to_array('Phil Mike Tony Steve', ',');

-- SELECT array_length(regexp_split_to_array('Phil Mike Tony Steve', ' '), 1);

-- SELECT to_tsvector('I am walking across the sitting room to sit with you.');

-- SELECT to_tsquery('walking & sitting');

-- SELECT to_tsvector('I am walking across the sitting room') @@ to_tsquery('walking & sitting');
-- SELECT to_tsvector('I am walking across the sitting room') @@ to_tsquery('walking & running');

-- CREATE TABLE president_speeches (
--  sotu_id serial PRIMARY KEY,
--  president varchar(100) NOT NULL,
--  title varchar(250) NOT NULL,
--  speech_date date NOT NULL,
--  speech_text text NOT NULL,
--  search_speech_text tsvector
-- );

-- COPY president_speeches (president, title, speech_date, speech_text)
-- FROM 'C:\S.Q.L\sotu-1946-1977.csv'
-- WITH (FORMAT CSV, DELIMITER '|', HEADER OFF, QUOTE '@')

-- UPDATE president_speeches
-- SET search_speech_text = to_tsvector('english', speech_text)

-- CREATE INDEX search_idx ON president_speeches USING gin(search_speech_text);

-- SELECT president, speech_date
-- FROM president_speeches
-- WHERE search_speech_text @@ to_tsquery('Vietnam')
-- ORDER BY speech_date; 

-- SELECT president,
--  speech_date,
--  ts_headline(speech_text, to_tsquery('Vietnam'),
--  'StartSel = <,
--  StopSel = >,
--  MinWords=5,
--  MaxWords=7,
--  MaxFragments=1')
-- FROM president_speeches
-- WHERE search_speech_text @@ to_tsquery('Vietnam');

-- SELECT president,
--  speech_date,
--  ts_headline(speech_text, to_tsquery('transportation & !roads'),
--  'StartSel = <,
--  StopSel = >,
--  MinWords=5,
--  MaxWords=7,
--  MaxFragments=1')
-- FROM president_speeches
-- WHERE search_speech_text @@ to_tsquery('transportation & !roads');

-- SELECT president,
--  speech_date,

--  ts_headline(speech_text, to_tsquery('military <-> defense'),
--  'StartSel = <,
--  StopSel = >,
--  MinWords=5,
--  MaxWords=7,
--  MaxFragments=1')
-- FROM president_speeches
-- WHERE search_speech_text @@ to_tsquery('military <-> defense');

-- SELECT president,
--  speech_date,
--  ts_rank(search_speech_text,
--  to_tsquery('war & security & threat & enemy')) AS score

-- FROM president_speeches
-- WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
-- ORDER BY score DESC
-- LIMIT 5

SELECT president,
 speech_date,
 ts_rank(search_speech_text,
 to_tsquery('war & security & threat & enemy'), 2)::numeric
 AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY score DESC
LIMIT 5;