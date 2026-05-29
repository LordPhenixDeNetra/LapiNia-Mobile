# Plan — Terminer toutes les tâches P1 « Lapins »

## **Résumé**
Objectif : terminer toutes les tâches **P1** de la section **Lapins** dans `lapiNia_Taches_Flutter.md` en livrant :
- Liste paginée (limit=20) + scroll infini + pull-to-refresh
- Filtres serveur (statut, race, sexe) + recherche locale (nom + numéro d’identification)
- CRUD idempotent via `SyncManager` (edge function `sync` + header `Idempotency-Key`), online et offline
- Fiche lapin en **onglets** + fallback offline (cache Drift)
- Photo lapin : picker + recadrage + compression < 200Ko + upload Supabase Storage (bucket public) + affichage (liste + fiche + formulaire)
- Suppression : confirmation + cascade SQLite (déjà partiellement en place)
- Statut dynamique : mise à jour automatique du statut du lapin lors des événements Portées (saillie → EN_GESTATION, mise bas → LACTATION, sevrage → REPOS), y compris offline (optimiste + queue)

Décisions confirmées :
- Pagination : **Nom A→Z** (keyset cursor sur `(nom, id)`)
- Photo : **avec recadrage** (image_cropper) et compression stricte < 200Ko
- Formulaire : 3 étapes avec généalogie = sélection **Père/Mère** et insertion dans la table Supabase `genealogie`

---

## **État actuel (constaté dans le repo)**
Référence tâches : `lapiNia_Taches_Flutter.md` (section “Lapins”, lignes P1).

### Liste
- Écran : `LapinListScreen` affiche une liste non paginée via `lapinsProvider` et fait :
  - recherche locale + filtres locaux (statut/sexe) dans l’UI
  - pas de filtres serveur, pas de pagination
- Provider : `LapinsController extends AsyncNotifier<List<Lapin>>`
  - online : fetch `lapins` (order `created_at desc`) puis cache local
  - offline : charge Drift via `LocalCacheService.getLapins`

### CRUD
- Online : `create/update/remove` utilisent directement Supabase `.insert/.update/.delete` (pas d’Idempotency-Key)
- Offline : les mutations sont bien mises en queue via `SyncManager.addMutation(...)`
- `SyncManager` est déjà câblé vers l’edge function `sync` via `_apiCall` dans `main.dart`

### Détail
- `lapinDetailProvider` : online-only, pas de fallback cache
- UI : `LapinDetailScreen` affiche “Infos” sur une seule page (pas d’onglets), pas de photo

### Photo
- Dépendances présentes : `image_picker`, `image_cropper`, `cached_network_image`
- Pas de service d’upload Storage actuellement, pas d’affichage d’images dans les écrans Lapins

### Cache local
- `LocalCacheService.getLapinById(...)` existe
- Suppression locale avec cascade partielle existe (LapinsLocal + PeseesLocal + SanteLocal)

### Statut dynamique
- `PorteesController.create` met à jour Supabase `lapins.statut` online, mais :
  - pas de mise à jour offline (queue manquante)
  - pas de mise à jour optimiste du cache/state Lapins

---

## **Proposed Changes (décision-complete)**

### 1) Liste paginée + filtres serveur + recherche locale
**Fichiers :**
- `lib/presentation/providers/lapin_provider.dart`
- `lib/presentation/screens/lapins/lapin_list_screen.dart`
- `lib/presentation/widgets/lapin_card.dart` (réutiliser ce widget au lieu du duplicat interne)

**1.1 Nouveau state riche (pagination keyset)**
- Remplacer `LapinsController extends AsyncNotifier<List<Lapin>>` par `LapinsController extends AsyncNotifier<LapinsListState>`.
- `LapinsListState` contient au minimum :
  - `items: List<Lapin>`
  - `isRefreshing: bool`
  - `isLoadingMore: bool`
  - `hasMore: bool`
  - curseur keyset : `lastNom: String?`, `lastId: String?`
  - filtres serveur : `StatutLapin? statut`, `SexeLapin? sexe`, `String? raceId`

**1.2 Fetch online (Supabase)**
- Query base :
  - `.from('lapins').select('*, races(*)').eq('user_id', userId)`
  - filtres :
    - si `statut != null` → `.eq('statut', statut.dbValue)`
    - si `sexe != null` → `.eq('sexe', sexe.dbValue)`
    - si `raceId != null` → `.eq('race_id', raceId)`
  - tri et pagination :
    - `.order('nom', ascending: true).order('id', ascending: true).limit(20)`
    - page suivante (keyset) :
      - ajouter un filtre type `(nom > lastNom) OR (nom == lastNom AND id > lastId)`
      - implémentation Supabase : `.or('nom.gt.$lastNom,and(nom.eq.$lastNom,id.gt.$lastId)')` (avec échappement/quoting si nécessaire)

