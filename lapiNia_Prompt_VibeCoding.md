# 🐇 lapiNia — Prompt Complet pour Vibe Coding

---

## CONTEXTE GÉNÉRAL

Tu vas construire **lapiNia**, une application mobile Flutter complète
d'élevage cunicole (lapins) pilotée par l'intelligence artificielle,
destinée aux éleveurs débutants et intermédiaires d'Afrique de l'Ouest
(Sénégal, Mali, Côte d'Ivoire).

L'application fonctionne **hors-ligne en priorité** (zones rurales,
connexion 2G/3G), se synchronise avec Supabase Cloud quand le réseau
est disponible, et intègre Claude API (Anthropic) comme moteur IA
principal via des Edge Functions Supabase sécurisées.

---

## STACK TECHNIQUE OBLIGATOIRE

```
Frontend   : Flutter 3.x (Dart) — iOS & Android
Backend    : Supabase Cloud (pas de backend custom à développer)
             → PostgreSQL auto-API REST
             → Auth (OTP SMS)
             → Storage (photos, PDF, QR codes)
             → Edge Functions (TypeScript/Deno) pour la logique IA
Base local : SQLite via Drift (mode hors-ligne)
IA         : Claude Sonnet API (Anthropic) via Edge Functions
             Mistral AI via Edge Functions (requêtes simples)
             TensorFlow Lite on-device (hors-ligne)
Notif Push : Firebase Cloud Messaging (FCM)
Paiement   : Orange Money + Wave (Afrique) + Stripe
CI/CD      : GitHub Actions
```

---

## ARCHITECTURE OBLIGATOIRE

### Principes SOLID à respecter strictement

**S — Single Responsibility**
- Chaque Edge Function = une seule responsabilité
- `diagnose-symptoms.ts` → diagnostic IA uniquement
- `calculate-ration.ts` → calcul nutritionnel uniquement
- `predict-growth.ts` → prédiction croissance uniquement
- `send-alert.ts` → notifications FCM uniquement
- Chaque BLoC Flutter gère un seul domaine métier

**O — Open/Closed**
- Les races, médicaments, aliments et langues sont dans
  PostgreSQL (pas dans le code)
- Ajouter une race = INSERT SQL, zéro modification de code

**L — Liskov Substitution**
- Interface `AIProvider` implémentée par ClaudeProvider,
  MistralProvider et TFLiteProvider — interchangeables
- Interface `BaseRepository<T>` implémentée par
  SupabaseRepo et LocalSQLiteRepo — interchangeables

**I — Interface Segregation**
- `ILapinSummary` pour le Dashboard (id, nom, statut, hasAlerte)
- `ILapinFull` pour la fiche détail (tout + historique)
- `ISanteWriter` pour DiagnosticService (write only)

**D — Dependency Inversion**
- AIRouter reçoit lowComplexity et highComplexity par injection
- Tous les services reçoivent leurs dépendances par constructeur
- Jamais d'instanciation directe dans les services métier

### Structure du projet Flutter

```
lib/
  core/
    interfaces/      # AIProvider, BaseRepository<T>,
                     # NotificationService, StorageService
    models/          # Lapin, Portee, Stock, EvenementSante,
                     # Race, Medicament, Finance, Alerte
    utils/           # IdempotencyKey, SyncManager,
                     # ApiVersionDetector, ConnectivityChecker
  data/
    repositories/    # LapinRepository, PorteeRepository,
                     # SanteRepository, StockRepository,
                     # FinanceRepository (impl BaseRepository<T>)
    local/           # Drift schemas, DAOs, SyncQueue
    remote/          # Supabase client, HTTP interceptors,
                     # JWT refresh handler
  domain/
    services/        # DiagnosticService, ReproductionService,
                     # AlerteService, NutritionService,
                     # GenetiqueService, FinanceService
  presentation/
    blocs/           # LapinBloc, PorteeBloc, SanteBloc,
                     # AlerteBloc, FinanceBloc, IABloc
    screens/         # Dashboard, Lapins, Portees, Sante,
                     # Alimentation, Finance, Formation, IA
    widgets/         # LapinCard, GrowthChart, AlerteBanner,
                     # RationCard, PorteeTimeline (atomiques)
```

### Structure Edge Functions Supabase

