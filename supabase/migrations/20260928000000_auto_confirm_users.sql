-- Auto confirm all users on signup and confirm existing unconfirmed users
-- This prevents "Invalid login credentials" caused by unconfirmed email in mobile apps

CREATE OR REPLACE FUNCTION public.handle_auto_confirm_user()
RETURNS trigger AS $$
BEGIN
  IF NEW.email_confirmed_at IS NULL THEN
    NEW.email_confirmed_at := now();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new signups
DROP TRIGGER IF EXISTS on_auth_user_auto_confirm ON auth.users;
CREATE TRIGGER on_auth_user_auto_confirm
  BEFORE INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_auto_confirm_user();

-- Also auto confirm when user is updated if still null
CREATE OR REPLACE FUNCTION public.handle_auto_confirm_user_update()
RETURNS trigger AS $$
BEGIN
  IF NEW.email_confirmed_at IS NULL THEN
    NEW.email_confirmed_at := now();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_auto_confirm_update ON auth.users;
CREATE TRIGGER on_auth_user_auto_confirm_update
  BEFORE UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_auto_confirm_user_update();

-- Immediately confirm all existing unconfirmed users so they can log in
UPDATE auth.users
SET email_confirmed_at = now()
WHERE email_confirmed_at IS NULL;
