-- Fix: RETURNS TABLE declares output vars named 'client' and 'role' which shadow
-- profile_clients column names inside plpgsql, causing "column reference is ambiguous".
-- Solution: use explicit table alias on every column in the admin-check subquery.

CREATE OR REPLACE FUNCTION public.listar_utilizadores_do_portal(p_client text)
RETURNS TABLE(
  id         uuid,
  client     text,
  role       text,
  status     text,
  created_at timestamptz,
  email      text,
  nome       text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.profile_clients _chk
    WHERE _chk.user_id = auth.uid()
      AND _chk.client  = p_client
      AND _chk.role    = 'admin'
  ) THEN
    RAISE EXCEPTION 'Not authorised: admin access to % required.', p_client;
  END IF;

  RETURN QUERY
    SELECT
      pc.user_id    AS id,
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

NOTIFY pgrst, 'reload schema';
