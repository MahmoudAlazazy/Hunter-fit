-- Fix Image Access Issue
-- This script fixes the storage policies to allow public access to progress photos

-- Drop existing storage policies for progress_photos bucket
DROP POLICY IF EXISTS "Users can upload their own progress photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own progress photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload progress photos" ON storage.objects;
DROP POLICY IF EXISTS "Public access to progress photos" ON storage.objects;

-- Create simple public access policy for viewing
CREATE POLICY "Public access to progress photos" ON storage.objects
    FOR SELECT USING (bucket_id = 'progress_photos');

-- Create policy for authenticated users to upload
CREATE POLICY "Authenticated users can upload progress photos" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'progress_photos' AND 
        auth.role() = 'authenticated'
    );

-- Grant necessary permissions
GRANT SELECT ON storage.objects TO anon;
GRANT ALL ON storage.objects TO authenticated;
