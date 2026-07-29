-- Idempotent: safe to run multiple times
-- Grants a Databricks human user OAuth-based Postgres access.

CREATE EXTENSION IF NOT EXISTS databricks_auth;

DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = :'target_user') THEN
      PERFORM databricks_create_role(:'target_user', 'USER');
   END IF;
END
$$;

GRANT CONNECT ON DATABASE :"db_name" TO :"target_user";
GRANT USAGE ON SCHEMA public TO :"target_user";
GRANT CREATE ON SCHEMA public TO :"target_user";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO :"target_user";
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"target_user";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO :"target_user";
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO :"target_user";
