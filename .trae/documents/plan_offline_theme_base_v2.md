## Résumé

Mettre en place une **gestion offline de base solide** (scope: **Lapins + Portées**) avec **CRUD offline + file de synchronisation**, et une **gestion de thème** (Système / Clair / Sombre) **persistée**, exposée via un **écran Settings dédié**.

Décisions validées :
- Offline : CRUD offline + synchro plus tard.
- Conflits : “Dernier écrit gagne”.
- Réglages : écran Settings dédié (route `/settings`).

## Analyse de l’existant (état actuel du repo)

### Offline / cache
- La DB locale Drift existe et contient déjà `LapinsLocal`, `PorteesLocal`, `SyncQueue` : [app_database.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/app_database.dart).
- Un service de cache local a été ajouté : [local_cache_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/local_cache_service.dart).
- Les providers métier **Lapins** / **Portées** lisent uniquement Supabase, sans fallback offline : [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart), [portee_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/portee_provider.dart).
- `SyncManager` persiste une queue en DB et tente de flusher à la reconnexion : [sync_manager.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/utils/sync_manager.dart).

Points bloquants à corriger :
- `LocalCacheService.upsertPortee()` utilise `portee.updatedAt`, mais le modèle `Portee` n’a pas de champ `updatedAt` → incohérence à corriger : [portee.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/portee.dart) + [local_cache_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/local_cache_service.dart).
- `LapinsController.create()` enfile `payload: data.toString()` (pas un JSON stable) : [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart).

### Thème (clair/sombre)
- `MaterialApp.router` est configurée en `themeMode: ThemeMode.system` (non persisté) : [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart).
- Beaucoup d’écrans forcent des couleurs via `AppColors.background`, `AppColors.white`, `AppColors.textDark`, ce qui casse le rendu en sombre : [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart) + autres fichiers listés dans “Changements”.
- Le thème global définit `inputDecorationTheme.fillColor: AppColors.white` (à adapter en sombre) : [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart).

## Changements proposés (décision-complete)

### 1) Corriger le modèle `Portee` (support cache/sync)

**Fichier :** [portee.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/portee.dart)
- Ajouter `updatedAt` (comme `Lapin`) :
  - `final DateTime updatedAt;` dans la classe.
  - `fromJson`: lire `updated_at`, fallback `created_at`.
  - `toJson`: inclure `updated_at`.
  - `copyWith`: inclure `updatedAt`.

**Pourquoi :**
- Le cache Drift stocke `updatedAt` et l’ordering dépend de ce champ.

### 2) Rendre `LocalCacheService` cohérent et utilisable

**Fichier :** [local_cache_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/local_cache_service.dart)
- Utiliser `updatedAt` cohérent pour `Portee` (après ajout dans le modèle).
- Conserver l’approche “JSON blob” (déjà en place) pour rester simple et rapide.
- Conserver `markLapinDeleted/markPorteeDeleted` pour les deletes offline.

### 3) Lapins : local-first + CRUD offline + queue sync

**Fichier :** [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart)

Objectif : `lapinsProvider` devient **local-first** :
- Si offline → lire `LocalCacheService.getLapins(userId)`.
- Si online → lire Supabase, puis `LocalCacheService.cacheLapins(userId, lapins)`.

Changements concrets :
- Injecter et utiliser :
  - `connectivityCheckerProvider` (online/offline)
  - `localCacheServiceProvider` (cache)
  - `syncManagerProvider` (queue persistée)
- Remplacer les payloads de sync par un JSON stable :
  - `payload: jsonEncode(data)` (au lieu de `data.toString()`).
- CRUD offline (politique “dernier écrit gagne”) :
  - **Create** :
    - Créer un `Lapin` “optimiste” (déjà construit par le formulaire).
    - Mettre à jour `state` immédiatement.
    - `LocalCacheService.upsertLapin(lapinAvecUpdatedAtNow)`.
    - `SyncManager.addMutation(tableName: 'lapins', operation: insert, payload: jsonEncode(data))`.
    - Si online : tenter l’insert Supabase + refresh/caching; si échec réseau → rester en mode offline (queue déjà prête).
  - **Update** :
    - Mettre à jour `state` immédiatement (remplacement par id).
    - Upsert cache local.
    - Enfiler mutation `update`.
    - Si online : tenter update Supabase + refresh/caching.
  - **Delete** :
    - Retirer de `state`.
    - `markLapinDeleted(id,userId)` en cache.
    - Enfiler mutation `delete` avec payload minimal (ex: `{ "id": "...", "user_id": "..." }`).
    - Si online : tenter delete Supabase + refresh/caching.

Hors scope (assumé) :
- `recordPesee()` touche `pesees` + update `lapins` : on le laisse **online-only** pour cette étape (afficher une erreur claire si offline).

### 4) Portées : local-first + CRUD offline + queue sync

**Fichier :** [portee_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/portee_provider.dart)

Objectif : `porteesProvider` devient **local-first** :
- Offline → cache local `LocalCacheService.getPortees(userId)`.
- Online → Supabase, puis `LocalCacheService.cachePortees(userId, portees)`.

CRUD offline :
- **Create** :
  - Mise à jour optimiste `state`.
  - Upsert cache local.
  - Enfiler `insert` dans `SyncManager`.
  - Si online : tenter insert Supabase + refresh/caching.
