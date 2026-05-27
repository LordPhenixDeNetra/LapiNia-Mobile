-- =====================================================
-- lapiNia - Migration SQL Tables
-- Version: 1.0
-- Date: Mai 2026
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- Table: races (données de référence, pas de RLS)
-- =====================================================
CREATE TABLE IF NOT EXISTS races (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nom TEXT NOT NULL UNIQUE,
  poids_adulte_min_kg DECIMAL,
  poids_adulte_max_kg DECIMAL,
  gmq_cible_g INTEGER,
  taille_portee_moyenne DECIMAL,
  age_1ere_mise_bas_jours INTEGER,
  adaptation_chaleur_score INTEGER CHECK (adaptation_chaleur_score BETWEEN 1 AND 5),
  profil_nutritionnel JSONB,
  sensibilites_pathologiques TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Table: lapins
-- =====================================================
CREATE TABLE IF NOT EXISTS lapins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users,
  nom TEXT NOT NULL,
  race_id UUID REFERENCES races,
  sexe TEXT NOT NULL CHECK (sexe IN ('M', 'F')),
  date_naissance DATE,
  poids_actuel_g INTEGER,
  statut TEXT NOT NULL DEFAULT 'REPOS' CHECK (statut IN (
    'REPOS', 'EN_GESTATION', 'LACTATION',
    'DISPONIBLE_SAILLIE', 'ENGRAISSEMENT',
    'MALADE', 'VENDU', 'MORT'
  )),
  numero_identification TEXT UNIQUE,
  photo_url TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE lapins ENABLE ROW LEVEL SECURITY;

-- RLS Policy
CREATE POLICY "lapins_user_isolation" ON lapins
  FOR ALL USING (user_id = auth.uid());

-- Index
CREATE INDEX idx_lapins_user_id ON lapins(user_id);
CREATE INDEX idx_lapins_statut ON lapins(statut);
CREATE INDEX idx_lapins_race_id ON lapins(race_id);

-- =====================================================
-- Table: portees
-- =====================================================
CREATE TABLE IF NOT EXISTS portees (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users,
  mere_id UUID NOT NULL REFERENCES lapins,
  pere_id UUID NOT NULL REFERENCES lapins,
  date_saillie DATE NOT NULL,
  date_mise_bas_prevue DATE,
  date_mise_bas_reelle DATE,
  nb_vivants INTEGER DEFAULT 0,
  nb_morts INTEGER DEFAULT 0,
  poids_total_portee_g INTEGER,
  statut TEXT NOT NULL DEFAULT 'EN_GESTATION' CHECK (statut IN (
    'EN_GESTATION', 'MISE_BAS', 'LACTATION',
    'SEVRAGE', 'TERMINEE'
  )),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE portees ENABLE ROW LEVEL SECURITY;
CREATE POLICY "portees_user_isolation" ON portees
  FOR ALL USING (user_id = auth.uid());

CREATE INDEX idx_portees_user_id ON portees(user_id);
CREATE INDEX idx_portees_mere_id ON portees(mere_id);
CREATE INDEX idx_portees_pere_id ON portees(pere_id);
CREATE INDEX idx_portees_statut ON portees(statut);

-- =====================================================
-- Table: lapereaux
-- =====================================================
CREATE TABLE IF NOT EXISTS lapereaux (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  portee_id UUID NOT NULL REFERENCES portees,
  user_id UUID NOT NULL REFERENCES auth.users,
  sexe TEXT CHECK (sexe IN ('M', 'F', 'INCONNU')),
  poids_naissance_g INTEGER,
  date_sevrage DATE,
  statut TEXT NOT NULL DEFAULT 'VIVANT' CHECK (statut IN (
    'VIVANT', 'MORT', 'VENDU', 'CONSERVÉ'
  )),
  lapin_id UUID REFERENCES lapins,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE lapereaux ENABLE ROW LEVEL SECURITY;
CREATE POLICY "lapereaux_user_isolation" ON lapereaux
  FOR ALL USING (user_id = auth.uid());

CREATE INDEX idx_lapereaux_portee_id ON lapereaux(portee_id);
CREATE INDEX idx_lapereaux_user_id ON lapereaux(user_id);

-- =====================================================
-- Table: pesees
-- =====================================================
CREATE TABLE IF NOT EXISTS pesees (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lapin_id UUID NOT NULL REFERENCES lapins,
  user_id UUID NOT NULL REFERENCES auth.users,
  date DATE NOT NULL,
  poids_g INTEGER NOT NULL,
  gmq_depuis_derniere DECIMAL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE pesees ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pesees_user_isolation" ON pesees
  FOR ALL USING (user_id = auth.uid());

CREATE INDEX idx_pesees_lapin_id ON pesees(lapin_id);
CREATE INDEX idx_pesees_user_id ON pesees(user_id);
CREATE INDEX idx_pesees_lapin_date ON pesees(lapin_id, date DESC);

-- =====================================================
-- Table: medicaments (référence, pas de RLS)
-- =====================================================
CREATE TABLE IF NOT EXISTS medicaments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nom TEXT NOT NULL UNIQUE,
  classe TEXT,
  posologie_ml_par_kg DECIMAL,
  voie_administration TEXT,
  contre_indications JSONB,
  delai_abattage_jours INTEGER,
  description TEXT
);

-- =====================================================
-- Table: sante
-- =====================================================
CREATE TABLE IF NOT EXISTS sante (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lapin_id UUID NOT NULL REFERENCES lapins,
  user_id UUID NOT NULL REFERENCES auth.users,
  date DATE NOT NULL,
  type TEXT NOT NULL CHECK (type IN (
    'MALADIE', 'VACCIN', 'TRAITEMENT',
    'OBSERVATION', 'DECES'
  )),
  description TEXT,
  medicament_id UUID REFERENCES medicaments,
  dosage_ml DECIMAL,
  duree_jours INTEGER,
  delai_abattage_fin DATE,
  statut TEXT NOT NULL DEFAULT 'EN_COURS' CHECK (statut IN ('EN_COURS', 'TERMINE', 'ABANDONNE')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE sante ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sante_user_isolation" ON sante
  FOR ALL USING (user_id = auth.uid());

CREATE INDEX idx_sante_lapin_id ON sante(lapin_id);
CREATE INDEX idx_sante_user_id ON sante(user_id);
CREATE INDEX idx_sante_lapin_date ON sante(lapin_id, created_at DESC);

-- =====================================================
-- Table: stocks
-- =====================================================
CREATE TABLE IF NOT EXISTS stocks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users,
  aliment TEXT NOT NULL,
  quantite_kg DECIMAL NOT NULL DEFAULT 0,
  seuil_alerte_kg DECIMAL NOT NULL DEFAULT 2,
  prix_kg_fcfa INTEGER,
  fournisseur_nom TEXT,
  fournisseur_contact TEXT,
  derniere_commande DATE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE stocks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "stocks_user_isolation" ON stocks
  FOR ALL USING (user_id = auth.uid());

CREATE INDEX idx_stocks_user_id ON stocks(user_id);

-- =====================================================
-- Table: finances
-- =====================================================
CREATE TABLE IF NOT EXISTS finances (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users,
  date DATE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('RECETTE', 'DEPENSE')),
  categorie TEXT NOT NULL CHECK (categorie IN (
    'ALIMENTATION', 'MEDICAMENTS', 'EQUIPEMENTS',
    'VENTE_LAPINS', 'MAIN_OEUVRE', 'TRANSPORT',
    'CHARGES_FIXES', 'AUTRE'
  )),
  montant_fcfa INTEGER NOT NULL,
  description TEXT,
  lapin_id UUID REFERENCES lapins,
  mode_paiement TEXT CHECK (mode_paiement IN (
    'CASH', 'ORANGE_MONEY', 'WAVE', 'VIREMENT', 'AUTRE'
  )),
  idempotency_key TEXT UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE finances ENABLE ROW LEVEL SECURITY;
CREATE POLICY "finances_user_isolation" ON finances
  FOR ALL USING (user_id = auth.uid());

CREATE INDEX idx_finances_user_id ON finances(user_id);
CREATE INDEX idx_finances_date ON finances(date DESC);
CREATE INDEX idx_finances_type ON finances(type);

-- =====================================================
-- Table: alertes
-- =====================================================
CREATE TABLE IF NOT EXISTS alertes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users,
  lapin_id UUID REFERENCES lapins,
  type TEXT NOT NULL CHECK (type IN (
    'MISE_BAS', 'STOCK_BAS', 'VACCINATION',
    'PESEE', 'SANTE', 'EPIDEMIE', 'FINANCE'
  )),
  message TEXT NOT NULL,
  priorite INTEGER NOT NULL CHECK (priorite IN (1, 2, 3)),
  date_echeance TIMESTAMPTZ,
  lue BOOLEAN DEFAULT FALSE,
  action_effectuee BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE alertes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "alertes_user_isolation" ON alertes
  FOR ALL USING (user_id = auth.uid());

CREATE INDEX idx_alertes_user_id ON alertes(user_id);
CREATE INDEX idx_alertes_user_lue ON alertes(user_id, lue);
CREATE INDEX idx_alertes_date_echeance ON alertes(date_echeance);

-- =====================================================
-- Table: genealogie
-- =====================================================
CREATE TABLE IF NOT EXISTS genealogie (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lapin_id UUID NOT NULL REFERENCES lapins,
  parent_id UUID NOT NULL REFERENCES lapins,
  role TEXT NOT NULL CHECK (role IN ('PERE', 'MERE')),
  generation INTEGER NOT NULL DEFAULT 1
);

ALTER TABLE genealogie ENABLE ROW LEVEL SECURITY;
CREATE POLICY "genealogie_user_isolation" ON genealogie
  FOR ALL USING (
    lapin_id IN (SELECT id FROM lapins WHERE user_id = auth.uid()) AND
    parent_id IN (SELECT id FROM lapins WHERE user_id = auth.uid())
  );

CREATE INDEX idx_genealogie_lapin_id ON genealogie(lapin_id);
CREATE INDEX idx_genealogie_parent_id ON genealogie(parent_id);

-- =====================================================
-- Table: sync_queue (pour la synchronisation hors-ligne)
-- =====================================================
CREATE TABLE IF NOT EXISTS sync_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users,
  table_name TEXT NOT NULL,
  operation TEXT NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
  payload JSONB NOT NULL,
  idempotency_key TEXT UNIQUE,
  processed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE sync_queue ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sync_queue_user_isolation" ON sync_queue
  FOR ALL USING (user_id = auth.uid());
