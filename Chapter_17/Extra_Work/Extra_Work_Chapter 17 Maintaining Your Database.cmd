
pg_dump -d gis_analysis -U postgres -Fc -f "C:\Users\Admin\gis_analysis_backup.dump"

Get-Item "C:\Users\Admin\gis_analysis_backup.dump" | Select-Object FullName, Length

pg_dump -t farmers_markets -d gis_analysis -U postgres -Fc -f "C:\Users\Admin\farmers_markets_backup.dump"

DROP DATABASE gis_analysis;

pg_restore -C -d postgres -U postgres "C:\Users\Admin\gis_analysis_backup.dump"

pg_restore -t farmers_markets -d gis_analysis -U postgres "C:\Users\Admin\farmers_markets_backup.dump"

pg_dump -d gis_analysis -U postgres -f "C:\Users\Admin\gis_analysis_readable.sql"

-- 1. Header metadata
-- PostgreSQL database dump
-- Dumped from database version 18...

-- 2. Extensions
CREATE EXTENSION IF NOT EXISTS postgis;

-- 3. Table definitions (structure first, no data yet)
CREATE TABLE public.farmers_markets (
    fmid bigint NOT NULL,
    market_name character varying(100) NOT NULL,
    ...
    geog_point geography(Point,4326)
);

-- 4. Data insertion via COPY commands (fast bulk load)
COPY public.farmers_markets (fmid, market_name, ...) FROM stdin;
2000002    Silverdale Farmers Market    ...
\.

-- 5. Constraints and indexes added AFTER data (faster this way)
ALTER TABLE ONLY public.farmers_markets
    ADD CONSTRAINT farmers_markets_pkey PRIMARY KEY (fmid);

CREATE INDEX market_pts_idx ON public.farmers_markets 
    USING gist (geog_point);

-- 6. Triggers and foreign keys last