-- Fix Row Level Security Policies for Comments Table

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view comments" ON comments;
DROP POLICY IF EXISTS "Users can create comments" ON comments;
DROP POLICY IF EXISTS "Users can update own comments" ON comments;
DROP POLICY IF EXISTS "Users can delete own comments" ON comments;

-- Create proper RLS policies for comments
CREATE POLICY "Users can view comments" ON comments FOR SELECT USING (true);

CREATE POLICY "Users can create comments" ON comments FOR INSERT WITH CHECK (
  auth.uid() = user_id
);

CREATE POLICY "Users can update own comments" ON comments FOR UPDATE USING (
  auth.uid() = user_id
);

CREATE POLICY "Users can delete own comments" ON comments FOR DELETE USING (
  auth.uid() = user_id
);

-- Also fix likes policies if needed
DROP POLICY IF EXISTS "Users can view likes" ON likes;
DROP POLICY IF EXISTS "Users can create likes" ON likes;
DROP POLICY IF EXISTS "Users can delete own likes" ON likes;

CREATE POLICY "Users can view likes" ON likes FOR SELECT USING (true);

CREATE POLICY "Users can create likes" ON likes FOR INSERT WITH CHECK (
  auth.uid() = user_id
);

CREATE POLICY "Users can delete own likes" ON likes FOR DELETE USING (
  auth.uid() = user_id
);

-- Fix posts policies to ensure they work properly
DROP POLICY IF EXISTS "Users can view public posts" ON posts;
DROP POLICY IF EXISTS "Users can view friends posts" ON posts;
DROP POLICY IF EXISTS "Users can manage own posts" ON posts;

CREATE POLICY "Users can view public posts" ON posts FOR SELECT USING (visibility = 'public');

CREATE POLICY "Users can view own posts" ON posts FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own posts" ON posts FOR ALL USING (auth.uid() = user_id);
