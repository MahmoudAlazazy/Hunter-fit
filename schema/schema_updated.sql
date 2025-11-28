-- =====================================================================
-- Supabase Fitness App - Updated SQL Schema
-- PostgreSQL dialect (Supabase)
-- =====================================================================

-- ---------------------------------------------------------------------
-- Extensions
-- ---------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- for gen_random_uuid()

-- ---------------------------------------------------------------------
-- DROP TYPES (re-creatable)
-- ---------------------------------------------------------------------
DROP TYPE IF EXISTS gender_enum CASCADE;
DROP TYPE IF EXISTS goal_enum CASCADE;
DROP TYPE IF EXISTS activity_level_enum CASCADE;
DROP TYPE IF EXISTS difficulty_enum CASCADE;
DROP TYPE IF EXISTS exercise_category_enum CASCADE;
DROP TYPE IF EXISTS muscle_group_enum CASCADE;
DROP TYPE IF EXISTS visibility_enum CASCADE;
DROP TYPE IF EXISTS meal_type_enum CASCADE;
DROP TYPE IF EXISTS notification_type_enum CASCADE;
DROP TYPE IF EXISTS notification_source_enum CASCADE;
DROP TYPE IF EXISTS heart_rate_zone_enum CASCADE;
DROP TYPE IF EXISTS message_attachment_type_enum CASCADE;
DROP TYPE IF EXISTS conversation_role_enum CASCADE;
DROP TYPE IF EXISTS schedule_status_enum CASCADE;

-- ---------------------------------------------------------------------
-- ENUMS
-- ---------------------------------------------------------------------
CREATE TYPE gender_enum AS ENUM ('male', 'female', 'non_binary', 'unspecified');
CREATE TYPE goal_enum AS ENUM ('lose_weight', 'build_muscle', 'maintain', 'improve_endurance', 'increase_flexibility');
CREATE TYPE activity_level_enum AS ENUM ('sedentary', 'light', 'moderate', 'active', 'very_active');
CREATE TYPE difficulty_enum AS ENUM ('beginner', 'intermediate', 'advanced');
CREATE TYPE exercise_category_enum AS ENUM ('cardio', 'strength', 'flexibility', 'mobility', 'yoga', 'hiit');
CREATE TYPE muscle_group_enum AS ENUM ('full_body', 'legs', 'glutes', 'chest', 'back', 'shoulders', 'arms', 'core');
CREATE TYPE visibility_enum AS ENUM ('public', 'friends', 'private');
CREATE TYPE meal_type_enum AS ENUM ('breakfast', 'lunch', 'dinner', 'snack', 'dessert');
CREATE TYPE notification_type_enum AS ENUM ('reminder', 'system', 'social');
CREATE TYPE notification_source_enum AS ENUM ('workout', 'meal', 'goal', 'system', 'social');
CREATE TYPE heart_rate_zone_enum AS ENUM ('rest', 'fat_burn', 'cardio', 'peak');
CREATE TYPE message_attachment_type_enum AS ENUM ('image', 'video', 'audio', 'file');
CREATE TYPE conversation_role_enum AS ENUM ('member', 'admin');
CREATE TYPE schedule_status_enum AS ENUM ('scheduled', 'completed', 'skipped', 'cancelled');

-- ---------------------------------------------------------------------
-- STORAGE BUCKETS (Supabase)
-- ---------------------------------------------------------------------
-- Clean up existing buckets if re-running
DELETE FROM storage.buckets WHERE name IN ('avatars', 'progress_photos', 'post_media', 'exercise_media', 'food_images');

-- Create buckets
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('avatars', 'avatars', true),
  ('progress_photos', 'progress_photos', false),
  ('post_media', 'post_media', true),
  ('exercise_media', 'exercise_media', true),
  ('food_images', 'food_images', true);

-- =====================================================================
-- CORE TABLES
-- =====================================================================

-- ---------------------------------------------------------------------
-- Profiles (extends Supabase auth.users)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS profiles CASCADE;
CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  username text UNIQUE,
  full_name text,
  email text,
  avatar_url text,
  gender gender_enum DEFAULT 'unspecified'::gender_enum,
  birth_date date,
  height_cm numeric(5,2),
  weight_kg numeric(6,2),
  goal goal_enum,
  activity_level activity_level_enum,
  timezone text DEFAULT 'UTC',
  language text DEFAULT 'en',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX profiles_username_idx ON profiles (username);
