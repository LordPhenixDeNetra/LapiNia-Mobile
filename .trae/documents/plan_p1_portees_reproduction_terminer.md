# Plan — Terminer P1 “Portées & Reproduction”

## Summary
Terminer (ou finaliser) toutes les tâches **P1** du bloc **Portées & Reproduction** en s’alignant sur l’implémentation déjà commencée (offline-first + Drift + SyncQueue) :
- Liste portées : badge statut + progression gestation (déjà en place, à i18n)
- Saillie : notes + contrôle consanguinité (déjà branché, à i18n)
- Détail portée : timeline gestation + checklist J25 + actions “mise bas / lapereaux / sevrage”
- Mise bas : formulaire + création batch de lapereaux
- Lapereaux : liste + édition (statut incl. **CONSOMMÉ**)
- Sevrage : confirmation + date_sevrage sur les lapereaux vivants + “destination par défaut” (option mixte)
- Notifications : **locales** J-3 / J-1 à **09:00** locale (hardening + i18n)
- Finalisation : routes, i18n, vérifs Flutter, mise à jour checklist `lapiNia_Taches_Flutter.md`

## Current State Analysis (constaté dans le repo)
### Déjà présent (partiel ou complet)
- Écrans :
  - Liste : [portee_list_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/portee_list_screen.dart)
  - Détail (basique) : [portee_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/portee_detail_screen.dart)
  - Saillie : [saillie_form_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/saillie_form_screen.dart)
  - Mise bas : [mise_bas_form_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/mise_bas_form_screen.dart)
  - Lapereaux : [lapereaux_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/lapereaux_screen.dart)
- Providers :
  - Portées : [portee_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/portee_provider.dart)
  - Lapereaux : [lapereau_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapereau_provider.dart)
- Offline-first :
  - Drift tables : `LapereauxLocal`, `PreMiseBasChecklistLocal` + `schemaVersion=3` dans [app_database.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/app_database.dart)
  - Cache : méthodes lapereaux dans [local_cache_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/local_cache_service.dart)
- Checklist J25 (locale) :
  - Service : [pre_mise_bas_checklist_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/domain/services/pre_mise_bas_checklist_service.dart)
  - Widget : [pre_mise_bas_checklist_card.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/widgets/portees/pre_mise_bas_checklist_card.dart)
- Timeline gestation (widget, à enrichir/i18n) : [gestation_timeline.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/widgets/portees/gestation_timeline.dart)
- Consanguinité :
  - Modèle : [consanguinity.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/consanguinity.dart)
  - Service : [consanguinity_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/domain/services/consanguinity_service.dart)
  - UI : contrôle dans [saillie_form_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/saillie_form_screen.dart)
- Notifications locales :
  - Déps : `flutter_local_notifications`, `timezone`, `flutter_timezone` dans `pubspec.yaml`
  - Services : [local_notification_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/domain/services/local_notification_service.dart), [portee_notifications_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/domain/services/portee_notifications_service.dart)
  - Init au bootstrap : [bootstrap_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/bootstrap_provider.dart)
- Supabase :
  - Migration statut **CONSOMMÉ** : [005_lapereaux_consomme.sql](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/migrations/005_lapereaux_consomme.sql)
  - Edge Function `consanguinity-check` : [index.ts](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/functions/consanguinity-check/index.ts)
  - Script de déploiement : `supabase/deploy_functions_server.sh` contient `consanguinity-check`

### Gaps P1 restants (constat)
- Routes manquantes :
  - `/portee/:id/mise-bas`
  - `/portee/:id/lapereaux`
  (actuellement, seul `/portee/:id` existe dans [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart))
