-- Seed idempotente: proprietária Susana Marques + imóveis T1 Matosinhos e T0 Boa Morte.
-- Requer utilizador em auth.users com email susana.marques@portocoaststays.pt
-- (criar primeiro em Authentication ou SQL de convite). Não insere auth aqui.

DO $$
DECLARE
  v_email constant text := 'susana.marques@portocoaststays.pt';
  v_nome  constant text := 'Susana Marques';
  v_uid   uuid;
BEGIN
  SELECT id INTO v_uid FROM auth.users WHERE email = v_email;
  IF v_uid IS NULL THEN
    RAISE NOTICE '017: ignorado — crie primeiro o utilizador Auth com email %', v_email;
    RETURN;
  END IF;

  UPDATE public.profiles
  SET nome = v_nome, client = 'portocoaststays'
  WHERE id = v_uid;

  INSERT INTO public.profile_clients (user_id, client, role, status)
  VALUES (v_uid, 'portocoaststays', 'user', 'active')
  ON CONFLICT (user_id, client) DO UPDATE
  SET status = 'active', role = EXCLUDED.role;

  IF NOT EXISTS (
    SELECT 1 FROM public.properties
    WHERE owner_id = v_uid AND client = 'portocoaststays' AND name = 'T1 Matosinhos'
  ) THEN
    INSERT INTO public.properties (
      client, owner_id, name, typology, address, city, postal_code, municipality, status, notes
    ) VALUES (
      'portocoaststays', v_uid, 'T1 Matosinhos', 'apartamento',
      '', 'Matosinhos', '', 'Matosinhos', 'setup', ''
    );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.properties
    WHERE owner_id = v_uid AND client = 'portocoaststays' AND name = 'T0 Boa Morte'
  ) THEN
    INSERT INTO public.properties (
      client, owner_id, name, typology, address, city, postal_code, municipality, status, notes
    ) VALUES (
      'portocoaststays', v_uid, 'T0 Boa Morte', 'apartamento',
      '', '', '', '', 'setup', ''
    );
  END IF;
END $$;

NOTIFY pgrst, 'reload schema';
