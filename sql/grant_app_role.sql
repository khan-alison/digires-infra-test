-- Idempotent: safe to run every deploy
-- Uses databricks_auth extension to create an OAuth-authenticated role
-- for a Databricks Service Principal (per official Lakebase docs).
-- NOTE: psql variable substitution (:'var') does NOT work inside DO $$ ... $$
-- blocks, so we use \gset + \if instead of a plpgsql DO block.

CREATE EXTENSION IF NOT EXISTS databricks_auth;

SELECT EXISTS (
  SELECT FROM pg_catalog.pg_roles WHERE rolname = :'app_sp_id'
) AS role_exists \gset

\if :role_exists
  \echo Role already exists, skipping creation
\else
  SELECT databricks_create_role(:'app_sp_id', 'SERVICE_PRINCIPAL');
\endif

GRANT ALL PRIVILEGES ON DATABASE :"db_name" TO :"app_sp_id";
GRANT USAGE ON SCHEMA public TO :"app_sp_id";
GRANT ALL ON ALL TABLES IN SCHEMA public TO :"app_sp_id";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO :"app_sp_id";
