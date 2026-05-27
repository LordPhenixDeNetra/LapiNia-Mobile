# Plan — Corriger assets manquants + warnings Gradle

## Summary

- Corriger l’erreur bloquante `unable to find directory entry in pubspec.yaml` en créant les dossiers d’assets attendus.
- Réduire le bruit de build Android en supprimant les warnings Java `source/target value 8 is obsolete` via une configuration Gradle globale.
- Laisser les versions de dépendances actuelles (pas de montée de versions) afin de conserver un build stable.

## Current State Analysis

- Le projet déclare 3 dossiers d’assets dans [pubspec.yaml](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/pubspec.yaml#L72-L78) :
  - `assets/images/`
  - `assets/icons/`
  - `assets/data/`
- Ces dossiers n’existent pas dans le workspace, ce qui provoque l’échec de `flutter run` avant même le build Android.
- La configuration Android utilise déjà Java 17 dans [android/app/build.gradle.kts](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/android/app/build.gradle.kts#L8-L21). Les warnings `source/target value 8 is obsolete` proviennent donc très probablement de sous-modules/plugins Android qui compilent encore en Java 8.
- Le `flutter pub get` termine, mais indique des packages plus récents “incompatibles avec les contraintes”. Ce n’est pas bloquant tant que le projet compile, donc aucune action de mise à jour n’est prévue dans ce plan.

## Proposed Changes

### 1) Créer les dossiers d’assets attendus

**But**: rendre la config `assets:` du pubspec cohérente et éviter l’erreur bloquante au lancement.

- Créer les répertoires suivants à la racine du projet :
  - `assets/images/`
  - `assets/icons/`
  - `assets/data/`
- Ajouter un petit fichier placeholder par dossier (ex: `.gitkeep`) pour que Git conserve les répertoires vides et pour éviter toute ambiguïté côté outils.

Fichiers/dossiers impactés:
- Nouveaux: `assets/images/.gitkeep`, `assets/icons/.gitkeep`, `assets/data/.gitkeep`
- Aucun changement requis dans `pubspec.yaml` (on garde les entrées existantes).

### 2) Supprimer les warnings Java 8 “obsolete options”

**But**: éviter la répétition des warnings Java liés à `-source 8 / -target 8` émis par des dépendances Android, sans toucher au code de ces plugins.

- Ajouter dans [android/build.gradle.kts](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/android/build.gradle.kts) une configuration appliquée à tous les sous-projets Android :
  - pour chaque tâche `JavaCompile`, ajouter l’argument `-Xlint:-options`

Notes:
- Cela ne change pas le niveau de compatibilité Java (le projet reste en Java 17 côté app).
- Cela masque uniquement ce warning “options obsolètes” (et pas les autres lints Java).

## Assumptions & Decisions

- On conserve les contraintes et versions actuelles du `pubspec.yaml` (pas de `pub upgrade`/`--major-versions`).
- Les dossiers d’assets doivent exister même si l’app n’utilise pas encore d’images/icônes/données (objectif: supprimer l’erreur bloquante).
- Les warnings Java 8 ne doivent pas bloquer le build; on les supprime pour améliorer la lisibilité des logs.

## Verification Steps

- Exécuter `flutter pub get` et vérifier l’absence d’erreurs.
- Exécuter `flutter run` et vérifier :
  - absence des erreurs “unable to find directory entry … assets/*”
  - absence (ou forte réduction) des warnings `source value 8 is obsolete` / `target value 8 is obsolete`
- Si un build a été interrompu précédemment, exécuter un `flutter clean` avant relance (optionnel, seulement si nécessaire).

