# Plan — Terminer P1 « Dashboard »

## 1) Résumé
Objectif : terminer toutes les tâches **P1** de la section **Dashboard** dans `lapiNia_Taches_Flutter.md` en rendant le dashboard vraiment “fonctionnel” (KPIs complets, conseil IA réel avec cache 24h, alertes actionnables, timeline 7 jours, pesée rapide, score de rentabilité).

## 2) État actuel (constats)
**Tâches P1 à faire (Dashboard)** : voir [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md#L40-L49).

**Implémentation actuelle**
- Écran principal : [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart)
  - KPIs partiels (lapins/gestantes/attendus) calculés localement.
  - “Conseil du jour” est un texte localisé mais **statique** (pas de function + pas de cache 24h).
  - Alertes : affichage top 3 via `alertesNonLuesProvider`, action “fait” (mais pas “marquer lue” explicite).
  - “Timeline 7 jours” inexistante.
  - “Pesée rapide” inexistante (sheet “Enregistrer” ne fait rien).
  - “Score rentabilité” inexistant.
- Données disponibles :
  - Lapins offline/local-first : [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart)
  - Portées offline/local-first : `porteesProvider` (non relu ici mais existant)
  - Alertes non lues : `alertesNonLuesProvider` dans [alerte_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/alerte_provider.dart)
  - Cache SQLite Drift existant mais **sans table** pour “daily advice” : [app_database.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/app_database.dart), [local_cache_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/local_cache_service.dart)
  - Onboarding profile local (SharedPreferences) récemment ajouté : [onboarding_profile_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/domain/services/onboarding_profile_service.dart)

## 3) Définition “Done” (acceptance)
- Le Dashboard coche toutes les P1 :
  - KPIs : nb lapins, nb gestantes, nb attendus, **prochaine naissance**.
  - Conseil IA du jour : appel `daily-advice` + **cache 24h en SQLite** (+ fallback si function indisponible).
  - Alertes : top 3 triées priorité + action “marquer comme lue” + “action faite”.
  - Timeline 7 jours : affiche les événements à venir (mises bas prévues + évènements planifiés pesée/vaccin).
  - Pesée rapide : ajout de pesée **depuis le dashboard** sans navigation.
  - Rentabilité : appel `rentability-score` + affichage score/100 + 3 actions (+ fallback).
- `flutter gen-l10n`, `flutter analyze`, `flutter test` passent.
- `lapiNia_Taches_Flutter.md` : tâches Dashboard P1 cochées + déplacées dans **Fait**.

## 4) Changements proposés (décision-complete)

### 4.1 KPIs complets (avec prochaine naissance)
**Fichier :** [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart)
- Étendre `_buildKpiGrid` :
  - Calculer **prochaine naissance** à partir des `portees` en gestation :
    - `dateMiseBasPrevue ?? dateSaillie + 31j`
    - prendre la plus proche dans le futur.
  - Ajouter un 4e KPI (carte) ou passer sur une grille 2x2 (plus lisible) :
    - “Prochaine naissance” : date + J‑N restant.
- i18n : nouvelles clés pour libellés/format (date + jours restants).

### 4.2 Conseil IA du jour + cache 24h (SQLite/Drift)
**Objectif :** vraie feature “P1” et offline-friendly.

1) Stockage SQLite (Drift)
- Modifier [app_database.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/data/local_db/app_database.dart)
  - Ajouter une table `DailyAdviceCache` :
    - `id` (text, primary key) : `${userId}-${yyyyMMdd}`
    - `userId` (text)
    - `content` (text)
    - `cachedAt` (datetime)
  - Ajouter un `MigrationStrategy` + bump `schemaVersion` (ex: 2) pour créer la table à l’upgrade sans casser les installs existantes.

2) Service
- Créer `lib/domain/services/daily_advice_service.dart`
  - `Future<String> getAdvice({required String userId, required Map<String, dynamic> context})`
  - Règles :
    - Lire cache SQLite (<= 24h) → retourner.
    - Sinon appeler `supabase.functions.invoke('daily-advice', body: context)`
    - Interpréter réponse :
      - `String` direct
      - ou `{ advice/message/content: "..." }`
    - En erreur → fallback local (texte) et/ou dernier cache existant.
  - Le `context` inclut (si dispo) :
    - onboarding profile local (pays/objectifs/expérience)
    - quelques stats (nb lapins, nb gestantes, etc.)

3) Provider Riverpod
- Ajouter `dailyAdviceProvider` dans `lib/presentation/providers/dashboard_providers.dart` (nouveau fichier)
  - `FutureProvider<String>` qui compose `DailyAdviceService` + dépendances.

