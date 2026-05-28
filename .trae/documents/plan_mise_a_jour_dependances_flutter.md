## Summary
- Mettre à jour Flutter SDK (stable) puis mettre à jour les dépendances Dart/Flutter du projet (pubspec) au maximum compatible, corriger les éventuels breaking changes, et vérifier build/run.
- Mettre à jour systématiquement [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md) à la fin (cases à cocher + déplacement en “Fait”).<mccoremem id="01KSQAGTSDBZPAHR5BZY8HY8QT" />

## Current State Analysis (repo)
- Flutter channel: `stable` (metadata) et revision `19074d12f7eaf6a8180cd4036a430c1d76de904e` : [\.metadata](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/.metadata#L6-L9).
- `pubspec.yaml` contient plusieurs dépendances avec versions majeures plus récentes disponibles (ex: `go_router`, `get_it`, `google_fonts`, etc.) et un override `path_provider_android: 2.2.23` : [pubspec.yaml](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/pubspec.yaml#L6-L78).
- Plusieurs dépendances “en avance” (firebase, mobile_scanner, notifications, charts) ne sont pas encore utilisées dans `lib/` (peu de risques de refactor API immédiat).
- Le projet compile actuellement (avant upgrade) mais affiche “packages have newer versions incompatible with dependency constraints”.

## Goals / Success Criteria
- `flutter run` n’affiche plus la majorité des “(x.y.z available)” grâce à des contraintes mises à jour (au maximum possible après upgrade Flutter).
- `flutter pub get` OK + `flutter analyze` OK.
- `flutter test` OK.
- L’app démarre et les écrans principaux (Welcome/Login/Onboarding/Dashboard) fonctionnent.

## Assumptions & Decisions
- Décision utilisateur: upgrade Flutter SDK + upgrade dépendances (pas seulement contraintes compatibles). (confirmé via question)
- On reste sur le channel `stable`.
- On accepte d’ajuster le code pour les breaking changes (go_router / Riverpod / etc.) si nécessaire.

## Proposed Changes (Implementation Plan)

### 1) Upgrade Flutter SDK
- Exécuter:
  - `flutter channel stable`
  - `flutter upgrade`
  - `flutter --version` pour tracer la version finale.
- Vérifier `flutter doctor -v` pour s’assurer que Android toolchain / Java / Gradle sont OK.

### 2) Audit des dépendances “outdated”
- Exécuter:
  - `flutter pub outdated --mode=null-safety`
  - `flutter pub upgrade --major-versions`
- Objectif: obtenir la matrice “current / upgradable / resolvable / latest”.

### 3) Mettre à jour pubspec.yaml (contraintes)
- Mettre à jour [pubspec.yaml](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/pubspec.yaml) avec les versions proposées par `pub outdated` (section “resolvable” / “latest” après upgrade Flutter).
  - **Core**: `supabase_flutter`, `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `hooks_riverpod`, `flutter_hooks`, `get_it`, `go_router`, `google_fonts`, `flutter_secure_storage`, `shared_preferences`, `connectivity_plus`, `uuid`, `intl`.
  - **Dev**: `flutter_lints`, `drift_dev`, `build_runner`.
- Ajuster `environment.sdk` si Dart a été upgradé (par Flutter upgrade). Exemple: passer à `sdk: ">=3.x.0 <4.0.0"` (valeur exacte décidée après `flutter --version`).

### 4) Retirer / ajuster `dependency_overrides`
- Tentative: supprimer `dependency_overrides: path_provider_android: 2.2.23`.
- Refaire `flutter pub get`.
- Si un conflit réapparaît, soit:
  - mettre l’override sur la version requise par le solveur, soit
  - remonter le conflit au package qui le cause et fixer les contraintes.

### 5) Corriger les breaking changes (si compilation casse)
- `flutter analyze` pour lister les erreurs.
- Corrections typiques attendues:
  - `go_router`: changements de signatures, `state` API, ou comportements de redirect.
  - `hooks_riverpod`: éventuels changements sur AsyncNotifier / Provider.
  - `supabase_flutter`: évolutions mineures sur auth/session/types.
  - plugins Android: modifications Gradle/manifest selon les versions (notifs, storage).
- Vérifier en priorité les fichiers d’entrée:
  - [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart)
  - [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)
  - providers Riverpod dans `lib/presentation/providers/*`

### 6) Vérification build/run
- Exécuter:
  - `flutter clean` (si nécessaire après upgrade Flutter)
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`
  - `flutter run` sur l’appareil Android
- Smoke test manuel:
  - Splash → Welcome/Login → Onboarding → Dashboard
  - Navigation 5 onglets

### 7) Mise à jour des tâches
- Mettre à jour [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md) :
  - cocher les items “maintenance/dépendances” terminés
  - déplacer ces items dans “Fait” si nécessaire.<mccoremem id="01KSQAGTSDBZPAHR5BZY8HY8QT" />

## Verification Checklist (Definition of Done)
- `flutter pub get` : OK
- `flutter analyze` : 0 issue
- `flutter test` : OK
- `flutter run` : app démarre et flow principal OK
- `lapiNia_Taches_Flutter.md` : mis à jour

