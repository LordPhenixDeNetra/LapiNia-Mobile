## Résumé

Terminer toutes les tâches **P1** dans **“Base app & architecture”** :
- Modèles & sérialisation (audit + finitions)
- Gestion erreurs UI (mapping erreurs Supabase → messages utilisateur cohérents)
- Téléchargements fichiers (sauvegarde + partage OS)
- Internationalisation (mise en place ARB + gen-l10n, langues “grand public” uniquement)
- Observabilité (logs structurés uniquement, pas de Sentry)

Décisions validées (issues des réponses) :
- i18n : **ARB + gen-l10n**
- Wolof : **pas maintenant**
- Observabilité : **logs seulement**
- Téléchargements : **avec partage OS**

## Analyse de l’existant (état actuel)

### Modèles & sérialisation
Les modèles principaux existent déjà avec `fromJson/toJson` :
- [lapin.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/lapin.dart)
- [portee.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/portee.dart)
- [pesel.dart (Pesee)](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/pesel.dart)
- [evenement_sante.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/evenement_sante.dart)
- [stock.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/stock.dart)
- [finance.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/finance.dart)
- [alerte.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/alerte.dart)
- [race.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/race.dart)

### Gestion erreurs UI
- On a un mapping “humain” uniquement pour l’auth : [_humanizeAuthError](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/auth_provider.dart).
- Le reste de l’app affiche souvent `e.toString()` directement (ex: écrans, providers), sans classification (réseau / 401 / 403 / 429 / 5xx…).

### Téléchargements fichiers
- Dépendances `path_provider`, `pdf`, `printing` existent dans [pubspec.yaml](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/pubspec.yaml).
- Aucun service d’export/sauvegarde/partage n’est présent dans `lib/` (pas d’usage de `pdf`/`printing` repéré).
- `share_plus` n’est pas dans le projet actuellement.

### Internationalisation
- `intl` est présent, mais aucune infra l10n Flutter :
  - pas de `flutter_localizations`
  - pas de `l10n.yaml`
  - `MaterialApp.router` n’a pas `supportedLocales` / `localizationsDelegates`
  - les libellés UI sont majoritairement hardcodés
- Dates et FCFA ne sont pas centralisés (pas de formatters communs).

### Observabilité
- Pas d’intégration de Sentry (et on ne la fait pas).
- Pas de logger commun / pas de handlers globaux d’erreurs.

## Changements proposés (décision-complete)

### 1) Modèles & sérialisation (P1)

Objectif : assurer une sérialisation robuste et homogène (types, null-safety, dates).

**Actions**
- Audit des 8 modèles ciblés (ci-dessus) :
  - cohérence clés DB (`snake_case`) ↔ champs Dart
  - parsing numérique `int/double` (ex: `double.tryParse(...)`)
  - dates : `YYYY-MM-DD` pour champs “date” et ISO pour `created_at/updated_at` (comme déjà utilisé dans plusieurs modèles)
- Harmoniser ce qui doit l’être :
  - si un modèle contient `updated_at` en DB, prévoir fallback sur `created_at` (pattern déjà appliqué pour `Lapin` et désormais `Portee`)

**Fichiers impactés**
- `lib/core/models/*.dart` (uniquement les modèles mentionnés dans la tâche)

### 2) Gestion erreurs UI (mapping Supabase) (P1)

Objectif : éviter `e.toString()` brut et fournir des messages cohérents par cas :
- réseau/offline
- non authentifié (401)
- pas d’accès (403 / RLS)
- introuvable (404)
- conflit (409)
- rate limit (429)
- erreur serveur (5xx)

**Implémentation**
- Ajouter un mapper unique (utilisable partout) :
  - Nouveau fichier : `lib/core/utils/error_mapper.dart`
  - API proposée :
    - `String humanizeError(Object error)`
    - `bool isNetworkError(Object error)` (utile pour certains flows offline)
  - Support minimum :
    - `AuthException` (réutiliser/centraliser l’existant)
    - erreurs PostgREST / Functions / Storage (selon les types exposés par `supabase_flutter`)
    - fallback générique si type non reconnu
- Mettre à jour les providers/controllers pour utiliser ce mapping :
  - `LapinsController`, `PorteesController`, `AlertesController` (et tout controller P0/P1 déjà branché) afin que `state = AsyncValue.error(humanizeError(e), ...)` retourne un message user-friendly.