CREATE INDEX profiles_email_idx ON profiles (email);
CREATE INDEX profiles_goal_idx ON profiles (goal);
CREATE INDEX profiles_activity_level_idx ON profiles (activity_level);

-- ---------------------------------------------------------------------
-- Settings (1:1 with profiles)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS settings CASCADE;
CREATE TABLE settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid UNIQUE NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  units text DEFAULT 'metric', -- 'metric' or 'imperial'
  notifications_enabled boolean DEFAULT true,
  daily_reminder_time time,
  privacy visibility_enum DEFAULT 'friends',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX settings_user_id_idx ON settings (user_id);

-- ---------------------------------------------------------------------
-- Exercises Catalog
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS exercises CASCADE;
CREATE TABLE exercises (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  category exercise_category_enum NOT NULL,
  equipment text,
  muscle_group muscle_group_enum,
  media_url text, -- storage link to image/video
  calories_per_minute numeric(6,2), -- ADDED: for UI calorie calculations
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX exercises_category_idx ON exercises (category);
CREATE INDEX exercises_muscle_group_idx ON exercises (muscle_group);
CREATE UNIQUE INDEX exercises_name_unique_idx ON exercises (name);

-- ---------------------------------------------------------------------
-- Workouts
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS workouts CASCADE;
CREATE TABLE workouts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  difficulty difficulty_enum,
  duration_minutes integer,
  image_url text, -- ADDED: for workout preview images
  is_private boolean DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX workouts_user_id_idx ON workouts (user_id);
CREATE INDEX workouts_difficulty_idx ON workouts (difficulty);

-- ---------------------------------------------------------------------
-- Workout Exercises (sequence and parameters)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS workout_exercises CASCADE;
CREATE TABLE workout_exercises (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workout_id uuid NOT NULL REFERENCES workouts (id) ON DELETE CASCADE,
  exercise_id uuid NOT NULL REFERENCES exercises (id) ON DELETE RESTRICT,
  order_index integer NOT NULL,
  sets integer,
  reps integer,
  duration_seconds integer,
  rest_seconds integer,
  notes text
);

CREATE INDEX workout_exercises_workout_id_idx ON workout_exercises (workout_id);
CREATE INDEX workout_exercises_exercise_id_idx ON workout_exercises (exercise_id);
CREATE UNIQUE INDEX workout_exercises_unique_order_idx ON workout_exercises (workout_id, order_index);

-- ---------------------------------------------------------------------
-- Workout Schedules
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS workout_schedules CASCADE;
CREATE TABLE workout_schedules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  workout_id uuid NOT NULL REFERENCES workouts (id) ON DELETE CASCADE,
  scheduled_date date NOT NULL,
  scheduled_time time,
  status schedule_status_enum DEFAULT 'scheduled',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX workout_schedules_user_id_idx ON workout_schedules (user_id);
CREATE INDEX workout_schedules_workout_id_idx ON workout_schedules (workout_id);
CREATE INDEX workout_schedules_date_idx ON workout_schedules (scheduled_date);

-- ---------------------------------------------------------------------
-- Workout History
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS workout_history CASCADE;
CREATE TABLE workout_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  workout_id uuid REFERENCES workouts (id) ON DELETE SET NULL,
  started_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz,
  duration_seconds integer,
  calories_burned numeric(10,2),
  progress_percentage numeric(5,2) DEFAULT 0, -- ADDED: for UI progress tracking
  mood text,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX workout_history_user_id_idx ON workout_history (user_id);
CREATE INDEX workout_history_workout_id_idx ON workout_history (workout_id);
CREATE INDEX workout_history_started_at_idx ON workout_history (started_at);

-- ---------------------------------------------------------------------
-- Exercise History within Workout History
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS exercise_history CASCADE;
CREATE TABLE exercise_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workout_history_id uuid NOT NULL REFERENCES workout_history (id) ON DELETE CASCADE,
  exercise_id uuid NOT NULL REFERENCES exercises (id) ON DELETE RESTRICT,
  sets_completed integer,
  notes text
);

CREATE INDEX exercise_history_workout_history_id_idx ON exercise_history (workout_history_id);
CREATE INDEX exercise_history_exercise_id_idx ON exercise_history (exercise_id);

