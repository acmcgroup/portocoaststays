-- Migration 006: public storage bucket portocoaststays-media + RLS policies
-- Run in Supabase SQL Editor.
-- If INSERT fails on buckets, create via UI (Storage → New bucket → name: portocoaststays-media → public: true)
-- then run only the CREATE POLICY lines.

INSERT INTO storage.buckets (id, name, public)
VALUES ('portocoaststays-media', 'portocoaststays-media', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "Public read portocoaststays-media"   ON storage.objects;
DROP POLICY IF EXISTS "Admin upload portocoaststays-media"  ON storage.objects;
DROP POLICY IF EXISTS "Admin update portocoaststays-media"  ON storage.objects;
DROP POLICY IF EXISTS "Admin delete portocoaststays-media"  ON storage.objects;

CREATE POLICY "Public read portocoaststays-media"
  ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'portocoaststays-media');

CREATE POLICY "Admin upload portocoaststays-media"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'portocoaststays-media' AND public.is_portocoaststays_admin());

CREATE POLICY "Admin update portocoaststays-media"
  ON storage.objects FOR UPDATE TO authenticated
  USING  (bucket_id = 'portocoaststays-media' AND public.is_portocoaststays_admin())
  WITH CHECK (bucket_id = 'portocoaststays-media' AND public.is_portocoaststays_admin());

CREATE POLICY "Admin delete portocoaststays-media"
  ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'portocoaststays-media' AND public.is_portocoaststays_admin());
