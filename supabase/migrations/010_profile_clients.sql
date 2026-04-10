-- Migration 010: profile_clients join table for multi-portal membership
-- Allows one user (same email/UUID) to belong to multiple portals with independent roles.
-- profiles table is untouched; all client/role access logic moves here.

-- 1. New join table
CREATE TABLE IF NOT EXISTS public.profile_clients (
  user_id    UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  client     TEXT        NOT NULL,
  role       TEXT        NOT NULL DEFAULT 'user' CHECK (role IN ('user','admin')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, client)
);

ALTER TABLE public.profile_clients ENABLE ROW LEVEL SECURITY;

-- Users read their own memberships
CREATE POLICY "Users read own memberships"
  ON public.profile_clients FOR SELECT TO authenticated
  USING (user_id = auth.uid());

-- Portal admins read/write memberships for portals where they are admin
CREATE POLICY "Portal admins manage their portal"
  ON public.profile_clients FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profile_clients pc
      WHERE pc.user_id = auth.uid()
        AND pc.client  = profile_clients.client
        AND pc.role    = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profile_clients pc
      WHERE pc.user_id = auth.uid()
        AND pc.client  = profile_clients.client
        AND pc.role    = 'admin'
    )
  );

-- 2. Backfill: copy existing client+role from profiles where client != 'public'
INSERT INTO public.profile_clients (user_id, client, role)
SELECT id, client, role
FROM   public.profiles
WHERE  client IS NOT NULL AND client <> 'public'
ON CONFLICT DO NOTHING;

-- Also ensure every user has at least a 'public' membership row
INSERT INTO public.profile_clients (user_id, client, role)
SELECT id, 'public', 'user'
FROM   public.profiles
ON CONFLICT DO NOTHING;

-- 3. Update trigger: on new signup, also insert 'public' membership
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, nome, role, client)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data->>'nome',
      NEW.raw_user_meta_data->>'full_name',
      split_part(NEW.email, '@', 1)
    ),
    'user',
    'public'
  )
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.profile_clients (user_id, client, role)
  VALUES (NEW.id, 'public', 'user')
  ON CONFLICT DO NOTHING;

  RETURN NEW;
END;
$$;

-- 4. Generic RPC: returns {client, role} for the current user in a given portal, or empty
CREATE OR REPLACE FUNCTION public.minha_adesao_portal(p_client TEXT)
RETURNS TABLE(client TEXT, role TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
    SELECT pc.client, pc.role
    FROM   public.profile_clients pc
    WHERE  pc.user_id = auth.uid()
      AND  pc.client  = p_client;
END;
$$;

GRANT EXECUTE ON FUNCTION public.minha_adesao_portal(text) TO authenticated;

-- 5. Rewrite portocoaststays admin RPCs to use profile_clients

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
    SELECT 1 FROM public.profile_clients
    WHERE  user_id = auth.uid()
      AND  client  = 'portocoaststays'
      AND  role    = 'admin'
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
  UPDATE public.profile_clients
  SET    role = 'admin'
  WHERE  user_id = target_id AND client = 'portocoaststays';
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
  UPDATE public.profile_clients
  SET    role = 'user'
  WHERE  user_id = target_id AND client = 'portocoaststays';
END;
$$;

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
  INSERT INTO public.profile_clients (user_id, client, role)
  VALUES (target_id, 'portocoaststays', 'user')
  ON CONFLICT (user_id, client) DO NOTHING;
END;
$$;

NOTIFY pgrst, 'reload schema';