- **recordMiseBas / recordSevrage** :
  - Reste **online-only** pour cette version (cela touche aussi le statut de la mère dans `lapins`).
  - En offline : erreur claire “Action indisponible hors ligne”.

### 5) Thème persisté : `ThemeService` + provider Riverpod

**Nouveaux fichiers :**
- `lib/domain/services/theme_service.dart`
- `lib/presentation/providers/theme_provider.dart`

**ThemeService**
- Stockage dans `SharedPreferences` avec clé `theme_mode` (`system|light|dark`).
- API :
  - `Future<ThemeMode> getThemeMode()`
  - `Future<void> setThemeMode(ThemeMode mode)`

**Provider**
- `themeModeProvider = AsyncNotifierProvider<ThemeModeController, ThemeMode>`
- `ThemeModeController.build()` lit le `ThemeService` (async) et renvoie le mode.
- Méthode `setMode(ThemeMode mode)` persiste + met à jour `state`.

**DI**
- Enregistrer `ThemeService` dans [service_locator.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/di/service_locator.dart).
- Ajouter le provider get_it dans [core_providers.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/core_providers.dart).

**App**
- Modifier [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart) :
  - `themeMode:` devient `ref.watch(themeModeProvider).asData?.value ?? ThemeMode.system`.

### 6) Écran Settings dédié (offline/sync + thème)

**Nouveau fichier :**
- `lib/presentation/screens/settings/settings_screen.dart`

**Router**
- Ajouter une route `/settings` dans [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart).
- Le bouton settings du dashboard navigue vers `/settings`.

**Contenu de l’écran**
- Bloc “Connexion” :
  - statut Online/Offline (basé sur `ConnectivityChecker.isOnline` + stream).
  - créer `connectivityStatusProvider` (ex: `StreamProvider<bool>`) pour refléter les changements en UI.
- Bloc “Synchronisation” :
  - afficher `pendingMutations` (via `FutureProvider<int>` qui lit `syncManager.pendingMutations`).
  - bouton “Synchroniser maintenant” → `syncManager.forceSync()` + SnackBar succès/erreur.
  - bouton “Rafraîchir” (invalidate des providers de statut).
- Bloc “Thème” :
  - 3 radios: Système / Clair / Sombre.
  - action → `themeModeProvider.notifier.setMode(...)`.

### 7) Nettoyage dark-mode (base) : retirer les couleurs forcées

Objectif : sur les écrans principaux, éviter les `AppColors.white/background/textDark` hardcodés, et laisser le thème décider.

**Fichiers ciblés (priorité)**
- Dashboard : [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart)
- Auth & boot : `login_screen.dart`, `onboarding_screen.dart`, `welcome_screen.dart`, `splash_screen.dart`
- Lapins : `lapin_list_screen.dart`, `lapin_detail_screen.dart`, `lapin_form_screen.dart`
- Portées : `portee_list_screen.dart`, `portee_detail_screen.dart`, `saillie_form_screen.dart`
- Widgets communs : `alerte_banner.dart`, `statut_badge.dart`, `loading_widget.dart`, `lapin_card.dart`

**Règles de refactor**
- Pour les `Scaffold(backgroundColor: ...)` : supprimer l’override ou utiliser `Theme.of(context).scaffoldBackgroundColor`.
- Pour les surfaces de cartes/containers : utiliser `Theme.of(context).cardColor` / `ColorScheme.surface`.
- Pour les textes : ne plus forcer `AppColors.textDark` ; utiliser `Theme.of(context).textTheme` + `colorScheme.onSurface` si nécessaire.
- Conserver `AppColors.primary / danger / alert` comme couleurs “brand / statut”.

**Thème global**
- Adapter `inputDecorationTheme.fillColor` selon le mode (dark → une couleur de surface sombre).
- Adapter `chipTheme` et éventuels fonds “gris clair” à partir de `ColorScheme` au lieu de `AppColors.greyLight` quand ça impacte fortement le sombre.

### 8) Mise à jour du fichier de tâches

**Fichier :** [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md)
- Cocher / déplacer en “Fait” les items correspondant :
  - Offline Lapins+Portées (CRUD + cache + queue)
  - Thème persisté + settings
  - Nettoyage dark mode (écrans principaux)

## Hypothèses (assumées)
- L’Edge Function `sync` existe côté Supabase (ou sera implémentée ensuite). Côté app, on garantit une **queue persistée** et un **payload JSON stable**.
- Le “dernier écrit gagne” est appliqué côté client en envoyant l’update/delete sans comparaison de version.

## Vérifications (acceptance)

### Automatique
- `flutter analyze` (0 issues).
- `flutter test`.

### Manuelle (checklist)
- Démarrer app en ligne, ouvrir Lapins/Portées : les listes se chargent, puis se mettent en cache.
- Couper internet :
  - Revenir sur Lapins/Portées : les données s’affichent depuis le cache (pas d’erreur).
  - Créer / modifier / supprimer un lapin : l’UI se met à jour immédiatement, et `pending mutations` augmente.
  - Créer une portée : idem.
- Rebrancher internet :
  - Ouvrir Settings → “Synchroniser maintenant” : la queue se vide (ou diminue) ; si erreur, elle reste et le message est visible.
- Thème :
  - Choisir Clair/Sombre/Système dans Settings : effet immédiat.
  - Redémarrer l’app : le thème choisi est conservé.
- UI sombre :
  - Dashboard/Lapins/Portées/Settings restent lisibles en sombre (pas de texte “invisible” ni fonds blancs agressifs).

