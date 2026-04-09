-- Migration 004: posts table with full RLS

CREATE TABLE IF NOT EXISTS public.posts (
  id                              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  client                          TEXT        NOT NULL DEFAULT 'portocoaststays'
                                              CHECK (client = 'portocoaststays'),
  status                          TEXT        NOT NULL DEFAULT 'draft'
                                              CHECK (status IN ('draft','published','archived')),
  created_at                      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  published_at                    TIMESTAMPTZ,
  slug_pt                         TEXT        NOT NULL DEFAULT '',
  category_pt                     TEXT        NOT NULL DEFAULT '',
  slug_en                         TEXT        NOT NULL DEFAULT '',
  category_en                     TEXT        NOT NULL DEFAULT '',
  featured_image_url              TEXT,
  featured_image_alt              TEXT,
  featured_image_position         TEXT        NOT NULL DEFAULT '50% 50%',
  featured_image_overlay_color    TEXT        NOT NULL DEFAULT '#001D2E',
  featured_image_overlay_opacity  INTEGER     NOT NULL DEFAULT 60
                                  CONSTRAINT featured_image_overlay_opacity_range
                                    CHECK (featured_image_overlay_opacity >= 0 AND featured_image_overlay_opacity <= 100),
  author_name                     TEXT        NOT NULL DEFAULT 'Porto Coast Stays',
  post_kind                       TEXT        NOT NULL DEFAULT 'article'
                                  CONSTRAINT posts_post_kind_check
                                    CHECK (post_kind IN ('article','report','case_study')),
  pt_title                        TEXT        NOT NULL DEFAULT '',
  pt_description                  TEXT        NOT NULL DEFAULT '',
  pt_related_service              TEXT        NOT NULL DEFAULT '/',
  pt_content_html                 TEXT        NOT NULL DEFAULT '',
  en_title                        TEXT        NOT NULL DEFAULT '',
  en_description                  TEXT        NOT NULL DEFAULT '',
  en_related_service              TEXT        NOT NULL DEFAULT '/',
  en_content_html                 TEXT        NOT NULL DEFAULT ''
);

CREATE UNIQUE INDEX IF NOT EXISTS posts_slug_pt_unique ON public.posts (slug_pt) WHERE slug_pt <> '';
CREATE UNIQUE INDEX IF NOT EXISTS posts_slug_en_unique ON public.posts (slug_en) WHERE slug_en <> '';

CREATE TRIGGER trg_posts_updated_at
  BEFORE UPDATE ON public.posts
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public reads published posts"
  ON public.posts FOR SELECT TO anon, authenticated
  USING (status = 'published' AND client = 'portocoaststays');

CREATE POLICY "Admin reads all posts"
  ON public.posts FOR SELECT TO authenticated
  USING (public.is_portocoaststays_admin());

CREATE POLICY "Admin inserts posts"
  ON public.posts FOR INSERT TO authenticated
  WITH CHECK (public.is_portocoaststays_admin());

CREATE POLICY "Admin updates posts"
  ON public.posts FOR UPDATE TO authenticated
  USING (public.is_portocoaststays_admin())
  WITH CHECK (public.is_portocoaststays_admin());

CREATE POLICY "Admin deletes posts"
  ON public.posts FOR DELETE TO authenticated
  USING (public.is_portocoaststays_admin());

CREATE INDEX IF NOT EXISTS idx_posts_client       ON public.posts (client);
CREATE INDEX IF NOT EXISTS idx_posts_status       ON public.posts (status);
CREATE INDEX IF NOT EXISTS idx_posts_published_at ON public.posts (published_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_post_kind    ON public.posts (post_kind);

NOTIFY pgrst, 'reload schema';
