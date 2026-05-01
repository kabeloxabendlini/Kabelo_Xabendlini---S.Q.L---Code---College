-- CREATE TABLE vacuum_test (
--  integer_column integer
-- );

-- SELECT pg_size_pretty(
--     pg_total_relation_size('vacuum_test')
-- );

-- INSERT INTO vacuum_test

-- SELECT * FROM generate_series(1,500000);

-- UPDATE vacuum_test
-- SET integer_column = integer_column + 1;

-- SELECT relname,
--  last_vacuum,
--  last_autovacuum,
--  vacuum_count,
--  autovacuum_count
-- FROM pg_stat_all_tables
-- WHERE relname = 'vacuum_test';

-- VACUUM vacuum_test;

-- VACUUM FULL vacuum_test;

-- SHOW config_file;

-- SET datestyle = 'iso, mdy';

-- SET timezone = 'US/Eastern';

-- SET default_text_search_config = 'pg_catalog.english';

-- SELECT pg_reload_conf();

SHOW data_directory;
