-- =====================================================
-- Table: idempotency_keys (Edge function sync)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.idempotency_keys (
  key TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.idempotency_keys ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "idempotency_keys_user_isolation" ON public.idempotency_keys;
CREATE POLICY "idempotency_keys_user_isolation" ON public.idempotency_keys
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE INDEX IF NOT EXISTS idx_idempotency_keys_user_id ON public.idempotency_keys(user_id);

