-- Fix RLS policies for user_follows table

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their follows" ON user_follows;
DROP POLICY IF EXISTS "Users can create their follows" ON user_follows;
DROP POLICY IF EXISTS "Users can update their follows" ON user_follows;
DROP POLICY IF EXISTS "Users can delete their follows" ON user_follows;

-- Create RLS policies for user_follows table
-- Using proper UUID casting for comparison

-- Policy for viewing follows (users can see who they follow and who follows them)
CREATE POLICY "Users can view their follows" ON user_follows FOR SELECT USING (
  follower_id::text = auth.uid()::text OR 
  following_id::text = auth.uid()::text
);

-- Policy for creating follows (users can follow others)
CREATE POLICY "Users can create their follows" ON user_follows FOR INSERT WITH CHECK (
  follower_id::text = auth.uid()::text
);

-- Policy for updating follows (users can update their own follows)
CREATE POLICY "Users can update their follows" ON user_follows FOR UPDATE USING (
  follower_id::text = auth.uid()::text
);

-- Policy for deleting follows (users can unfollow others)
CREATE POLICY "Users can delete their follows" ON user_follows FOR DELETE USING (
  follower_id::text = auth.uid()::text
);

-- Ensure RLS is enabled on user_follows table
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;

-- Grant necessary permissions
GRANT SELECT ON user_follows TO authenticated;
GRANT INSERT ON user_follows TO authenticated;
GRANT UPDATE ON user_follows TO authenticated;
GRANT DELETE ON user_follows TO authenticated;
