-- CREATE EXTENSION postgis;

-- SELECT srtext
-- FROM spatial_ref_sys
-- WHERE srid = 4326;

-- SELECT ST_GeomFromText('POINT(-74.9233606 42.699992)', 4326);
-- SELECT ST_GeomFromText('LINESTRING(-74.9 42.7, -75.1 42.7)', 4326);
-- SELECT ST_GeomFromText('POLYGON((-74.9 42.7, -75.1 42.7,
--  -75.1 42.6, -74.9 42.7))', 4326);
-- SELECT ST_GeomFromText('MULTIPOINT (-74.9 42.7, -75.1 42.7)', 4326);
-- SELECT ST_GeomFromText('MULTILINESTRING((-76.27 43.1, -76.06 43.08),
--  (-76.2 43.3, -76.2 43.4,
--  -76.4 43.1))', 4326);
-- SELECT ST_GeomFromText('MULTIPOLYGON((
--  (-74.92 42.7, -75.06 42.71,
--  -75.07 42.64, -74.92 42.7),
--  (-75.0 42.66, -75.0 42.64,
--  -74.98 42.64, -74.98 42.66,
--  -75.0 42.66)))',	4326);

-- SELECT
-- ST_GeogFromText('SRID=4326;MULTIPOINT(-74.9 42.7, -75.1 42.7, -74.924 42.6)')

-- SELECT ST_PointFromText('POINT(-74.9233606 42.699992)', 4326);
-- SELECT ST_MakePoint(-74.9233606, 42.699992);
-- SELECT ST_SetSRID(ST_MakePoint(-74.9233606, 42.699992), 4326);

-- SELECT ST_LineFromText('LINESTRING(-105.90 35.67,-105.91 35.67)', 4326);
-- SELECT ST_MakeLine(ST_MakePoint(-74.9, 42.7), ST_MakePoint(-74.1, 42.4));

-- SELECT ST_PolygonFromText('POLYGON((-74.9 42.7, -75.1 42.7,
--  -75.1 42.6, -74.9 42.7))', 4326);
 
-- SELECT ST_MakePolygon(
--  ST_GeomFromText('LINESTRING(-74.92 42.7, -75.06 42.71,
--  -75.07 42.64, -74.92 42.7)', 4326));
 
-- SELECT ST_MPolyFromText('MULTIPOLYGON((
--  (-74.92 42.7, -75.06 42.71,
--  -75.07 42.64, -74.92 42.7),
--  (-75.0 42.66, -75.0 42.64,
--  -74.98 42.64, -74.98 42.66,
--  -75.0 42.66)
--  ))', 4326)

-- CREATE TABLE farmers_markets (
--  fmid bigint PRIMARY KEY,
--  market_name varchar(100) NOT NULL,
--  street varchar(180),
--  city varchar(60),
--  county varchar(25),
--  st varchar(20) NOT NULL,
--  zip varchar(10),
--  longitude numeric(10,7),
--  latitude numeric(10,7),
--  organic varchar(1) NOT NULL
-- );

-- COPY farmers_markets
-- FROM 'C:\S.Q.L\farmers_markets.csv'
-- WITH (FORMAT CSV, HEADER);

-- ALTER TABLE farmers_markets ADD COLUMN IF NOT EXISTS geog_point geography(POINT, 4326);

-- UPDATE farmers_markets
-- SET geog_point = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography;

-- CREATE INDEX market_pts_idx ON farmers_markets USING GIST (geog_point);
-- SELECT longitude,
--  latitude,
--  geog_point,
--  ST_AsText(geog_point)
-- FROM farmers_markets
-- WHERE longitude IS NOT NULL
-- LIMIT 5;

-- SELECT ST_Distance(
--  ST_GeogFromText('POINT(-73.9283685 40.8296466)'),
--  ST_GeogFromText('POINT(-73.8480153 40.7570917)')
--  ) / 1609.344 AS mets_to_yanks;

SELECT market_name,
 city,
 round(
 (ST_Distance(geog_point,
 ST_GeogFromText('POINT(-93.6204386 41.5853202)')
 ) / 1609.344)::numeric(8,5), 2
 ) AS miles_from_dt
FROM farmers_markets
WHERE ST_DWithin(geog_point,
 ST_GeogFromText('POINT(-93.6204386 41.5853202)'),
 10000)
ORDER BY miles_from_dt ASC;

