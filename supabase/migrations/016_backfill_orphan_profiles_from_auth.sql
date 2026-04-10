-- Repair rare cases: auth.users row exists but public.profiles / profile_clients missing (failed trigger, old data).
-- Safe to run multiple times (idempotent).

INSERT INTO public.profiles (id, email, nome, role, client)
SELECT
  u.id,
  COALESCE(u.email, ''),
  COALESCE(
    u.raw_user_meta_data->>'nome',
    u.raw_user_meta_data->>'full_name',
    split_part(COALESCE(u.email, 'user'), '@', 1)
  ),
  'user',
  'public'
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = u.id);

-- Mínimo: uma linha profile_clients por utilizador sem nenhuma (fallback 'public')
INSERT INTO public.profile_clients (user_id, client, role, status)
SELECT p.id, 'public', 'user', 'pending'
FROM public.profiles p
WHERE NOT EXISTS (SELECT 1 FROM public.profile_clients pc WHERE pc.user_id = p.id);

NOTIFY pgrst, 'reload schema';
