# ============================================================
# Step 1 — Create a FULL database backup (custom format)
# ============================================================

# -d gis_analysis → database to back up
# -U postgres     → username
# -Fc             → custom compressed format (best for pg_restore)
# -f              → output file path

pg_dump -d gis_analysis -U postgres -Fc -f "C:\Users\Admin\gis_analysis_backup.dump"


# ============================================================
# Step 2 — Verify the backup file exists and check its size
# ============================================================

# Get file path and size (useful to confirm backup worked)
Get-Item "C:\Users\Admin\gis_analysis_backup.dump" | Select-Object FullName, Length

# ================================================================
# Step 3 — Check the size of the database before and after backup
# ================================================================

SELECT pg_size_pretty(pg_total_relation_size('vacuum_test'));
SELECT pg_size_pretty(
 pg_total_relation_size('vacuum_test')
 );

# ============================================================
# Step 4 — Backup ONLY a specific table
# ============================================================

# -t farmers_markets → only dump this table
pg_dump -t farmers_markets -d gis_analysis -U postgres -Fc -f "C:\Users\Admin\farmers_markets_backup.dump"


# ============================================================
# Step 5 — Drop the database (⚠️ destructive operation)
# ============================================================

# Deletes the entire database (make sure you have a backup!)
DROP DATABASE gis_analysis;


# ============================================================
# Step 6 — Restore FULL database from backup
# ============================================================

# -C        → recreate the database automatically
# -d postgres → connect to default db to run restore
pg_restore -C -d postgres -U postgres "C:\Users\Admin\gis_analysis_backup.dump"


# ============================================================
# Step 7 — Restore ONLY a specific table
# ============================================================

# Restores farmers_markets table into existing database
pg_restore -t farmers_markets -d gis_analysis -U postgres "C:\Users\Admin\farmers_markets_backup.dump"


# ============================================================
# Step 8 — Create a human-readable SQL backup
# ============================================================

# This creates a plain-text .sql file (not compressed)
# Useful for reviewing or version control

pg_dump -d gis_analysis -U postgres -f "C:\Users\Admin\gis_analysis_readable.sql"

-- ============================================================
-- 1. Header metadata
-- ============================================================
-- Contains information about PostgreSQL version, dump time, etc.
-- Helps ensure compatibility when restoring

-- ============================================================
-- 2. Extensions
-- ============================================================
CREATE EXTENSION IF NOT EXISTS postgis;
-- Ensures required extensions (like PostGIS for GIS data) exist


-- ============================================================
-- 3. Table definitions (schema only)
-- ============================================================
CREATE TABLE public.farmers_markets (
    fmid bigint NOT NULL,
    market_name character varying(100) NOT NULL,
    ...
    geog_point geography(Point,4326)  -- spatial column
);
-- Structure is created BEFORE inserting data


-- ============================================================
-- 4. Data loading (bulk insert using COPY)
-- ============================================================
COPY public.farmers_markets (fmid, market_name, ...) FROM stdin;
2000002    Silverdale Farmers Market    ...
\.
-- COPY is much faster than INSERT for large datasets


-- ============================================================
-- 5. Constraints and indexes (added AFTER data load)
-- ============================================================
ALTER TABLE ONLY public.farmers_markets
    ADD CONSTRAINT farmers_markets_pkey PRIMARY KEY (fmid);

CREATE INDEX market_pts_idx 
ON public.farmers_markets 
USING gist (geog_point);
-- Index created after data load = better performance


-- ============================================================
-- 6. Triggers and foreign keys (applied last)
-- ============================================================
-- Ensures referential integrity AFTER data is loaded

Use --clean with pg_dump if you want automatic drops before restore:
pg_dump -d gis_analysis -U postgres -Fc --clean -f backup.dump

Restore with verbose output:
pg_restore -v -d gis_analysis backup.dump

Avoid password prompts:
set PGPASSWORD=yourpassword