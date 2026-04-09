-- Migration 008: task_templates table

CREATE TABLE IF NOT EXISTS public.task_templates (
  id           TEXT        PRIMARY KEY,
  client       TEXT        NOT NULL DEFAULT 'portocoaststays',
  section_num  INTEGER     NOT NULL DEFAULT 0,
  section_name TEXT        NOT NULL DEFAULT '',
  description  TEXT        NOT NULL DEFAULT '',
  criticidade  TEXT        NOT NULL DEFAULT 'urgente'
               CHECK (criticidade IN ('bloqueante','urgente','importante','otimizacao')),
  ambito       TEXT        NOT NULL DEFAULT 'A'
               CHECK (ambito IN ('G','A')),
  resp         TEXT        NOT NULL DEFAULT 'G',
  notes        TEXT        NOT NULL DEFAULT '',
  sort_order   INTEGER     NOT NULL DEFAULT 0
);

ALTER TABLE public.task_templates ENABLE ROW LEVEL SECURITY;

-- Everyone authenticated can read templates
CREATE POLICY "Authenticated reads task_templates"
  ON public.task_templates FOR SELECT TO authenticated
  USING (true);

-- Only admin can modify
CREATE POLICY "Admin manages task_templates"
  ON public.task_templates FOR ALL TO authenticated
  USING (public.is_portocoaststays_admin())
  WITH CHECK (public.is_portocoaststays_admin());

NOTIFY pgrst, 'reload schema';