-- ---------------------------------------------------------------------
-- Exercise Set Logs (per set data)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS exercise_set_logs CASCADE;
CREATE TABLE exercise_set_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_history_id uuid NOT NULL REFERENCES exercise_history (id) ON DELETE CASCADE,
  set_number integer NOT NULL,
  reps integer,
  weight_kg numeric(7,2),
  duration_seconds integer
);

CREATE INDEX exercise_set_logs_exercise_history_id_idx ON exercise_set_logs (exercise_history_id);
CREATE UNIQUE INDEX exercise_set_logs_unique_set_idx ON exercise_set_logs (exercise_history_id, set_number);

-- ---------------------------------------------------------------------
-- Foods Catalog
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS foods CASCADE;
CREATE TABLE foods (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  brand text,
  serving_size_g numeric(7,2),
  calories_per_serving numeric(8,2),
  protein_g numeric(8,2),
  carbs_g numeric(8,2),
  fat_g numeric(8,2),
  fiber_g numeric(8,2),
  sugar_g numeric(8,2),
  sodium_mg numeric(10,2),
  image_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX foods_name_idx ON foods (name);
CREATE INDEX foods_brand_idx ON foods (brand);

-- ---------------------------------------------------------------------
-- Meals
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS meals CASCADE;
CREATE TABLE meals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  meal_type meal_type_enum NOT NULL,
  name text,
  served_at timestamptz, -- actual meal time
  notes text,
  image_url text, -- ADDED: for meal photos
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX meals_user_id_idx ON meals (user_id);
CREATE INDEX meals_served_at_idx ON meals (served_at);
CREATE INDEX meals_meal_type_idx ON meals (meal_type);

-- ---------------------------------------------------------------------
-- Meal Items (link meals to foods)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS meal_items CASCADE;
CREATE TABLE meal_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  meal_id uuid NOT NULL REFERENCES meals (id) ON DELETE CASCADE,
  food_id uuid NOT NULL REFERENCES foods (id) ON DELETE RESTRICT,
  servings numeric(8,2) NOT NULL DEFAULT 1.0
);

CREATE INDEX meal_items_meal_id_idx ON meal_items (meal_id);
CREATE INDEX meal_items_food_id_idx ON meal_items (food_id);

-- ---------------------------------------------------------------------
-- Nutrition (daily targets and aggregates)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS nutrition CASCADE;
CREATE TABLE nutrition (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  date date NOT NULL,
  calories_target numeric(8,2),
  protein_target_g numeric(8,2),
  carbs_target_g numeric(8,2),
  fats_target_g numeric(8,2),
  calories_consumed numeric(8,2) DEFAULT 0,
  protein_consumed_g numeric(8,2) DEFAULT 0,
  carbs_consumed_g numeric(8,2) DEFAULT 0,
  fats_consumed_g numeric(8,2) DEFAULT 0,
  water_ml integer DEFAULT 0,
  fiber_g numeric(8,2) DEFAULT 0,
  sodium_mg numeric(10,2) DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, date)
);

CREATE INDEX nutrition_user_id_idx ON nutrition (user_id);
CREATE INDEX nutrition_date_idx ON nutrition (date);

-- ---------------------------------------------------------------------
-- Water Intake (detailed tracking)
-- ADDED: New table for detailed water intake tracking
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS water_intake CASCADE;
CREATE TABLE water_intake (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  date date NOT NULL,
  time_slot text NOT NULL, -- e.g., "6am - 8am"
  amount_ml integer NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX water_intake_user_id_idx ON water_intake (user_id);
CREATE INDEX water_intake_date_idx ON water_intake (date);
CREATE INDEX water_intake_time_slot_idx ON water_intake (time_slot);

-- ---------------------------------------------------------------------
-- Calorie Logs (ingest/expend entries)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS calorie_logs CASCADE;
CREATE TABLE calorie_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  source text NOT NULL, -- 'meal','workout','manual'
  amount_kcal numeric(8,2) NOT NULL,
  occurred_at timestamptz NOT NULL DEFAULT now(),
  ref_table text,   -- optional reference table name
  ref_id uuid,      -- optional reference id
  notes text
);

CREATE INDEX calorie_logs_user_id_idx ON calorie_logs (user_id);
CREATE INDEX calorie_logs_occurred_at_idx ON calorie_logs (occurred_at);

