-- Multi-portal: profiles.client CHECK, profile_clients.status, garantir_adesao_portal,
-- listar_utilizadores_do_portal filter + status column, assign_client upsert, minha_adesao_portal status.

ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_client_check;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_client_check
  CHECK (client = ANY (ARRAY['luzdaalma'::text, 'easy2clean'::text, 'portocoaststays'::text, 'public'::text]));

ALTER TABLE public.profile_clients
  ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'pending'
  CHECK (status = ANY (ARRAY['pending'::text, 'active'::text]));

UPDATE public.profile_clients SET status = 'active';

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_client TEXT;
BEGIN
  v_client := COALESCE(
    NULLIF(TRIM(NEW.raw_user_meta_data->>'client'), ''),
    NULLIF(TRIM(NEW.raw_user_meta_data->>'portal_client'), ''),
    'public'
  );

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

  INSERT INTO public.profile_clients (user_id, client, role, status)
  VALUES (NEW.id, v_client, 'user', 'pending')
  ON CONFLICT (user_id, client) DO NOTHING;

  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.garantir_adesao_portal(p_client text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
BEGIN
  IF p_client IS NULL OR btrim(p_client) = '' THEN
    RAISE EXCEPTION 'p_client required';
  END IF;

  SET LOCAL row_security TO off;

  INSERT INTO public.profiles (id, email, nome, role, client)
  SELECT
    u.id,
    u.email,
    COALESCE(
      u.raw_user_meta_data->>'nome',
      u.raw_user_meta_data->>'full_name',
      split_part(u.email, '@', 1)
    ),
    'user',
    'public'
  FROM auth.users u
  WHERE u.id = auth.uid()
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.profile_clients (user_id, client, role, status)
  VALUES (auth.uid(), btrim(p_client), 'user', 'pending')
  ON CONFLICT (user_id, client) DO NOTHING;
END;
$function$;

GRANT EXECUTE ON FUNCTION public.garantir_adesao_portal(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.garantir_adesao_portal(text) TO service_role;

CREATE OR REPLACE FUNCTION public.portocoaststays_ensure_membership_on_login()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  PERFORM public.garantir_adesao_portal('portocoaststays');
END;
$function$;

DROP FUNCTION IF EXISTS public.listar_utilizadores_do_portal(text);

CREATE FUNCTION public.listar_utilizadores_do_portal(p_client text)
 RETURNS TABLE(id uuid, client text, role text, status text, created_at timestamp with time zone, email text, nome text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
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
      pc.status,
      pc.created_at,
      p.email,
      p.nome
    FROM public.profile_clients pc
    JOIN public.profiles p ON p.id = pc.user_id
    WHERE pc.client = p_client
    ORDER BY pc.created_at DESC;
END;
$function$;

GRANT EXECUTE ON FUNCTION public.listar_utilizadores_do_portal(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.listar_utilizadores_do_portal(text) TO service_role;

CREATE OR REPLACE FUNCTION public.portocoaststays_assign_client(target_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  IF NOT public.is_portocoaststays_admin() THEN
    RAISE EXCEPTION 'Not authorised.';
  END IF;
  INSERT INTO public.profile_clients (user_id, client, role, status)
  VALUES (target_id, 'portocoaststays', 'user', 'active')
  ON CONFLICT (user_id, client) DO UPDATE SET status = 'active';
END;
$function$;

DROP FUNCTION IF EXISTS public.minha_adesao_portal(text);

CREATE FUNCTION public.minha_adesao_portal(p_client text)
 RETURNS TABLE(client text, role text, status text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  RETURN QUERY
    SELECT pc.client, pc.role, pc.status
    FROM   public.profile_clients pc
    WHERE  pc.user_id = auth.uid()
      AND  pc.client  = p_client;
END;
$function$;

GRANT EXECUTE ON FUNCTION public.minha_adesao_portal(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.minha_adesao_portal(text) TO service_role;
