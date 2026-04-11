-- Assign Porto Coast Stays portfolio to Afonso Cruz (afonso@dappio.pt) for admin / global tasks context.
UPDATE public.properties p
SET owner_id = '6a0f5531-b9db-4357-94bd-aff4fc2e04bb'
WHERE p.client = 'portocoaststays'
  AND EXISTS (
    SELECT 1 FROM public.profiles pr
    WHERE pr.id = '6a0f5531-b9db-4357-94bd-aff4fc2e04bb'
      AND pr.email = 'afonso@dappio.pt'
  );
