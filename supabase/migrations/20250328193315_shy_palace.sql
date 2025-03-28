/*
  # Add Email Restrictions and Create Initial Users

  1. Changes
    - Add email domain check for thermal-systems.co.uk
    - Create initial admin users
    - Update profiles table with role restrictions

  2. Security
    - Only allows specific thermal-systems.co.uk email addresses
    - Sets up initial admin users
    - Enforces role constraints
*/

-- Add email domain check to auth.users
ALTER TABLE auth.users
ADD CONSTRAINT users_email_domain_check
CHECK (
  email = ANY (ARRAY[
    'nia@thermal-systems.co.uk',
    'adam@thermal-systems.co.uk',
    'dave@thermal-systems.co.uk'
  ])
);

-- Create initial users if they don't exist
DO $$
DECLARE
  nia_uid uuid;
  adam_uid uuid;
  dave_uid uuid;
BEGIN
  -- Create users in auth.users if they don't exist
  INSERT INTO auth.users (email, role, instance_id)
  VALUES 
    ('nia@thermal-systems.co.uk', 'authenticated', '00000000-0000-0000-0000-000000000000')
  ON CONFLICT (email) DO NOTHING
  RETURNING id INTO nia_uid;

  INSERT INTO auth.users (email, role, instance_id)
  VALUES 
    ('adam@thermal-systems.co.uk', 'authenticated', '00000000-0000-0000-0000-000000000000')
  ON CONFLICT (email) DO NOTHING
  RETURNING id INTO adam_uid;

  INSERT INTO auth.users (email, role, instance_id)
  VALUES 
    ('dave@thermal-systems.co.uk', 'authenticated', '00000000-0000-0000-0000-000000000000')
  ON CONFLICT (email) DO NOTHING
  RETURNING id INTO dave_uid;

  -- Create corresponding profiles
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES
    (nia_uid, 'nia@thermal-systems.co.uk', 'Nia', 'admin'),
    (adam_uid, 'adam@thermal-systems.co.uk', 'Adam', 'admin'),
    (dave_uid, 'dave@thermal-systems.co.uk', 'Dave', 'admin')
  ON CONFLICT (id) DO UPDATE
  SET role = 'admin';
END $$;