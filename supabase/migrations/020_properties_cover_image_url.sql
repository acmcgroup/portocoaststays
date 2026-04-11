-- Imagem de capa por imóvel (URL pública ou caminho sob o site estático, ex. /assets/...)

ALTER TABLE public.properties
  ADD COLUMN IF NOT EXISTS cover_image_url text;

COMMENT ON COLUMN public.properties.cover_image_url IS 'URL ou caminho público da foto de capa (ex. /assets/images/properties/t1-matosinhos.jpeg)';

-- Liga fotos conhecidas quando os nomes coincidem (seed / dados existentes)
UPDATE public.properties
SET cover_image_url = '/assets/images/properties/t1-matosinhos.jpeg'
WHERE client = 'portocoaststays' AND name = 'T1 Matosinhos'
  AND (cover_image_url IS NULL OR cover_image_url = '');

UPDATE public.properties
SET cover_image_url = '/assets/images/properties/t0-boa-morte.jpeg'
WHERE client = 'portocoaststays' AND name = 'T0 Boa Morte'
  AND (cover_image_url IS NULL OR cover_image_url = '');

NOTIFY pgrst, 'reload schema';
