-- Check if the database is set up correctly
-- Run these commands to debug the issue

-- 1. Check if workout_schedules table exists and has data
SELECT * FROM workout_schedules;

-- 2. Check if the table structure is correct
\d workout_schedules;

-- 3. Check if there are any schedules for your user (replace with your user ID)
-- First get your user ID:
SELECT id, email FROM auth.users LIMIT 1;

-- Then check schedules for that user:
SELECT * FROM workout_schedules WHERE user_id = 'YOUR_USER_ID_HERE';

-- 4. If no data exists, check if the table was modified correctly:
-- Check if workout_id is now TEXT type
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'workout_schedules' AND column_name = 'workout_id';

-- 5. Check if id column has proper default
SELECT column_default FROM information_schema.columns 
WHERE table_name = 'workout_schedules' AND column_name = 'id';
