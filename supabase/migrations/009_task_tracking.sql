-- Migration 009: property_task_status, owner_global_task_status, task_comments

-- ── [A] tasks: per property ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.property_task_status (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID        NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
  task_id     TEXT        NOT NULL,
  status      TEXT        NOT NULL DEFAULT 'pending'
              CHECK (status IN ('pending','in_progress','completed','blocked')),
  updated_by  UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (property_id, task_id)
);

CREATE INDEX IF NOT EXISTS idx_pts_property_id ON public.property_task_status (property_id);
CREATE INDEX IF NOT EXISTS idx_pts_task_id     ON public.property_task_status (task_id);
CREATE INDEX IF NOT EXISTS idx_pts_status      ON public.property_task_status (status);

ALTER TABLE public.property_task_status ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin manages property_task_status"
  ON public.property_task_status FOR ALL TO authenticated
  USING (public.is_portocoaststays_admin())
  WITH CHECK (public.is_portocoaststays_admin());

CREATE POLICY "Owner reads own property_task_status"
  ON public.property_task_status FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.properties p
      WHERE p.id = property_id AND p.owner_id = auth.uid()
    )
  );

CREATE POLICY "Owner updates own property_task_status"
  ON public.property_task_status FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.properties p
      WHERE p.id = property_id AND p.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.properties p
      WHERE p.id = property_id AND p.owner_id = auth.uid()
    )
  );

CREATE POLICY "Owner inserts own property_task_status"
  ON public.property_task_status FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.properties p
      WHERE p.id = property_id AND p.owner_id = auth.uid()
    )
  );

-- ── [G] tasks: per owner ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.owner_global_task_status (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id   UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  task_id    TEXT        NOT NULL,
  status     TEXT        NOT NULL DEFAULT 'pending'
             CHECK (status IN ('pending','in_progress','completed','blocked')),
  updated_by UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (owner_id, task_id)
);

CREATE INDEX IF NOT EXISTS idx_ogts_owner_id ON public.owner_global_task_status (owner_id);
CREATE INDEX IF NOT EXISTS idx_ogts_task_id  ON public.owner_global_task_status (task_id);

ALTER TABLE public.owner_global_task_status ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin manages owner_global_task_status"
  ON public.owner_global_task_status FOR ALL TO authenticated
  USING (public.is_portocoaststays_admin())
  WITH CHECK (public.is_portocoaststays_admin());

CREATE POLICY "Owner reads own global_task_status"
  ON public.owner_global_task_status FOR SELECT TO authenticated
  USING (owner_id = auth.uid());

CREATE POLICY "Owner writes own global_task_status"
  ON public.owner_global_task_status FOR INSERT TO authenticated
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Owner updates own global_task_status"
  ON public.owner_global_task_status FOR UPDATE TO authenticated
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

-- ── Task comments ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.task_comments (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  client      TEXT        NOT NULL DEFAULT 'portocoaststays',
  property_id UUID        REFERENCES public.properties(id) ON DELETE CASCADE,
  owner_id    UUID        REFERENCES public.profiles(id) ON DELETE SET NULL,
  task_id     TEXT        NOT NULL,
  author_id   UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  author_role TEXT        NOT NULL DEFAULT 'user'
              CHECK (author_role IN ('admin','user')),
  is_internal BOOLEAN     NOT NULL DEFAULT false,
  content     TEXT        NOT NULL DEFAULT '',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tc_property_id ON public.task_comments (property_id);
CREATE INDEX IF NOT EXISTS idx_tc_owner_id    ON public.task_comments (owner_id);
CREATE INDEX IF NOT EXISTS idx_tc_task_id     ON public.task_comments (task_id);

ALTER TABLE public.task_comments ENABLE ROW LEVEL SECURITY;

-- Admin sees all
CREATE POLICY "Admin manages task_comments"
  ON public.task_comments FOR ALL TO authenticated
  USING (public.is_portocoaststays_admin())
  WITH CHECK (public.is_portocoaststays_admin());

-- Owner reads non-internal comments on own properties
CREATE POLICY "Owner reads property task_comments"
  ON public.task_comments FOR SELECT TO authenticated
  USING (
    is_internal = false
    AND (
      (property_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_id AND p.owner_id = auth.uid()
      ))
      OR (owner_id = auth.uid())
    )
  );

-- Owner writes non-internal comments on own properties
CREATE POLICY "Owner inserts task_comments"
  ON public.task_comments FOR INSERT TO authenticated
  WITH CHECK (
    is_internal = false
    AND author_id = auth.uid()
    AND (
      (property_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_id AND p.owner_id = auth.uid()
      ))
      OR (owner_id = auth.uid())
    )
  );

NOTIFY pgrst, 'reload schema';
