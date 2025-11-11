/*
  # Remove Public Access Policies

  ## Overview
  Removes the old public access policies that allow anyone to view and insert collections and words.
  Only authenticated users should be able to access their own collections.

  ## Changes
  - Drop "Anyone can view collections" policy
  - Drop "Anyone can insert collections" policy  
  - Drop "Anyone can view words" policy
  - Drop "Anyone can insert words" policy

  ## Security Impact
  After this migration, only authenticated users will be able to:
  - View their own collections and words
  - Create collections and words (linked to their user_id)
  - Update their own collections and words
  - Delete their own collections and words

  ## Notes
  The authenticated user policies are already in place and will continue to work.
  This simply removes the overly permissive public access policies.
*/

-- Drop public access policies for collections
DROP POLICY IF EXISTS "Anyone can view collections" ON collections;
DROP POLICY IF EXISTS "Anyone can insert collections" ON collections;

-- Drop public access policies for words
DROP POLICY IF EXISTS "Anyone can view words" ON words;
DROP POLICY IF EXISTS "Anyone can insert words" ON words;
