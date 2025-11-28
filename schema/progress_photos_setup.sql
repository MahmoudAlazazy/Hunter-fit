-- Progress Photos Table Setup
-- This SQL script creates the progress_photos table and sets up storage

-- Create progress_photos table if it doesn't exist
CREATE TABLE IF NOT EXISTS progress_photos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    photo_url TEXT NOT NULL,
    photo_type TEXT NOT NULL CHECK (photo_type IN ('front', 'side', 'back')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE progress_photos ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own progress photos" ON progress_photos
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own progress photos" ON progress_photos
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own progress photos" ON progress_photos
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own progress photos" ON progress_photos
    FOR DELETE USING (auth.uid() = user_id);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_progress_photos_updated_at BEFORE UPDATE
    ON progress_photos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create storage bucket for progress photos
INSERT INTO storage.buckets (id, name, public) 
VALUES ('progress_photos', 'progress_photos', true)
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies
CREATE POLICY "Users can upload their own progress photos" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'progress_photos' AND 
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view their own progress photos" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'progress_photos' AND 
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Public access to progress photos" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'progress_photos'
    );

-- Grant permissions
GRANT ALL ON progress_photos TO authenticated;
GRANT SELECT ON progress_photos TO anon;
