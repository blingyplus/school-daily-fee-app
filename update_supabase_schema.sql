-- Drop and recreate Supabase schema for school management system
-- This script will completely reset the database schema

-- Drop all tables in reverse dependency order
DROP TABLE IF EXISTS public.audit_log CASCADE;
DROP TABLE IF EXISTS public.sync_log CASCADE;
DROP TABLE IF EXISTS public.school_config CASCADE;
DROP TABLE IF EXISTS public.holidays CASCADE;
DROP TABLE IF EXISTS public.fee_collections CASCADE;
DROP TABLE IF EXISTS public.attendance_records CASCADE;
DROP TABLE IF EXISTS public.scholarships CASCADE;
DROP TABLE IF EXISTS public.student_fee_config CASCADE;
DROP TABLE IF EXISTS public.students CASCADE;
DROP TABLE IF EXISTS public.classes CASCADE;
DROP TABLE IF EXISTS public.admins CASCADE;
DROP TABLE IF EXISTS public.school_teachers CASCADE;
DROP TABLE IF EXISTS public.teachers CASCADE;
DROP TABLE IF EXISTS public.schools CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- Drop functions
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- Now run the complete schema from supabase_schema.sql
-- (The rest of the schema will be applied from the main file)
