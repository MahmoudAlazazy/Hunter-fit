-- Simple fix: Modify workout_schedules table to accept workout names
-- Run this in your Supabase SQL editor

-- Step 1: Drop the foreign key constraint first
ALTER TABLE workout_schedules DROP CONSTRAINT IF EXISTS workout_schedules_workout_id_fkey;

-- Step 2: Change workout_id to text
ALTER TABLE workout_schedules 
ALTER COLUMN workout_id TYPE TEXT USING workout_id::TEXT;

-- That's it! Now you can save workout names directly
