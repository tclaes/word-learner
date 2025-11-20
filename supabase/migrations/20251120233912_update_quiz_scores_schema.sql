/*
  # Update quiz_scores table schema

  ## Overview
  Updates the quiz_scores table to support new quiz functionality:
  - Adds created_at column for consistent timestamps
  - Adds percentage column for storing accuracy percentage
  - Adds duration_seconds column for tracking quiz duration
  - Removes quiz_direction and accuracy columns (no longer used)

  ## Changes
  1. Add new columns:
     - created_at (timestamptz) - timestamp when quiz was completed
     - percentage (integer) - accuracy percentage (0-100)
     - duration_seconds (integer) - quiz duration in seconds
  
  2. Migrate existing data:
     - Copy completed_at to created_at
     - Calculate percentage from score and total_questions
  
  3. Remove deprecated columns:
     - quiz_direction (not used in new implementation)
     - accuracy (replaced by percentage)
     - completed_at (replaced by created_at)

  ## Notes
  - This migration preserves all existing quiz data
  - Default values ensure data integrity
*/

-- Add new columns
ALTER TABLE quiz_scores 
  ADD COLUMN IF NOT EXISTS created_at timestamptz DEFAULT now(),
  ADD COLUMN IF NOT EXISTS percentage integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS duration_seconds integer DEFAULT 0;

-- Migrate existing data
UPDATE quiz_scores
SET 
  created_at = COALESCE(completed_at, now()),
  percentage = CASE 
    WHEN total_questions > 0 THEN ROUND((score::numeric / total_questions::numeric) * 100)
    ELSE 0
  END
WHERE created_at IS NULL OR percentage = 0;

-- Remove deprecated columns
ALTER TABLE quiz_scores
  DROP COLUMN IF EXISTS quiz_direction,
  DROP COLUMN IF EXISTS accuracy,
  DROP COLUMN IF EXISTS completed_at;

-- Make new columns NOT NULL after data migration
ALTER TABLE quiz_scores
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN percentage SET NOT NULL,
  ALTER COLUMN duration_seconds SET NOT NULL;
