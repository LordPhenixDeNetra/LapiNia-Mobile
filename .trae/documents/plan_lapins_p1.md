# Plan — Terminer P1 « Lapins »

## 1) Résumé
Objectif : terminer toutes les tâches **P1** de la section **Lapins** dans `lapiNia_Taches_Flutter.md` en livrant une expérience “terrain” : liste paginée + filtres/recherche, CRUD robustes (idempotency), fiche lapin en onglets, photo (upload + affichage), suppression avec cascade locale, statut dynamique mis à jour par les événements.

Décisions utilisateur
- Photos : bucket **public** (URL directe stockée dans `photo_url`).
- Pagination : **scroll infini**.

## 2) État actuel (constats)
Source : section **Lapins** dans [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md#L46-L58).

Implémentation existante
- Liste Lapins : affichage + recherche locale + filtres locaux (statut/sexe) dans [lapin_list_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_list_screen.dart)
- Provider Lapins : charge tout (pas de pagination) + offline via cache Drift + CRUD optimiste + queue offline via `SyncManager` dans [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart)
- Fiche Lapin : écran unique (pas d’onglets) + record pesée online-only dans [lapin_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_detail_screen.dart)
- Détail Lapin : provider online-only (pas de fallback cache) : [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart#L260-L268)
- Formulaire Lapin : 1 page (pas 3 étapes), textes hardcodés, pas de photo : [lapin_form_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_form_screen.dart)
- Cache local : `LocalCacheService` ne fournit pas `getLapinById` et ne cascade pas la suppression : [local_cache_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/local_cache_service.dart)
- Supabase Storage : pas d’usage trouvé dans le code (aucune logique d’upload existante).

## 3) Définition “Done” (acceptance)
Les lignes P1 “Lapins” passent à **[x]** et sont déplacées dans “Fait”, et l’app respecte :
- Liste : pagination (limit=20) + scroll infini + pull-to-refresh + requête Supabase filtrée (statut/race/sexe) ; recherche locale sur `nom` + `numero_identification`.
- CRUD : create/update/delete via flow **idempotent** (edge function `sync` + Idempotency-Key) ; offline OK.
- Fiche : 4 onglets (Croissance / Santé / Reproductions / Infos) ; “Infos” reprend les champs existants ; les autres onglets peuvent afficher des placeholders tant que les modules P1 dédiés ne sont pas livrés.
- Photo : caméra/galerie + compression “best effort” < 200 Ko + upload Storage + affichage (liste + fiche + formulaire).
- Suppression : confirmation + suppression remote + **cascade SQLite** (au minimum tables locales liées via `lapinId`).
- Statut dynamique : lors d’une saillie/mise bas/sevrage (features existantes côté Portées), le statut du lapin est mis à jour **aussi en offline** (optimiste + queue).
- `flutter gen-l10n`, `flutter analyze`, `flutter test` OK.

## 4) Changements proposés (décision-complete)

### 4.1 Liste paginée + filtres serveur + recherche locale
**Fichiers :**
- [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart)
- [lapin_list_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_list_screen.dart)

1) Nouveau state de liste (pagination keyset)
- Remplacer `LapinsController extends AsyncNotifier<List<Lapin>>` par un state riche (ex: `LapinsListState`) :
  - `items: List<Lapin>`
  - `isRefreshing`
  - `isLoadingMore`
  - `hasMore`
  - `lastNom`, `lastId` (curseur keyset)
  - filtres : `statutDbValue`, `sexeDbValue`, `raceId`
- Pagination “keyset” (order `nom asc`, puis `id asc`) :
  - première page : `eq(user_id) + order(nom) + order(id) + limit(20)`
  - page suivante : ajouter un `.or("nom.gt.$lastNom,and(nom.eq.$lastNom,id.gt.$lastId)")`
- Offline :
  - si offline : charger `LocalCacheService.getLapins()` et appliquer pagination localement (slicing) + filtres + recherche.

2) UI “scroll infini”
- Dans `ListView.builder`, ajouter un item “loader” en bas + déclencher `loadMore()` quand index proche fin.
- Pull-to-refresh appelle `refresh()` et reset le curseur.
- Recherche locale (nom + numeroIdentification) reste côté UI (sur les `items` déjà chargés).

### 4.2 CRUD idempotent (online + offline via SyncManager)
**Fichiers :**
- [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart)
- [sync_manager.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/utils/sync_manager.dart)
- (si besoin) [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart) pour l’API call (déjà existant `_apiCall`)

But : satisfaire “idempotency key” de la tâche.
- Stratégie : toutes les mutations `lapins` passent via `SyncManager.addMutation()` (même online). Si online, `SyncManager` envoie immédiatement la mutation via edge function `sync` + header `Idempotency-Key`.
- Après confirmation (ou après refresh), recharger le lapin depuis Supabase (`select('*, races(*)')`) et mettre à jour cache + state.
- Maintenir l’optimisme UI (ajout/modif/suppression instantanés) comme aujourd’hui.

