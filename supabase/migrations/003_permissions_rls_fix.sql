-- =====================================================
-- lapiNia - Fix permissions + RLS policies (self-host friendly)
-- Exécuter ce script dans Supabase Studio (SQL Editor) si l'app a des erreurs RLS.
-- =====================================================

GRANT USAGE ON SCHEMA public TO anon, authenticated;

GRANT SELECT ON TABLE public.races TO anon, authenticated;
GRANT SELECT ON TABLE public.medicaments TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.lapins TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.portees TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.lapereaux TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.pesees TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.sante TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.stocks TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.finances TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.alertes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.genealogie TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.sync_queue TO authenticated;

ALTER TABLE public.lapins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lapereaux ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pesees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sante ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.finances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alertes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.genealogie ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_queue ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "lapins_user_isolation" ON public.lapins;
CREATE POLICY "lapins_user_isolation" ON public.lapins
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "portees_user_isolation" ON public.portees;
CREATE POLICY "portees_user_isolation" ON public.portees
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "lapereaux_user_isolation" ON public.lapereaux;
CREATE POLICY "lapereaux_user_isolation" ON public.lapereaux
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "pesees_user_isolation" ON public.pesees;
CREATE POLICY "pesees_user_isolation" ON public.pesees
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "sante_user_isolation" ON public.sante;
CREATE POLICY "sante_user_isolation" ON public.sante
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "stocks_user_isolation" ON public.stocks;
CREATE POLICY "stocks_user_isolation" ON public.stocks
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "finances_user_isolation" ON public.finances;
CREATE POLICY "finances_user_isolation" ON public.finances
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "alertes_user_isolation" ON public.alertes;
CREATE POLICY "alertes_user_isolation" ON public.alertes
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "genealogie_user_isolation" ON public.genealogie;
CREATE POLICY "genealogie_user_isolation" ON public.genealogie
  FOR ALL USING (
    lapin_id IN (SELECT id FROM public.lapins WHERE user_id = auth.uid()) AND
    parent_id IN (SELECT id FROM public.lapins WHERE user_id = auth.uid())
  )
  WITH CHECK (
    lapin_id IN (SELECT id FROM public.lapins WHERE user_id = auth.uid()) AND
    parent_id IN (SELECT id FROM public.lapins WHERE user_id = auth.uid())
  );

DROP POLICY IF EXISTS "sync_queue_user_isolation" ON public.sync_queue;
CREATE POLICY "sync_queue_user_isolation" ON public.sync_queue
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