```
supabase/functions/
  _shared/
    ai-router.ts           # AIRouter (SOLID-D)
    base-repository.ts     # BaseRepository<T> (SOLID-O)
    notification-service.ts
    auth-middleware.ts
    rate-limiter.ts
    idempotency.ts
  diagnose-symptoms/       # POST /edge/diagnose
  predict-growth/          # POST /edge/predict-growth
  calculate-ration/        # POST /edge/calculate-ration
  consanguinity-check/     # POST /edge/consanguinity
  send-weekly-report/      # CRON lundi 7h
  check-stock-alerts/      # CRON quotidien 8h
```

---

## BASE DE DONNÉES POSTGRESQL (SUPABASE)

Crée exactement ces tables avec RLS activé sur toutes :

```sql
-- RLS pattern pour TOUTES les tables
CREATE POLICY "{table}_user_isolation" ON {table}
  FOR ALL USING (user_id = auth.uid());

-- Table races (données de référence, pas de RLS)
CREATE TABLE races (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nom TEXT NOT NULL,
  poids_adulte_min_kg DECIMAL,
  poids_adulte_max_kg DECIMAL,
  gmq_cible_g INTEGER,
  taille_portee_moyenne DECIMAL,
  age_1ere_mise_bas_jours INTEGER,
  adaptation_chaleur_score INTEGER, -- 1 à 5
  profil_nutritionnel JSONB,
  sensibilites_pathologiques TEXT[],
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Table lapins
CREATE TABLE lapins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users NOT NULL,
  nom TEXT NOT NULL,
  race_id UUID REFERENCES races,
  sexe TEXT CHECK (sexe IN ('M', 'F')),
  date_naissance DATE,
  poids_actuel_g INTEGER,
  statut TEXT CHECK (statut IN (
    'REPOS', 'EN_GESTATION', 'LACTATION',
    'DISPONIBLE_SAILLIE', 'ENGRAISSEMENT',
    'MALADE', 'VENDU', 'MORT'
  )),
  numero_identification TEXT UNIQUE,
  photo_url TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Table portees
CREATE TABLE portees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users NOT NULL,
  mere_id UUID REFERENCES lapins NOT NULL,
  pere_id UUID REFERENCES lapins NOT NULL,
  date_saillie DATE NOT NULL,
  date_mise_bas_prevue DATE,
  date_mise_bas_reelle DATE,
  nb_vivants INTEGER DEFAULT 0,
  nb_morts INTEGER DEFAULT 0,
  poids_total_portee_g INTEGER,
  statut TEXT CHECK (statut IN (
    'EN_GESTATION', 'MISE_BAS', 'LACTATION',
    'SEVRAGE', 'TERMINEE'
  )),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Table lapereaux
CREATE TABLE lapereaux (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  portee_id UUID REFERENCES portees NOT NULL,
  user_id UUID REFERENCES auth.users NOT NULL,
  sexe TEXT CHECK (sexe IN ('M', 'F', 'INCONNU')),
  poids_naissance_g INTEGER,
  date_sevrage DATE,
  statut TEXT CHECK (statut IN (
    'VIVANT', 'MORT', 'VENDU', 'CONSERVE'
  )),
  lapin_id UUID REFERENCES lapins, -- si conservé comme reproducteur
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Table pesees
CREATE TABLE pesees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lapin_id UUID REFERENCES lapins NOT NULL,
  user_id UUID REFERENCES auth.users NOT NULL,
  date DATE NOT NULL,
  poids_g INTEGER NOT NULL,
  gmq_depuis_derniere DECIMAL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Table medicaments (référence, pas de RLS)
CREATE TABLE medicaments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nom TEXT NOT NULL,
  classe TEXT,
  posologie_ml_par_kg DECIMAL,
  voie_administration TEXT,
  contre_indications JSONB,
  delai_abattage_jours INTEGER,
  description TEXT
);

-- Table sante
CREATE TABLE sante (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lapin_id UUID REFERENCES lapins NOT NULL,
  user_id UUID REFERENCES auth.users NOT NULL,
  date DATE NOT NULL,
  type TEXT CHECK (type IN (
    'MALADIE', 'VACCIN', 'TRAITEMENT',
    'OBSERVATION', 'DECES'
  )),
  description TEXT,
  medicament_id UUID REFERENCES medicaments,
  dosage_ml DECIMAL,
  duree_jours INTEGER,
  delai_abattage_fin DATE,
  statut TEXT CHECK (statut IN ('EN_COURS', 'TERMINE', 'ABANDONNE')),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Table stocks
CREATE TABLE stocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users NOT NULL,
  aliment TEXT NOT NULL,
  quantite_kg DECIMAL NOT NULL DEFAULT 0,
  seuil_alerte_kg DECIMAL NOT NULL DEFAULT 2,
  prix_kg_fcfa INTEGER,
  fournisseur_nom TEXT,
  fournisseur_contact TEXT,
  derniere_commande DATE,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Table finances
CREATE TABLE finances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users NOT NULL,
  date DATE NOT NULL,
  type TEXT CHECK (type IN ('RECETTE', 'DEPENSE')),
  categorie TEXT CHECK (categorie IN (
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
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Table alertes
CREATE TABLE alertes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users NOT NULL,
  lapin_id UUID REFERENCES lapins,
  type TEXT CHECK (type IN (
    'MISE_BAS', 'STOCK_BAS', 'VACCINATION',
    'PESEE', 'SANTE', 'EPIDEMIE', 'FINANCE'
  )),
  message TEXT NOT NULL,
  priorite INTEGER CHECK (priorite IN (1, 2, 3)), -- 1=critique
  date_echeance TIMESTAMPTZ,
  lue BOOLEAN DEFAULT false,
  action_effectuee BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Table genealogie
CREATE TABLE genealogie (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lapin_id UUID REFERENCES lapins NOT NULL,
  parent_id UUID REFERENCES lapins NOT NULL,
  role TEXT CHECK (role IN ('PERE', 'MERE')),
  generation INTEGER NOT NULL DEFAULT 1
);
```

