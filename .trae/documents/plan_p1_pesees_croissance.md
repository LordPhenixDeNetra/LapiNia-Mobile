# Plan — Terminer P1 « Pesées & Croissance »

## 1) Résumé
Objectif : terminer toutes les tâches **P1** de la section **Pesées & Croissance** dans [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md#L52-L60) en livrant :
- enregistrement de pesées (poids + date) avec flux idempotent (online + offline queue),
- liste paginée des pesées d’un lapin (limit 50),
- calcul local du GMQ (gain moyen quotidien) entre pesées,
- graphique de croissance (courbe réelle + courbe cible race + zones couleur),
- détection “décrochage GMQ” (badge sur fiche + alerte dashboard),
- prédiction de croissance via Edge Function `predict-growth` (courbe prévisionnelle + repères 10/12/14 semaines + “date de vente optimale”).

## 2) État actuel (constats)
Sources :
- Tâches P1 “Pesées & Croissance” : [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md#L52-L60)
- Écran fiche lapin (onglet Croissance) : placeholder dans [lapin_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_detail_screen.dart#L178-L359)

Implémentation existante (partielle) :
- Ajout “pesée rapide” : `FloatingActionButton` sur la fiche lapin, saisie d’un poids uniquement (pas de date) et insert direct Supabase dans [recordPesee](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_detail_screen.dart#L52-L84) → appelle [LapinsController.recordPesee](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart#L391-L416).
- Pas de liste des pesées, pas de graphique, pas de GMQ, pas de prédiction, pas d’alerte.
- Modèle `Pesee` déjà présent : [pesel.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/core/models/pesel.dart) (nom de fichier atypique mais utilisable).

Base Supabase déjà en place :
- Table `pesees` + RLS : [001_initial_schema.sql](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/migrations/001_initial_schema.sql#L120-L142)
- Table `alertes` (type inclut `PESEE`) + RLS : [001_initial_schema.sql](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/migrations/001_initial_schema.sql#L242-L269)
- Edge Function `predict-growth` existe dans le repo : [predict-growth/index.ts](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/functions/predict-growth/index.ts)

## 3) Définition “Done” (acceptance)
Les 6 lignes P1 “Pesées & Croissance” passent à **[x]** et sont déplacées dans “Fait”, et l’app respecte :
- Ajouter pesée : saisie poids (g) + date (sélecteur) + création idempotente (queue offline + exécution immédiate online) ; met à jour `lapins.poids_actuel_g`.
- Liste pesées : vue dédiée dans l’onglet “Croissance” (fiche lapin), pagination **offset** (limit 50), affichage date + poids + GMQ calculé.
- GMQ : calcul local entre 2 pesées consécutives (tri par date), arrondi lisible.
- Graphique croissance : `fl_chart` avec :
  - courbe réelle (bleu) à partir des pesées,
  - courbe cible race (vert pointillé),
  - zones couleur (au minimum : sous-cible / proche-cible / au-dessus).
- Alerte décrochage : si GMQ < 80% de la norme race sur une période d’au moins 7 jours :
  - badge rouge visible sur la fiche lapin (onglet Croissance),
  - création d’une alerte `alertes.type = 'PESEE'` visible dans le dashboard.
- Prédiction : bouton “Prédire” (online-only) qui appelle `/functions/v1/predict-growth`, affiche une courbe prévisionnelle + repères 10/12/14 semaines et une “date vente optimale” dérivée.
- `flutter gen-l10n`, `flutter analyze`, `flutter test` OK.

## 4) Checklist Supabase (à faire / vérifier)
À vérifier avant de tester le module (auto-hébergé ou cloud) :
- Table `pesees` existe avec colonnes : `id`, `lapin_id`, `user_id`, `date`, `poids_g`, `gmq_depuis_derniere`, `notes`, `created_at` ; RLS active + policy `pesees_user_isolation`.
- Table `alertes` existe et autorise `INSERT/SELECT` pour l’utilisateur (RLS + `alertes_user_isolation`) ; valeur `type='PESEE'` acceptée.
- Edge Function `predict-growth` est déployée sur le serveur et répond sur `/functions/v1/predict-growth` (401 sans token attendu).
- Si l’app utilise la function `sync` (recommandé pour idempotency), la version déployée est à jour et la table `idempotency_keys` est OK.

## 5) Changements proposés (décision-complete)

### 5.1 Provider Pesées paginé (online + offline cache)
**Nouveaux éléments Flutter :**
- Un provider dédié, sur le modèle de `LapinsController`, par exemple :
  - `PeseesListState(items, isRefreshing, isLoadingMore, hasMore, offset)`
  - `PeseesController extends AsyncNotifier<PeseesListState>` en `family(lapinId)`

**Online (offset-based comme la tâche)**
- Requête Supabase : `from('pesees').select().eq('lapin_id', lapinId).order('date', descending: true).range(offset, offset+49)`
- Page suivante : augmenter `offset += 50`.

**Offline**
- Ajouter à `LocalCacheService` :
  - `getPeseesByLapin(userId, lapinId)` (tri date desc),
  - `cachePesees(userId, lapinId, pesees)` / `upsertPesee(pesee)` / `markPeseeDeleted`.
- En offline, la pagination est faite localement (slicing 50).

### 5.2 Ajout pesée idempotent (online + offline queue)
**Objectif :** satisfaire “idempotency key”.

Changements :
- Remplacer l’insert direct (online-only) par un flux via `SyncManager.addMutation()` :
  1) Mutation `pesees insert` avec un `id` UUID généré (idempotencyKey utilisé par SyncManager pour la requête `sync`).
  2) Mutation `lapins update` pour `poids_actuel_g` (et `updated_at`).
- UI optimiste :
  - ajouter la pesée au state local et la mettre en cache Drift immédiatement,
  - mettre à jour le poids actuel du lapin dans le cache/liste.

UI :
- Remplacer le dialogue actuel “poids seul” par un formulaire léger (dialog/bottom sheet) :
  - poids (g) obligatoire,
  - date obligatoire (prérempli à aujourd’hui),
  - (optionnel) notes.

### 5.3 GMQ local
Règles :
- Trier les pesées par date croissante pour le calcul (même si la liste est affichée décroissante).
- Pour chaque pesée `i` (sauf la première) :
  - `deltaPoids = poids[i] - poids[i-1]`
  - `deltaJours = max(1, date[i] - date[i-1])`
  - `gmq = deltaPoids / deltaJours`
- Affichage dans la liste : “+X g/j” (ou “—” si impossible).

### 5.4 Graphique croissance (réel vs cible vs zones)
UI dans l’onglet “Croissance” de la fiche lapin :
- Un composant `GrowthChart` basé sur `fl_chart` :
  - série réelle : points `(date, poids_g)` en bleu,
  - série cible : ligne verte en pointillé :
    - calculée via `race.gmqCibleG` si disponible, sinon fallback linéaire vers `poidsAdulteMaxKg`.
  - zones : remplissage de fond en 3 bandes (sous 80% cible / 80–110% cible / >110% cible).

### 5.5 Alerte “décrochage GMQ” + badge fiche + alerte dashboard
Détection :
- Dès qu’on a au moins 2 pesées + une race avec `gmqCibleG`,
- Calculer le GMQ sur la dernière période (ou la période cumulée la plus récente) :
  - si `deltaJours >= 7` et `gmq < 0.8 * gmqCibleG` → décrochage.

Badge sur fiche :
- Dans l’onglet Croissance, afficher un badge rouge “GMQ faible” + valeur GMQ vs cible.

Alerte dashboard (persistante) :
- Créer/mettre à jour une entrée dans `alertes` :
  - `type='PESEE'`, `priorite=2`, `lapin_id`, `message` explicite, `date_echeance=now`.
- Anti-duplication :
  - avant insert, vérifier s’il existe déjà une alerte non lue `type='PESEE'` pour ce lapin avec un message “GMQ faible” récent.

### 5.6 Prédiction croissance (Edge Function `predict-growth`)
Flutter :
- Ajouter un `GrowthPredictionService` similaire à [DailyAdviceService](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/domain/services/daily_advice_service.dart) qui fait :
  - `supabase.functions.invoke('predict-growth', body: {raceId, poidsActuelG, ageJours, userId})`
- Exposer via provider (FutureProvider.family ou AsyncNotifier).

UI :
- Bouton “Prédire” visible uniquement si online + `ageJours` + `poidsActuelG` disponibles.
- Afficher :
  - courbe prévisionnelle (orange) sur 30 jours (donnée par l’edge function),
  - repères 10/12/14 semaines : conversions `ageJours` → dates, et poids estimés sur la courbe,
  - “date vente optimale” : heuristique locale (ex: première date où le poids atteint un seuil : `poidsAdulteMinKg` ou un pourcentage de `poidsAdulteMaxKg`).

## 6) Fichiers concernés (prévision)
- UI :
  - [lapin_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_detail_screen.dart) (remplacer l’onglet Croissance placeholder)
  - (ajout) widgets croissance : `GrowthChart`, `PeseeList`, `AddPeseeDialog`
- Providers :
  - `pesee_provider.dart` (nouveau) : pagination + refresh + loadMore + offline fallback
  - (adaptation) [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart) : retirer `recordPesee` direct ou le déléguer au nouveau module
  - [alerte_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/alerte_provider.dart) : utilisé tel quel (création alerte via Supabase depuis module croissance)
- Local cache :
  - [local_cache_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/local_cache_service.dart) : ajouter méthodes `pesees`
- Domain services :
  - `growth_prediction_service.dart` (nouveau) + injection dans `service_locator.dart` / `core_providers.dart` (comme `DailyAdviceService`)
- i18n :
  - `lib/l10n/app_fr.arb`, `lib/l10n/app_en.arb` : libellés growth (GMQ, prédiction, erreurs)

## 7) Vérifications
- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`
- Tests manuels (Android) :
  - Ajouter une pesée (poids + date) → vérifier nouvelle ligne en base `pesees` + poids actuel du lapin mis à jour.
  - Offline : mode avion → ajouter pesée → vérifier apparition dans la liste locale + enqueue sync ; repasser online → vérifier remontée Supabase.
  - Liste : scroll jusqu’en bas → charger page suivante (50).
  - GMQ : vérifier affichage cohérent entre 2 pesées.
  - Décrochage : créer 2 pesées espacées de 7 jours avec GMQ bas → badge + alerte dashboard.
  - Prédiction : bouton “Prédire” → courbe orange + repères.