### 4.3 Fiche lapin en onglets + fallback offline
**Fichiers :**
- [lapin_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_detail_screen.dart)
- [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart)
- [local_cache_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/local_cache_service.dart)

1) Offline/stale-while-revalidate pour `lapinDetailProvider`
- Ajouter `LocalCacheService.getLapinById(userId, lapinId)`.
- Provider détail :
  - si offline : retourner cache (sinon erreur “lapin introuvable offline”)
  - si online : retourner cache si présent immédiatement, puis rafraîchir (invalidate/refresh) après fetch remote (ou afficher directement remote si cache absent).

2) UI Tabs
- `DefaultTabController(length: 4)` + `TabBar` + `TabBarView` :
  - Croissance : placeholder “à venir” (le module complet est dans “Pesées & Croissance” P1).
  - Santé : placeholder “à venir” (module complet dans section Santé).
  - Reproductions : placeholder “à venir” (module complet dans Portées).
  - Infos : reprendre le layout actuel (race, sexe, statut, poids, âge, id, notes).

### 4.4 Photo lapin (picker + compression + upload + affichage)
**Fichiers :**
- Nouveau `lib/domain/services/lapin_photo_service.dart`
- [lapin_form_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_form_screen.dart)
- [lapin_list_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_list_screen.dart)
- [lapin_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_detail_screen.dart)
- [core_providers.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/core_providers.dart) + [service_locator.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/di/service_locator.dart)

Pré-requis Supabase
- Bucket Storage **public** nommé `lapins` avec politique autorisant upload/lecture pour l’utilisateur (RLS/policies côté Supabase).

Implémentation (MVP robuste)
- Picker : `image_picker` (camera/galerie).
- Compression “best effort” : utiliser `image_picker` avec `imageQuality`, `maxWidth`/`maxHeight` ; contrôler la taille du fichier ; si >200 Ko, afficher un message et proposer de réessayer avec une qualité plus basse.
- Upload :
  - chemin : `lapins/{lapinId}.jpg`
  - `upsert: true`, `contentType: image/jpeg`
  - récupérer URL publique et l’écrire dans `photo_url`
- UI :
  - Liste : remplacer l’avatar icône par une vignette `CachedNetworkImage` si `photoUrl != null`.
  - Fiche : entête avec photo + bouton “Changer photo” (si online) ; sinon fallback.
  - Formulaire : composant “Photo” dans étape identité.

### 4.5 Suppression avec cascade SQLite
**Fichiers :**
- [local_cache_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/local_cache_service.dart)
- [app_database.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/app_database.dart) (si besoin de helpers)

Changements
- Dans `markLapinDeleted` :
  - marquer `LapinsLocal.isDeleted = true` comme aujourd’hui
  - cascade : marquer aussi en deleted toutes les entrées locales liées :
    - `PeseesLocal` (lapinId)
    - `SanteLocal` (lapinId)
    - autres tables dépendantes si présentes/pertinentes dans le schéma

### 4.6 Statut dynamique lapin (online + offline)
**Fichiers :**
- [portee_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/portee_provider.dart)
- [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart)
- [local_cache_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/local_cache_service.dart)

Objectif : assurer la cohérence statut même hors ligne.
- À la création d’une portée (saillie) :
  - update optimiste local du lapin mère → `EN_GESTATION` + cache
  - ajouter mutation sync “lapins update statut” en queue (si offline) ou via `SyncManager` (si online)
- À la mise bas / sevrage :
  - même approche (optimiste + queue) pour `LACTATION` puis `REPOS`

## 5) i18n + thème (minimum nécessaire)
**Fichiers :** `lib/l10n/app_fr.arb`, `lib/l10n/app_en.arb`
- Ajouter les libellés manquants pour photo (changer, choisir source), pagination (charger), placeholders onglets.
- Remplacer les chaînes hardcodées de [lapin_form_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_form_screen.dart) par `l10n`.

## 6) Mise à jour tâches + “où voir les nouveautés”
Après implémentation :
- Mettre à jour [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md) :
  - cocher et **déplacer** toutes les lignes P1 “Lapins” vers **Fait**.
- Dans la réponse finale :
  - indiquer **où voir** les nouveautés dans l’app (Lapins → Liste/fiche/photo).
  - indiquer **où voir** la liste “dernières fonctionnalités” dans le repo (section “Fait”).

## 7) Vérifications
- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`
- Tests manuels (Android) :
  - Liste Lapins : scroll infini + filtres + recherche.
  - Offline : activer mode avion → liste/fiche lapin accessibles via cache.
  - Photo : sélection + upload + affichage en liste/fiche.
  - Suppression : suppression lapin + vérifier que les données locales dépendantes ne restent pas visibles.