-- ---------------------------------------------------------------------
-- Activity Tracking (daily aggregates)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS activity_tracking CASCADE;
CREATE TABLE activity_tracking (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  date date NOT NULL,
  steps integer DEFAULT 0,
  distance_m numeric(10,2) DEFAULT 0,
  floors integer DEFAULT 0,
  calories_active numeric(10,2) DEFAULT 0,
  heart_rate_avg integer, -- ADDED: average heart rate
  heart_rate_max integer, -- ADDED: max heart rate
  UNIQUE (user_id, date),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX activity_tracking_user_id_idx ON activity_tracking (user_id);
CREATE INDEX activity_tracking_date_idx ON activity_tracking (date);

-- ---------------------------------------------------------------------
-- Heart Rate
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS heart_rate CASCADE;
CREATE TABLE heart_rate (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  measured_at timestamptz NOT NULL DEFAULT now(),
  bpm integer NOT NULL,
  zone heart_rate_zone_enum,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX heart_rate_user_id_idx ON heart_rate (user_id);
CREATE INDEX heart_rate_measured_at_idx ON heart_rate (measured_at);

-- ---------------------------------------------------------------------
-- BMI Tracking
-- ADDED: New table for BMI history tracking
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS bmi_history CASCADE;
CREATE TABLE bmi_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  date date NOT NULL,
  height_cm numeric(5,2) NOT NULL,
  weight_kg numeric(6,2) NOT NULL,
  bmi numeric(5,2) NOT NULL,
  category text, -- 'underweight', 'normal', 'overweight', 'obese'
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX bmi_history_user_id_idx ON bmi_history (user_id);
CREATE INDEX bmi_history_date_idx ON bmi_history (date);

-- ---------------------------------------------------------------------
-- Sleep Tracking
-- ADDED: New table for sleep tracking
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS sleep_tracking CASCADE;
CREATE TABLE sleep_tracking (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  date date NOT NULL,
  bedtime timestamptz NOT NULL,
  wake_time timestamptz NOT NULL,
  duration_minutes integer NOT NULL,
  quality_score integer CHECK (quality_score >= 1 AND quality_score <= 10),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX sleep_tracking_user_id_idx ON sleep_tracking (user_id);
CREATE INDEX sleep_tracking_date_idx ON sleep_tracking (date);

-- ---------------------------------------------------------------------
-- Sleep Alarms
-- ADDED: New table for sleep alarms
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS sleep_alarms CASCADE;
CREATE TABLE sleep_alarms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  title text NOT NULL DEFAULT 'Alarm',
  alarm_time timestamptz NOT NULL,
  is_enabled boolean DEFAULT true,
  vibrate boolean DEFAULT true,
  repeat_days text, -- e.g., 'Mon,Tue,Wed,Thu,Fri'
  sound text, -- sound file path or name
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX sleep_alarms_user_id_idx ON sleep_alarms (user_id);
CREATE INDEX sleep_alarms_alarm_time_idx ON sleep_alarms (alarm_time);

-- ---------------------------------------------------------------------
-- Progress Photos
-- ADDED: New table for progress photo tracking
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS progress_photos CASCADE;
CREATE TABLE progress_photos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  date date NOT NULL,
  photo_url text NOT NULL,
  photo_type text DEFAULT 'front', -- 'front', 'side', 'back'
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX progress_photos_user_id_idx ON progress_photos (user_id);
CREATE INDEX progress_photos_date_idx ON progress_photos (date);

-- ---------------------------------------------------------------------
-- Notifications
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS notifications CASCADE;
CREATE TABLE notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  title text NOT NULL,
  body text,
  type notification_type_enum NOT NULL,
  source notification_source_enum,
  data jsonb,
  sent_at timestamptz NOT NULL DEFAULT now(),
  read_at timestamptz
);

CREATE INDEX notifications_user_id_idx ON notifications (user_id);
CREATE INDEX notifications_sent_at_idx ON notifications (sent_at);
CREATE INDEX notifications_type_idx ON notifications (type);

-- ---------------------------------------------------------------------
-- Social: Posts
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS posts CASCADE;
CREATE TABLE posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  content text,
  image_url text, -- storage link in post_media
  visibility visibility_enum DEFAULT 'public',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX posts_user_id_idx ON posts (user_id);
CREATE INDEX posts_visibility_idx ON posts (visibility);
CREATE INDEX posts_created_at_idx ON posts (created_at);

-- ---------------------------------------------------------------------
-- Social: Comments (supports replies via parent_comment_id)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS comments CASCADE;
CREATE TABLE comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES posts (id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  parent_comment_id uuid REFERENCES comments (id) ON DELETE CASCADE,
  content text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX comments_post_id_idx ON comments (post_id);
CREATE INDEX comments_user_id_idx ON comments (user_id);
CREATE INDEX comments_parent_comment_id_idx ON comments (parent_comment_id);

-- ---------------------------------------------------------------------
-- Social: Likes (polymorphic to posts or comments)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS likes CASCADE;
CREATE TABLE likes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  post_id uuid REFERENCES posts (id) ON DELETE CASCADE,
  comment_id uuid REFERENCES comments (id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (
    (post_id IS NOT NULL AND comment_id IS NULL)
    OR (post_id IS NULL AND comment_id IS NOT NULL)
  )
);

CREATE INDEX likes_user_id_idx ON likes (user_id);
CREATE INDEX likes_post_id_idx ON likes (post_id) WHERE post_id IS NOT NULL;
CREATE INDEX likes_comment_id_idx ON likes (comment_id) WHERE comment_id IS NOT NULL;

-- Prevent duplicate likes for same target
CREATE UNIQUE INDEX likes_unique_post_like_idx ON likes (user_id, post_id) WHERE post_id IS NOT NULL;
CREATE UNIQUE INDEX likes_unique_comment_like_idx ON likes (user_id, comment_id) WHERE comment_id IS NOT NULL;

-- ---------------------------------------------------------------------
-- Social: Follows
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS user_follows CASCADE;
CREATE TABLE user_follows (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  following_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT user_follows_no_self_follow CHECK (follower_id <> following_id),
  UNIQUE (follower_id, following_id)
);

CREATE INDEX user_follows_follower_idx ON user_follows (follower_id);
CREATE INDEX user_follows_following_idx ON user_follows (following_id);

-- ---------------------------------------------------------------------
-- Messaging: Conversations
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS conversations CASCADE;
CREATE TABLE conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  is_group boolean DEFAULT false,
  title text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Messaging: Conversation Participants
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS conversation_participants CASCADE;
CREATE TABLE conversation_participants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES conversations (id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  role conversation_role_enum DEFAULT 'member',
  joined_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (conversation_id, user_id)
);

CREATE INDEX conversation_participants_conversation_id_idx ON conversation_participants (conversation_id);
CREATE INDEX conversation_participants_user_id_idx ON conversation_participants (user_id);

-- ---------------------------------------------------------------------
-- Messaging: Messages
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS messages CASCADE;
CREATE TABLE messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES conversations (id) ON DELETE CASCADE,
  sender_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  content text,
  attachment_url text,
  attachment_type message_attachment_type_enum,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX messages_conversation_id_idx ON messages (conversation_id);
CREATE INDEX messages_sender_id_idx ON messages (sender_id);
CREATE INDEX messages_created_at_idx ON messages (created_at);

-- =====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_set_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE nutrition ENABLE ROW LEVEL SECURITY;
ALTER TABLE water_intake ENABLE ROW LEVEL SECURITY;
ALTER TABLE calorie_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE heart_rate ENABLE ROW LEVEL SECURITY;
ALTER TABLE bmi_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE sleep_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE sleep_alarms ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view all profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can create own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can delete own profile" ON profiles FOR DELETE USING (auth.uid() = id);

-- Settings policies
CREATE POLICY "Users can view own settings" ON settings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own settings" ON settings FOR ALL USING (auth.uid() = user_id);

-- Exercises policies
CREATE POLICY "Anyone can view exercises" ON exercises FOR SELECT USING (true);
CREATE POLICY "Admins can manage exercises" ON exercises FOR ALL USING (auth.jwt() ->> 'role' = 'admin');

-- Workouts policies
CREATE POLICY "Users can view public workouts" ON workouts FOR SELECT USING (is_private = false);
CREATE POLICY "Users can view own workouts" ON workouts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own workouts" ON workouts FOR ALL USING (auth.uid() = user_id);

-- Workout schedules policies
CREATE POLICY "Users can view own schedules" ON workout_schedules FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own schedules" ON workout_schedules FOR ALL USING (auth.uid() = user_id);

-- Nutrition policies
CREATE POLICY "Users can view own nutrition" ON nutrition FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own nutrition" ON nutrition FOR ALL USING (auth.uid() = user_id);

-- Water intake policies
CREATE POLICY "Users can view own water intake" ON water_intake FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own water intake" ON water_intake FOR ALL USING (auth.uid() = user_id);

-- Activity tracking policies
CREATE POLICY "Users can view own activity" ON activity_tracking FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own activity" ON activity_tracking FOR ALL USING (auth.uid() = user_id);

-- Heart rate policies
CREATE POLICY "Users can view own heart rate" ON heart_rate FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own heart rate" ON heart_rate FOR ALL USING (auth.uid() = user_id);

-- BMI history policies
CREATE POLICY "Users can view own BMI history" ON bmi_history FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own BMI history" ON bmi_history FOR ALL USING (auth.uid() = user_id);

-- Sleep tracking policies
CREATE POLICY "Users can view own sleep data" ON sleep_tracking FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own sleep data" ON sleep_tracking FOR ALL USING (auth.uid() = user_id);

-- Sleep alarms policies
CREATE POLICY "Users can view own sleep alarms" ON sleep_alarms FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own sleep alarms" ON sleep_alarms FOR ALL USING (auth.uid() = user_id);

-- Progress photos policies
CREATE POLICY "Users can view own progress photos" ON progress_photos FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own progress photos" ON progress_photos FOR ALL USING (auth.uid() = user_id);

-- Social features policies
CREATE POLICY "Users can view public posts" ON posts FOR SELECT USING (visibility = 'public');
CREATE POLICY "Users can view friends posts" ON posts FOR SELECT USING (visibility = 'friends');
CREATE POLICY "Users can manage own posts" ON posts FOR ALL USING (auth.uid() = user_id);

-- =====================================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for tables with updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_settings_updated_at BEFORE UPDATE ON settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workouts_updated_at BEFORE UPDATE ON workouts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workout_schedules_updated_at BEFORE UPDATE ON workout_schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_exercises_updated_at BEFORE UPDATE ON exercises
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_foods_updated_at BEFORE UPDATE ON foods
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meals_updated_at BEFORE UPDATE ON meals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_nutrition_updated_at BEFORE UPDATE ON nutrition
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_activity_tracking_updated_at BEFORE UPDATE ON activity_tracking
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sleep_alarms_updated_at BEFORE UPDATE ON sleep_alarms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Calculate BMI function
CREATE OR REPLACE FUNCTION calculate_bmi(height_cm numeric, weight_kg numeric)
RETURNS numeric AS $$
BEGIN
    RETURN ROUND(weight_kg / ((height_cm / 100) * (height_cm / 100)), 2);
END;
$$ language 'plpgsql';

-- BMI category function
CREATE OR REPLACE FUNCTION get_bmi_category(bmi numeric)
RETURNS text AS $$
BEGIN
    IF bmi < 18.5 THEN
        RETURN 'underweight';
    ELSIF bmi < 25 THEN
        RETURN 'normal';
    ELSIF bmi < 30 THEN
        RETURN 'overweight';
    ELSE
        RETURN 'obese';
    END IF;
END;
$$ language 'plpgsql';

-- =====================================================================
-- SAMPLE DATA
-- =====================================================================

-- Sample exercises
INSERT INTO exercises (name, description, category, muscle_group, calories_per_minute) VALUES
('Push-ups', 'Classic upper body exercise', 'strength', 'chest', 8.0),
('Squats', 'Lower body compound movement', 'strength', 'legs', 6.0),
('Plank', 'Core stability exercise', 'strength', 'core', 4.0),
('Running', 'Cardiovascular exercise', 'cardio', 'full_body', 12.0),
('Jumping Jacks', 'Full body cardio exercise', 'cardio', 'full_body', 10.0),
('Yoga Flow', 'Flexibility and balance', 'flexibility', 'full_body', 3.0);

-- Sample foods
INSERT INTO foods (name, brand, serving_size_g, calories_per_serving, protein_g, carbs_g, fat_g) VALUES
('Chicken Breast', 'Generic', 100, 165, 31, 0, 3.6),
('Brown Rice', 'Generic', 100, 112, 2.6, 22, 0.9),
('Broccoli', 'Generic', 100, 34, 2.8, 7, 0.4),
('Banana', 'Generic', 118, 105, 1.3, 27, 0.4),
('Greek Yogurt', 'Generic', 100, 59, 10, 3.6, 0.4),
('Almonds', 'Generic', 28, 164, 6, 6, 14);

-- =====================================================================
-- END OF SCHEMA
-- =====================================================================