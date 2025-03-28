/*
  # Add Email Restrictions for Thermal Systems Users

  1. Changes
    - Add email domain validation through RLS policies
    - Set up initial admin profiles structure
    - Add email validation function

  2. Security
    - Restricts sign-ups to specific thermal-systems.co.uk emails
    - Ensures only authorized users can access the system
*/

-- Create a function to validate thermal systems emails
CREATE OR REPLACE FUNCTION public.is_thermal_systems_email(email text)
RETURNS boolean AS $$
BEGIN
  RETURN email = ANY (ARRAY[
    'nia@thermal-systems.co.uk',
    'adam@thermal-systems.co.uk',
    'dave@thermal-systems.co.uk'
  ]);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create policy to ensure only thermal systems emails can be inserted
CREATE POLICY "Only allow Thermal Systems emails"
  ON public.profiles
  FOR ALL
  USING (is_thermal_systems_email(email))
  WITH CHECK (is_thermal_systems_email(email));

-- Create profiles for authorized users if they don't exist
DO $$
BEGIN
  -- Nia's profile
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    gen_random_uuid(),
    'nia@thermal-systems.co.uk',
    'Nia',
    'admin'
  )
  ON CONFLICT (email) DO UPDATE
  SET role = 'admin';

  -- Adam's profile
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    gen_random_uuid(),
    'adam@thermal-systems.co.uk',
    'Adam',
    'admin'
  )
  ON CONFLICT (email) DO UPDATE
  SET role = 'admin';

  -- Dave's profile
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    gen_random_uuid(),
    'dave@thermal-systems.co.uk',
    'Dave',
    'admin'
  )
  ON CONFLICT (email) DO UPDATE
  SET role = 'admin';
END $$;