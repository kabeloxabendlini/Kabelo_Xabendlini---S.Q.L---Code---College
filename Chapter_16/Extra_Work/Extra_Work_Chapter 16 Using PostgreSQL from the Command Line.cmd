-- ============================================
-- STEP 1: Connect to the gis_analysis database
-- -U postgres  = login as the postgres superuser
-- -d gis_analysis = connect to the gis_analysis database
-- -W = prompt for password
-- ============================================
psql -U postgres -d gis_analysis -W


-- ============================================
-- STEP 2: Import Santa Fe linear water shapefile
-- Run this in CMD (not inside psql)
-- -I = create a spatial index after import
-- -s 4269 = set the SRID (coordinate system) to NAD83
-- -W LATIN1 = handle special characters using LATIN1 encoding
-- santafe_linearwater_2016 = name to give the new table in PostgreSQL
-- | psql ... = pipe the output directly into PostgreSQL
-- ============================================
"C:\Program Files\PostgreSQL\18\bin\shp2pgsql" -I -s 4269 -W LATIN1 "C:\S.Q.L\tl_2016_35049_linearwater.shp" santafe_linearwater_2016 | psql -U postgres -d gis_analysis -W


-- ============================================
-- STEP 3: Import Santa Fe roads shapefile
-- Same flags as above but for the roads shapefile
-- santafe_roads_2016 = name to give the new table in PostgreSQL
-- ============================================
"C:\Program Files\PostgreSQL\18\bin\shp2pgsql" -I -s 4269 -W LATIN1 "C:\S.Q.L\tl_2016_35049_roads.shp" santafe_roads_2016 | psql -U postgres -d gis_analysis -W


-- ============================================
-- STEP 4: Switch to gis_analysis database (if not already there)
-- \c = connect/switch to a different database
-- \dt = list all tables in the current database
-- Verify all 4 tables exist:
-- farmers_markets, spatial_ref_sys,
-- santafe_linearwater_2016, santafe_roads_2016, us_counties_2010
-- ============================================
\c gis_analysis
\dt


-- ============================================
-- STEP 5: Check geometry type of the water table
-- ST_GeometryType() returns the type of geometry
-- e.g. MULTILINESTRING, POLYGON, POINT etc.
-- ============================================
SELECT ST_GeometryType(geom)
FROM santafe_linearwater_2016
LIMIT 1;


-- ============================================
-- STEP 6: Check geometry type of the roads table
-- ============================================
SELECT ST_GeometryType(geom)
FROM santafe_roads_2016
LIMIT 1;


-- ============================================
-- STEP 7: Describe the table structure
-- \d = shows all column names and data types
-- Use this to confirm exact column names before querying
-- ============================================
\d santafe_linearwater_2016
\d santafe_roads_2016


-- ============================================
-- STEP 8: Find all roads that cross the Santa Fe River
-- ST_Intersects() = returns true if two geometries share any space
-- water alias = santafe_linearwater_2016
-- roads alias = santafe_roads_2016
-- rttyp = route type code (e.g. M=Municipal, S=State, I=Interstate)
-- Results ordered alphabetically by road name
-- ============================================
SELECT water.fullname AS waterway,
       roads.rttyp,
       roads.fullname AS road
FROM santafe_linearwater_2016 water
JOIN santafe_roads_2016 roads
    ON ST_Intersects(water.geom, roads.geom)
WHERE water.fullname = 'Santa Fe Riv'
ORDER BY roads.fullname;


-- ============================================
-- STEP 9: Find the 5 largest US counties by square miles
-- ST_Area() = calculates the area of a geometry
-- ::geography = cast to geography type for accurate real-world measurements
-- 2589988.110336 = square meters per square mile (conversion factor)
-- ::numeric = cast to numeric for use with round()
-- 2 = round to 2 decimal places
-- Results ordered largest to smallest
-- ============================================
SELECT name10,
       statefp10 AS st,
       round(
         (ST_Area(geom::geography) / 2589988.110336)::numeric,
         2
       ) AS square_miles
FROM us_counties_2010
ORDER BY square_miles DESC
LIMIT 5;


-- ============================================
-- STEP 10: Exit psql and return to CMD prompt
-- ============================================
\q