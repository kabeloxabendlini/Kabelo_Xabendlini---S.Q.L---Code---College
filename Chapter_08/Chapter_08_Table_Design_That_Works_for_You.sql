-- SELECT current_database();

-- DROP TABLE IF EXISTS pls_fy2014_pupld14a;

-- CREATE TABLE pls_fy2014_pupld14a (
--     stabr      varchar(100),
--     fscskey    varchar(100)  CONSTRAINT fscskey2014_key PRIMARY KEY,
--     libid      varchar(100)  NOT NULL,
--     libname    varchar(100)  NOT NULL,
--     obereg     varchar(100),
--     rstatus    integer       NOT NULL,
--     statstru   varchar(100),
--     statname   varchar(100),
--     stataddr   varchar(100),
--     longitud   numeric(10,7),
--     latitude   numeric(10,7),
--     fipsst     varchar(100),
--     fipsco     varchar(100),
--     address    varchar(100),
--     city       varchar(100)  NOT NULL,
--     zip        varchar(100),
--     zip4       varchar(100),
--     cnty       varchar(100),
--     phone      varchar(100),
--     c_relatn   varchar(100),
--     c_legbas   varchar(100),
--     c_admin    varchar(100),
--     geocode    varchar(100),
--     lsabound   varchar(100),
--     startdat   varchar(100),
--     enddate    varchar(100),
--     popu_lsa   numeric(12,2),
--     centlib    numeric(12,2),
--     branlib    numeric(12,2),
--     bkmob      numeric(12,2),
--     master     numeric(12,2),
--     libraria   numeric(12,2),
--     totstaff   numeric(12,2),
--     locgvt     numeric(12,2),
--     stgvt      numeric(12,2),
--     fedgvt     numeric(12,2),
--     totincm    numeric(12,2),
--     salaries   numeric(12,2),
--     benefit    numeric(12,2),
--     staffexp   numeric(12,2),
--     prmatexp   numeric(12,2),
--     elmatexp   numeric(12,2),
--     totexpco   numeric(12,2),
--     totopexp   numeric(12,2),
--     lcap_rev   numeric(12,2),
--     scap_rev   numeric(12,2),
--     fcap_rev   numeric(12,2),
--     cap_rev    numeric(12,2),
--     capital    numeric(12,2),
--     bkvol      numeric(12,2),
--     ebook      numeric(12,2),
--     audio_ph   numeric(12,2),
--     audio_dl   numeric(12,2),
--     video_ph   numeric(12,2),
--     video_dl   numeric(12,2),
--     database   numeric(12,2),
--     subscrip   numeric(12,2),
--     hrs_open   numeric(12,2),
--     visits     numeric(12,2) NOT NULL,
--     referenc   numeric(12,2),
--     regbor     numeric(12,2),
--     totcir     numeric(12,2),
--     kidcircl   numeric(12,2),
--     elmatcir   numeric(12,2),
--     loanto     numeric(12,2),
--     loanfm     numeric(12,2),
--     totpro     numeric(12,2),
--     totatten   numeric(12,2),
--     gpterms    numeric(12,2),
--     pitusr     numeric(12,2),
--     wifisess   numeric(12,2) NOT NULL,
--     yr_sub     integer       NOT NULL
-- );

-- CREATE INDEX libname2014_idx ON pls_fy2014_pupld14a (libname);
-- CREATE INDEX stabr2014_idx   ON pls_fy2014_pupld14a (stabr);
-- CREATE INDEX city2014_idx    ON pls_fy2014_pupld14a (city);
-- CREATE INDEX visits2014_idx  ON pls_fy2014_pupld14a (visits);

-- COPY pls_fy2014_pupld14a
-- FROM 'C:\S.Q.L\pls_fy2014_pupld14a.csv'
-- WITH (FORMAT CSV, HEADER);

-- DROP TABLE IF EXISTS pls_fy2009_pupld09a;

