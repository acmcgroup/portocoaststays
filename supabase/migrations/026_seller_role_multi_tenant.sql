-- Migration 026: seller role + multi-tenant RLS
-- Adds 'seller' role, widens client CHECK constraints, replaces all hardcoded
-- single-client RLS policies with per-row dynamic checks, and fixes existing
-- security gaps (role-less Owner policies, missing status check in is_portocoaststays_admin).

-- ── 1. Widen client CHECK constraints ────────────────────────────────────────
-- RLS (below) becomes the enforcement layer; no hardcoded client in constraints.

ALTER TABLE public.posts        DROP CONSTRAINT IF EXISTS posts_client_check;
ALTER TABLE public.properties   DROP CONSTRAINT IF EXISTS properties_client_check;
ALTER TABLE public.media_assets DROP CONSTRAINT IF EXISTS media_assets_client_check;

-- ── 2. Add 'seller' to profile_clients role enum ─────────────────────────────

ALTER TABLE public.profile_clients
  DROP CONSTRAINT IF EXISTS profile_clients_role_check;
ALTER TABLE public.profile_clients
  ADD  CONSTRAINT profile_clients_role_check
       CHECK (role IN ('user','seller','admin'));

-- ── 3. Fix task_comments.author_role CHECK — add 'seller' ────────────────────

ALTER TABLE public.task_comments
  DROP CONSTRAINT IF EXISTS task_comments_author_role_check;
ALTER TABLE public.task_comments
  ADD  CONSTRAINT task_comments_author_role_check
       CHECK (author_role IN ('admin','seller','user'));

-- ── 4. Fix is_portocoaststays_admin() — add status = 'active' check ──────────
-- Previously only checked role = 'admin', allowing pending/suspended admins through.

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
    WHERE user_id = auth.uid()
      AND client  = 'portocoaststays'
      AND role    = 'admin'
      AND status  = 'active'
  );
END;
$$;

-- ── 5. posts — admin only ────────────────────────────────────────────────────
-- Drop old hardcoded policies; new policy uses the row's own client column.

DROP POLICY IF EXISTS "Admin reads all posts" ON public.posts;
DROP POLICY IF EXISTS "Admin inserts posts"   ON public.posts;
DROP POLICY IF EXISTS "Admin updates posts"   ON public.posts;
DROP POLICY IF EXISTS "Admin deletes posts"   ON public.posts;

CREATE POLICY "Portal admin CRUD posts"
  ON public.posts FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profile_clients
      WHERE user_id = auth.uid()
        AND client  = posts.client
        AND role    = 'admin'
        AND status  = 'active'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profile_clients
      WHERE user_id = auth.uid()
        AND client  = posts.client
        AND role    = 'admin'
        AND status  = 'active'
    )
  );

-- "Public reads published posts" is intentionally left unchanged.

-- ── 6. properties — admin or seller; drop role-less Owner policies ───────────
-- "Owner inserts own properties" was a real gap: any authenticated user could
-- create a property. All Owner policies are replaced with role-checked ones.

DROP POLICY IF EXISTS "Admin reads all properties"   ON public.properties;
DROP POLICY IF EXISTS "Admin inserts properties"     ON public.properties;
DROP POLICY IF EXISTS "Admin updates properties"     ON public.properties;
DROP POLICY IF EXISTS "Admin deletes properties"     ON public.properties;
DROP POLICY IF EXISTS "Owner reads own properties"   ON public.properties;
DROP POLICY IF EXISTS "Owner inserts own properties" ON public.properties;
DROP POLICY IF EXISTS "Owner updates own properties" ON public.properties;

CREATE POLICY "Portal staff CRUD properties"
  ON public.properties FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profile_clients
      WHERE user_id = auth.uid()
        AND client  = properties.client
        AND role    IN ('admin','seller')
        AND status  = 'active'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profile_clients
      WHERE user_id = auth.uid()
        AND client  = properties.client
        AND role    IN ('admin','seller')
        AND status  = 'active'
    )
  );

-- ── 7. media_assets — admin or seller ────────────────────────────────────────

DROP POLICY IF EXISTS "Admin reads media_assets"   ON public.media_assets;
DROP POLICY IF EXISTS "Admin inserts media_assets" ON public.media_assets;
DROP POLICY IF EXISTS "Admin updates media_assets" ON public.media_assets;
DROP POLICY IF EXISTS "Admin deletes media_assets" ON public.media_assets;

CREATE POLICY "Portal staff CRUD media_assets"
  ON public.media_assets FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profile_clients
      WHERE user_id = auth.uid()
        AND client  = media_assets.client
        AND role    IN ('admin','seller')
        AND status  = 'active'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profile_clients
      WHERE user_id = auth.uid()
        AND client  = media_assets.client
        AND role    IN ('admin','seller')
        AND status  = 'active'
    )
  );

-- ── 8. task_templates — admin CRUD, seller SELECT (scoped to client) ─────────

DROP POLICY IF EXISTS "Authenticated reads task_templates" ON public.task_templates;
DROP POLICY IF EXISTS "Admin manages task_templates"       ON public.task_templates;

CREATE POLICY "Portal staff reads task_templates"
  ON public.task_templates FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profile_clients
      WHERE user_id = auth.uid()
        AND client  = task_templates.client
        AND role    IN ('admin','seller')
        AND status  = 'active'
    )
  );

