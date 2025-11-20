/*
  # Fix Security and Performance Issues

  ## Overview
  Addresses critical performance and security issues identified in database audit:
  - Adds missing indexes on foreign keys
  - Optimizes RLS policies to prevent re-evaluation on each row
  
  ## Performance Improvements
  
  ### 1. Missing Indexes
  Adds indexes on foreign key columns to improve query performance:
    - `collections.user_id` - Index for user-collection lookups
    - `quiz_scores.user_id` - Index for user-quiz score lookups
    - `quiz_scores.collection_id` - Index for collection-quiz score lookups
  
  ### 2. RLS Policy Optimization
  Updates all RLS policies to use `(select auth.uid())` instead of `auth.uid()`.
  This prevents the function from being re-evaluated for each row, significantly
  improving performance at scale.
  
  ## Changes Applied
  
  ### Indexes
  - Create index on collections(user_id)
  - Create index on quiz_scores(user_id)
  - Create index on quiz_scores(collection_id)
  
  ### RLS Policies Updated
  - All policies on `collections` table (4 policies)
  - All policies on `words` table (4 policies)
  - All policies on `quiz_scores` table (4 policies)
  
  ## Notes
  The leaked password protection must be enabled manually in the Supabase Dashboard:
  Authentication > Policies > Enable "Leaked Password Protection"
*/

-- ============================================================================
-- ADD MISSING INDEXES ON FOREIGN KEYS
-- ============================================================================

-- Index for collections.user_id
CREATE INDEX IF NOT EXISTS collections_user_id_idx ON collections(user_id);

-- Index for quiz_scores.user_id
CREATE INDEX IF NOT EXISTS quiz_scores_user_id_idx ON quiz_scores(user_id);

-- Index for quiz_scores.collection_id
CREATE INDEX IF NOT EXISTS quiz_scores_collection_id_idx ON quiz_scores(collection_id);

-- ============================================================================
-- OPTIMIZE RLS POLICIES - COLLECTIONS TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own collections" ON collections;
DROP POLICY IF EXISTS "Users can insert own collections" ON collections;
DROP POLICY IF EXISTS "Users can update own collections" ON collections;
DROP POLICY IF EXISTS "Users can delete own collections" ON collections;

-- Create optimized policies with (select auth.uid())
CREATE POLICY "Users can view own collections"
  ON collections FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY "Users can insert own collections"
  ON collections FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY "Users can update own collections"
  ON collections FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY "Users can delete own collections"
  ON collections FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = user_id);

-- ============================================================================
-- OPTIMIZE RLS POLICIES - WORDS TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view words from own collections" ON words;
DROP POLICY IF EXISTS "Users can insert words to own collections" ON words;
DROP POLICY IF EXISTS "Users can update words in own collections" ON words;
DROP POLICY IF EXISTS "Users can delete words from own collections" ON words;

-- Create optimized policies with (select auth.uid())
CREATE POLICY "Users can view words from own collections"
  ON words FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = words.collection_id
      AND collections.user_id = (select auth.uid())
    )
  );

CREATE POLICY "Users can insert words to own collections"
  ON words FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = words.collection_id
      AND collections.user_id = (select auth.uid())
    )
  );

CREATE POLICY "Users can update words in own collections"
  ON words FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = words.collection_id
      AND collections.user_id = (select auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = words.collection_id
      AND collections.user_id = (select auth.uid())
    )
  );

CREATE POLICY "Users can delete words from own collections"
  ON words FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = words.collection_id
      AND collections.user_id = (select auth.uid())
    )
  );

-- ============================================================================
-- OPTIMIZE RLS POLICIES - QUIZ_SCORES TABLE
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own quiz scores" ON quiz_scores;
DROP POLICY IF EXISTS "Users can insert own quiz scores" ON quiz_scores;
DROP POLICY IF EXISTS "Users can update own quiz scores" ON quiz_scores;
DROP POLICY IF EXISTS "Users can delete own quiz scores" ON quiz_scores;

-- Create optimized policies with (select auth.uid())
CREATE POLICY "Users can view own quiz scores"
  ON quiz_scores FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY "Users can insert own quiz scores"
  ON quiz_scores FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY "Users can update own quiz scores"
  ON quiz_scores FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY "Users can delete own quiz scores"
  ON quiz_scores FOR DELETE
  TO authenticated
  USING ((select auth.uid()) = user_id);
