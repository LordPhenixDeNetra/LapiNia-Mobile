## Summary
- Mettre en place une **gestion hors ligne “de base mais solide”** pour les modules **Lapins + Portées** : lecture/écriture offline, mise en file (queue) des mutations, synchro à la reconnexion, et UI d’état (offline / sync en attente).
- Mettre en place une **gestion sombre/clair excellente** : choix **Système / Clair / Sombre**, préférence persistée, et correction des couleurs “hardcodées” qui cassent le thème sombre.
- Mettre à jour [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md) après implémentation (cases + “Fait”).<mccoremem id="01KSQAGTSDBZPAHR5BZY8HY8QT" />

## Current State Analysis (repo)
### Hors ligne
- Connectivité: `ConnectivityChecker` existe et expose `isOnline` + `onConnectivityChanged` : [connectivity_checker.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/utils/connectivity_checker.dart).
- Queue persistante: `SyncManager` + table Drift `SyncQueue` existent : [sync_manager.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/utils/sync_manager.dart), [app_database.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/app_database.dart#L105-L116).
- Tables locales JSON “génériques” existent (LapinsLocal/PorteesLocal/…) mais ne sont pas utilisées par les providers : [app_database.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/app_database.dart#L9-L28).
- Les providers `LapinsController` / `PorteesController` lisent/écrivent directement Supabase et échouent en offline (pas de fallback local) : [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart), [portee_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/portee_provider.dart).

### Thème
- `MaterialApp.router` utilise `themeMode: ThemeMode.system` sans persistance utilisateur : [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart#L182-L196).
- Plusieurs écrans forcent des couleurs `AppColors.background / AppColors.white / AppColors.textDark` qui rendent le dark mode incohérent : ex [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart#L24-L26).
- Le bouton settings existe déjà dans le Dashboard mais est vide : [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart#L46-L55).

## Intent / Decisions (confirmés)
- Offline scope: **Lapins + Portées** (priorité).
- Thème: choix **Système + Clair + Sombre** (persisté).

## Goals / Success Criteria
### Hors ligne
- En mode avion / sans internet :
  - Liste Lapins/Portées visible via cache local.
  - Création / modification / suppression Lapin/Portée possible (optimiste), sans crash.
  - Les actions sont ajoutées à `sync_queue` et marquées “en attente”.
- À la reconnexion :
  - La queue se traite automatiquement (ou via action “Synchroniser”).
  - Les écrans se rafraîchissent depuis Supabase et recachent en local.

### Thème
- L’utilisateur peut choisir **Système / Clair / Sombre** depuis une UI accessible.
- Le choix est persisté (redémarrage de l’app conserve le thème).
- Les écrans principaux (Login/Onboarding/Dashboard/Lapins/Portées) respectent le thème sombre.

## Proposed Changes (Implementation Plan)

### 1) Stockage local “local-first” (Lapins + Portées)
**Nouveaux fichiers**
- `lib/data/local_db/local_cache_service.dart`
  - Implémente un petit service au-dessus de Drift (`AppDatabase`) :
    - `getLapins(userId)`, `upsertLapin(lapin)`, `markLapinDeleted(id, userId)`
    - `getPortees(userId)`, `upsertPortee(portee)`, `markPorteeDeleted(id, userId)`
  - Encode/décode `data` en JSON (`jsonEncode`/`jsonDecode`) à partir des `toJson()/fromJson()` des modèles.

**Fichiers modifiés**
- `lib/presentation/providers/lapin_provider.dart`
  - Lecture:
    - Si `connectivityChecker.isOnline` → fetch Supabase → cache local → return.
    - Sinon → return cache local.
  - Mutations (create/update/delete/recordPesee):
    - Si offline (ou catch d’erreur réseau) :
      - écrire dans le cache local (optimiste)
      - pousser dans `SyncManager.addMutation(...)` avec un payload JSON
      - mettre à jour `state` sans appeler Supabase
    - Si online:
      - appeler Supabase
      - recacher en local
      - refresh

- `lib/presentation/providers/portee_provider.dart`
  - Même stratégie “local-first” que Lapins (create/recordMiseBas/recordSevrage + refresh).

**Remarques de compat**
- Ajuster `SyncManager.addMutation` pour stocker un payload JSON (string) cohérent (au lieu de `data.toString()`), afin de pouvoir rejouer proprement.

### 2) UI d’état offline + synchronisation
**Nouveaux providers**
- `lib/presentation/providers/offline_providers.dart`
  - `isOnlineProvider` (Provider<bool>) basé sur `ConnectivityChecker` (réactif via listen interne Riverpod).
  - `pendingSyncCountProvider` (FutureProvider<int>) basé sur `SyncManager.pendingMutations`.

**UI Settings (réutilise le bouton déjà présent)**
- `lib/presentation/screens/dashboard/dashboard_screen.dart`
  - Implémenter `onPressed` du bouton settings:
    - Ouvre un `showModalBottomSheet` affichant :
      - état: “En ligne / Hors ligne”
      - “X actions en attente”
      - bouton “Synchroniser maintenant” → `SyncManager.forceSync()` + refresh providers Lapins/Portées
      - bloc “Thème” (radio System/Clair/Sombre)

**Optionnel mais recommandé**
- Ajouter une petite bannière non-intrusive “Hors ligne” sur les écrans Lapins/Portées/Dashboard (ex: `MaterialBanner` ou `Container` en haut de `body`), en utilisant `isOnlineProvider`.

### 3) Gestion du thème (persisté)
**Nouveaux fichiers**
- `lib/domain/services/theme_service.dart`
  - Stocke la préférence dans `SharedPreferences` (clé `theme_mode`).
  - API: `Future<ThemeMode> getThemeMode()`, `Future<void> setThemeMode(ThemeMode mode)`.
- `lib/presentation/providers/theme_provider.dart`
  - `ThemeController extends AsyncNotifier<ThemeMode>`:
    - `build()` charge via `ThemeService`
    - `setMode(ThemeMode)` persiste + met à jour l’état immédiatement.

**Fichiers modifiés**
- `lib/core/di/service_locator.dart`
  - Enregistrer `ThemeService` (dépend de `SharedPreferences.getInstance()`).
- `lib/main.dart`
  - `themeMode:` piloté par `themeModeProvider` (fallback `ThemeMode.system` pendant chargement).
  - Corriger `ThemeData` pour le dark:
    - `inputDecorationTheme.fillColor` doit dépendre de `brightness` (éviter `AppColors.white` en dark).
    - harmoniser couleurs texte (label/hint) via `colorScheme.onSurfaceVariant`.

### 4) Nettoyage minimal des couleurs hardcodées
- Sur les écrans principaux (au minimum):
  - [login_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/auth/login_screen.dart)
  - [onboarding_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/auth/onboarding_screen.dart)
  - [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart)
  - `lapins/*` et `portees/*`
- Remplacer:
  - `backgroundColor: AppColors.background` → laisser le thème gérer (`Theme.of(context).scaffoldBackgroundColor`)
  - `color: AppColors.textDark` → `Theme.of(context).colorScheme.onSurface`
  - `AppColors.white` pour cartes/inputs → `Theme.of(context).colorScheme.surface`

### 5) Mise à jour des tâches
- Mettre à jour [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md) :
  - Ajouter/cocher les tâches “Offline (Lapins/Portées)” + “Thème (persisté + UI)”
  - Déplacer en “Fait” une fois validé.<mccoremem id="01KSQAGTSDBZPAHR5BZY8HY8QT" />

## Verification Steps
- `flutter analyze` (0 issue)
- `flutter test`
- Tests manuels Android (mode avion):
  - Ouvrir Lapins/Portées → contenu provient du cache
  - Créer un lapin/portée offline → visible immédiatement + compteur “actions en attente”
  - Repasser online → “Synchroniser maintenant” → compteur retombe à 0, refresh depuis Supabase
- Thème:
  - Changer thème dans settings → UI change instantanément
  - Redémarrer l’app → le thème reste identique

