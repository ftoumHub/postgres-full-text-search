ALTER SYSTEM SET max_connections = 1000;
ALTER SYSTEM RESET shared_buffers;
CREATE DATABASE pg_fts;
CREATE USER ggn WITH PASSWORD 'ggn';
GRANT ALL PRIVILEGES ON DATABASE "pg_fts" to ggn;