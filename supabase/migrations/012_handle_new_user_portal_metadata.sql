-- Migration 012: read portal tag from multiple user_metadata keys + explicit ON CONFLICT
-- Supabase signUp options.data may expose keys as client / portal_client; accept both.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
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

  INSERT INTO public.profile_clients (user_id, client, role)
  VALUES (NEW.id, v_client, 'user')
  ON CONFLICT (user_id, client) DO NOTHING;

  RETURN NEW;
END;
$$;

NOTIFY pgrst, 'reload schema';
