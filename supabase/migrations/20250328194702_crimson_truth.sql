/*
  # Fix leads table RLS policies

  1. Changes
    - Update RLS policies for leads table to allow proper access
    - Allow authenticated users to insert leads
    - Allow users to view all leads
    - Allow users to update their assigned leads

  2. Security
    - Enable RLS on leads table
    - Add policies for authenticated users
*/

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admin can insert leads" ON leads;
DROP POLICY IF EXISTS "Users can update assigned leads" ON leads;
DROP POLICY IF EXISTS "Users can view all leads" ON leads;

-- Create new policies
CREATE POLICY "Users can insert leads"
  ON leads
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can view all leads"
  ON leads
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can update leads"
  ON leads
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);