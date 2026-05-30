# Plan — P1 “QR Code & Traçabilité”

## Summary
Terminer les tâches **(Flutter · P1)** du bloc **QR Code & Traçabilité** :
- Génération QR code (`qr_flutter`) — encodage `lapinia://lapin/{id}`
- Affichage + partage + impression QR code
- Scanner QR code (`mobile_scanner`) — ouverture directe de la fiche lapin
- Identifiant unique auto-généré `{PAYS}-{ANNÉE}-{RACE}-{NUMÉRO}`

Le plan inclut systématiquement :
- **Où voir dans l’app**
- **Côté Supabase** : requêtes SQL/commandes + vérifications

## Current State Analysis (repo)
### Déjà présent
- Dépendances déjà installées : `qr_flutter`, `mobile_scanner`, `printing`, `pdf`, `share_plus` : [pubspec.yaml](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/pubspec.yaml#L45-L68)
- Champ DB + modèle pour identifiant : `numero_identification` :
  - Modèle : [lapin.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/lapin.dart#L5-L98)
  - Migration : `lapins.numero_identification TEXT UNIQUE` : [001_initial_schema.sql](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/migrations/001_initial_schema.sql#L30-L48)
- Routes existantes :
  - Fiche lapin : `/lapin/:id` : [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)
- Écran création/édition lapin possède déjà un champ `numeroController` (mais pas d’auto-génération) : [lapin_form_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_form_screen.dart#L38-L178)
- Service de partage fichier (utilise `share_plus`) : [file_share_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/domain/services/file_share_service.dart)

### Manquant
- Aucun écran dédié QR Code (plein écran + partager + imprimer).
- Aucun écran scanner.
- Pas d’entrée UI pour scanner / voir QR.
- Pas de deep-link platform (Android/iOS) pour scheme `lapinia://`.
- Pas d’auto-génération de `numero_identification` au moment de la création.

## Decisions & Assumptions (figées)
### A) QR code (payload)
- Le contenu du QR code est **toujours** : `lapinia://lapin/{id}` (où `{id}` est l’UUID du lapin).
- Dans l’app, le scan navigue directement vers `/lapin/:id` (sans passer par un navigateur).

### B) Deep link OS (ouvrir l’app depuis un QR scanné hors app)
- Android + iOS configurés pour ouvrir l’app quand l’utilisateur scanne un QR `lapinia://lapin/{id}` dans un scanner externe.
- Le routeur mappe `lapinia://lapin/<uuid>` → `/lapin/<uuid>`.

### C) Identifiant unique `{PAYS}-{ANNÉE}-{RACE}-{NUMÉRO}`
- Généré automatiquement **si le champ est vide** lors de la création.
- Source `PAYS` :
  - depuis `OnboardingProfile.country` si disponible, sinon fallback sur 2 lettres.
  - mapping stable (ex: Sénégal→SN, Mali→ML, Côte d’Ivoire→CI).
- Source `RACE` :
  - si `Race.nom` est déjà un code (ex: “NZW”), on le prend tel quel (normalisé).
  - sinon : 3 premières lettres alphanum uppercase.
- Source `NUMÉRO` :
  - compteur local (SharedPreferences) par clé `(PAYS, ANNÉE, RACE)` ; format 4 chiffres, ex `0042`.
- Limite acceptée P1 : compteur local = possible collision multi-appareils. Le champ est unique côté DB : en cas de conflit, l’utilisateur pourra modifier le numéro (P2 pourra ajouter résolution automatique).

### D) Impression
- Utiliser `printing` (dialogue d’impression système). Cela couvre aussi les imprimantes Bluetooth si elles sont déclarées au niveau OS (selon Android/driver).

## Proposed Changes (Flutter)
### 1) Auto-génération de `numero_identification`
- Fichier : [lapin_form_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_form_screen.dart)
  - Avant `submit()`, si `numeroController.text` est vide :
    - récupérer `country` depuis `onboardingProfileServiceProvider.getProfile()`
    - récupérer `year = DateTime.now().year`
    - récupérer un `raceCode` depuis la `Race` sélectionnée
    - demander un compteur local via un nouveau service (ci-dessous) et renseigner le champ
- Nouveau service :
  - `lib/domain/services/lapin_identifier_service.dart`
    - `Future<String> generateNumeroIdentification({required String? country, required int year, required String? raceCode})`
    - stocker le compteur dans `SharedPreferences`
- DI :
  - enregistrer dans [service_locator.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/di/service_locator.dart)
  - provider dans [core_providers.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/core_providers.dart)

### 2) Écran “QR Code lapin” (plein écran)
- Nouveau fichier :
  - `lib/presentation/screens/lapins/lapin_qr_screen.dart`
- UI :
  - QR en grand via `QrImageView` (qr_flutter)
  - Texte sous QR : nom + `numero_identification` (si présent) + id
  - Boutons :
    - **Partager** : capture QR + texte en image PNG via `RepaintBoundary` → `FileShareService.shareFile(...)`
    - **Imprimer** : générer un mini PDF (pdf package) contenant QR + info, puis `Printing.layoutPdf(...)`

### 3) Accès “Voir QR code” depuis fiche lapin
- Fichier : `lib/presentation/screens/lapins/lapin_detail_screen.dart`
  - Ajouter un bouton/icone “QR” dans l’AppBar (ou une action dans la section infos) → route `/lapin/:id/qr`.

### 4) Scanner QR code
- Nouveau fichier :
  - `lib/presentation/screens/qr/qr_scanner_screen.dart`
- Implémentation :
  - `MobileScanner` (mobile_scanner)
  - Parsing :
    - si valeur commence par `lapinia://lapin/` :
      - extraire `{id}` (path segment)
      - `context.go('/lapin/$id')`
    - sinon : message “QR non reconnu”.

### 5) Navigation / routes
- Fichier : [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)
  - Ajouter routes :
    - `/lapin/:id/qr` → `LapinQrScreen(lapinId: id)`
    - `/qr/scan` → `QrScannerScreen()`
  - Ajouter un mapping deep-link dans `redirect` :
    - si `state.uri.scheme == 'lapinia' && state.uri.host == 'lapin'`
      - prendre `state.uri.pathSegments.first` comme id
      - rediriger vers `/lapin/<id>`

### 6) Entrées UI
- Fichier : [plus_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/plus/plus_screen.dart)
  - Ajouter tuile “Scanner QR” → `context.push('/qr/scan')`
- Optionnel (si souhaité) : ajouter un bouton scan dans `LapinListScreen` AppBar.

### 7) Deep linking platform (Android/iOS)
- Android :
  - `android/app/src/main/AndroidManifest.xml` : intent-filter pour scheme `lapinia` + host `lapin`
- iOS :
  - `ios/Runner/Info.plist` : `CFBundleURLTypes` pour scheme `lapinia`

### 8) i18n + tâches
- i18n :
  - `lib/l10n/app_fr.arb` + `lib/l10n/app_en.arb` : libellés (Scanner QR, QR Code, Partager, Imprimer, erreurs).
- Tâches :
  - Cocher les 4 items P1 “QR Code & Traçabilité” et les déplacer dans “Fait” dans [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md).

## Côté Supabase (commandes / vérifs)
### 1) Vérifier contrainte d’unicité identifiant
```sql
select count(*) from public.lapins where numero_identification is not null;

select numero_identification, count(*) as c
from public.lapins
where numero_identification is not null
group by numero_identification
having count(*) > 1;
```
Attendu : aucun doublon.

### 2) Vérifier une fiche lapin via identifiant (utile debug)
```sql
select id, user_id, nom, numero_identification, created_at
from public.lapins
where numero_identification is not null
order by created_at desc
limit 20;
```

## Où voir dans l’app (acceptance)
- **Création lapin** :
  - Lapins → “+” → créer un lapin sans remplir “Identifiant” → il est auto-rempli au moment de l’enregistrement.
- **QR Code** :
  - Lapins → ouvrir fiche lapin → bouton “QR” → QR plein écran + Partager + Imprimer.
- **Scanner** :
  - Plus → Scanner QR → scan d’un QR `lapinia://lapin/{id}` → ouverture fiche lapin.
- **Deep link externe** :
  - Scanner externe (app caméra) sur QR `lapinia://lapin/{id}` → ouverture lapiNia directement sur la fiche.

## Verification (tech)
- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`
- Test manuel Android :
  - Scan in-app + scan externe
  - Partage image QR via Share sheet
  - Impression via dialogue système