**Fichiers impactés**
- Nouveau : `lib/core/utils/error_mapper.dart`
- Modifiés :
  - [auth_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/auth_provider.dart)
  - [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart)
  - [portee_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/portee_provider.dart)
  - `lib/presentation/providers/alerte_provider.dart`

### 3) Téléchargements fichiers + partage OS (P1)

Objectif : une base solide pour “sauvegarder + partager” des PDF/exports.

**Dépendance**
- Ajouter `share_plus` dans [pubspec.yaml](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/pubspec.yaml).

**Service**
- Nouveau fichier : `lib/domain/services/file_share_service.dart`
- API proposée :
  - `Future<String> saveBytes({required List<int> bytes, required String filename})`
    - sauvegarde dans `getApplicationDocumentsDirectory()` (portable et sans permission)
  - `Future<void> shareFile({required String path, String? mimeType})`
    - utilise `Share.shareXFiles([XFile(path, mimeType: ...)])`

**Validation**
- Ajouter un petit “hook” d’usage dans Settings (optionnel) ou un test unitaire simple si faisable.
  - Dans un premier temps : test manuel via un bouton “Partager un fichier de test” (si tu veux), sinon juste service prêt.

### 4) Internationalisation (ARB + gen-l10n) (P1)

Objectif : mettre en place i18n “standard Flutter” et migrer les écrans principaux.

**Langues**
- FR + EN (langues grand public), pas de Wolof.

**Infra Flutter l10n**
- Ajouter dans `pubspec.yaml` :
  - `flutter_localizations: sdk: flutter`
  - `flutter: generate: true`
- Ajouter `l10n.yaml` à la racine :
  - `arb-dir: lib/l10n`
  - `template-arb-file: app_fr.arb`
  - `output-localization-file: app_localizations.dart`
  - `output-class: AppLocalizations`
- Ajouter les fichiers ARB :
  - `lib/l10n/app_fr.arb`
  - `lib/l10n/app_en.arb`

**Wiring app**
- Modifier [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart) :
  - `localizationsDelegates`
  - `supportedLocales`
  - utiliser `AppLocalizations` sur les libellés migrés

**Migration des textes (scope raisonnable P1)**
- Migrer au minimum :
  - Splash / Welcome / Login
  - Dashboard (titres, sections, boutons)
  - Settings
  - Lapins / Portées (titres + messages vides)

**Formatage dates & FCFA**
- Nouveau fichier : `lib/core/utils/formatters.dart`
  - `String formatDate(BuildContext context, DateTime date)` → `dd/MM/yyyy` via `intl`
  - `String formatFcfa(BuildContext context, int amount)` → `NumberFormat.currency(symbol: 'FCFA', decimalDigits: 0, name: 'XOF')`
- Remplacer les `'$day/$month/$year'` dans les écrans migrés par le formatter.

### 5) Observabilité : logs structurés (P1, sans Sentry)

Objectif : logs exploitables + capture des erreurs globales (au minimum).

**Logger**
- Nouveau fichier : `lib/core/utils/app_logger.dart`
  - `AppLogger.info(String message, {Map<String, Object?>? data})`
  - `AppLogger.warn(...)`
  - `AppLogger.error(String message, Object error, StackTrace st, {Map<String, Object?>? data})`
  - implémentation basée sur `dart:developer` (`log`) avec payload JSON.

**Handlers globaux**
- Dans [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart) :
  - `FlutterError.onError = ...` → logger
  - `PlatformDispatcher.instance.onError = ...` → logger

## Hors scope (pour éviter de déraper)
- Ajout de Wolof et traduction complète de toute l’app.
- Intégration Sentry / Crashlytics / service externe.
- Génération de PDF métier (passeport, registre…) si les écrans/flows ne sont pas encore présents.

## Vérifications (acceptance)

### Automatique
- `flutter analyze` (0 erreur)
- `flutter test`
- `flutter build apk --debug`

### Manuelle (checklist)
- Langue :
  - en changeant la langue système (FR/EN), les écrans migrés changent bien de libellés.
- Erreurs :
  - en coupant internet, les erreurs affichées sont “humaines” (et non `Exception: ...`).
- Partage :
  - sauvegarde d’un fichier puis partage OS fonctionne (Android).
- Logs :
  - une erreur volontaire (ex: exception déclenchée) ressort via `AppLogger` et est capturée par les handlers globaux.

