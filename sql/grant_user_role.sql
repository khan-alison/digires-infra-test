-- Idempotent: safe to run multiple times
-- Grants a Databricks human user OAuth-based Postgres access.
-- NOTE: psql variable substitution (:'var') does NOT work inside DO $$ ... $$
-- blocks, so we use \gset + \if instead of a plpgsql DO block.

CREATE EXTENSION IF NOT EXISTS databricks_auth;

SELECT EXISTS (
  SELECT FROM pg_catalog.pg_roles WHERE rolname = :'target_user'
) AS role_exists \gset

\if :role_exists
  \echo Role already exists, skipping creation
\else
  SELECT databricks_create_role(:'target_user', 'USER');
\endif

GRANT CONNECT ON DATABASE :"db_name" TO :"target_user";
GRANT USAGE ON SCHEMA public TO :"target_user";
GRANT CREATE ON SCHEMA public TO :"target_user";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO :"target_user";
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"target_user";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO :"target_user";
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO :"target_user";
