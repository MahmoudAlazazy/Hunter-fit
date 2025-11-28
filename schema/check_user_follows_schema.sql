-- Check user_follows table schema
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_follows' 
ORDER BY ordinal_position;

-- Check if table exists
SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE  table_schema = 'public'
   AND    table_name   = 'user_follows'
);

-- If columns are TEXT, we need to cast auth.uid() to text
-- If columns are UUID, we need to use auth.uid() directly