---

## BEST PRACTICES API DESIGN À RESPECTER

```
1. CLEAR NAMING
   Toutes les routes Supabase suivent le pattern REST :
   GET    /rest/v1/lapins              → liste
   GET    /rest/v1/lapins?id=eq.:id    → un lapin
   POST   /rest/v1/lapins              → créer
   PATCH  /rest/v1/lapins?id=eq.:id    → modifier
   DELETE /rest/v1/lapins?id=eq.:id    → supprimer
   GET    /rest/v1/pesees?lapin_id=eq.:id → pesées d'un lapin

2. IDEMPOTENCY
   Chaque mutation Flutter génère un UUID local (IdempotencyKey)
   Ce UUID est stocké dans SQLite avant l'envoi réseau
   Le champ idempotency_key est UNIQUE en base
   Si réseau perdu → retry automatique sans doublon

3. PAGINATION
   Cursor-based pour les listes croissantes (lapins, alertes)
   Offset-based pour les historiques (pesées, santé)
   Toujours limit=20 par défaut, max=100

4. FILTERING & SORTING
   Utiliser les query params Supabase natifs :
   ?statut=eq.EN_GESTATION&order=created_at.desc&limit=20

5. VERSIONING
   Préfixer toutes les Edge Functions par /v1/
   /v1/edge/diagnose, /v1/edge/predict-growth, etc.

6. RATE LIMITING
   Configurer dans Supabase Dashboard :
   Gratuit  : 500 req/h, 50 Edge Fn/jour
   Éleveur  : 2000 req/h, 500 Edge Fn/jour
   Pro      : 5000 req/h, illimité

7. SECURITY
   Authorization: Bearer <jwt> dans chaque requête Flutter
   RLS sur toutes les tables (jamais de bypass)
   Clés API IA uniquement dans variables d'env Supabase
```

---

## MODULES À DÉVELOPPER (par ordre de priorité)

### MODULE 1 — Authentification
- Écran de bienvenue avec sélection de langue (FR/Wolof)
- Inscription et connexion par OTP SMS (Supabase Auth)
- Questionnaire d'initialisation (5 questions : nb lapins,
  objectif, région, races, budget)
- Profil éleveur avec photo

