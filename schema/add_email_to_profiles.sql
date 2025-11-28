-- Migration to add email column to profiles table
-- This fixes the PostgrestException: Could not find the 'email' column of 'profiles'

-- Add email column to profiles table
ALTER TABLE profiles ADD COLUMN email text;

-- Create index for email (optional, for performance if you query by email)
CREATE INDEX profiles_email_idx ON profiles (email);

-- Update existing profiles with email from auth.users
UPDATE profiles 
SET email = auth.users.email 
FROM auth.users 
WHERE profiles.id = auth.users.id;

-- Add comment for documentation
COMMENT ON COLUMN profiles.email IS 'User email address, synced from auth.users';