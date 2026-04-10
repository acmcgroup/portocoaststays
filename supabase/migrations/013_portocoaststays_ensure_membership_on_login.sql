-- Migration 013: after login from this portal, ensure profile_clients has a row for portocoaststays (role user).
-- Lets users who already exist in another client's portal get membership here without a second signup.

CREATE OR REPLACE FUNCTION public.portocoaststays_ensure_membership_on_login()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  SET LOCAL row_security TO off;
  INSERT INTO public.profile_clients (user_id, client, role)
  VALUES (auth.uid(), 'portocoaststays', 'user')
  ON CONFLICT (user_id, client) DO NOTHING;
END;
$$;

GRANT EXECUTE ON FUNCTION public.portocoaststays_ensure_membership_on_login() TO authenticated;

NOTIFY pgrst, 'reload schema';
