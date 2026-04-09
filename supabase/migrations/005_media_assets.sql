-- Migration 005: media_assets table with admin-only RLS

CREATE TABLE IF NOT EXISTS public.media_assets (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  client        TEXT        NOT NULL DEFAULT 'portocoaststays'
                            CHECK (client = 'portocoaststays'),
  post_id       UUID        REFERENCES public.posts(id) ON DELETE SET NULL,
  filename      TEXT        NOT NULL,
  storage_path  TEXT        NOT NULL UNIQUE,
  public_url    TEXT        NOT NULL,
  alt_text      TEXT        NOT NULL DEFAULT '',
  mime_type     TEXT        NOT NULL DEFAULT 'image/jpeg',
  file_size     BIGINT,
  uploaded_by   UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_media_assets_post_id ON public.media_assets (post_id);

ALTER TABLE public.media_assets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin reads media_assets"
  ON public.media_assets FOR SELECT TO authenticated
  USING (public.is_portocoaststays_admin());

CREATE POLICY "Admin inserts media_assets"
  ON public.media_assets FOR INSERT TO authenticated
  WITH CHECK (public.is_portocoaststays_admin());

CREATE POLICY "Admin updates media_assets"
  ON public.media_assets FOR UPDATE TO authenticated
  USING (public.is_portocoaststays_admin())
  WITH CHECK (public.is_portocoaststays_admin());

CREATE POLICY "Admin deletes media_assets"
  ON public.media_assets FOR DELETE TO authenticated
  USING (public.is_portocoaststays_admin());

NOTIFY pgrst, 'reload schema';
