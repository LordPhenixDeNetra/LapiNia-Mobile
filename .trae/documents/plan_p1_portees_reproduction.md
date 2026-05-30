# Plan — P1 “Portées & Reproduction”

## Summary
Terminer les tâches **(Flutter · P1)** du bloc **Portées & Reproduction** :
- Liste portées : statut coloré + barre progression gestation
- Enregistrer une saillie : sélection femelle/mâle, date, notes, idempotency (via SyncManager)
- Vérification consanguinité : Edge Function `consanguinity-check` + warning/blocage selon seuil
- Timeline gestation visuelle : J0–J31 + jalons
- Checklist pré-mise bas J25 : stockée **localement** (SQLite/Drift)
- Enregistrer mise bas : mise à jour portée + statut mère + création lapereaux
- Lapereaux : liste + mise à jour (poids/statut/destination)
- Enregistrer sevrage : confirmation + statut mère → REPOS + date sevrage lapereaux
- Notifications “mise bas” : **locales** (pas FCM) à J-3 et J-1

Le plan inclut systématiquement :
- **Où voir dans l’app**
- **Côté Supabase** : SQL/commandes + vérifications

## Current State Analysis (repo)
### Flutter — Existant
- Liste/Détail/Création saillie :
  - [portee_list_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/portee_list_screen.dart)
  - [portee_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/portee_detail_screen.dart)
  - [saillie_form_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/saillie_form_screen.dart)
- Provider portées (offline-first + sync) :
  - [portee_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/portee_provider.dart)
  - `create()` (saillie), `recordMiseBas(...)`, `recordSevrage(...)` existent
- Modèles :
  - Portée : [portee.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/portee.dart)
  - Lapereau : [lapereau.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/lapereau.dart)
  - Enums : [enums.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/constants/enums.dart)
- Base locale Drift : pas de table lapereaux / pas de checklist : [app_database.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/app_database.dart)
- Notifs : dépendances présentes mais pas d’implémentation : [notification_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/interfaces/notification_service.dart)

### Supabase — Existant
- Tables + RLS :
  - `portees`, `lapereaux`, `genealogie` : [001_initial_schema.sql](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/migrations/001_initial_schema.sql)
- Edge Functions existantes : `sync`, IA, `recommend-race` ; **pas** de `consanguinity-check` : [supabase/functions](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/functions)

### Gaps à combler (P1)
- UI Portées trop basique : pas de barre progression, pas de timeline, pas de formulaire mise bas, pas de gestion lapereaux.
- Pas de provider `lapereaux` (Supabase + cache).
- Pas de checklist pré-mise bas stockée localement.
- Pas de consanguinity-check (Edge Function).
- Notifs “mise bas” inexistantes (décision : **locales**).
- Schéma lapereaux : ajouter le statut **CONSOMMÉ** (décision utilisateur).

## Decisions & Assumptions (figées)
### A) Notifications
- Pour P1 : **notifications locales** (flutter_local_notifications), planifiées à **J-3 et J-1** de la `date_mise_bas_prevue`, à une heure fixe (ex: 09:00 locale).
- Annulation des notifs : quand `recordMiseBas` est appelé (mise bas réelle), ou si la portée est supprimée (si on ajoute cette action plus tard).

### B) Lapereaux — statut “CONSOMMÉ”
- Ajout d’un statut **CONSOMMÉ** à `lapereaux.statut` côté Supabase + enum Flutter.
- UI “destination” = `CONSERVÉ / VENDU / CONSOMMÉ` (et `MORT` si applicable).

### C) Consanguinité (P1)
- Implémentation pragmatique basée sur ancêtres **jusqu’à 3 générations**, alignée sur les seuils demandés :
  - Ancêtre commun génération 1 (même parent) → **25%** (blocage)
  - génération 2 (même grand-parent) → **12.5%** (blocage)
  - génération 3 (même arrière-grand-parent) → **6.25%** (warning)
- Si offline ou si généalogie insuffisante : afficher “Consanguinité non vérifiable” et autoriser la saillie (P1).

## Proposed Changes (Flutter)
### 1) Liste portées : statut coloré + progression
- Fichier : [portee_list_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/portee_list_screen.dart)
  - Badge couleur selon `StatutPortee`
  - Barre progression `joursGestationEcoules / 31` (si `enGestation`)
  - Micro-copy : “J{elapsed} — {remaining} jours restants”