- Détail portée trop basique : pas de timeline/checklist/actions contextualisées (mise bas / lapereaux / sevrage).
- Sevrage : `PorteesController.recordSevrage` ne met pas à jour `lapereaux.date_sevrage` (et donc pas de “destination par défaut”).
- i18n : beaucoup de clés absentes pour saillie/consanguinité/mise bas/lapereaux/checklist/timeline (actuellement, `porteesTitle`, `newSaillie` existent, mais le reste manque dans les `.arb`).
- Notifications : titres/bodies hardcodés en FR, et pas de garde si la date (J-3/J-1) est déjà passée.
- Checklist “tâches” : les items P1 “Portées & Reproduction” ne sont pas cochés dans `lapiNia_Taches_Flutter.md`, et la ligne “Notifications push … FCM” doit être alignée sur la décision “locales”.

## Decisions & Assumptions (figés)
- Notifications “mise bas” : **locales** (pas FCM), planifiées à **J-3** et **J-1**, à **09:00 locale**.
- Sevrage : **option mixte** :
  - au moment du sevrage, on demande une **destination par défaut** (Conservé/Vendu/Consommé)
  - puis on laisse l’utilisateur ajuster ensuite dans l’écran “Lapereaux”
- Poids au sevrage : **aucun** (P1 light).

## Proposed Changes (Flutter)
### A) Routing
- Fichier : [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)
  - Ajouter 2 routes (branche Portées) :
    - `/portee/:id/mise-bas` → `MiseBasFormScreen(porteeId)`
    - `/portee/:id/lapereaux` → `LapereauxScreen(porteeId)`

### B) Détail portée (UI + actions)
- Fichier : [portee_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/portee_detail_screen.dart)
  - Remplacer l’écran “Infos + bouton sevrage” par une vue structurée :
    - Carte résumé (mère/père/statut/dates/notes)
    - Si `statut == enGestation` :
      - afficher `GestationTimeline(elapsedDays)`
      - si `elapsedDays >= 25` : afficher `PreMiseBasChecklistCard(porteeId)`
      - CTA “Enregistrer mise bas” → `context.push('/portee/$id/mise-bas')`
    - Si `statut == lactation || statut == sevrage || statut == terminee` :
      - CTA “Lapereaux” → `context.push('/portee/$id/lapereaux')`
    - Si `statut == lactation` :
      - CTA “Enregistrer sevrage” :
        - dialog : choisir destination par défaut (Conservé/Vendu/Consommé)
        - appelle une nouvelle méthode `recordSevrage(...)` enrichie (voir section D)

### C) Timeline gestation (enrichissement + i18n)
- Fichier : [gestation_timeline.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/widgets/portees/gestation_timeline.dart)
  - Remplacer les strings hardcodés (“Timeline gestation”, “Jour …”) par l10n.
  - Ajouter les descriptions des jalons (P1) :
    - J7 implantation
    - J25 préparer nid
    - J28 alerte
    - J31 mise bas
  - Conserver le rendu simple (pas de graph complexe), mais rendre “jalons” explicites.

### D) Sevrage : mise à jour lapereaux + destination par défaut (option mixte)
- Fichier : [portee_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/portee_provider.dart)
  - Étendre `recordSevrage` (ou créer `recordSevrageWithDestination`) pour :
    - mettre à jour `portees.statut = SEVRAGE` (déjà)
    - mettre à jour `lapins(statut) = REPOS` (déjà)
    - pour chaque lapereau du `porteeId` dont `statut == VIVANT` :
      - set `date_sevrage = today`
      - si “destination par défaut” choisie et si statut actuel est `VIVANT` :
        - set `statut = VENDU` ou `CONSERVÉ` ou `CONSOMMÉ`
      - persister offline-first :
        - cache local (Drift `LapereauxLocal`)
        - `syncManager.addMutation(tableName: 'lapereaux', operation: update, payload: ...)`
  - Source de la liste lapereaux :
    - priorité : `ref.read(lapereauxProvider(porteeId)).asData?.value`
    - fallback offline : `localCacheService.getLapereaux(userId, porteeId)`

