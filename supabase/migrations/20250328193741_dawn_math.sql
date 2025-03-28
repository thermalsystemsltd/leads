/*
  # Fix User Creation Process

  1. Changes
    - Modify trigger function to properly validate emails before user creation
    - Update RLS policies to allow proper user creation flow
    - Add proper error handling for unauthorized emails
    - Fix profile creation timing

  2. Security
    - Maintain email restrictions
    - Ensure proper profile creation
    - Keep RLS policies secure
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

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Only allow Thermal Systems emails" ON public.profiles;
DROP POLICY IF EXISTS "Users can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;

-- Create policies for profile access
CREATE POLICY "Only allow Thermal Systems emails"
  ON public.profiles
  FOR INSERT
  TO public
  WITH CHECK (is_thermal_systems_email(email));

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
  WITH CHECK (is_thermal_systems_email(email));

-- Create or replace the function to handle new user creation
CREATE OR REPLACE FUNCTION auth.handle_new_user()
RETURNS trigger AS $$
BEGIN
  IF NOT public.is_thermal_systems_email(NEW.email::text) THEN
    RAISE EXCEPTION 'Unauthorized email domain' USING ERRCODE = '23505';
  END IF;

  -- Create profile after validating email
  INSERT INTO public.profiles (id, email, role)
  VALUES (NEW.id, NEW.email, 'admin')
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create new trigger in auth schema
CREATE TRIGGER on_auth_user_created
  BEFORE INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION auth.handle_new_user();

-- Create function to handle updated timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;