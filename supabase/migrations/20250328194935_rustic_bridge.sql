/*
  # Add new fields to leads table

  1. Changes
    - Add contact_position field
    - Add industry_type field
    - Add address field
    - Add delete policy for leads

  2. Security
    - Maintain existing RLS policies
    - Add policy for deleting leads
*/

-- Add new columns
ALTER TABLE leads
  ADD COLUMN IF NOT EXISTS contact_position text,
  ADD COLUMN IF NOT EXISTS industry_type text,
  ADD COLUMN IF NOT EXISTS address text;

-- Add delete policy
CREATE POLICY "Users can delete leads"
  ON leads
  FOR DELETE
  TO authenticated
  USING (true);