### MODULE 2 — Tableau de Bord
- Carte "Conseil IA du jour" (appel Edge Function /diagnose
  avec contexte de l'élevage)
- Statistiques : nb lapins, femelles gestantes, lapereaux
  attendus, prochaine naissance
- Liste des alertes prioritaires (rouge/orange/vert)
- Timeline des 7 prochains jours
- Widget saisie rapide (pesée en 2 taps)

### MODULE 3 — Gestion des Lapins
- Liste avec filtres (statut, race, sexe)
- Fiche individuelle complète avec photo
- Saisie de pesée avec courbe de croissance
  (graphique réel vs courbe cible selon la race)
- Calcul automatique du GMQ entre chaque pesée
- Alerte si GMQ < 80% de la norme pendant 7 jours
- Statut dynamique mis à jour automatiquement
- QR code généré par animal (via qr_flutter package)

### MODULE 4 — Reproduction et Portées
- Formulaire de saisie de saillie avec :
  - Sélection femelle (filtrée sur statut=REPOS)
  - Sélection mâle (filtrée sur sexe=M)
  - Vérification consanguinité via Edge Function
    /v1/edge/consanguinity avant validation
- Timeline de gestation visuelle J0–J31 :
  - J7 : implantation (badge vert)
  - J25 : préparer maternité (badge orange)
  - J28–J31 : mise bas (badge rouge)
- Notifications push automatiques J-3 et J-1
- Enregistrement mise bas (nb vivants, poids portée)
- Suivi lactation avec pesées J1/J7/J14/J21
- Alerte si lapereau < 10g/j de prise de poids
- Sevrage automatiquement suggéré à J28–J35

### MODULE 5 — Santé et Diagnostic IA
- Journal quotidien d'observation (30 secondes)
  - Appétit (0–3), comportement, selles, aspect
- Formulaire de diagnostic :
  - Sélection multiple de symptômes (liste prédéfinie)
  - Bouton "Analyser" → appel Edge Function /v1/edge/diagnose
  - Affichage : 2–3 diagnostics probables avec %,
    urgence (IMMÉDIATE/48H/SURVEILLANCE), traitement
- Bibliothèque de 25 maladies avec fiches détaillées
- Carnet de vaccination avec rappels automatiques
- Pharmacologie :
  - Base de 40 médicaments avec dosage auto selon poids
  - Alerte si contre-indiqué (gestation/lactation)
  - Compte à rebours délai d'abattage
- Alerte épidémique si 3+ animaux mêmes symptômes/48h

### MODULE 6 — Alimentation et Stocks
- Inventaire des aliments avec jauge de stock
  (vert > 50%, orange 20–50%, rouge < 20%)
- Calcul de ration IA via Edge Function /v1/edge/calculate-ration
  - Adapte automatiquement selon stade physiologique
  - Gestation : +20% de la ration normale
  - Lactation : +40% de la ration normale
- Base de 50+ aliments locaux africains
- Alertes rupture de stock configurables
- Prédiction de consommation sur 30 jours
- Plan de transition alimentaire au sevrage (7 jours)

### MODULE 7 — Finance et Rentabilité
- Journal des ventes (mode paiement : cash/Orange Money/Wave)
- Journal des dépenses avec catégorisation auto
- Tableau de bord financier (graphiques mensuels)
- Calcul coût de production par lapereau
- Prix de vente suggéré par l'IA
- Seuil de rentabilité en temps réel
- Export rapport PDF mensuel

### MODULE 8 — Assistant IA (Chat)
- Interface chat avec historique
- Contexte complet de l'élevage injecté dans chaque prompt
- Questions rapides prédéfinies (boutons)
- Base de 200 Q&R embarquées (hors-ligne)
- Routing automatique Mistral/Claude selon complexité

### MODULE 9 — Formation
- 12 leçons avec quiz de validation
- Glossaire illustré (200+ termes)
- Fiches pratiques téléchargeables

### MODULE 10 — Notifications
- Alertes mise bas (J-3, J-1, Jour J)
- Rappels vaccination
- Alertes stock critique
- Rapport hebdomadaire (lundi matin)
- Paramétrage des préférences de notification

---

## EDGE FUNCTIONS À DÉVELOPPER

### 1. diagnose-symptoms (SOLID-S)

```typescript
// supabase/functions/diagnose-symptoms/index.ts
import { AIRouter } from '../_shared/ai-router.ts';
import { authMiddleware } from '../_shared/auth-middleware.ts';
import { checkIdempotency } from '../_shared/idempotency.ts';

Deno.serve(async (req) => {
  // 1. Auth JWT
  const userId = await authMiddleware(req);

  // 2. Idempotency check
  const idempotencyKey = req.headers.get('Idempotency-Key');
  const cached = await checkIdempotency(idempotencyKey);
  if (cached) return cached;

  // 3. Parse body
  const { lapinId, symptomes } = await req.json();

  // 4. Récupérer contexte élevage depuis PostgreSQL
  const { data: lapin } = await supabase
    .from('lapins')
    .select('*, races(*), sante(*), pesees(*)')
    .eq('id', lapinId)
    .single();

  // 5. Router IA selon complexité
  const router = new AIRouter(
    new MistralProvider(Deno.env.get('MISTRAL_KEY')!),
    new ClaudeProvider(Deno.env.get('ANTHROPIC_KEY')!)
  );
  const complexity = symptomes.length >= 3 ? 'high' : 'low';

  // 6. Construire prompt avec contexte
  const prompt = buildDiagnosticPrompt(lapin, symptomes);
  const result = await router.route(prompt, complexity);

  // 7. Parser résultat JSON
  const diagnostic = JSON.parse(result);

  // 8. Persister dans table sante
  await supabase.from('sante').insert({
    lapin_id: lapinId,
    user_id: userId,
    type: 'MALADIE',
    description: diagnostic.diagnostic_principal,
    date: new Date().toISOString()
  });

  // 9. Vérifier épidémie (3+ animaux mêmes symptômes/48h)
  const { count } = await supabase
    .from('sante')
    .select('*', { count: 'exact' })
    .eq('user_id', userId)
    .gte('created_at', new Date(Date.now() - 48*3600*1000).toISOString());

  if (count >= 3) {
    await sendEpidemieAlert(userId, count);
    diagnostic.alerte_epidemique = true;
    diagnostic.animaux_touches = count;
  }

  return new Response(JSON.stringify(diagnostic), {
    headers: { 'Content-Type': 'application/json' }
  });
});
```

### 2. calculate-ration (SOLID-S)

```typescript
// Calcule la ration quotidienne selon stade physiologique
// Input: { lapinId, alimentsDisponibles[] }
// Output: { rations[], coutTotal, alertesStock[] }

const FACTEURS_STADE = {
  REPOS: 1.0,
  EN_GESTATION: 1.2,    // +20%
  LACTATION: 1.4,       // +40%
  ENGRAISSEMENT: 1.15,
};

// Utiliser Mistral (complexité faible, économique)
const complexity = 'low';
```

### 3. consanguinity-check (SOLID-S)

```typescript
// Calcule le coefficient F de Wright sur 3 générations
// Input: { femelle_id, male_id }
// Output: { coefficient_f, risque, ancetres_communs[] }

// Algorithme pur, pas d'appel IA nécessaire
// Récupérer l'arbre généalogique depuis table genealogie
// Calculer F selon Wright : F = Σ (1/2)^(n1+n2+1) * (1+FA)
```

### 4. predict-growth (SOLID-S)

```typescript
// Prédit la courbe de croissance jusqu'au poids de vente
// Input: { lapinId, semainesAvenir }
// Output: { courbe[], poids_vente_estime, date_vente_optimale }

// Modèle : TFLite ou Mistral selon connectivité
// Basé sur : race (GMQ cible), pesées historiques,
//            alimentation actuelle
```

---

## SYNCHRONISATION HORS-LIGNE

```dart
// À implémenter dans SyncManager
class SyncManager {
  // 1. Toujours écrire en SQLite local d'abord
  // 2. Ajouter à la PersistentQueue avec Idempotency-Key
  // 3. Écouter ConnectivityStream
  // 4. Quand en ligne : vider la queue vers Supabase
  // 5. Conflict resolution : Last-Write-Wins sur updated_at

  // Tables à synchroniser (bidirectionnel) :
  // lapins, portees, pesees, sante, stocks, finances

  // Tables lecture seule (pas de sync locale) :
  // races, medicaments (données de référence)
}
```

---

## AI ROUTER (SOLID-D) — CODE COMPLET

```typescript
// supabase/functions/_shared/ai-router.ts

export interface AIProvider {
  complete(prompt: string, maxTokens: number): Promise<string>;
  isAvailable(): Promise<boolean>;
  getEstimatedCostFcfa(tokens: number): number;
}

export class ClaudeProvider implements AIProvider {
  constructor(private apiKey: string) {}

  async complete(prompt: string, maxTokens = 1000): Promise<string> {
    const res = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': this.apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-5',
        max_tokens: maxTokens,
        system: SYSTEM_PROMPT_CUNICULTURE_FR,
        messages: [{ role: 'user', content: prompt }],
      }),
    });
    const data = await res.json();
    return data.content[0].text;
  }

  async isAvailable(): Promise<boolean> {
    try {
      await fetch('https://api.anthropic.com/v1/models',
        { headers: { 'x-api-key': this.apiKey } });
      return true;
    } catch { return false; }
  }

  getEstimatedCostFcfa(tokens: number): number {
    return Math.ceil(tokens * 0.018); // ~0.018 FCFA/token
  }
}

export class MistralProvider implements AIProvider {
  constructor(private apiKey: string) {}

  async complete(prompt: string, maxTokens = 500): Promise<string> {
    const res = await fetch('https://api.mistral.ai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'mistral-large-latest',
        max_tokens: maxTokens,
        messages: [
          { role: 'system', content: SYSTEM_PROMPT_CUNICULTURE_FR },
          { role: 'user', content: prompt }
        ],
      }),
    });
    const data = await res.json();
    return data.choices[0].message.content;
  }

  async isAvailable(): Promise<boolean> { return true; }
  getEstimatedCostFcfa(tokens: number): number {
    return Math.ceil(tokens * 0.002); // ~10x moins cher
  }
}

export class AIRouter {
  constructor(
    private low: AIProvider,   // MistralProvider
    private high: AIProvider,  // ClaudeProvider
  ) {}

  async route(prompt: string, complexity: 'low' | 'high'): Promise<string> {
    const provider = complexity === 'high' ? this.high : this.low;
    const available = await provider.isAvailable();
    if (!available) return this.low.complete(prompt, 500);
    const maxTokens = complexity === 'high' ? 1000 : 500;
    return provider.complete(prompt, maxTokens);
  }
}

// System prompt commun à tous les providers
const SYSTEM_PROMPT_CUNICULTURE_FR = `
Tu es lapiNia, un assistant IA expert en cuniculture (élevage de lapins)
spécialisé pour l'Afrique de l'Ouest.

Tu connais :
- Les races adaptées au climat sahélien (NZW, Californien, Fauve de Bourgogne)
- Les maladies courantes en Afrique de l'Ouest et leurs traitements
- Les aliments locaux (son de mil, moringa, fanes de carottes, tourteau d'arachide)
- Les prix du marché en FCFA
- Les pratiques vétérinaires accessibles sans équipement spécialisé

Règles :
- Réponds toujours en français simple et clair
- Adapte tes conseils au contexte africain (ressources locales, climat chaud)
- Pour les diagnostics, donne TOUJOURS un niveau d'urgence :
  IMMÉDIATE / 48H / SURVEILLANCE
- Pour les dosages médicamenteux, donne TOUJOURS le délai d'abattage
- Réponds en JSON quand demandé, sans markdown ni backticks
`;
```

---

## DESIGN UI/UX

```
Couleurs :
  Primaire    : #2E7D32 (vert forêt)
  Alerte      : #E65100 (ambre)
  Danger      : #B71C1C (rouge)
  IA          : #4A148C (violet)
  Fond        : #F1F8E9 (vert très clair)
  Texte       : #263238 (gris foncé)

Typographie :
  Titres      : Poppins Bold
  Corps       : Nunito Regular
  Code        : Courier New

Principes UX :
  - Aucune action ne dépasse 3 taps
  - Feedback visuel immédiat < 200ms
  - Mode hors-ligne clairement indiqué (badge orange)
  - Contraste élevé (lecture en plein soleil africain)
  - Boutons larges (utilisation avec les mains sales/humides)
  - Pas de texte inférieur à 14sp

Navigation :
  Bottom Navigation Bar avec 5 onglets :
  🏠 Accueil | 🐇 Lapins | 🤰 Portées | 🍃 Aliments | 🧠 IA
```

---

## CONTRAINTES TECHNIQUES IMPORTANTES

```
1. HORS-LIGNE EN PRIORITÉ
   Toujours écrire en SQLite d'abord, Supabase ensuite
   L'app doit être 100% fonctionnelle sans connexion
   pour les fonctionnalités de base (saisie, consultation)

2. PERFORMANCE SUR APPAREILS LIMITÉS
   Taille app < 80 Mo
   Démarrage < 3 secondes sur Android 2 Go RAM
   Listes virtualisées (ListView.builder) toujours
   Images compressées avant upload (< 200 Ko)

3. IDEMPOTENCY PARTOUT
   Chaque POST génère un UUID Idempotency-Key côté Flutter
   Stocké en SQLite avant l'envoi
   Supprimé de la queue après confirmation serveur

4. SÉCURITÉ
   Jamais de clés API dans le code Flutter
   Toujours via Edge Functions Supabase
   RLS activé et testé sur toutes les tables
   Pas de données sensibles en clair dans les logs

5. GESTION DES ERREURS
   Toujours afficher un message utilisateur compréhensible
   Logger dans Sentry pour le debug
   Retry automatique x3 avec backoff exponentiel
   Mode dégradé si IA cloud indisponible (TFLite fallback)
```

---

## ORDRE DE DÉVELOPPEMENT RECOMMANDÉ

```
Phase 1 (semaines 1–2) :
  ✅ Setup Supabase (tables + RLS + Auth)
  ✅ Setup Flutter (structure Clean Architecture + BLoC)
  ✅ Setup GitHub Actions (CI/CD)
  ✅ Authentification OTP SMS fonctionnelle
  ✅ SQLite local avec Drift + SyncManager basique

Phase 2 (semaines 3–5) :
  ✅ Module Lapins (CRUD complet + pesées + courbe croissance)
  ✅ Module Portées (saillie + gestation + mise bas + sevrage)
  ✅ Notifications push FCM (alertes mise bas)
  ✅ Dashboard avec KPIs

Phase 3 (semaines 6–8) :
  ✅ Edge Function diagnose-symptoms (Claude + Mistral)
  ✅ Edge Function calculate-ration
  ✅ Edge Function consanguinity-check
  ✅ Module Santé complet avec diagnostic IA
  ✅ Module Alimentation avec rations IA

Phase 4 (semaines 9–10) :
  ✅ Module Finance
  ✅ QR codes (qr_flutter)
  ✅ Export PDF (pdf package)
  ✅ Module IA Chat (assistant conversationnel)

Phase 5 (semaines 11–13) :
  ✅ Module Formation (leçons + quiz)
  ✅ Onboarding complet
  ✅ Optimisation performance
  ✅ Tests (unitaires + intégration)
  ✅ Soumission App Store + Google Play
```

---

## PACKAGES FLUTTER RECOMMANDÉS

```yaml
dependencies:
  # Supabase
  supabase_flutter: ^2.0.0

  # Base locale hors-ligne
  drift: ^2.0.0
  sqlite3_flutter_libs: ^0.5.0

  # State management
  flutter_bloc: ^8.0.0
  equatable: ^2.0.0

  # Navigation
  go_router: ^12.0.0

  # UI
  flutter_svg: ^2.0.0
  cached_network_image: ^3.0.0
  shimmer: ^3.0.0

  # Graphiques (courbes de croissance)
  fl_chart: ^0.65.0

  # QR Code
  qr_flutter: ^4.1.0
  mobile_scanner: ^4.0.0

  # PDF
  pdf: ^3.10.0
  printing: ^5.12.0

  # Notifications
  firebase_messaging: ^14.0.0
  flutter_local_notifications: ^16.0.0

  # Connectivité
  connectivity_plus: ^5.0.0

  # Stockage fichiers
  image_picker: ^1.0.0
  image_cropper: ^5.0.0

  # Utilitaires
  uuid: ^4.0.0
  intl: ^0.18.0
  shared_preferences: ^2.2.0
  path_provider: ^2.1.0
```

---

## COMMANDE DE DÉMARRAGE

Commence par cette séquence dans cet ordre exact :

1. Créer le projet Supabase sur supabase.com
2. Exécuter tous les scripts SQL de création des tables
3. Activer RLS et créer les politiques d'isolation
4. Créer le projet Flutter avec `flutter create lapinia`
5. Mettre en place la structure Clean Architecture
6. Configurer Supabase Flutter SDK avec les clés du projet
7. Implémenter l'authentification OTP SMS
8. Créer le schéma Drift pour SQLite local
9. Implémenter le SyncManager basique
10. Développer le module Lapins en premier (CRUD complet)

---

*lapiNia v3.0 — Prompt Vibe Coding Complet*
*Flutter · Supabase · Claude AI · SOLID · API Design*
MARKDOWN_EOF