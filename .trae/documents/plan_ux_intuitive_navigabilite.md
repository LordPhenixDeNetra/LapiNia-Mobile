# Plan — Refonte UX (intuitive + navigabilité)

## 1) Résumé
Objectif : rendre l’app **très facile d’usage** et **intuitive** en réduisant la charge cognitive, en harmonisant les états UI (chargement/erreur/vide/offline), et en rendant la navigation plus “prévisible” (où je suis / comment revenir / comment trouver une fonctionnalité).

Décisions validées :
- Navigation : **4 onglets + “Plus”** (onglet secondaire type hub).
- 4e onglet principal : **IA**.
- Accueil (dashboard) : **Actions rapides + alertes** en priorité.
- Guidage : **léger** (micro-copies + empty states avec CTA + 1–2 tooltips “first run” max).

## 2) Critères de succès (acceptance)
- Un utilisateur débutant peut (sans aide) :
  - Ajouter un lapin, créer une saillie, et comprendre l’état “offline/sync en attente”.
  - Retrouver Aliments + Réglages via “Plus” en moins de 2 taps.
- Navigation cohérente :
  - Le bouton back a un comportement stable (retour écran précédent dans la même section).
  - Les formulaires restent en plein écran (root navigator) pour éviter de “perdre” la stack d’un onglet.
- UI cohérente :
  - Les écrans clés n’affichent plus `CircularProgressIndicator()`/`Text(e.toString())` “bruts” : utilisation systématique de `LoadingWidget` / `ErrorDisplayWidget` / `EmptyStateWidget`.
  - Les libellés principaux (bottom nav, “Plus”, textes durs visibles) sont localisés (FR/EN).

## 3) État actuel (constats)
### 3.1 Navigation
- Routing basé sur `StatefulShellRoute.indexedStack` avec 5 onglets (dont Aliments), et formulaires `lapin/new`, `lapin/:id/edit`, `saillie/new` ouverts via `parentNavigatorKey` root : bon pour la navigabilité.
  - Fichiers : [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart), [main_shell_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/main_shell_screen.dart)
- Les labels de la bottom bar sont actuellement en dur (FR).

### 3.2 Dashboard
- “Actions rapides” + bannière connectivité déjà présentes.
- Deux sections restent non harmonisées :
  - Alertes : `CircularProgressIndicator()` + `Text(e.toString())`, bouton “Voir tout” non branché.
  - Prochaines portées : idem + strings en dur (`'Mère'`, progression “Jx”, etc.).
  - Fichier : [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart)

### 3.3 Composants communs existants
- États UI unifiés déjà présents :
  - `LoadingWidget`, `EmptyStateWidget`, `ErrorDisplayWidget`, `OfflineBanner`
  - `ConnectivityBanner` (offline + pending + CTA sync)
  - Fichiers : [loading_widget.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/widgets/common/loading_widget.dart), [connectivity_banner.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/widgets/common/connectivity_banner.dart)

### 3.4 Écrans “liste” vs “détail”
- Listes Lapins/Portées déjà partiellement harmonisées, mais quelques textes restent en dur.
  - Fichiers : [lapin_list_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_list_screen.dart), [portee_list_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/portee_list_screen.dart)
- Détail Lapin (et probablement d’autres écrans détail) : loading/error non harmonisés + beaucoup de textes en dur.
  - Fichier : [lapin_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_detail_screen.dart)

## 4) Changements proposés (décision-complete)

### 4.1 Navigation : passer à “4 + Plus”
**Objectif :** réduire la charge cognitive tout en gardant l’accès rapide aux features fréquentes.

1) Routing
- Modifier [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)
  - Ajouter `_plusNavigatorKey`.
  - Retirer la branche `Aliments` de la `StatefulShellRoute`.
  - Ajouter une branche `Plus` contenant :
    - `GoRoute(path: '/plus', pageBuilder: NoTransitionPage(child: PlusScreen()))`
    - `GoRoute(path: '/aliments', pageBuilder: NoTransitionPage(child: AlimentsScreen()))` (déplacée dans Plus)
    - `GoRoute(path: '/alertes', pageBuilder: NoTransitionPage(child: AlertesScreen()))` (nouvelle)
  - Conserver les formulaires en root navigator (`/lapin/new`, `/lapin/:id/edit`, `/saillie/new`) tels qu’actuellement.

2) Bottom navigation
- Modifier [main_shell_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/main_shell_screen.dart)
  - Destinations : Accueil, Lapins, Portées, IA, Plus.
  - Remplacer les labels en dur par `AppLocalizations`.

3) Écran “Plus” (hub)
- Créer `lib/presentation/screens/plus/plus_screen.dart`
  - UI simple : `Scaffold(appBar: AppBar(title: l10n.plusTitle), body: ListView(...))`
  - Items (ListTile) :
    - Alertes → `/alertes`
    - Aliments → `/aliments`
    - Réglages → `/settings` (route existante)
  - Inclure `ConnectivityBanner` en haut pour cohérence offline/sync.

