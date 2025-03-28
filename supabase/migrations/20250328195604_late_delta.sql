/*
  # Update lead status options

  1. Changes
    - Update status column constraint to include new status options
    - Add default status value

  2. Security
    - Maintain existing RLS policies
*/

-- Drop existing status check constraint
ALTER TABLE leads DROP CONSTRAINT IF EXISTS leads_status_check;

-- Add new status check constraint with updated options
ALTER TABLE leads 
  ALTER COLUMN status SET DEFAULT 'new',
  ADD CONSTRAINT leads_status_check 
    CHECK (status IN ('new', 'contacted', 'confirmed'));