-- Migration 011: trigger reads portal client from signup metadata + admin user-listing RPC
--
-- When a user registers via a portal's register.html, the form passes
-- options.data.client = CLIENT_ID. This migration updates handle_new_user to
-- read that value so the profile_clients row is tagged with the correct portal
-- instead of the generic 'public' fallback.
--
-- Also adds listar_utilizadores_do_portal(), a SECURITY DEFINER RPC that joins
-- profile_clients with profiles to expose nome + email alongside membership data,
-- without granting cross-user reads on the profiles table directly.

-- 1. Update trigger: use client from signup metadata when available
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_client TEXT;
BEGIN
  -- Use client passed in signup metadata, fall back to 'public' for direct signups
  v_client := COALESCE(NULLIF(TRIM(NEW.raw_user_meta_data->>'client'), ''), 'public');

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
  VALUES (NEW.id, v_client, 'user')
  ON CONFLICT DO NOTHING;

  RETURN NEW;
END;
$$;

-- 2. Admin RPC: list all members of a portal with nome + email
--    Only callable by users who are admin in that portal (enforced inside function).
CREATE OR REPLACE FUNCTION public.listar_utilizadores_do_portal(p_client TEXT)
RETURNS TABLE (
  id         UUID,
  client     TEXT,
  role       TEXT,
  created_at TIMESTAMPTZ,
  email      TEXT,
  nome       TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Gate: caller must be admin in the requested portal
  IF NOT EXISTS (
    SELECT 1 FROM public.profile_clients
    WHERE user_id = auth.uid()
      AND client  = p_client
      AND role    = 'admin'
  ) THEN
    RAISE EXCEPTION 'Not authorised: admin access to % required.', p_client;
  END IF;

  RETURN QUERY
    SELECT
      pc.user_id  AS id,
      pc.client,
      pc.role,
      pc.created_at,
      p.email,
      p.nome
    FROM public.profile_clients pc
    JOIN public.profiles p ON p.id = pc.user_id
    ORDER BY pc.created_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.listar_utilizadores_do_portal(text) TO authenticated;

NOTIFY pgrst, 'reload schema';
