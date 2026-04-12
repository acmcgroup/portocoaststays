-- Migration 027: Fix infinite recursion in RLS policies introduced by 026.
--
-- Root cause: the inline EXISTS(SELECT 1 FROM profile_clients ...) subqueries
-- in 026's USING/WITH CHECK clauses run with row security still ON for
-- profile_clients. That table's own "Portal admins manage their portal" policy
-- also queries profile_clients, causing infinite recursion.
--
-- Fix: introduce a single SECURITY DEFINER helper that bypasses row security
-- when checking the caller's role, and rewrite all affected policies to use it.

-- ── 1. Generic role-check helper (SECURITY DEFINER + row_security OFF) ────────

CREATE OR REPLACE FUNCTION public.portal_role_check(p_client text, p_roles text[])
RETURNS boolean
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  SET LOCAL row_security TO off;
  RETURN EXISTS (
    SELECT 1 FROM public.profile_clients
    WHERE user_id = auth.uid()
      AND client  = p_client
      AND role    = ANY(p_roles)
      AND status  = 'active'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.portal_role_check(text, text[]) TO authenticated;

-- ── 2. posts — drop inline policy, replace with helper ───────────────────────

DROP POLICY IF EXISTS "Portal admin CRUD posts" ON public.posts;

CREATE POLICY "Portal admin CRUD posts"
  ON public.posts FOR ALL TO authenticated
  USING     (public.portal_role_check(posts.client, ARRAY['admin']))
  WITH CHECK (public.portal_role_check(posts.client, ARRAY['admin']));

-- ── 3. properties — drop inline policy, replace with helper ──────────────────

DROP POLICY IF EXISTS "Portal staff CRUD properties" ON public.properties;

CREATE POLICY "Portal staff CRUD properties"
  ON public.properties FOR ALL TO authenticated
  USING     (public.portal_role_check(properties.client, ARRAY['admin','seller']))
  WITH CHECK (public.portal_role_check(properties.client, ARRAY['admin','seller']));

-- ── 4. media_assets ───────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Portal staff CRUD media_assets" ON public.media_assets;

CREATE POLICY "Portal staff CRUD media_assets"
  ON public.media_assets FOR ALL TO authenticated
  USING     (public.portal_role_check(media_assets.client, ARRAY['admin','seller']))
  WITH CHECK (public.portal_role_check(media_assets.client, ARRAY['admin','seller']));

-- ── 5. task_templates ─────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Portal staff reads task_templates"    ON public.task_templates;
DROP POLICY IF EXISTS "Portal admin manages task_templates"  ON public.task_templates;

CREATE POLICY "Portal staff reads task_templates"
  ON public.task_templates FOR SELECT TO authenticated
  USING (public.portal_role_check(task_templates.client, ARRAY['admin','seller']));

CREATE POLICY "Portal admin manages task_templates"
  ON public.task_templates FOR ALL TO authenticated
  USING     (public.portal_role_check(task_templates.client, ARRAY['admin']))
  WITH CHECK (public.portal_role_check(task_templates.client, ARRAY['admin']));

-- ── 6. property_task_status ───────────────────────────────────────────────────
-- Admin: reuse is_portocoaststays_admin() (already SECURITY DEFINER + row_security OFF).
-- Seller: check property ownership directly (no profile_clients join needed here;
--         role is verified separately via portal_role_check).

DROP POLICY IF EXISTS "Portal admin CRUD property_task_status"      ON public.property_task_status;
DROP POLICY IF EXISTS "Portal seller CRUD own property_task_status" ON public.property_task_status;

CREATE POLICY "Portal admin CRUD property_task_status"
  ON public.property_task_status FOR ALL TO authenticated
  USING     (public.is_portocoaststays_admin())
  WITH CHECK (public.is_portocoaststays_admin());

CREATE POLICY "Portal seller CRUD own property_task_status"
  ON public.property_task_status FOR ALL TO authenticated
  USING (
    public.portal_role_check('portocoaststays', ARRAY['seller'])
    AND EXISTS (
      SELECT 1 FROM public.properties p
      WHERE p.id       = property_task_status.property_id
        AND p.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    public.portal_role_check('portocoaststays', ARRAY['seller'])
    AND EXISTS (
      SELECT 1 FROM public.properties p
      WHERE p.id       = property_task_status.property_id
        AND p.owner_id = auth.uid()
    )
  );

-- ── 7. owner_global_task_status ───────────────────────────────────────────────

DROP POLICY IF EXISTS "Portal seller CRUD own global_task_status" ON public.owner_global_task_status;

CREATE POLICY "Portal seller CRUD own global_task_status"
  ON public.owner_global_task_status FOR ALL TO authenticated
  USING (
    owner_id = auth.uid()
    AND public.portal_role_check('portocoaststays', ARRAY['seller'])
  )
  WITH CHECK (
    owner_id = auth.uid()
    AND public.portal_role_check('portocoaststays', ARRAY['seller'])
  );

-- ── 8. task_comments ──────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Portal seller CRUD non-internal task_comments" ON public.task_comments;

CREATE POLICY "Portal seller CRUD non-internal task_comments"
  ON public.task_comments FOR ALL TO authenticated
  USING (
    is_internal = false
    AND public.portal_role_check('portocoaststays', ARRAY['seller'])
    AND (
      (
        property_id IS NOT NULL
        AND EXISTS (
          SELECT 1 FROM public.properties p
          WHERE p.id = property_id AND p.owner_id = auth.uid()
        )
      )
      OR owner_id = auth.uid()
    )
  )
  WITH CHECK (
    is_internal = false
    AND author_id = auth.uid()
    AND public.portal_role_check('portocoaststays', ARRAY['seller'])
    AND (
      (
        property_id IS NOT NULL
        AND EXISTS (
          SELECT 1 FROM public.properties p
          WHERE p.id = property_id AND p.owner_id = auth.uid()
        )
      )
      OR owner_id = auth.uid()
    )
  );

NOTIFY pgrst, 'reload schema';
