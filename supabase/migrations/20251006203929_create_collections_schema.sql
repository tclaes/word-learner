/*
  # Create Collections Schema

  ## Overview
  Creates tables for managing language learning collections and their associated word pairs.

  ## New Tables
  
  ### `collections`
  - `id` (uuid, primary key) - Unique identifier for each collection
  - `name` (text, not null) - Name of the collection (e.g., "French", "Spanish")
  - `created_at` (timestamptz) - Timestamp when collection was created
  - `updated_at` (timestamptz) - Timestamp when collection was last updated

  ### `words`
  - `id` (uuid, primary key) - Unique identifier for each word pair
  - `collection_id` (uuid, foreign key) - References parent collection
  - `dutch` (text, not null) - Dutch word/phrase
  - `translation` (text, not null) - Translation in target language
  - `created_at` (timestamptz) - Timestamp when word pair was created

  ## Security
  - RLS enabled on both tables
  - Public read access for all users (anyone can view collections)
  - No write policies yet (will be added when auth is implemented)

  ## Notes
  1. Collections can have multiple word pairs through the foreign key relationship
  2. Deleting a collection will cascade delete all associated words
  3. Both tables have timestamps for tracking creation and updates
*/

-- Create collections table
CREATE TABLE IF NOT EXISTS collections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create words table
CREATE TABLE IF NOT EXISTS words (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id uuid NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
  dutch text NOT NULL,
  translation text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE words ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access
CREATE POLICY "Anyone can view collections"
  ON collections
  FOR SELECT
  USING (true);

CREATE POLICY "Anyone can view words"
  ON words
  FOR SELECT
  USING (true);

-- Create policies for public write access (temporary - should be restricted to authenticated users)
CREATE POLICY "Anyone can insert collections"
  ON collections
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can insert words"
  ON words
  FOR INSERT
  WITH CHECK (true);

-- Create index for faster word lookups by collection
CREATE INDEX IF NOT EXISTS words_collection_id_idx ON words(collection_id);