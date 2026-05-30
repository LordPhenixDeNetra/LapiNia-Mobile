# Plan — Terminer P1 “Races”

## Objectif
Terminer (ou finaliser si partiellement fait) toutes les tâches **(Flutter · P1)** du bloc **Races** dans [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md#L69-L76) :
- **Liste races** (`GET /rest/v1/races`) avec **cache local 7 jours**
- **Fiche race**
- **Comparateur** (2–3 races) selon objectif
- **Recommandation** (`POST /functions/v1/recommend-race`) selon région, objectif, ressources

Le plan inclut aussi (exigence process) :
- **Où voir dans l’app** (chemins de navigation)
- **Côté Supabase** : requêtes SQL + commandes de déploiement/tests

## État actuel (constaté dans le repo)
### Déjà en place
- Modèle `Race` : [race.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/race.dart)
- Table Supabase `races` + seed data : [001_initial_schema.sql](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/migrations/001_initial_schema.sql), [002_reference_data.sql](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/migrations/002_reference_data.sql)
- Drift : table locale `RacesRef` (id, data, cachedAt) : [app_database.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/app_database.dart#L81-L87)
- Cache local : `getRacesRef()` / `setRacesRef()` existe déjà : [local_cache_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/local_cache_service.dart#L241-L263)
- Navigation : onglet **Plus** existe : [plus_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/plus/plus_screen.dart), routes : [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)

### Manquant / à terminer
- `racesProvider` ne consomme pas le cache (fetch direct Supabase) : [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart#L575-L579)
- Aucun écran Races (liste / détail / comparateur)
- Aucune Edge Function `recommend-race` : `supabase/functions/recommend-race` n’existe pas
- Script self-hosted ne déploie pas `recommend-race` : [deploy_functions_server.sh](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/deploy_functions_server.sh)
- i18n manquant pour l’entrée “Races” et libellés écrans/boutons : [app_fr.arb](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/l10n/app_fr.arb), [app_en.arb](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/l10n/app_en.arb)

## Décisions (figées pour exécution)
### Point d’entrée UI
- **Plus → Races** (tuile dédiée dans l’onglet Plus), puis navigation vers :
  - Détail race
  - Comparateur
  - Recommandation

### Cache (stale-while-revalidate)
- TTL “frais” : **7 jours**
- Hors-ligne :
  - si cache présent (même expiré) : retour cache
  - si cache absent : erreur explicite (le caller gère un état erreur)
- En ligne :
  - si cache présent : retour immédiat cache + refresh en arrière-plan si `cachedAt` > 7 jours, puis `ref.invalidateSelf()`
  - si cache absent : fetch remote puis écrit cache

### Comparateur
- Sélection **2 ou 3** races
- Objectifs (3 chips) :
  - `MEAT` (poids adulte max + GMQ)
  - `BREEDING` (taille portée + âge 1ère mise bas)
  - `HEAT_RESILIENCE` (adaptation chaleur)

### Recommandation
- Réponse attendue : Top 3 races + “raisons” + “points d’attention” (format JSON stable)
- IA :
  - utilise **Claude** si `ANTHROPIC_API_KEY` présent
  - sinon **Mistral** si `MISTRAL_API_KEY` présent
  - sinon `501` avec message explicite “IA non configurée”

## Changements proposés (Flutter)
### 1) `racesProvider` avec cache 7 jours
- Fichier : [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart)
- Actions :
  - Remplacer l’implémentation actuelle de `racesProvider` par une version qui :
    - lit `connectivityCheckerProvider` + `localCacheServiceProvider`
    - essaye `cache.getRacesRef()` d’abord
    - si online : fetch Supabase `from('races').select().order('nom')`
    - écrit cache via `cache.setRacesRef(...)`
    - applique la stratégie stale-while-revalidate décrite plus haut
  - Garder `FutureProvider<List<Race>>` (utilisé par Onboarding, Form lapin, Filtre lapins).

### 2) Routes + entrée Plus
- Fichier : [plus_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/plus/plus_screen.dart)
  - Ajouter tuile “Races” → `context.push('/races')`
- Fichier : [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)
  - Ajouter imports écrans `races/*`
  - Ajouter routes dans la branche “Plus” :
    - `/races` → liste
    - `/race/:id` → détail
    - `/races/compare` (query `ids=a,b,c`) → comparateur
    - `/races/recommend` → formulaire + résultats

### 3) Écrans Races
- Nouveau dossier : `lib/presentation/screens/races/`
- Nouveaux écrans :
  - `race_list_screen.dart`
    - Recherche texte
    - Cartes races + navigation vers détail
    - CTA : “Comparer” (ouvre sélection 2–3 races) + “Recommander une race”
  - `race_detail_screen.dart`
    - Affichage des champs P1 (poids, GMQ, portée, adaptation chaleur, sensibilités)
    - Bouton “Comparer” (ajoute la race courante à une sélection rapide, ou redirige vers `/races/compare?ids=...`)
  - `race_compare_screen.dart`
    - Lecture des `ids` depuis query
    - Récupère les races via `racesProvider`
    - Table comparative (scroll horizontal) avec mise en évidence selon objectif

### 4) Recommandation (modèles + service + UI)
- Modèles :
  - `lib/core/models/race_recommendation.dart`
    - `RaceRecommendationRequest` (country, city, goal, resources)
    - `RaceRecommendationItem` (raceId, raceName, reasons[], warnings[])
    - `RaceRecommendationResult` (items: List<RaceRecommendationItem>)
- Service :
  - `lib/domain/services/race_recommendation_service.dart`
    - appelle `supabase.functions.invoke('recommend-race', body: ...)`
- DI + providers :
  - enregistrer le service dans [service_locator.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/di/service_locator.dart)
  - exposer `raceRecommendationServiceProvider` dans [core_providers.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/core_providers.dart)
- UI :
  - `race_recommendation_screen.dart` (dans `screens/races/`)
    - formulaire (pays/ville préremplis via `OnboardingProfileService` quand possible)
    - choix objectif + ressources (chips)
    - affichage résultat (top 3) + deep-link vers fiche race

### 5) i18n
- Fichiers :
  - [app_fr.arb](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/l10n/app_fr.arb)
  - [app_en.arb](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/l10n/app_en.arb)
- Ajouter les clés nécessaires (minimum) :
  - `plusRaces`
  - `racesTitle`, `racesSearchHint`
  - `racesCompareCta`, `racesRecommendCta`
  - `racesCompareTitle`, `racesRecommendTitle`
  - `racesGoalMeat`, `racesGoalBreeding`, `racesGoalHeatResilience`
  - messages d’erreur (offline/IA non configurée)

### 6) Mise à jour tâches
- Fichier : [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md)
  - Cocher les 4 tâches P1 “Races” et les déplacer dans la section “Fait” (selon la convention du document).

## Changements proposés (Supabase)
### 1) Vérifier que les races existent
SQL (Studio / psql) :
```sql
select count(*) as races_count from public.races;
select nom, gmq_cible_g, adaptation_chaleur_score
from public.races
order by nom
limit 20;
```
Si `races_count = 0` :
- rejouer l’insertion de [002_reference_data.sql](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/migrations/002_reference_data.sql) (au minimum les `INSERT INTO races`).

### 2) Edge Function `recommend-race`
- Ajouter : `supabase/functions/recommend-race/index.ts`
- Comportement :
  - CORS + OPTIONS
  - Valide `Authorization`
  - Charge la liste des races depuis `public.races` (pour contraindre le choix)
  - Appelle l’IA (Claude/Mistral) et force une réponse JSON strictement parsable
  - Retourne `501` si aucune clé IA configurée

Variables d’environnement (self-hosted, dans le container edge-functions) :
- `ANTHROPIC_API_KEY` ou `MISTRAL_API_KEY`
- (déjà requis par d’autres fonctions) `SUPABASE_URL`, `SUPABASE_ANON_KEY`

### 3) Déploiement self-hosted (script)
- Mettre à jour [deploy_functions_server.sh](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/deploy_functions_server.sh) :
  - ajouter `recommend-race` aux dossiers créés (`mkdir -p ...`)
  - ajouter un bloc `cat >"$FUNCTIONS_DIR/recommend-race/index.ts" ...`
- Puis côté serveur :
```bash
./deploy_functions_server.sh
docker restart supabase-supabase-ie1kda-supabase-edge-functions
```
(adapter le nom du container si différent)

### 4) Tests endpoint
- Sans token (doit renvoyer 401) :
```bash
curl -i https://TON_DOMAINE/functions/v1/recommend-race
```
- Avec token (exemple générique) :
```bash
curl -i https://TON_DOMAINE/functions/v1/recommend-race \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"country":"Sénégal","city":"Dakar","goal":"MEAT","resources":["granules","luzerne"]}'
```

## Vérifications (Definition of Done)
### Où voir dans l’app (manuel)
- **Plus → Races**
  - Liste visible + recherche
  - Ouverture fiche race
  - Comparateur : sélectionner 2–3 races et voir le tableau
  - Recommandation : formulaire → top 3 résultats → navigation vers fiche race
- Mode avion :
  - si les races ont déjà été chargées 1 fois : la liste reste visible via cache

### Flutter (tech)
- `flutter analyze`
- Démarrage app sans crash + navigation routes OK

### Supabase (tech)
- `select count(*) from public.races;` > 0
- `POST /functions/v1/recommend-race` renvoie un JSON “top 3” quand une clé IA est configurée

