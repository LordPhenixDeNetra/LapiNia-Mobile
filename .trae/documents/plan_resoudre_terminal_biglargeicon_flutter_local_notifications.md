## Resume

Le build Android echoue sur `flutter_local_notifications` (erreur Java: `bigLargeIcon(null)` ambigu a cause de 2 surcharges Bitmap/Icon). La solution propre est de mettre a jour `flutter_local_notifications` vers une version ou le correctif est integre (>= 17.2.1), puis re-verifier le build.

## Analyse De L Etat Actuel

- La commande `flutter run` echoue pendant `:flutter_local_notifications:compileDebugJavaWithJavac`.
- Message cle: `reference to bigLargeIcon is ambiguous ... both method bigLargeIcon(Bitmap) and bigLargeIcon(Icon) match`.
- Version actuelle resolue: `flutter_local_notifications 16.3.3` (depuis [pubspec.lock](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/pubspec.lock#L489-L496)).
- Contrainte actuelle: `flutter_local_notifications: ^16.0.0` dans [pubspec.yaml](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/pubspec.yaml#L45-L48).
- L appli ne reference pas directement `flutter_local_notifications` dans `lib/` (aucune occurrence), donc une mise a jour a peu de risques cote code Dart.
- Le desugaring Java 8 requis est deja active dans [android/app/build.gradle.kts](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/android/app/build.gradle.kts#L13-L49).

## Changements Proposes

### 1) Mettre a jour flutter_local_notifications

- Fichier: [pubspec.yaml](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/pubspec.yaml)
- Changement:
  - Remplacer `flutter_local_notifications: ^16.0.0` par `flutter_local_notifications: ^17.2.2`
- Pourquoi:
  - Le bug `bigLargeIcon(null)` est corrige a partir de `17.2.1` (upgrade recommande vers 17.2.1+).
- Impact:
  - Mise a jour transitive de `flutter_local_notifications_platform_interface` et potentiellement d autres sous-packages.
  - Peu ou pas de changements Dart attendus car aucune utilisation directe dans le code applicatif.

### 2) Regenerer le lockfile

- Executer `flutter pub get`
- Attendu:
  - [pubspec.lock](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/pubspec.lock) refletera une version >= 17.2.1.

### 3) Nettoyer et rebuild si necessaire

- Si Android Studio/Gradle conserve un cache incoherent:
  - `flutter clean`
  - `flutter pub get`
  - `flutter run`

## Alternative (Plan B) Si La Mise A Jour Est Bloquee

Si une contrainte externe empeche l upgrade, appliquer un correctif local (non ideal) en forçant le type sur l appel ambigu dans le code Java du plugin (pub cache) via cast explicite.
Cette option n est proposee qu en dernier recours car elle modifie le cache local et sera ecrasee au prochain `pub get`.

## Hypotheses Et Decisions

- Decision: choisir `^17.2.2` plutot que la derniere majeure (20/21) pour minimiser les breaking changes.
- Hypothese: la version Flutter installee est compatible avec `flutter_local_notifications 17.2.x`.

## Verification

1. `flutter pub get` sans erreur.
2. `flutter run` sur l appareil Android sans erreur de compilation Java.
3. (Optionnel) `flutter build apk --debug` passe.
