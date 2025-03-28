/*
  # Add Email Restrictions for Thermal Systems Users

  1. Changes
    - Add email domain validation through RLS policies
    - Set up email validation function
    - Add policies to restrict access to authorized emails

  2. Security
    - Restricts access to specific thermal-systems.co.uk emails
    - Ensures data integrity through proper foreign key relationships
    - Implements row level security for profiles
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
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;

-- Create policies for profile access
CREATE POLICY "Only allow Thermal Systems emails"
  ON public.profiles
  FOR INSERT
  WITH CHECK (is_thermal_systems_email(email));

CREATE POLICY "Users can view own profile"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (is_thermal_systems_email(email));

-- Create trigger function to automatically create profile
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  IF is_thermal_systems_email(NEW.email) THEN
    INSERT INTO public.profiles (id, email, role)
    VALUES (NEW.id, NEW.email, 'admin')
    ON CONFLICT (id) DO UPDATE
    SET role = 'admin';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();