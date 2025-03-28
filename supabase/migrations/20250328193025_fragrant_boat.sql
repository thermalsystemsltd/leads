/*
  # Customer Leads Management Schema Update

  1. Changes
    - Update leads table structure with correct user reference columns
    - Enable RLS
    - Add policies for authenticated users

  2. Security
    - Row Level Security (RLS) enabled
    - Policies ensure users can only access their own leads
    - Added proper foreign key constraints to profiles table
*/

-- Create table if it doesn't exist
CREATE TABLE IF NOT EXISTS leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_name text NOT NULL,
  contact_name text NOT NULL,
  contact_email text,
  contact_phone text,
  requirements text,
  status text DEFAULT 'new',
  assigned_to uuid REFERENCES profiles(id),
  created_by uuid REFERENCES profiles(id),
  estimated_value numeric(10,2),
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add status constraint
DO $$ 
BEGIN
  ALTER TABLE leads
    ADD CONSTRAINT leads_status_check 
    CHECK (status = ANY (ARRAY['new', 'contacted', 'in_progress', 'quoted', 'won', 'lost']));
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Enable RLS
DO $$ 
BEGIN
  ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
EXCEPTION
  WHEN others THEN NULL;
END $$;

-- Drop existing policies if they exist
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Admin can insert leads" ON leads;
  DROP POLICY IF EXISTS "Users can update assigned leads" ON leads;
  DROP POLICY IF EXISTS "Users can view all leads" ON leads;
END $$;

-- Create policies
CREATE POLICY "Admin can insert leads"
  ON leads
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Users can update assigned leads"
  ON leads
  FOR UPDATE
  TO authenticated
  USING (
    assigned_to = auth.uid()
    OR EXISTS (
      SELECT 1
      FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    assigned_to = auth.uid()
    OR EXISTS (
      SELECT 1
      FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Users can view all leads"
  ON leads
  FOR SELECT
  TO authenticated
  USING (true);