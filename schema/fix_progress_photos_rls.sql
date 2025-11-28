-- Fix Progress Photos RLS Policy Issue
-- This script fixes the storage policy for progress photos to match the actual folder structure used in the app

-- Drop existing storage policies for progress_photos bucket
DROP POLICY IF EXISTS "Users can upload their own progress photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own progress photos" ON storage.objects;
DROP POLICY IF EXISTS "Public access to progress photos" ON storage.objects;

-- Create corrected storage policies using string functions instead of regex
-- The app uses: userId/filename structure (not progress_photos/userId/filename)

CREATE POLICY "Users can upload their own progress photos" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'progress_photos' AND 
        auth.uid()::text = split_part(name, '/', 1) -- Get first folder (userId) from userId/filename
    );

CREATE POLICY "Users can view their own progress photos" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'progress_photos' AND 
        auth.uid()::text = split_part(name, '/', 1) -- Get first folder (userId) from userId/filename
    );

-- Alternative: Allow authenticated users to upload with additional checks
CREATE POLICY "Authenticated users can upload progress photos" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'progress_photos' AND 
        auth.role() = 'authenticated' AND
        (auth.uid()::text = split_part(name, '/', 1) OR name LIKE auth.uid()::text || '/%')
    );

-- Public read access for progress photos
CREATE POLICY "Public access to progress photos" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'progress_photos'
    );

-- Grant necessary permissions
GRANT ALL ON SCHEMA storage TO authenticated;
GRANT ALL ON SCHEMA storage TO anon;

-- Also fix the progress_photos table RLS policies if needed
-- Drop existing table policies
DROP POLICY IF EXISTS "Users can view their own progress photos" ON progress_photos;
DROP POLICY IF EXISTS "Users can insert their own progress photos" ON progress_photos;
DROP POLICY IF EXISTS "Users can update their own progress photos" ON progress_photos;
DROP POLICY IF EXISTS "Users can delete their own progress photos" ON progress_photos;

-- Recreate table policies with proper checks
CREATE POLICY "Users can view their own progress photos" ON progress_photos
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own progress photos" ON progress_photos
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own progress photos" ON progress_photos
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own progress photos" ON progress_photos
    FOR DELETE USING (auth.uid() = user_id);
