# Plan — Terminer les tâches P0 “Base app & architecture”

## Summary
Objectif : terminer (ou finaliser si partiel) toutes les tâches **(Flutter · P0)** de la section **Base app & architecture** dans [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md#L18-L39), en alignant l’app sur :
- hooks + Riverpod (choisi)
- DI `get_it`
- runtime config (env + feature flags)
- session sécurisée
- base locale Drift + queue de sync persistante
- Splash/Boot + guard go_router
- Theme (Poppins/Nunito via `google_fonts`) + bottom nav 5 onglets
- mise à jour du fichier de tâches (checkbox + section “Fait” si présente)

## Current State Analysis (repo)
Constats basés sur l’état actuel du code :
- Navigation déjà en place avec `go_router` : [AppRouter](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/app_router.dart).
- Bottom nav existante mais **3 onglets** (au lieu de 5) : [MainShellScreen](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/main_shell_screen.dart).
- Initialisation Supabase + lecture config runtime (dart-define + assets `.env` + JSON) déjà présente : [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart#L18-L120).
- State management actuellement via `flutter_bloc` (Auth/Lapin/Portee/Alerte) : [presentation/blocs](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/blocs/).
- Interfaces déjà présentes : [BaseRepository](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/interfaces/base_repository.dart), [AIProvider](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/interfaces/ai_provider.dart).
- Drift est déjà dans les dépendances, mais pas de DB locale structurée/“11 tables” ni queue persistante : [pubspec.yaml](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/pubspec.yaml#L18-L21) + `SyncManager` actuel (queue mémoire) : [sync_manager.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/utils/sync_manager.dart).
- Splash/boot et redirect “onboarding/dashboard/login” ne sont pas réellement appliqués (initialLocation `'/welcome'`) : [AppRouter](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/app_router.dart#L22-L40) + [WelcomeScreen](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/auth/welcome_screen.dart).
- Thème existe, mais pas explicitement Poppins/Nunito + dark mode : [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart#L290-L397).

## Proposed Changes (decision-complete)

### 1) Dépendances & conventions (P0 Setup projet)
**Fichiers**
- [pubspec.yaml](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/pubspec.yaml)

**Changements**
- Ajouter :
  - `hooks_riverpod` + `flutter_hooks` (migration choisie)
  - `get_it` (DI exigée par la checklist)
  - `flutter_secure_storage` (session sécurisée)
  - `google_fonts` (Poppins + Nunito)
  - `drift_flutter` si nécessaire (selon usage actuel de Drift)
- Garder `flutter_bloc` uniquement le temps de la migration si nécessaire, puis le retirer quand plus utilisé.
- Confirmer/ajuster `flutter_lints` déjà présent.

### 2) Runtime config (P0 Configuration runtime)
**Fichiers**
- [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart)
- Nouveau : `lib/core/config/app_config.dart`
- Nouveau : `lib/core/config/env_loader.dart`

**Changements**
- Introduire un `AppConfig` (immutable) contenant :
  - `environment` (dev|staging|prod) via `APP_ENV` (dart-define ou assets `.env`)
  - `supabaseUrl`, `supabaseAnonKey`
  - `timeouts` (ex: `apiTimeoutMs`)
  - `featureFlags` (ex: `SUPABASE_FUNCTIONS_ENABLED`, `OFFLINE_ENABLED`, `AI_ENABLED`)
- Conserver le mécanisme actuel (dart-define → assets `.env` → JSON), mais ajouter le parsing des champs ci-dessus.

### 3) DI get_it (P0 DI + singleton)
**Fichiers**
- Nouveau : `lib/core/di/service_locator.dart`

**Changements**
- Enregistrer dans GetIt :
  - `AppConfig`
  - `SupabaseClient` (singleton `Supabase.instance.client`)
  - `FlutterSecureStorage`
  - DB Drift (singleton)
  - Repositories (Lapins/Portées/Pesées/Alertes/etc — au moins ceux utilisés par l’app actuelle)
  - `SyncManager`

### 4) Supabase client + session sécurisée (P0 Client + Gestion session)
**Fichiers**
- Nouveau : `lib/data/supabase/supabase_client_factory.dart` (si utile pour centraliser init/options)
- Nouveau : `lib/domain/services/session_service.dart`
- Modifs : `lib/main.dart`, `lib/presentation/router/app_router.dart`

**Changements**
- Initialiser Supabase une seule fois (déjà fait), mais :
  - Ajouter un `SessionService` qui :
    - persiste la session (tokens + expiration) dans `flutter_secure_storage`
    - restaure au démarrage
    - clear au logout
  - Standardiser la source de vérité auth : `supabase.auth.onAuthStateChange`

### 5) Migration BLoC → hooks_riverpod (demandé)
**Fichiers**
- Remplacer progressivement :
  - `lib/presentation/blocs/auth/*` → `lib/presentation/providers/auth_provider.dart`
  - idem pour Lapin/Portee/Alerte (au minimum les 4 providers nécessaires au routing et aux écrans existants)
- Mettre à jour les screens vers `HookConsumerWidget` (pas de `StatefulWidget`)

**Décision**
- Utiliser `AsyncValue` / `Notifier` / `AsyncNotifier` (Riverpod 2) pour standardiser chargement/erreurs.

### 6) SQLite local Drift — 11 tables + migrations (P0)
**Fichiers**
- Nouveau : `lib/data/local_db/app_database.dart` (Drift)
- Nouveau : `lib/data/local_db/tables/*.dart`
- Génération : `build_runner` (drift_dev déjà présent)

**Tables (11)**
- `lapins_local`, `portees_local`, `pesees_local`, `sante_local`, `stocks_local`, `finances_local`, `alertes_local`
- `races_ref`, `medicaments_ref`, `aliments_locaux_ref`
- `sync_queue` (+ éventuellement `idempotency_keys` si on sépare)

**Migrations**
- Mettre en place `schemaVersion` + stratégie de migration (Drift).

### 7) IdempotencyKey persistée (P0)
**Fichiers**
- [idempotency_key.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/utils/idempotency_key.dart)
- DB Drift (`sync_queue` ou table dédiée)

**Changements**
- Générer UUID v4 (déjà dépendance `uuid`)
- Avant tout appel réseau “mutating” (insert/update), écrire dans DB :
  - `idempotency_key`
  - `operation`
  - `payload hash`
  - `created_at`
- Après succès confirmé, supprimer l’entrée.

### 8) SyncManager skeleton persistant (P0)
**Fichiers**
- [sync_manager.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/utils/sync_manager.dart)
- Nouveau : `lib/core/utils/persistent_queue.dart` (ou dans `data/local_db`)

**Changements**
- Remplacer la queue mémoire par une queue Drift (`sync_queue`)
- Ajouter un `ConnectivityStream` (connectivity_plus) :
  - quand online : flush queue
  - retry avec backoff + max retries
- Garder l’API `enqueue(table, op, payload)` existante, mais persistante.

### 9) Splash/Boot + Auth guard go_router (P0)
**Fichiers**
- Modifs : [app_router.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/app_router.dart)
- Nouveau : `lib/presentation/screens/splash/splash_screen.dart`
- Nouveau : `lib/presentation/providers/bootstrap_provider.dart`

**Changements**
- `initialLocation` → `/splash`
- Splash déclenche :
  - init DI (get_it)
  - init supabase (si pas déjà)
  - restore session
  - déterminer destination :
    - pas de session → `/welcome` (ou `/login`)
    - session + onboarding incomplet → `/onboarding`
    - session + onboarding ok → `/dashboard`
- Guard go_router :
  - utiliser `refreshListenable` / `GoRouterRefreshStream` branché sur le provider auth (sinon redirect non réactif)

### 10) AppColors / AppTheme + dark mode (P0)
**Fichiers**
- [app_colors.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/constants/app_colors.dart)
- [app_typography.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/constants/app_typography.dart)
- Modifs : `main.dart` (MaterialApp themes)

**Changements**
- Confirmer palette (semble déjà présente).
- Refaire AppTypography via `google_fonts` :
  - Titres : Poppins
  - Corps : Nunito
- Ajouter `darkTheme` + `ThemeMode.system`

### 11) Bottom Navigation Bar — 5 onglets (P0)
**Fichiers**
- [main_shell_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/main_shell_screen.dart)
- [app_router.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/app_router.dart)
- Nouveaux écrans placeholders :
  - `lib/presentation/screens/aliments/aliments_screen.dart`
  - `lib/presentation/screens/ia/ia_screen.dart`

**Changements**
- Étendre ShellRoute avec routes `/aliments` et `/ia`
- Modifier la bottom nav à 5 items (Accueil/Lapins/Portées/Aliments/IA)
- Les 2 nouveaux onglets affichent un écran simple “à venir” (P0 = wiring navigation)

### 12) Mettre à jour le fichier de tâches (obligatoire)
**Fichiers**
- [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md)

**Changements**
- Cocher toutes les tâches P0 terminées.
- Si certaines restent partiellement faites après implémentation, les annoter “En cours” (sans changer la structure globale).
- Déplacer dans “Fait” si le fichier contient une section dédiée (sinon rester dans la section actuelle cochée).

## Assumptions & Decisions
- Migration vers hooks_riverpod est **dans le scope** (choix utilisateur).
- `google_fonts` est accepté pour Poppins/Nunito (choix utilisateur).
- Drift sera utilisé comme base locale principale (déjà présent dans pubspec).
- Les onglets “Aliments” et “IA” seront livrés en P0 comme navigation + écrans placeholder; la logique métier détaillée reste en P1/P2.

## Verification Steps
- `flutter pub get`
- `dart run build_runner build -d` (génération Drift)
- `flutter analyze`
- Tests manuels :
  - Démarrage → Splash → redirection correcte (logout/login)
  - Navigation 5 onglets (ShellRoute) sans crash
  - Session persistée : kill app → relaunch → reste connecté
  - Mode avion : actions offline mises en queue (au moins une mutation) → retour online → flush
- Vérifier que [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md) est mis à jour (P0 cochées).

