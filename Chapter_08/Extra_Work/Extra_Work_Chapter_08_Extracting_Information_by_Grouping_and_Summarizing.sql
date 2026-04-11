-- SELECT
--     pls14.stabr,
--     sum(pls14.gpterms)                                            
-- 	AS gpterms_2014,
--     sum(pls09.gpterms)                                            
-- 	AS gpterms_2009,
--     round( (CAST(sum(pls14.gpterms) AS numeric(12,2)) - 
-- 	sum(pls09.gpterms)) /
--             NULLIF(sum(pls09.gpterms), 0) * 100, 2 )             
-- 			AS gpterms_pct_chg,
--     sum(pls14.pitusr)                                             
-- 	AS pitusr_2014,
--     sum(pls09.pitusr)                                             
-- 	AS pitusr_2009,
--     round( (CAST(sum(pls14.pitusr) 
-- 	AS numeric(12,2)) - sum(pls09.pitusr)) /
--             NULLIF(sum(pls09.pitusr), 0) * 100, 2 )              
-- 			AS pitusr_pct_chg
-- FROM pls_fy2014_pupld14a pls14
--      JOIN pls_fy2009_pupld09a pls09
--      ON pls14.fscskey = pls09.fscskey
-- WHERE pls14.gpterms >= 0
--   AND pls09.gpterms >= 0
--   AND pls14.pitusr >= 0
--   AND pls09.pitusr >= 0
-- GROUP BY pls14.stabr
-- ORDER BY gpterms_pct_chg DESC;

-- CREATE TABLE obereg_codes (
--     obereg     varchar(2) CONSTRAINT obereg_key PRIMARY KEY,
--     region     text NOT NULL
-- );

-- INSERT INTO obereg_codes (obereg, region)
-- VALUES
--     ('01', 'New England'),
--     ('02', 'Mideast'),
--     ('03', 'Great Lakes'),
--     ('04', 'Plains'),
--     ('05', 'Southeast'),
--     ('06', 'Southwest'),
--     ('07', 'Rocky Mountains'),
--     ('08', 'Far West'),
--     ('09', 'Outlying Areas');

-- SELECT
--     ob.region,
--     sum(pls14.visits)                                              
-- 	AS visits_2014,
--     sum(pls09.visits)                                              
-- 	AS visits_2009,
--     round( (CAST(sum(pls14.visits) AS numeric(12,2)) - sum(pls09.visits)) /
--             NULLIF(sum(pls09.visits), 0) * 100, 2 )               
-- 			AS visits_pct_chg
-- FROM pls_fy2014_pupld14a pls14
--      JOIN pls_fy2009_pupld09a pls09
--      ON pls14.fscskey = pls09.fscskey
--      JOIN obereg_codes ob
--      ON pls14.obereg = ob.obereg
-- WHERE pls14.visits >= 0
--   AND pls09.visits >= 0
-- GROUP BY ob.region
-- ORDER BY visits_pct_chg DESC;

-- SELECT pls14.fscskey,
--        pls14.libname,
--        pls09.fscskey
-- FROM pls_fy2014_pupld14a pls14
--      FULL OUTER JOIN pls_fy2009_pupld09a pls09
--      ON pls14.fscskey = pls09.fscskey
-- WHERE pls09.fscskey IS NULL
-- ORDER BY pls14.fscskey;

-- SELECT pls09.fscskey,
--        pls09.libname,
--        pls14.fscskey
-- FROM pls_fy2014_pupld14a pls14
--      FULL OUTER JOIN pls_fy2009_pupld09a pls09
--      ON pls14.fscskey = pls09.fscskey
-- WHERE pls14.fscskey IS NULL
-- ORDER BY pls09.fscskey;

SELECT COALESCE(pls14.fscskey, pls09.fscskey)  AS fscskey,
       COALESCE(pls14.libname, pls09.libname)  AS libname,
       CASE WHEN pls09.fscskey IS NULL THEN 'Not in 2009'
       WHEN pls14.fscskey IS NULL THEN 'Not in 2014'
       END AS status
FROM pls_fy2014_pupld14a pls14
     FULL OUTER JOIN pls_fy2009_pupld09a pls09
     ON pls14.fscskey = pls09.fscskey
WHERE pls14.fscskey IS NULL
   OR pls09.fscskey IS NULL
ORDER BY fscskey;