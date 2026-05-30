DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    WHERE t.relname = 'lapereaux'
      AND c.conname = 'lapereaux_statut_check'
  ) THEN
    EXECUTE 'ALTER TABLE public.lapereaux DROP CONSTRAINT lapereaux_statut_check';
  END IF;
END $$;

ALTER TABLE public.lapereaux
  ADD CONSTRAINT lapereaux_statut_check CHECK (
    statut IN ('VIVANT', 'MORT', 'VENDU', 'CONSERVÉ', 'CONSOMMÉ')
  );

