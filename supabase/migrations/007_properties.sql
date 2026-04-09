-- Migration 007: properties table with RLS

CREATE TABLE IF NOT EXISTS public.properties (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  client        TEXT        NOT NULL DEFAULT 'portocoaststays'
                            CHECK (client = 'portocoaststays'),
  owner_id      UUID        REFERENCES public.profiles(id) ON DELETE SET NULL,
  name          TEXT        NOT NULL DEFAULT '',
  typology      TEXT        NOT NULL DEFAULT 'apartamento'
                            CHECK (typology IN ('apartamento','moradia','quarto','outro')),
  address       TEXT        NOT NULL DEFAULT '',
  city          TEXT        NOT NULL DEFAULT '',
  postal_code   TEXT        NOT NULL DEFAULT '',
  municipality  TEXT        NOT NULL DEFAULT '',
  rnal_number   TEXT,
  nif_titular   TEXT,
  status        TEXT        NOT NULL DEFAULT 'setup'
                            CHECK (status IN ('setup','active','suspended','closed')),
  notes         TEXT        NOT NULL DEFAULT '',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_properties_updated_at
  BEFORE UPDATE ON public.properties
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;

-- Admin sees all properties for this client
CREATE POLICY "Admin reads all properties"
  ON public.properties FOR SELECT TO authenticated
  USING (public.is_portocoaststays_admin() AND client = 'portocoaststays');

CREATE POLICY "Admin inserts properties"
  ON public.properties FOR INSERT TO authenticated
  WITH CHECK (public.is_portocoaststays_admin());

CREATE POLICY "Admin updates properties"
  ON public.properties FOR UPDATE TO authenticated
  USING (public.is_portocoaststays_admin())
  WITH CHECK (public.is_portocoaststays_admin());

CREATE POLICY "Admin deletes properties"
  ON public.properties FOR DELETE TO authenticated
  USING (public.is_portocoaststays_admin());

-- Owner sees and edits own properties
CREATE POLICY "Owner reads own properties"
  ON public.properties FOR SELECT TO authenticated
  USING (owner_id = auth.uid());

CREATE POLICY "Owner inserts own properties"
  ON public.properties FOR INSERT TO authenticated
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Owner updates own properties"
  ON public.properties FOR UPDATE TO authenticated
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

CREATE INDEX IF NOT EXISTS idx_properties_client   ON public.properties (client);
CREATE INDEX IF NOT EXISTS idx_properties_owner_id ON public.properties (owner_id);
CREATE INDEX IF NOT EXISTS idx_properties_status   ON public.properties (status);

NOTIFY pgrst, 'reload schema';
