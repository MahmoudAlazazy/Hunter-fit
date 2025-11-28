-- Fix RLS policy for profiles table to allow profile creation
-- This fixes the error: new row violates row-level security policy for table "profiles"

-- Add INSERT policy for profiles table
-- Allow users to create their own profile (where id matches their auth.uid)
CREATE POLICY "Users can create own profile" ON profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Also add DELETE policy for completeness (users can delete their own profile)
CREATE POLICY "Users can delete own profile" ON profiles FOR DELETE 
USING (auth.uid() = id);

-- Add comments for documentation
COMMENT ON POLICY "Users can create own profile" ON profiles IS 'Allow authenticated users to create their own profile';
COMMENT ON POLICY "Users can delete own profile" ON profiles IS 'Allow users to delete their own profile';