CREATE POLICY "Portal admin manages task_templates"
  ON public.task_templates FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profile_clients
      WHERE user_id = auth.uid()
        AND client  = task_templates.client
        AND role    = 'admin'
        AND status  = 'active'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profile_clients
      WHERE user_id = auth.uid()
        AND client  = task_templates.client
        AND role    = 'admin'
        AND status  = 'active'
    )
  );

-- ── 9. property_task_status — admin all, seller own properties ────────────────
-- Old Owner policies had no role check. New ones join profile_clients.

DROP POLICY IF EXISTS "Admin manages property_task_status"     ON public.property_task_status;
DROP POLICY IF EXISTS "Owner reads own property_task_status"   ON public.property_task_status;
DROP POLICY IF EXISTS "Owner updates own property_task_status" ON public.property_task_status;
DROP POLICY IF EXISTS "Owner inserts own property_task_status" ON public.property_task_status;

CREATE POLICY "Portal admin CRUD property_task_status"
  ON public.property_task_status FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.properties p
      JOIN public.profile_clients pc ON pc.user_id = auth.uid()
      WHERE p.id     = property_task_status.property_id
        AND pc.client = p.client
        AND pc.role   = 'admin'
        AND pc.status = 'active'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.properties p
      JOIN public.profile_clients pc ON pc.user_id = auth.uid()
      WHERE p.id     = property_task_status.property_id
        AND pc.client = p.client
        AND pc.role   = 'admin'
        AND pc.status = 'active'
    )
  );

CREATE POLICY "Portal seller CRUD own property_task_status"
  ON public.property_task_status FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.properties p
      JOIN public.profile_clients pc ON pc.user_id = auth.uid()
      WHERE p.id        = property_task_status.property_id
        AND p.owner_id  = auth.uid()
        AND pc.client   = p.client
        AND pc.role     = 'seller'
        AND pc.status   = 'active'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.properties p
      JOIN public.profile_clients pc ON pc.user_id = auth.uid()
      WHERE p.id        = property_task_status.property_id
        AND p.owner_id  = auth.uid()
        AND pc.client   = p.client
        AND pc.role     = 'seller'
        AND pc.status   = 'active'
    )
  );

-- ── 10. owner_global_task_status — admin all, seller own ─────────────────────

DROP POLICY IF EXISTS "Admin manages owner_global_task_status" ON public.owner_global_task_status;
DROP POLICY IF EXISTS "Owner reads own global_task_status"     ON public.owner_global_task_status;
DROP POLICY IF EXISTS "Owner writes own global_task_status"    ON public.owner_global_task_status;
DROP POLICY IF EXISTS "Owner updates own global_task_status"   ON public.owner_global_task_status;

CREATE POLICY "Portal admin CRUD owner_global_task_status"
  ON public.owner_global_task_status FOR ALL TO authenticated
  USING (public.is_portocoaststays_admin())
  WITH CHECK (public.is_portocoaststays_admin());

CREATE POLICY "Portal seller CRUD own global_task_status"
  ON public.owner_global_task_status FOR ALL TO authenticated
  USING (
    owner_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profile_clients
      WHERE user_id = auth.uid()
        AND role    = 'seller'
        AND status  = 'active'
    )
  )
  WITH CHECK (
    owner_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profile_clients
      WHERE user_id = auth.uid()
        AND role    = 'seller'
        AND status  = 'active'
    )
  );

-- ── 11. task_comments — admin all (incl. internal), seller non-internal ───────

DROP POLICY IF EXISTS "Admin manages task_comments"        ON public.task_comments;
DROP POLICY IF EXISTS "Owner reads property task_comments" ON public.task_comments;
DROP POLICY IF EXISTS "Owner inserts task_comments"        ON public.task_comments;

CREATE POLICY "Portal admin CRUD task_comments"
  ON public.task_comments FOR ALL TO authenticated
  USING (public.is_portocoaststays_admin())
  WITH CHECK (public.is_portocoaststays_admin());

CREATE POLICY "Portal seller CRUD non-internal task_comments"
  ON public.task_comments FOR ALL TO authenticated
  USING (
    is_internal = false
    AND EXISTS (
      SELECT 1 FROM public.profile_clients pc
      WHERE pc.user_id = auth.uid()
        AND pc.role    = 'seller'
        AND pc.status  = 'active'
    )
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
    AND EXISTS (
      SELECT 1 FROM public.profile_clients pc
      WHERE pc.user_id = auth.uid()
        AND pc.role    = 'seller'
        AND pc.status  = 'active'
    )
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

-- ── 12. Seller role management RPCs ──────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.portocoaststays_promover_seller(target_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.is_portocoaststays_admin() THEN
    RAISE EXCEPTION 'Not authorised: only portocoaststays admins can promote sellers.';
  END IF;
  UPDATE public.profile_clients
  SET    role = 'seller'
  WHERE  user_id = target_id AND client = 'portocoaststays';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found or not assigned to portocoaststays.';
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.portocoaststays_promover_seller(uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.portocoaststays_revogar_seller(target_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.is_portocoaststays_admin() THEN
    RAISE EXCEPTION 'Not authorised.';
  END IF;
  UPDATE public.profile_clients
  SET    role = 'user'
  WHERE  user_id = target_id AND client = 'portocoaststays';
END;
$$;

GRANT EXECUTE ON FUNCTION public.portocoaststays_revogar_seller(uuid) TO authenticated;

NOTIFY pgrst, 'reload schema';