### 4.2 Dashboard : priorité actions + alertes, sections harmonisées
**Objectif :** “je comprends quoi faire maintenant” + états UI propres.

- Modifier [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart)
  1) Alertes
  - Remplacer `loading/error` par `LoadingWidget` / `ErrorDisplayWidget`.
  - Remplacer l’état vide (actuellement container custom) par un `EmptyStateWidget` (ou un petit card cohérent), avec CTA “Voir toutes les alertes” → `/alertes`.
  - Brancher “Voir tout” sur `/alertes`.
  - Pour “marquer comme fait”, utiliser une méthode existante côté provider (idéalement `AlertesController.markAsActionDone`) pour centraliser la logique.

  2) Prochaines portées
  - Remplacer `loading/error` par `LoadingWidget` / `ErrorDisplayWidget`.
  - Remplacer l’état vide par `EmptyStateWidget` avec CTA “Nouvelle saillie” → `/saillie/new`.
  - Localiser les strings visibles (mère inconnue, libellé de progression, “jours restants”).
  - Remplacer les couleurs “progress/badges” basées sur `AppColors.*` par `colorScheme.*` quand c’est possible sans perdre la sémantique.

### 4.3 Écran Alertes (pour “Voir tout” + meilleure actionnabilité)
**Objectif :** rendre les alertes actionnables et faciles à “vider”.

- Créer `lib/presentation/screens/alertes/alertes_screen.dart`
  - Source de données : `alertesControllerProvider` (déjà présent).
  - UI :
    - `SegmentedButton` ou `FilterChip` : “Non lues” / “Toutes”.
    - Liste : cards/list tiles, avec priorité visible (couleur sémantique).
    - Actions :
      - “Marquer comme lue”
      - “Action faite” (si applicable)
  - États : `LoadingWidget` / `ErrorDisplayWidget` / `EmptyStateWidget`.

### 4.4 Harmonisation des écrans “détail” (minimum viable)
**Objectif :** éviter les erreurs/chargements “bruts” et supprimer les textes en dur les plus visibles.

- Modifier [lapin_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_detail_screen.dart)
  - Remplacer loading/error par des versions cohérentes (scaffold + `LoadingWidget` / `ErrorDisplayWidget`).
  - Ajouter `ConnectivityBanner` dans le `body` (haut de liste) pour cohérence.
  - Localiser les libellés visibles : supprimer/annuler, ajouter pesée, poids, enregistrer, titres de sections, etc.

Optionnel (si rapide et symétrique) :
- Appliquer la même harmonisation à `PorteeDetailScreen` et aux dialogs “destructifs”.

### 4.5 i18n : supprimer les strings “en dur” visibles (navigation + plus + détails)
- Modifier `lib/l10n/app_fr.arb` + `lib/l10n/app_en.arb`
  - Ajouter clés :
    - Navigation : `navHome`, `navLapins`, `navPortees`, `navIa`, `navPlus`
    - Plus : `plusTitle`, `plusAlerts`, `plusFeed`, `plusSettings`
    - Commun : `cancel`, `delete`, `confirm`, `deleteConfirmTitle`, `deleteConfirmBody` (+ placeholders)
    - Détails : libellés poids/pesée, “mère inconnue”, “race inconnue”, “saillie”, “jours restants”, etc.
- Régénérer l10n (`flutter gen-l10n`) après ajout des clés.

## 5) Plan d’exécution (ordre)
1) Implémenter “Plus” : `PlusScreen` + routes + bottom nav + l10n nav.
2) Implémenter “AlertesScreen” + brancher “Voir tout” du dashboard.
3) Harmoniser dashboard (Alertes + Prochaines portées) : états + empty states + i18n + couleurs.
4) Harmoniser `LapinDetailScreen` (et `PorteeDetailScreen` si inclus) : états + i18n + connectivité.
5) Vérifier i18n (FR/EN), puis `flutter analyze` + `flutter test`.
6) Mettre à jour `lapiNia_Taches_Flutter.md` : cocher + déplacer en section “Fait” les items UX effectivement terminés.

## 6) Vérifications
- Navigabilité
  - Onglets : retour sur chaque onglet conserve sa pile (ex. Lapins → détail → retour).
  - Formulaires : `/lapin/new` et `/saillie/new` s’ouvrent en plein écran et retour revient à l’écran précédent.
  - Plus : Alertes/Aliments accessibles, Settings accessible.
- États UI
  - Dashboard : pas de loading/error “brut”.
  - AlertesScreen : loading/error/empty cohérents.
  - LapinDetail : loading/error cohérents.
- Techniques
  - `flutter gen-l10n`
  - `flutter analyze`
  - `flutter test`

