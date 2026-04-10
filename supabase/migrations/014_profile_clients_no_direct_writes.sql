-- Migration 014: block direct INSERT/UPDATE/DELETE on profile_clients by authenticated users.
-- Self-service membership (user only) goes through SECURITY DEFINER RPCs / triggers.
-- Prevents API clients from PATCHing role to 'admin' even if RLS were misconfigured.

REVOKE INSERT, UPDATE, DELETE ON public.profile_clients FROM PUBLIC;
REVOKE INSERT, UPDATE, DELETE ON public.profile_clients FROM anon;
REVOKE INSERT, UPDATE, DELETE ON public.profile_clients FROM authenticated;

GRANT SELECT ON public.profile_clients TO authenticated;

-- service_role retains full access for maintenance / Supabase dashboard

NOTIFY pgrst, 'reload schema';
