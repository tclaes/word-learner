/*
  # Add User Authentication and Link Collections to Users

  1. Schema Changes
    - Add `user_id` column to `collections` table
    - Create foreign key relationship to `auth.users`
    - Create `quiz_scores` table to track user quiz performance
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to auth.users)
      - `collection_id` (uuid, foreign key to collections)
      - `score` (integer)
      - `total_questions` (integer)
      - `accuracy` (numeric)
      - `quiz_direction` (text - 'dutch-to-translation' or 'translation-to-dutch')
      - `completed_at` (timestamptz)

  2. Security
    - Update RLS policies for `collections` table
      - Users can only read/create/update/delete their own collections
    - Update RLS policies for `words` table
      - Users can only access words from their own collections
    - Add RLS policies for `quiz_scores` table
      - Users can only read/create their own quiz scores

  3. Data Migration
    - Set default user_id for existing collections (will need manual update)
*/

-- Add user_id column to collections table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'collections' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE collections ADD COLUMN user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Create quiz_scores table
CREATE TABLE IF NOT EXISTS quiz_scores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  collection_id uuid NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
  score integer NOT NULL DEFAULT 0,
  total_questions integer NOT NULL DEFAULT 0,
  accuracy numeric(5,2) DEFAULT 0,
  quiz_direction text NOT NULL DEFAULT 'dutch-to-translation',
  completed_at timestamptz DEFAULT now()
);

-- Enable RLS on quiz_scores
ALTER TABLE quiz_scores ENABLE ROW LEVEL SECURITY;

-- Drop existing policies for collections if they exist
DROP POLICY IF EXISTS "Users can view own collections" ON collections;
DROP POLICY IF EXISTS "Users can insert own collections" ON collections;
DROP POLICY IF EXISTS "Users can update own collections" ON collections;
DROP POLICY IF EXISTS "Users can delete own collections" ON collections;

-- Drop existing policies for words if they exist
DROP POLICY IF EXISTS "Users can view words from own collections" ON words;
DROP POLICY IF EXISTS "Users can insert words to own collections" ON words;
DROP POLICY IF EXISTS "Users can update words in own collections" ON words;
DROP POLICY IF EXISTS "Users can delete words from own collections" ON words;

-- Create RLS policies for collections
CREATE POLICY "Users can view own collections"
  ON collections FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own collections"
  ON collections FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own collections"
  ON collections FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own collections"
  ON collections FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Create RLS policies for words
CREATE POLICY "Users can view words from own collections"
  ON words FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = words.collection_id
      AND collections.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert words to own collections"
  ON words FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = words.collection_id
      AND collections.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update words in own collections"
  ON words FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = words.collection_id
      AND collections.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = words.collection_id
      AND collections.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete words from own collections"
  ON words FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = words.collection_id
      AND collections.user_id = auth.uid()
    )
  );

-- Create RLS policies for quiz_scores
CREATE POLICY "Users can view own quiz scores"
  ON quiz_scores FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own quiz scores"
  ON quiz_scores FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own quiz scores"
  ON quiz_scores FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own quiz scores"
  ON quiz_scores FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);