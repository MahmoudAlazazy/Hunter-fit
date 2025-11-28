-- Fix the ID issue: Make sure workout_schedules table has proper UUID default
-- Run this in your Supabase SQL editor

-- Check if the table has the correct default value for id
-- If not, update it:

ALTER TABLE workout_schedules 
ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- Also make sure the column can accept NULL during insertion but will use default
ALTER TABLE workout_schedules 
ALTER COLUMN id DROP NOT NULL;

-- Then set it back to NOT NULL with default
ALTER TABLE workout_schedules 
ALTER COLUMN id SET NOT NULL;

-- This should allow the database to generate UUID automatically