-- CREATE TABLE pls_fy2009_pupld09a (
--     stabr      varchar(100),
--     fscskey    varchar(100)  CONSTRAINT fscskey2009_key PRIMARY KEY,
--     libid      varchar(100)  NOT NULL,
--     libname    varchar(100)  NOT NULL,
--     address    varchar(100),
--     city       varchar(100)  NOT NULL,
--     zip        varchar(100),
--     zip4       varchar(100),
--     cnty       varchar(100),
--     phone      varchar(100),
--     c_relatn   varchar(100),
--     c_legbas   varchar(100),
--     c_admin    varchar(100),
--     geocode    varchar(100),
--     lsabound   varchar(100),
--     startdat   varchar(100),
--     enddate    varchar(100),
--     popu_lsa   numeric(12,2),
--     centlib    numeric(12,2),
--     branlib    numeric(12,2),
--     bkmob      numeric(12,2),
--     master     numeric(12,2),
--     libraria   numeric(12,2),
--     totstaff   numeric(12,2),
--     locgvt     numeric(12,2),
--     stgvt      numeric(12,2),
--     fedgvt     numeric(12,2),
--     totincm    numeric(12,2),
--     salaries   numeric(12,2),
--     benefit    numeric(12,2),
--     staffexp   numeric(12,2),
--     prmatexp   numeric(12,2),
--     elmatexp   numeric(12,2),
--     totexpco   numeric(12,2),
--     totopexp   numeric(12,2),
--     lcap_rev   numeric(12,2),
--     scap_rev   numeric(12,2),
--     fcap_rev   numeric(12,2),
--     cap_rev    numeric(12,2),
--     capital    numeric(12,2),
--     bkvol      numeric(12,2),
--     ebook      numeric(12,2),
--     audio      numeric(12,2),
--     video      numeric(12,2),
--     database   numeric(12,2),
--     subscrip   numeric(12,2),
--     hrs_open   numeric(12,2),
--     visits     numeric(12,2) NOT NULL,
--     referenc   numeric(12,2),
--     regbor     numeric(12,2),
--     totcir     numeric(12,2),
--     kidcircl   numeric(12,2),
--     loanto     numeric(12,2),
--     loanfm     numeric(12,2),
--     totpro     numeric(12,2),
--     totatten   numeric(12,2),
--     gpterms    numeric(12,2),
--     pitusr     numeric(12,2),
--     yr_sub     integer       NOT NULL,
--     obereg     varchar(100),
--     rstatus    integer,
--     statstru   varchar(100),
--     statname   varchar(100),
--     stataddr   varchar(100),
--     longitud   numeric(10,7),
--     latitude   numeric(10,7),
--     fipsst     varchar(100),
--     fipsco     varchar(100)
-- );

-- CREATE INDEX libname2009_idx ON pls_fy2009_pupld09a (libname);
-- CREATE INDEX stabr2009_idx   ON pls_fy2009_pupld09a (stabr);
-- CREATE INDEX city2009_idx    ON pls_fy2009_pupld09a (city);
-- CREATE INDEX visits2009_idx  ON pls_fy2009_pupld09a (visits);

-- COPY pls_fy2009_pupld09a
-- FROM 'C:\S.Q.L\pls_fy2009_pupld09a.csv'
-- WITH (FORMAT CSV, HEADER);

-- SELECT count(*)
-- FROM pls_fy2014_pupld14a;

-- SELECT count(*)
-- FROM pls_fy2009_pupld09a;

-- SELECT count(salaries)
-- FROM pls_fy2014_pupld14a;

-- SELECT count(libname)
-- FROM pls_fy2014_pupld14a;

-- SELECT count(DISTINCT libname)
-- FROM pls_fy2014_pupld14a;

-- SELECT max(visits), min(visits)
-- FROM pls_fy2014_pupld14a;

-- SELECT stabr
-- FROM pls_fy2014_pupld14a

-- GROUP BY stabr
-- ORDER BY stabr;

-- SELECT city, stabr
-- FROM pls_fy2014_pupld14a

-- GROUP BY city, stabr
-- ORDER BY city, stabr;

-- SELECT stabr, count(*)
-- FROM pls_fy2014_pupld14a

-- GROUP BY stabr
-- ORDER BY count(*) DESC;

-- SELECT sum(visits) AS visits_2014
-- FROM pls_fy2014_pupld14a
-- WHERE visits >= 0;

-- SELECT sum(visits) AS visits_2009
-- FROM pls_fy2009_pupld09a
-- WHERE visits >= 0;

-- SELECT sum(visits) AS visits_2014
-- FROM pls_fy2014_pupld14a
-- WHERE visits >= 0;

-- SELECT sum(visits) AS visits_2009
-- FROM pls_fy2009_pupld09a
-- WHERE visits >= 0;

-- SELECT sum(pls14.visits) AS visits_2014,
-- sum(pls09.visits) AS visits_2009
-- FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09

-- ON pls14.fscskey = pls09.fscskey
-- WHERE pls14.visits >= 0 AND pls09.visits >= 0;

-- SELECT pls14.stabr,
--  sum(pls14.visits) AS visits_2014,
--  sum(pls09.visits) AS visits_2009,
--  round( (CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits)) /
--  sum(pls09.visits) * 100, 2 ) AS pct_change

-- FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
-- ON pls14.fscskey = pls09.fscskey
-- WHERE pls14.visits >= 0 AND pls09.visits >= 0
-- GROUP BY pls14.stabr
-- ORDER BY pct_change DESC;

SELECT pls14.stabr,
	sum(pls14.visits) AS visits_2014,
	sum(pls09.visits) AS visits_2009,
	round( (CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits)) /
				sum(pls09.visits) * 100, 2 ) AS pct_change
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.visits >= 0 AND pls09.visits >= 0
GROUP BY pls14.stabr
HAVING sum(pls14.visits) > 50000000
ORDER BY pct_change DESC;