**1.3 Fetch offline (Drift)**
- Charger `LocalCacheService.getLapins(userId)` puis appliquer :
  - filtres statut/sexe/race sur la liste
  - pagination locale : `skip(page*20).take(20)`
- `hasMore` est déterminé via la taille (si on obtient 20 items, on suppose qu’il y a une page suivante).

**1.4 UI liste**
- `LapinListScreen` :
  - passer à `LapinsListState` (items + loader + loadMore)
  - scroll infini :
    - `ListView.builder(itemCount: items.length + (hasMore ? 1 : 0))`
    - dernier item = loader, et déclenche `loadMore()` quand on approche de la fin
  - pull-to-refresh → `ref.read(lapinsProvider.notifier).refresh()`
  - recherche locale conservée dans l’UI, appliquée uniquement sur `state.items` déjà chargés.

**1.5 Filtres**
- Convertir le bottom sheet en filtres “typed” (pas des strings) :
  - Statut : `StatutLapin?`
  - Sexe : `SexeLapin?`
  - Race : dropdown basé sur `racesProvider`
- À l’application des filtres : appeler `setFilters(...)` sur le controller, reset curseur + reload.

---

### 2) CRUD Lapins idempotent (online + offline) via SyncManager
**Fichiers :**
- `lib/presentation/providers/lapin_provider.dart`
- (optionnel) `lib/core/utils/sync_manager.dart` si besoin d’un helper “fire-and-refresh”

Objectif : pour `create/update/delete`, utiliser **le même chemin** (queue) en online et offline.

**2.1 Create**
- Conserver l’optimisme UI + cache local immédiat.
- Au lieu de `.insert` Supabase direct :
  - `await syncManager.addMutation(tableName: 'lapins', operation: insert, payload: jsonEncode(data))`
  - si online : `SyncManager` enverra immédiatement via l’edge function `sync` avec `Idempotency-Key`
- Après enqueue (ou après un délai court / ou à la fin d’un écran) : déclencher `refresh()` pour resynchroniser la liste depuis Supabase si online.

**2.2 Update**
- Même stratégie : update optimiste local + enqueue mutation `lapins` update via `SyncManager`.
- Si online : `refresh()` pour réconcilier avec le serveur.

**2.3 Delete**
- Garder la suppression optimiste (retirer de la liste) + `LocalCacheService.markLapinDeleted` (déjà cascade partielle).
- Enqueue mutation `lapins` delete via `SyncManager` (même online).
- Si online : `refresh()`.

---

### 3) Fiche lapin en onglets + fallback offline
**Fichiers :**
- `lib/presentation/providers/lapin_provider.dart`
- `lib/presentation/screens/lapins/lapin_detail_screen.dart`
- `lib/data/local_db/local_cache_service.dart` (déjà OK pour `getLapinById`)

**3.1 Provider détail (offline-first)**
- Remplacer `lapinDetailProvider = FutureProvider.family(...)` par un controller `LapinDetailController extends AsyncNotifier<Lapin?>` en `family`.
- Stratégie :
  - si offline : retourner `LocalCacheService.getLapinById(userId, lapinId)` (sinon erreur “introuvable hors ligne”)
  - si online :
    - charger d’abord le cache si présent (pour affichage immédiat)
    - fetch remote `select('*, races(*)')` (limiter les joins non utilisés)
    - upsert cache + mettre à jour state

**3.2 UI onglets**
- `DefaultTabController(length: 4)` + `TabBar` + `TabBarView` :
  - Croissance : placeholder (“à venir”) + CTA vers futur module Pesées
  - Santé : placeholder (“à venir”)
  - Reproductions : placeholder (“à venir”)
  - Infos : reprendre le contenu actuel (race, sexe, statut, poids, âge, ID, notes)

---

### 4) Photo lapin (recadrage + compression + upload + affichage)
**Fichiers :**
- Nouveau : `lib/domain/services/lapin_photo_service.dart`
- `lib/core/di/service_locator.dart` + `lib/presentation/providers/core_providers.dart` (provider du service)
- `lib/presentation/widgets/lapin_card.dart`
- `lib/presentation/screens/lapins/lapin_list_screen.dart`
- `lib/presentation/screens/lapins/lapin_detail_screen.dart`
- `lib/presentation/screens/lapins/lapin_form_screen.dart`

**4.1 Service `LapinPhotoService`**
- Responsabilités :
  - pick image (camera/galerie) via `image_picker`
  - recadrage + compression via `image_cropper` (avec `compressQuality` et éventuellement `maxWidth/maxHeight`)
  - contrôle strict du poids : si `> 200 * 1024`, refuser et demander de recommencer (message clair)
  - upload Supabase Storage (bucket `lapins`, public) :
    - path : `{lapinId}.jpg` (ou `lapins/{lapinId}.jpg` si convention choisie, à garder stable)
    - `upsert: true`, `contentType: image/jpeg`
  - récupérer l’URL publique via `getPublicUrl(path)` et la renvoyer

