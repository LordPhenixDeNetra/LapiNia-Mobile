# Tasks
- [x] Task 1: Supabase migrations (fertilité)
  - [x] Ajouter `lapins.score_fertilite` (INTEGER, nullable, borné 0..100 si possible)
  - [x] Étendre `alertes.type` avec `FERTILITE`
  - [x] Ajouter index utiles (`lapins(user_id, score_fertilite)`, `alertes(type)`) si nécessaire

- [x] Task 2: Edge Function `fertility-advice`
  - [x] Créer `supabase/functions/fertility-advice/index.ts`
  - [x] Utiliser `_shared/ai-router.ts` pour générer des recommandations
  - [x] Ajouter fallback templates si IA non configurée (clé absente/vide)
  - [x] Ajouter test curl dans `supabase/deploy_functions_server.sh`

- [x] Task 3: Edge Function `suggest-males`
  - [x] Créer `supabase/functions/suggest-males/index.ts`
  - [x] Entrées: `femelleId`, `objectif` (anti-consanguinite|croissance|equilibre)
  - [x] Récupérer mâles candidats (lapins sexe=M, statut compatible)
  - [x] Calculer score: consanguinité (via algo commun / réutilisation logique consanguinity-check) + traits race (croissance) selon objectif
  - [x] Sortie: top N (ex: 10) avec justification courte
  - [x] Ajouter test curl dans `supabase/deploy_functions_server.sh`

- [x] Task 4: Modèles + Drift + cache
  - [x] Ajouter `scoreFertilite` au modèle `Lapin` (+ parsing/json)
  - [x] Mettre à jour la table Drift locale des lapins (colonne `score_fertilite`)
  - [x] Ajouter une table Drift d’historique mensuel des scores (ex: `FertilityScoresLocal`)
  - [x] Étendre `LocalCacheService` pour lire/écrire l’historique

- [x] Task 5: Calcul score fertilité local
  - [x] Implémenter `FertilityScoreService` (calc sous-scores + total)
  - [x] Calculer à partir de `portees` + `lapereaux` (offline-first) sur 6 mois
  - [x] Persister score courant dans `lapins.score_fertilite` via SyncQueue (update lapin)
  - [x] Persister l’historique mensuel local

- [x] Task 6: Alerte baisse fertilité
  - [x] Détecter “drop > 20 pts en 3 mois” après recalcul
  - [x] Créer alerte `alertes` type `FERTILITE`, priorite=2, message standard
  - [x] Récupérer recommandations via `fertility-advice` et enrichir le message (ou stocker payload local)

- [x] Task 7: UI Lapin “Repro”
  - [x] Remplacer le placeholder de l’onglet Repro par:
    - [x] Carte “Score fertilité” (badge XX/100 + bouton détails)
    - [x] CTA “Arbre généalogique” (ouvre nouvel écran)
  - [x] Détails du score: bottom sheet avec 4 sous-scores + explications

- [x] Task 8: UI Arbre généalogique (3 générations)
  - [x] Créer écran `LapinGenealogyScreen` (routes + navigation)
  - [x] Provider `genealogyProvider(lapinId)` qui charge `public.genealogie` + lapins parents nécessaires
  - [x] Rendu arbre simple (3 niveaux) + nœuds cliquables vers `/lapin/:id`

- [x] Task 9: UI Suggestion mâles (Nouvelle saillie)
  - [x] Ajouter bouton “Suggérer des mâles” dans `SaillieFormScreen`
  - [x] Bottom sheet: choix objectif (3 options) + liste résultats
  - [x] Sélection d’un mâle remplit le dropdown “Mâle”

- [x] Task 10: i18n + vérifications
  - [x] Ajouter libellés FR/EN (score fertilité, sous-scores, objectifs, messages)
  - [x] Vérifier `flutter gen-l10n`, `flutter analyze`, `flutter test`
  - [x] Documenter commandes Supabase de validation (SQL + curl)

- [x] Task 11: Stabiliser `suggest-males` (top N déterministe)
  - [x] Ajouter un ordering explicite côté DB pour les candidats (au minimum `order('id')`)
  - [x] Ajouter un tie-breaker dans le tri final (`score desc`, puis `maleId asc`)
  - [x] Vérifier que les 3 objectifs donnent des résultats stables à score égal (pas de permutation aléatoire)

  Notes (validation Supabase)

  SQL (schéma)

  ```sql
  select column_name, data_type
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'lapins'
    and column_name = 'score_fertilite';

  select conname, pg_get_constraintdef(oid)
  from pg_constraint
  where conrelid = 'public.alertes'::regclass
    and contype = 'c';
  ```

  SQL (généalogie)

  ```sql
  select *
  from public.genealogie
  where lapin_id = '<LAPIN_ID>'
  order by generation asc, role asc;
  ```

  Curl (Edge Functions)

  ```bash
  curl -i \
    -H "Authorization: Bearer <JWT>" \
    -H "apikey: <ANON_KEY>" \
    -H "Content-Type: application/json" \
    -d '{"lapinId":"<LAPIN_ID>","scoreNow":42,"scoreBefore":70}' \
    https://<PROJECT_REF>.functions.supabase.co/fertility-advice

  curl -i \
    -H "Authorization: Bearer <JWT>" \
    -H "apikey: <ANON_KEY>" \
    -H "Content-Type: application/json" \
    -d '{"femelleId":"<FEMELLE_ID>","objectif":"equilibre"}' \
    https://<PROJECT_REF>.functions.supabase.co/suggest-males
  ```

# Task Dependencies
- Task 4 dépend de Task 1 (schéma DB) pour aligner modèles/Drift
- Task 6 dépend de Task 5 (scores calculés)
- Task 7–9 dépendent de Task 4–5 (données dispo)
- Task 2–3 peuvent être faits en parallèle