### 2) Vérification consanguinité avant saillie
- Fichier : [saillie_form_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/saillie_form_screen.dart)
  - Quand femelle + mâle sélectionnés et online :
    - appeler `POST /functions/v1/consanguinity-check`
    - afficher résultat (OK/WARN/BLOCK)
    - si BLOCK : désactiver le bouton “Enregistrer” + message explicite
  - Gestion offline : message “Vérification indisponible hors-ligne”
- Nouveau service :
  - `lib/domain/services/consanguinity_service.dart` (appelle l’Edge Function)
  - provider dans `core_providers.dart` + DI `service_locator.dart`

### 3) Notifs locales (mise bas)
- Nouveau service :
  - `lib/domain/services/local_notification_service.dart` (implémentation partielle de `NotificationService` centrée sur local)
  - `lib/domain/services/portee_notifications_service.dart` (planifie/annule notifs par `porteeId`)
- Intégrations :
  - Initialisation au démarrage (dans `main.dart` ou bootstrap provider déjà existant) + demande permission.
  - Dans `PorteesController.create(...)` (ou `SaillieFormScreen.submit`) :
    - calculer `date_mise_bas_prevue`
    - programmer 2 notifs locales (J-3 et J-1)
  - Dans `recordMiseBas` :
    - annuler les notifs associées à la portée

### 4) Détail portée : timeline + actions (mise bas / sevrage) + checklist J25
- Fichier : [portee_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/portee_detail_screen.dart)
  - Refonte :
    - Carte résumé (mère/père/statut/dates)
    - Timeline gestation (widget dédié)
    - Section “Checklist J25” (affichée si gestation et jours >= 25)
    - Bouton “Enregistrer mise bas” (si gestation) → ouvre un formulaire (bottom sheet ou écran)
    - Section “Lapereaux” (si mise bas/lactation/sevrage) → navigation vers écran lapereaux
    - Bouton “Enregistrer sevrage” (si lactation) → confirmation + mise à jour
- Nouveaux widgets (réutilisables) :
  - `lib/presentation/widgets/portees/gestation_timeline.dart`
  - `lib/presentation/widgets/portees/pre_mise_bas_checklist_card.dart`

### 5) Checklist pré-mise bas locale (SQLite)
- Drift : ajouter une table locale (schemaVersion + migration Drift) :
  - `PreMiseBasChecklistLocal` : `id`, `userId`, `porteeId`, `itemKey`, `checked`, `updatedAt`
- Nouveau service :
  - `lib/domain/services/pre_mise_bas_checklist_service.dart`
  - expose :
    - `Future<List<ChecklistItem>> list(porteeId)`
    - `Future<void> toggle(itemKey, checked)`
  - valeurs par défaut : `cage_maternite`, `nid`, `temperature`, `aliments`, `isolement`

### 6) Mise bas : formulaire + création lapereaux
- Nouveau écran :
  - `lib/presentation/screens/portees/mise_bas_form_screen.dart`
- Flux :
  - champs : date (default today), nb vivants, nb morts, poids total portée
  - appel `PorteesController.recordMiseBas(...)`
  - création automatique de `lapereaux` :
    - insérer `nbVivants` lignes `statut=VIVANT`
    - insérer `nbMorts` lignes `statut=MORT`
    - `sexe=INCONNU`, `poids_naissance_g=null`
  - implémentation création lapereaux via nouveau `LapereauxController` (voir ci-dessous) utilisant `SyncManager.addMutation` (offline-first).

### 7) Lapereaux : provider + écran liste + mise à jour
- Nouveau provider :
  - `lib/presentation/providers/lapereau_provider.dart`
  - `lapereauxProvider(porteeId)` : charge `GET /rest/v1/lapereaux?portee_id=eq.{id}&order=created_at.asc`
  - méthodes :
    - `createBatch(...)` (utilisé après mise bas)
    - `updateLapereau(...)` (poids, sexe, statut, date_sevrage)
- Cache local :
  - Drift table `LapereauxLocal` ou cache par `porteeId` (JSON) + méthodes dans `local_cache_service.dart`
- Écran :
  - `lib/presentation/screens/portees/lapereaux_screen.dart`
  - UI :
    - liste des lapereaux (chips statut/destination)
    - édition rapide (bottom sheet) : poids naissance, sexe, destination
    - appliquer `CONSOMMÉ` (nouvelle valeur)

