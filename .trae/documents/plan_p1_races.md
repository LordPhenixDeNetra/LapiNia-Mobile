# Plan — P1 “Races”

## Summary
Terminer toutes les tâches **P1** du bloc **Races** :
- Liste des races (avec cache local 7 jours)
- Fiche race (détails)
- Comparateur (2–3 races)
- Recommandation via Edge Function `recommend-race` (IA Claude/Mistral)

Inclut systématiquement : “où voir dans l’app” + “quoi faire côté Supabase”.

## Current State Analysis (repo)
### Déjà présent
- Modèle `Race` : [race.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/race.dart)
- Table Supabase `races` + colonnes nécessaires : [001_initial_schema.sql](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/migrations/001_initial_schema.sql)
- Données de référence (15 races) : [002_reference_data.sql](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/migrations/002_reference_data.sql)
- Provider `racesProvider` (fetch direct Supabase, sans cache) : [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart)
- Drift : table locale `RacesRef` (non utilisée aujourd’hui) : [app_database.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/app_database.dart)
- Navigation : entrée la plus naturelle via l’onglet **Plus** : [plus_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/plus/plus_screen.dart), routes définies dans [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)

### Manquant / incomplet
- Aucun écran “Races” (liste/détail/comparateur).
- Pas de cache local 7 jours pour `GET races`.
- Pas d’Edge Function `recommend-race` dans `supabase/functions`.
- Script de déploiement serveur ne déploie pas `recommend-race`.

## Decisions & Assumptions
- **Point d’entrée UI** : onglet **Plus** (choix utilisateur).
- **Recommandation** : via IA (Claude/Mistral) (choix utilisateur), avec fallback clair si aucune clé IA n’est configurée.
- **Cache races** : stratégie “stale-while-revalidate” :
  - retourne le cache si présent (même expiré) pour ne jamais afficher “vide” hors-ligne,
  - si online et cache > 7 jours : refresh en arrière-plan.
- **Comparateur** : 2–3 races, tableau scroll horizontal, sélection de l’objectif (Viande / Repro / Rusticité) qui influence l’ordre et la mise en avant.

## Proposed Changes (Flutter)
### 1) Cache local 7 jours (RacesRef)
- Fichier : [local_cache_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/local_cache_service.dart)
  - Ajouter :
    - `Future<({List<Race> races, DateTime cachedAt})?> getRacesRef()`
    - `Future<void> setRacesRef(List<Race> races)`
- Fichier : [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart)
  - Remplacer `racesProvider` par une implémentation avec cache (utilise `localCacheServiceProvider` + `connectivityCheckerProvider`).
  - Conserver la signature `FutureProvider<List<Race>>` pour minimiser l’impact (onboarding et lapins form utilisent déjà ce provider).

### 2) Écrans Races (liste / détail / comparateur)
- Nouveaux écrans :
  - `lib/presentation/screens/races/race_list_screen.dart`
  - `lib/presentation/screens/races/race_detail_screen.dart`
  - `lib/presentation/screens/races/race_compare_screen.dart`
- UX
  - **Liste** : recherche, cards avec résumé (poids min/max, GMQ cible, adaptation chaleur).
  - **Détail** : sections :
    - Poids adulte min/max
    - GMQ cible
    - Taille portée moyenne
    - Âge 1ère mise bas
    - Adaptation chaleur (1–5)
    - Profil nutritionnel (si présent)
    - Sensibilités pathologiques (chips)
  - **Comparateur** : sélection 2–3 races + objectif, puis tableau comparatif.

### 3) Recommandation (UI + service)
- Service Flutter :
  - `lib/domain/services/race_recommendation_service.dart`
    - `Future<RaceRecommendationResult> recommendRace({country, city, goal, resources})`
  - Modèles :
    - `lib/core/models/race_recommendation.dart`
- UI (dans module Races) :
  - Sur `RaceListScreen` : bouton “Recommander une race”
  - Form simple :
    - Région (pays/ville) préremplie via `OnboardingProfileService`
    - Objectif (chips)
    - Ressources disponibles (chips multi-select)
  - Résultat :
    - Top 3 recommandations (card : nom + raisons + points d’attention) + lien vers fiche race.

### 4) Navigation
- [plus_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/plus/plus_screen.dart)
  - Ajouter une tuile “Races”.
- [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)
  - Ajouter routes (dans la branche `/plus`) :
    - `/races` (liste)
    - `/race/:id` (détail)
    - `/races/compare?ids=a,b,c` (comparateur)

### 5) i18n + tâches
- `lib/l10n/app_fr.arb` + `lib/l10n/app_en.arb` : libellés écrans/boutons.
- `lapiNia_Taches_Flutter.md` : cocher les 4 items P1 “Races”.

## Proposed Changes (Supabase)
### 1) Vérifications DB (SQL Editor)
```sql
select count(*) as races_count from public.races;
select nom, gmq_cible_g, adaptation_chaleur_score
from public.races
order by nom
limit 20;
```

Si `races_count = 0`, appliquer la migration de données :
- Rejouer uniquement la section “Insertion des 15 races” de [002_reference_data.sql](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/migrations/002_reference_data.sql)

### 2) Edge Function `recommend-race` (IA)
- Ajouter `supabase/functions/recommend-race/index.ts`
  - Vérifier JWT (`Authorization`) + récupérer user (comme `sync`)
  - Lire body `{ country, city, goal, resources }`
  - Charger la liste des races depuis `public.races`
  - Construire un prompt qui impose de choisir dans la liste des races existantes
  - Appeler :
    - Claude si `ANTHROPIC_API_KEY` présent
    - Sinon Mistral si `MISTRAL_API_KEY` présent
    - Sinon retourner `501` avec message “No AI provider configured”
- Variables serveur à configurer (self-hosted) :
  - `ANTHROPIC_API_KEY` **ou** `MISTRAL_API_KEY` dans le container edge-functions
  - Ne jamais mettre ces secrets dans le repo

### 3) Déploiement self-hosted
- Mettre à jour [deploy_functions_server.sh](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/deploy_functions_server.sh) pour copier `recommend-race` dans le volume des fonctions.
- Redémarrer edge-functions (commande exacte dépend du nom du container, ex.):
```bash
docker restart supabase-supabase-ie1kda-supabase-edge-functions
```

### 4) Tests endpoint (serveur)
- Vérifier que l’endpoint répond (401 attendu sans token) :
```bash
curl -i https://TON_DOMAINE/functions/v1/recommend-race
```

## Verification (acceptance)
### Flutter
- `flutter analyze`
- Tests manuels :
  - Onglet **Plus** → **Races**
  - Liste visible + recherche
  - Ouvrir fiche race
  - Comparateur 2–3 races
  - Mode avion : la liste des races reste visible si déjà chargée (cache)
  - Bouton “Recommander une race” :
    - sans clé IA : message explicite “IA non configurée”
    - avec clé IA : top 3 recommandations + navigation vers fiche race

### Supabase
- DB : `select count(*) from races;` > 0
- Function : `POST /functions/v1/recommend-race` renvoie un JSON attendu avec top 3 races

