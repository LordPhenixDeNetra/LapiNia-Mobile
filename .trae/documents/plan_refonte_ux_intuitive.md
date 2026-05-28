# Plan — Refonte UX (simple & intuitive)

## Résumé
Objectif: repenser l’expérience utilisateur pour que l’app soit **très facile**, **très intuitive**, avec une **bonne navigabilité**.

Décisions confirmées:
- Profil ciblé: **Débutant (guidé)**.
- Accueil: **Mix** (actions rapides + KPI + alertes).
- Style: **Material 3 natif**.
- Navigation: **Bottom bar conservée** mais avec **piles séparées par onglet** (StatefulShellRoute).
- Hors-ligne: **indicateur global** (visible partout).

Périmètre UX prioritaire:
- Flows “core” (1–2 taps): **Lapins**, **Portées**, **évènements (pesée/santé/stock)**, **alertes + sync offline**.

## Analyse de l’état actuel (constaté dans le code)
### Navigation
- Routes: [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)
- Shell actuel: `ShellRoute` + `BottomNavigationBar` ([main_shell_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/main_shell_screen.dart))
- Problème UX: pas de piles séparées par onglet → le bouton “Retour” et la navigation inter-onglets sont moins naturels.

### Cohérence UI (loading / empty / error)
- Widgets communs existent mais peu utilisés: [loading_widget.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/widgets/common/loading_widget.dart)
- Strings non localisées et couleurs “en dur” encore présentes sur plusieurs écrans (ex: Dashboard) : [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart)

### Thème / Material 3
- Thème M3 présent mais souvent “court-circuité” par `AppColors` et `BottomNavigationBarThemeData` : [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart)
- Plusieurs couleurs `Colors.*` / `Color(0x...)` dans les widgets → incohérences light/dark et accessibilité (contraste).

### Offline / Sync
- Settings expose déjà l’essentiel (statut réseau, pending, sync) : [settings_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/settings/settings_screen.dart)
- UX à améliorer: rendre l’information **visible partout**, pas seulement dans Settings.

## Changements proposés (décision-complete)
### 1) Refonte navigation pour “bonne navigabilité”
**But UX**
- Chaque onglet conserve son historique (aller dans un détail, changer d’onglet, revenir, etc.).
- Le bouton Android “Retour” devient intuitif.

**Implémentation**
- Modifier [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart) :
  - Remplacer `ShellRoute` par `StatefulShellRoute.indexedStack`.
  - Créer 5 branches (dashboard/lapins/portees/aliments/ia), chacune avec ses sous-routes.
  - Introduire `GlobalKey<NavigatorState>`:
    - 1 clé “root” (pour pages plein écran: login/onboarding/settings, et formulaires si souhaité)
    - 1 clé par branche (pour la pile par onglet)
  - Définir les routes “détail” dans la branche correspondante:
    - Branche Lapins: liste + détail + edit/new (selon règle ci-dessous)
    - Branche Portées: liste + détail + saillie/new

**Règle UX (débutant)**
- Détails: **dans l’onglet** (pile de la branche) → navigation simple.
- Formulaires: ouvrir en **plein écran** (root navigator) pour focus (pas de changements d’onglet accidentels).

**Fichiers impactés**
- [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)
- [main_shell_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/main_shell_screen.dart) (adaptation à `StatefulNavigationShell`)

### 2) Accueil (Dashboard) “Mix”: actions rapides + infos utiles
**But UX**
- Mettre en avant les actions principales (1–2 taps) + conserver un aperçu (KPI, alertes, prochaines portées).

**Implémentation**
- Revoir [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart) :
  - En haut: “Actions rapides” (4 boutons):
    - Ajouter un lapin (`/lapin/new`)
    - Nouvelle saillie (`/saillie/new`)
    - Enregistrer évènement (ouvre un bottom-sheet “Pesée / Santé / Stock” — même si les modules ne sont pas encore complets, préparer la navigation)
    - Synchroniser / voir statut (ouvre Settings ou déclenche `forceSync`)
  - Conserver KPI + alertes + prochaines portées en dessous.
  - Remplacer les strings hardcodées par `l10n.*`.
  - Remplacer couleurs hardcodées par `Theme.of(context).colorScheme.*`.

**Fichiers impactés**
- [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart)
- Création widgets si nécessaire (dans `lib/presentation/widgets/common/`) :
  - `quick_actions_bar.dart`
  - `dashboard_section_header.dart`

### 3) Composants communs: loading / empty / error unifiés + localisés
**But UX**
- Une expérience cohérente (mêmes patterns partout), lisible pour débutant, avec CTA (réessayer / ajouter / ouvrir settings).

