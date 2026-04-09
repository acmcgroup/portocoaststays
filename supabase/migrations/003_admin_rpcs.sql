-- Migration 003: Tenant-scoped admin RPCs for portocoaststays

CREATE OR REPLACE FUNCTION public.is_portocoaststays_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
VOLATILE
SET search_path = public
AS $$
BEGIN
  SET LOCAL row_security TO off;
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
      AND role = 'admin'
      AND client = 'portocoaststays'
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.portocoaststays_promover_admin(target_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.is_portocoaststays_admin() THEN
    RAISE EXCEPTION 'Not authorised: only portocoaststays admins can promote users.';
  END IF;
  UPDATE public.profiles
  SET role = 'admin', client = 'portocoaststays', updated_at = NOW()
  WHERE id = target_id AND client = 'portocoaststays';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found or not assigned to portocoaststays.';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.portocoaststays_revogar_admin(target_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.is_portocoaststays_admin() THEN
    RAISE EXCEPTION 'Not authorised.';
  END IF;
  IF target_id = auth.uid() THEN
    RAISE EXCEPTION 'You cannot revoke your own admin access.';
  END IF;
  UPDATE public.profiles
  SET role = 'user', updated_at = NOW()
  WHERE id = target_id AND client = 'portocoaststays';
END;
$$;

-- Assign a user to this client (admin action after self-registration)
CREATE OR REPLACE FUNCTION public.portocoaststays_assign_client(target_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.is_portocoaststays_admin() THEN
    RAISE EXCEPTION 'Not authorised.';
  END IF;
  UPDATE public.profiles
  SET client = 'portocoaststays', updated_at = NOW()
  WHERE id = target_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.is_portocoaststays_admin()               TO authenticated;
GRANT EXECUTE ON FUNCTION public.portocoaststays_promover_admin(uuid)     TO authenticated;
GRANT EXECUTE ON FUNCTION public.portocoaststays_revogar_admin(uuid)      TO authenticated;
GRANT EXECUTE ON FUNCTION public.portocoaststays_assign_client(uuid)      TO authenticated;

NOTIFY pgrst, 'reload schema';
