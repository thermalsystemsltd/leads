/*
  # Fix user creation and profile handling

  1. Changes
    - Move trigger function to auth schema
    - Change trigger timing to BEFORE INSERT
    - Improve error handling for unauthorized emails
    - Fix profile creation logic

  2. Security
    - Maintain email restrictions
    - Keep RLS policies
    - Ensure proper error handling
*/

-- Drop existing trigger and function if they exist
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS auth.handle_new_user();

-- Recreate the function in auth schema with proper error handling
CREATE OR REPLACE FUNCTION auth.handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- Validate email before allowing user creation
  IF NOT EXISTS (
    SELECT 1 
    WHERE NEW.email IN (
      'nia@thermal-systems.co.uk',
      'adam@thermal-systems.co.uk',
      'dave@thermal-systems.co.uk'
    )
  ) THEN
    RAISE EXCEPTION 'Unauthorized email address'
      USING HINT = 'Only authorized Thermal Systems email addresses are allowed',
            ERRCODE = '23505';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to run BEFORE INSERT
CREATE TRIGGER on_auth_user_created
  BEFORE INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION auth.handle_new_user();

-- Ensure RLS is enabled
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Recreate policies with proper permissions
DROP POLICY IF EXISTS "Only allow Thermal Systems emails" ON public.profiles;
DROP POLICY IF EXISTS "Users can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;

CREATE POLICY "Only allow Thermal Systems emails"
  ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (
    email IN (
      'nia@thermal-systems.co.uk',
      'adam@thermal-systems.co.uk',
      'dave@thermal-systems.co.uk'
    )
  );

CREATE POLICY "Users can view all profiles"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can update their own profile"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (
    email IN (
      'nia@thermal-systems.co.uk',
      'adam@thermal-systems.co.uk',
      'dave@thermal-systems.co.uk'
    )
  );