**Implémentation**
- Refactor [loading_widget.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/widgets/common/loading_widget.dart) :
  - Utiliser `ColorScheme` au lieu de `AppColors` et `Colors.white`.
  - Localiser “Erreur”, “Réessayer”, “Mode hors-ligne” via `AppLocalizations`.
- Mettre à jour les écrans pour utiliser systématiquement:
  - `LoadingWidget`
  - `EmptyStateWidget` (avec CTA)
  - `ErrorDisplayWidget` (avec retry)

**Fichiers à harmoniser (minimum)**
- Dashboard: [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart)
- Lapins: [lapin_list_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_list_screen.dart), [lapin_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/lapins/lapin_detail_screen.dart)
- Portées: [portee_list_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/portee_list_screen.dart), [portee_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/portee_detail_screen.dart)
- Settings: [settings_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/settings/settings_screen.dart)

### 4) Hors-ligne: indicateur global + accès rapide à la synchro
**But UX**
- L’utilisateur comprend instantanément “je suis hors-ligne / mes actions sont en attente” sans aller dans Réglages.

**Implémentation**
- Créer un widget commun `ConnectivityStatusBanner` (ou `OfflineBanner` amélioré) qui:
  - Affiche une `MaterialBanner` ou une card compacte en haut des écrans quand offline.
  - Affiche “X actions en attente” quand online mais queue non vide.
  - Propose un CTA “Synchroniser” (ouvre Settings ou appelle `forceSync`).
- L’insérer dans la structure commune des écrans:
  - Option A (reco): wrapper `AppScaffold` (un Scaffold commun) utilisé par Dashboard/Lapins/Portées.
  - Option B: insertion manuelle par écran (moins propre).

**Fichiers impactés**
- Nouveau: `lib/presentation/widgets/common/connectivity_banner.dart`
- Modifs: écrans Dashboard/Lapins/Portées (ajout du banner)
- Providers existants à réutiliser:
  - `connectivityCheckerProvider` (état réseau)
  - `syncManagerProvider` + `pendingMutations`

### 5) Material 3 natif: NavigationBar + tokens ColorScheme
**But UX**
- Cohérence Android, rendu plus moderne, meilleur dark mode, et accessibilité.

**Implémentation**
- Migrer `BottomNavigationBar` → `NavigationBar` dans [main_shell_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/main_shell_screen.dart).
- Dans [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart):
  - Ajouter `NavigationBarThemeData` (et réduire l’usage de `BottomNavigationBarThemeData`).
  - Remplacer les couleurs “en dur” là où possible par le `ColorScheme`.
- Définir une stratégie “couleurs métier”:
  - Conserver `AppColors` uniquement pour statuts métier OU
  - Introduire un `ThemeExtension` (ex: `StatusColors`) pour isoler les couleurs métier et rester compatible M3.

### 6) Micro-UX pour débutants (aides légères)
**But UX**
- Moins d’erreurs, moins de stress, utilisateur guidé sans tutoriel lourd.

**Implémentation (quick wins)**
- Formulaires:
  - libellés + helperText + validations plus explicites (ex: LapinForm, SaillieForm)
  - CTA de sauvegarde unique et clair
  - auto-focus intelligent + clavier adapté (email/num/date)
- Listes:
  - Empty state toujours avec CTA “Ajouter…”
  - Recherche visible + filtres accessibles
- Messages:
  - Utiliser le mapper d’erreurs existant plutôt que `toString()` (déjà en place côté providers; harmoniser côté UI si nécessaire)

## Hypothèses & décisions
- On garde les 5 onglets actuels (même si “Aliments/IA” sont placeholders) pour éviter une refonte fonctionnelle non demandée.
- On priorise la cohérence UX et la navigation; pas d’ajout de features métier (nouveaux modules) dans ce plan.
- Les actions rapides “Pesée/Santé/Stock” peuvent, au besoin, pointer vers des écrans placeholders existants (ou rester désactivées si l’écran n’existe pas).

## Vérifications (obligatoires)
- Qualité:
  - `flutter analyze` sans erreurs.
  - `flutter test` OK.
- Tests manuels UX:
  - Onboarding → Dashboard, puis navigation onglets + back button (Android).
  - Lapins: liste → détail → retour; puis changer d’onglet et revenir (pile conservée).
  - Formulaires ouverts en plein écran, annulation/retour clair.
  - Offline: activer mode avion → bannière visible, création lapin offline, pending visible, puis reconnect → sync.
  - Thème: clair/sombre/système (vérifier contraste sur bannières, CTA, KPI).

## Mise à jour des tâches
- Mettre à jour `lapiNia_Taches_Flutter.md` après implémentation:
  - cocher les tâches UX réalisées
  - déplacer les tâches terminées dans “Fait”.