### E) Notifications : robustesse + i18n
- Fichiers :
  - [portee_notifications_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/domain/services/portee_notifications_service.dart)
  - [local_notification_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/domain/services/local_notification_service.dart)
  - Ajouter des gardes :
    - ne pas programmer une notif si la date calculée (J-3/J-1 à 09:00) est déjà passée
  - Remplacer titres/bodies hardcodés par des strings l10n (passer title/body depuis appelant, ou introduire un mini “formatter” dans le service de portées).

### F) i18n (FR + EN)
- Fichiers :
  - [app_fr.arb](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/l10n/app_fr.arb)
  - [app_en.arb](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/l10n/app_en.arb)
  - Ajouter les clés manquantes utilisées par :
    - `SaillieFormScreen` (labels Femelle/Mâle/Date, consanguinité)
    - `MiseBasFormScreen` (titre, labels, validation)
    - `LapereauxScreen` (titre, empty state, edition)
    - `PreMiseBasChecklistCard` (title + items)
    - `GestationTimeline` (title + descriptions jalons)
    - `PorteeDetailScreen` (CTA + sections)
    - `PorteeListScreen` (microcopy “Saillie”, “jours restants”)

### G) Checklist tâches
- Fichier : [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md)
  - Cocher toutes les tâches P1 “Portées & Reproduction”.
  - Mettre la ligne “Notifications …” en cohérence avec la décision :
    - remplacer “Notifications push … FCM …” par “Notifications locales … (flutter_local_notifications)”.
  - Déplacer les tâches terminées dans “Fait”.

## Proposed Changes (Supabase)
### A) Migration “CONSOMMÉ”
- Déjà présent : [005_lapereaux_consomme.sql](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/migrations/005_lapereaux_consomme.sql)
- Exécution : appliquer la migration dans votre pipeline Supabase (self-hosted) comme d’habitude.

### B) Edge Function `consanguinity-check`
- Déjà présent : [index.ts](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/functions/consanguinity-check/index.ts)
- Déploiement :
  - via votre flux self-hosted existant (script `deploy_functions_server.sh` déjà prêt).

## Côté Supabase — Commandes / Vérifications
### 1) Vérifier que le statut “CONSOMMÉ” est actif côté DB
```sql
select conname, pg_get_constraintdef(c.oid)
from pg_constraint c
join pg_class t on t.oid = c.conrelid
where t.relname = 'lapereaux' and c.contype = 'c';
```

### 2) Vérifier les lapereaux et leurs statuts / date_sevrage
```sql
select id, portee_id, statut, sexe, poids_naissance_g, date_sevrage, created_at
from public.lapereaux
order by created_at desc
limit 50;
```

### 3) Tester consanguinity-check (curl)
```bash
curl -i https://TON_DOMAINE/functions/v1/consanguinity-check \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"mereId":"<UUID_FEMELLE>","pereId":"<UUID_MALE>"}'
```

## Verification (Flutter)
- `flutter pub get`
- `flutter gen-l10n`
- `dart run build_runner build --delete-conflicting-outputs` (si Drift nécessite regen `app_database.g.dart`)
- `flutter analyze`
- `flutter test`

## Où voir dans l’app (Acceptance)
- **Liste portées** : Onglet **Portées** → cartes avec badge statut + barre progression + “Jx — y jours restants”.
- **Nouvelle saillie** : Portées → bouton **+** → choisir femelle/mâle/date/notes → résultat consanguinité (OK/WARN/BLOCK) → enregistrer.
- **Détail portée** : Portées → ouvrir une portée :
  - si gestation : timeline + checklist J25 (≥ J25)
  - CTA “Enregistrer mise bas”
- **Mise bas** : Détail portée → “Enregistrer mise bas” → saisie → statut passe à Lactation + lapereaux créés.
- **Lapereaux** : Détail portée → “Lapereaux” → liste + édition (poids/sexe/statut incluant Consommé).
- **Sevrage** : Détail portée (statut Lactation) → “Enregistrer sevrage” → choix destination par défaut → date_sevrage appliquée + mère en REPOS.

