-- ===========================
-- PostgreSQL Initialization
-- ===========================

-- Grant privileges to laravel_user
GRANT ALL PRIVILEGES ON DATABASE laravel_db TO laravel_user;

-- Enable useful extensions
\c laravel_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For full-text search

-- Set timezone (persistent)
ALTER DATABASE laravel_db SET timezone TO 'Asia/Jakarta';
