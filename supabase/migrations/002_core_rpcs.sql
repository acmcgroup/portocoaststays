-- Migration 002: Core RPCs

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.obter_meu_role()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role TEXT;
BEGIN
  SELECT role INTO v_role FROM public.profiles WHERE id = auth.uid();
  RETURN COALESCE(v_role, 'user');
END;
$$;

CREATE OR REPLACE FUNCTION public.obter_meu_client()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_client TEXT;
BEGIN
  SELECT client INTO v_client FROM public.profiles WHERE id = auth.uid();
  RETURN COALESCE(v_client, 'public');
END;
$$;

GRANT EXECUTE ON FUNCTION public.obter_meu_role()   TO authenticated;
GRANT EXECUTE ON FUNCTION public.obter_meu_client() TO authenticated;