4) UI
- Modifier `_buildConseilCard` pour afficher le texte venant du provider (loading/error/empty unifiés).

### 4.3 Alertes prioritaires + “marquer comme lue”
**Fichiers :**
- [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart)
- [alerte_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/alerte_provider.dart)

Changements :
- Dans la liste top 3 du dashboard :
  - Ajouter une action “marquer comme lue” (icône `done`) → `AlertesController.markAsRead(id)`.
  - Conserver l’action “action faite” → `markAsActionDone`.
  - Couleur priorité : error/tertiary/primary (déjà cohérent).
- Vérifier que la query est bien triée par priorité (`order('priorite')`) (déjà présent dans `alertesNonLuesProvider`).

### 4.4 Timeline 7 jours
**Objectif :** donner une vision “ce qui arrive bientôt”.

1) Modèle
- Créer `lib/core/models/dashboard_timeline_event.dart`
  - `DateTime date`
  - `String title`
  - `String subtitle`
  - `String? route` (ex: `/portee/:id`, `/lapin/:id`)
  - `String type` (`birth|vaccin|weight|other`)

2) Source de données “minimale mais complète P1”
- **Mises bas** : depuis `porteesProvider` :
  - garder les gestations dont la date prévue est dans `[today..today+7]`.
- **Pesées programmées / vaccinations** :
  - Ajouter une table Drift `PlannedEvents` (ou `Reminders`) :
    - `id`, `userId`, `type` (`WEIGHT`/`VACCINE`), `targetId` (lapinId), `date`, `note`, `createdAt`
  - Ajouter un mini service `planned_events_service.dart` (CRUD minimal) + provider.
  - Dans le dashboard, afficher les événements de `PlannedEvents` sur 7 jours.

3) UI
- Ajouter une section “Timeline (7 jours)” sous les alertes :
  - `LoadingWidget` / `ErrorDisplayWidget` / `EmptyStateWidget`
  - Liste verticale (7 jours) ou “cards” compactes.
  - Tap sur event avec `route` → navigation.

### 4.5 Widget “Pesée rapide” (2 taps)
**Objectif :** enregistrer une pesée sans quitter le dashboard.

Implémentation :
- Modifier `_showRecordEventSheet` (dashboard)
  - Tap “Pesée” :
    - Ouvrir une bottom sheet “Pesée rapide”
    - Étape courte :
      1) sélectionner un lapin (ListTile / Dropdown)
      2) saisir poids (champ numérique) + bouton “Enregistrer”
  - Appeler `LapinsController.recordPesee(lapinId, poidsG)` (déjà existant).
  - Si offline : afficher un message clair (action indisponible hors ligne).

### 4.6 Score de rentabilité
**Objectif :** carte “score /100 + 3 actions”.

1) Modèle
- Créer `lib/core/models/rentability_score.dart` :
  - `int score`
  - `List<String> actions`

2) Service
- Créer `lib/domain/services/rentability_service.dart`
  - Appel `supabase.functions.invoke('rentability-score', body: { userId, kpis, maybe stocks/finances summary })`
  - Fallback local si function indisponible :
    - règles simples basées sur : nb lapins, gestantes, pending mutations, présence de saillies, etc.

3) UI
- Ajouter une carte sur le dashboard (entre Conseil et KPIs, ou sous la Timeline) :
  - Score visible + 3 actions en bullets.

## 5) i18n
- Modifier `lib/l10n/app_fr.arb` + `lib/l10n/app_en.arb` :
  - KPI “prochaine naissance”
  - Timeline “7 jours”
  - Pesée rapide (labels champs, erreurs)
  - Rentabilité (titre, libellés)
- `flutter gen-l10n` après ajout des clés.

## 6) Mise à jour des tâches + “où voir les nouveautés”
Après implémentation :
- Mettre à jour [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md)
  - cocher et **déplacer** toutes les lignes P1 de “Dashboard” vers **Fait**.
- Dans la réponse finale, indiquer :
  - **où voir les nouveautés dans l’app** (Dashboard + sections ajoutées)
  - **où voir la liste dans le repo** (section “Fait” du fichier tâches).

## 7) Vérifications
- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`
- Tests manuels :
  - Dashboard s’affiche en offline (lapins/portees depuis cache) et conseil IA via cache/fallback.
  - Pesée rapide : en online, crée une pesée et reflète le poids (au moins sur le lapin concerné après refresh).
  - Alertes : “marquer lue” retire l’alerte de la liste non lue.
  - Timeline : affiche les mises bas + événements planifiés sur 7 jours.