### 8) Sevrage : confirmation + mise à jour lapereaux
- Sur `PorteeDetailScreen` :
  - bouton “Enregistrer sevrage” (si `StatutPortee.lactation`)
  - action :
    - `PorteesController.recordSevrage(porteeId, mereId)`
    - pour chaque lapereau “vivant” :
      - set `date_sevrage = today`
      - si destination non renseignée : rester `VIVANT` (P1), ou demander à l’utilisateur (modal) avant validation

### 9) Routes + navigation
- Fichier : [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)
  - ajouter :
    - `/portee/:id/mise-bas` → `MiseBasFormScreen(porteeId: id)`
    - `/portee/:id/lapereaux` → `LapereauxScreen(porteeId: id)`

### 10) i18n + tâches
- i18n :
  - `lib/l10n/app_fr.arb` + `lib/l10n/app_en.arb` : labels (mise bas, sevrage, lapereaux, checklist, consanguinité, progression).
- Checklist :
  - cocher les tâches P1 de “Portées & Reproduction” et les déplacer dans “Fait” dans [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md).

## Proposed Changes (Supabase)
### 1) Migration — ajouter `CONSOMMÉ` à `lapereaux.statut`
- Nouveau fichier :
  - `supabase/migrations/005_lapereaux_consomme.sql`
- Contenu :
  - supprimer/recréer le CHECK constraint (ou alter via `ALTER TABLE ... DROP CONSTRAINT ... ADD CONSTRAINT ...`)
  - inclure `'CONSOMMÉ'` dans la liste.

### 2) Edge Function — `consanguinity-check`
- Nouveau fichier :
  - `supabase/functions/consanguinity-check/index.ts`
- Input JSON :
  - `{ "mereId": "<uuid>", "pereId": "<uuid>" }`
- Output JSON :
  - `{ "ok": true, "f": 0.125, "level": "BLOCK"|"WARN"|"OK"|"UNKNOWN", "commonAncestors": ["<uuid>", ...] }`
- Implementation :
  - créer client Supabase avec `SUPABASE_URL` + `SUPABASE_ANON_KEY` + header `Authorization` (comme `sync`)
  - `auth.getUser()` pour valider session
  - requêtes `genealogie` pour récupérer ancêtres (1..3 générations) des 2 lapins
  - calcul `f` selon l’ancêtre commun le plus proche
- Déploiement self-hosted :
  - mettre à jour `supabase/deploy_functions_server.sh` pour copier la nouvelle function

## Côté Supabase (commandes / vérifs)
### 1) Vérifier statut “CONSOMMÉ”
```sql
select conname, pg_get_constraintdef(c.oid)
from pg_constraint c
join pg_class t on t.oid = c.conrelid
where t.relname = 'lapereaux' and c.contype = 'c';
```

### 2) Vérifier insert/update lapereaux
```sql
select id, portee_id, statut, sexe, poids_naissance_g, date_sevrage, created_at
from public.lapereaux
order by created_at desc
limit 30;
```

### 3) Tester consanguinity-check (curl)
```bash
curl -i https://TON_DOMAINE/functions/v1/consanguinity-check \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"mereId":"<UUID_FEMELLE>","pereId":"<UUID_MALE>"}'
```

## Où voir dans l’app (acceptance)
- **Liste portées** : Portées → voir badge statut + progression gestation.
- **Saillie** : Portées → “+” → sélection femelle/mâle/date → résultat consanguinité (OK/WARN/BLOCK) puis enregistrement.
- **Timeline** : Portées → ouvrir une portée → timeline J0–J31 visible.
- **Checklist J25** : Portées → ouvrir une portée en gestation ≥ J25 → checklist affichée et persistée localement.
- **Mise bas** : Portées → ouvrir une portée en gestation → “Enregistrer mise bas” → saisie → statut passe à Lactation + lapereaux créés.
- **Lapereaux** : Portées → détail → “Lapereaux” → liste + mise à jour (poids/sexe/destination incl. Consommé).
- **Sevrage** : Portées → détail → “Enregistrer sevrage” → statut portée sevrage + mère REPOS.
- **Notifs locales** : après enregistrement d’une saillie → notifications OS à J-3 et J-1 (si permissions accordées).

## Verification (tech)
- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`
- Tests manuels (Android) :
  - Offline : création saillie sans check consanguinité, sync à reconnexion
  - Online : consanguinity-check OK/WARN/BLOCK
  - Mise bas → création lapereaux → édition statuts
  - Notifs locales planifiées et annulées après mise bas