**4.2 Persist `photo_url`**
- Après upload, appeler `updateLapin(...)` (via `SyncManager`) pour écrire `photo_url` dans la row `lapins`.
- Refresh liste + détail si online.

**4.3 Affichage**
- `LapinCard` :
  - si `lapin.photoUrl != null` → `CachedNetworkImage` (circle/rounded) à la place de l’icône
  - fallback : icône sexe comme aujourd’hui
- `LapinDetailScreen` :
  - header avec photo (si dispo)
  - action “Changer photo” (désactivée si offline)
- `LapinFormScreen` :
  - dans étape “Identité”, composant photo :
    - si nouveau lapin : l’image est uploadée **après** la création (on a besoin de l’ID)
    - si édition : upload direct + update `photo_url`

Pré-requis Supabase :
- Bucket public `lapins` + policies lecture/écriture pour l’utilisateur (côté Supabase).

---

### 5) Formulaire lapin 3 étapes (identité + paramètres + généalogie)
**Fichiers :**
- `lib/presentation/screens/lapins/lapin_form_screen.dart`
- `lib/presentation/providers/lapin_provider.dart` (pour accéder à la liste lapins en sélection)

**5.1 UX**
- Remplacer le formulaire “1 page” par une navigation en 3 étapes :
  - Étape 1 : Identité (photo, nom*, race, sexe)
  - Étape 2 : Paramètres (date naissance, statut, poids, numéro identification, notes)
  - Étape 3 : Généalogie (sélection facultative d’un père et/ou d’une mère)
- Le bouton final “Créer / Mettre à jour” déclenche :
  - create/update du lapin via `lapinsProvider.notifier`
  - si père/mère sélectionnés :
    - insertion dans table `genealogie` via `SyncManager.addMutation` :
      - payload `{'lapin_id': lapinId, 'parent_id': pereId, 'role': 'PERE', 'generation': 1}`
      - payload `{'lapin_id': lapinId, 'parent_id': mereId, 'role': 'MERE', 'generation': 1}`
  - si photo choisie :
    - upload storage puis update `photo_url`

**5.2 Contraintes**
- Empêcher de sélectionner le lapin lui-même comme parent.
- Empêcher de choisir le même parent pour père et mère.

---

### 6) Statut dynamique lapin (online + offline)
**Fichiers :**
- `lib/presentation/providers/portee_provider.dart`
- `lib/presentation/providers/lapin_provider.dart`
- `lib/data/local_db/local_cache_service.dart`

**6.1 Saillie (create portée)**
- À la création (optimiste) :
  - mettre à jour localement le lapin mère → `EN_GESTATION` :
    - dans `lapinsProvider` : helper `setLapinStatutOptimistic(lapinId, statut)`
    - upsert cache
  - en offline : enqueue une mutation `lapins` update statut via `SyncManager` en plus de la mutation `portees` insert
  - en online : idem (queue) + refresh.

**6.2 Mise bas / Sevrage**
- Autoriser l’action en offline (au lieu de throw) :
  - mettre à jour optimiste du statut mère
  - enqueue la mutation `lapins` update statut
  - enqueue la mutation `portees` update statut (et champs) si nécessaire
- En online : exécuter via queue + refresh.

---

### 7) i18n (Lapins) + nettoyage des strings hardcodées
**Fichiers :**
- `lib/l10n/app_fr.arb`
- `lib/l10n/app_en.arb`
- `lib/presentation/screens/lapins/lapin_list_screen.dart`
- `lib/presentation/screens/lapins/lapin_form_screen.dart`

Champs à localiser :
- Bottom sheet filtres (“Filtrer”, “Statut”, “Sexe”, “Race”, “Réinitialiser”, “Appliquer”)
- Form 3 étapes (titres, labels, validations, boutons next/back/save)
- Photo (choisir source, recadrer, erreurs taille >200Ko, pas de réseau)
- Placeholders onglets de la fiche

---

### 8) Mise à jour du fichier tâches (après implémentation)
**Fichier :**
- `lapiNia_Taches_Flutter.md`

Après validation :
- Cocher et déplacer dans “Fait” toutes les lignes P1 de la section “Lapins” :
  - liste paginée
  - filtres
  - recherche
  - créer (3 étapes + idempotency)
  - fiche onglets
  - modifier
  - supprimer + cascade
  - photo + upload + compression
  - statut dynamique

---

## **Vérifications**
- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`
- Tests manuels :
  - Liste : scroll infini, pull-to-refresh, filtres (statut/race/sexe), recherche locale
  - Offline : activer mode avion → ouvrir liste et fiche depuis cache (`getLapinById`)
  - CRUD : créer/modifier/supprimer offline puis repasser online → vérifier synchronisation
  - Photo : choisir → recadrer → upload → affichage liste + fiche, erreurs si >200Ko
  - Statut dynamique : créer une saillie offline → vérifier statut mère passe à EN_GESTATION dans la liste et se synchronise ensuite

