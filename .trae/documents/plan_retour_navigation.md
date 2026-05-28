# Plan — Corriger le retour (back) et la navigation

## 1) Résumé
But : rendre le **retour vers les pages précédentes** cohérent et prévisible, surtout avec la navigation par onglets (`StatefulShellRoute.indexedStack`).

Décisions validées :
- À la racine d’un onglet (Lapins/Portées/IA/Plus), le **back Android doit ramener à Accueil**.
- Depuis Accueil, quand on ouvre “Voir tout” (Alertes/Portées), **un back doit revenir à Accueil**.
- Dans les écrans détail (Lapin/Portée), l’icône “liste” doit faire **pop si possible**, sinon naviguer vers la liste.

## 2) État actuel (constats)
### 2.1 Router
- Navigation onglets via `StatefulShellRoute.indexedStack` dans [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart).
- Le shell est rendu par [main_shell_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/main_shell_screen.dart) sans interception du back système.

### 2.2 Usages de `context.go(...)` qui cassent “retour”
- Dashboard utilise `context.go('/alertes')` et `context.go('/portees')` (les transitions ne sont pas empilées comme un push).
  - [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart)
- Portée détail a une action “liste” qui force `context.go('/portees')` au lieu de revenir en arrière si on vient de la liste.
  - [portee_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/portee_detail_screen.dart)

## 3) Changements proposés (décision-complete)

### 3.1 Back Android : retour vers Accueil depuis la racine d’un onglet
**Fichier :** [main_shell_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/main_shell_screen.dart)

Ajouter un `PopScope` (ou `WillPopScope` selon SDK) autour du `Scaffold` pour implémenter :
1) Si un écran est empilé dans l’onglet courant (ex: Lapins → Détail), on fait un `pop` (retour normal).
2) Sinon (on est à la racine de l’onglet) :
   - si `navigationShell.currentIndex != 0` → `navigationShell.goBranch(0)` (Accueil) et on **bloque** la fermeture de l’app.
   - si `navigationShell.currentIndex == 0` → on laisse le système fermer l’app (back normal sur Accueil racine).

Implémentation suggérée (logique, sans imposer l’API exacte) :
- Déterminer si on peut pop via `GoRouter.of(context).canPop()` ou `Navigator.of(context).canPop()`.
- Si possible → `context.pop()` / `Navigator.maybePop`.
- Sinon → bascule onglet.

### 3.2 Dashboard : “Voir tout” doit être une navigation empilée (push)
**Fichier :** [dashboard_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/dashboard/dashboard_screen.dart)

Objectif : 1 back = retour Accueil (pas “sortie app”).

- Remplacer les `context.go('/alertes')` par `context.push('/alertes')`.
  - Cela garantit que l’écran Alertes se ferme par `pop` et revient à l’Accueil.
- Pour “Voir tout Portées” :
  - Utiliser `context.go('/portees')` (changement d’onglet) **mais** couplé avec la règle 3.1 : à la racine de Portées, back → Accueil.
  - Alternative (si nécessaire après test) : `context.push('/portees')` si `go_router` supporte proprement le push cross-branch sans effets indésirables.

### 3.3 Écrans détail : “Liste” = pop si possible
**Fichier :** [portee_detail_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/portees/portee_detail_screen.dart)

Remplacer l’action :
- Avant : `context.go('/portees')`
- Après :
  - Si on peut `pop` → `context.pop()`
  - Sinon → `context.go('/portees')`

Même principe à appliquer partout où un bouton “retour à liste” existe.

### 3.4 Router : positionner Alertes comme route “root overlay” (si nécessaire)
**Fichier :** [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)

Si après 3.2, l’ouverture de `/alertes` depuis Accueil ne revient pas correctement (ex: nécessite 2 backs via Plus) :
- Déplacer `/alertes` hors de la branche “Plus” pour en faire une route top-level (root navigator).
- Conserver l’accès depuis Plus via `context.push('/alertes')`.

## 4) Ordre d’exécution
1) Ajouter `PopScope` sur [main_shell_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/main_shell_screen.dart).
2) Ajuster Dashboard (remplacer `go` par `push` pour Alertes + vérifier Portées).
3) Ajuster Portée détail (pop si possible).
4) (Si besoin) Ajuster router pour rendre `/alertes` top-level.

## 5) Vérifications / Acceptation
- **Onglets (racine)** : depuis Lapins/Portées/IA/Plus à la racine → back = Accueil (et pas fermeture app).
- **Pile d’onglet** : Lapins → Détail → back = Lapins (pas Accueil).
- **CTA Accueil**
  - Accueil → “Voir tout Alertes” → back = Accueil.
  - Accueil → “Voir tout Portées” → back = Accueil (immédiat ou après être revenu à la racine Portées, selon choix final).
- Tests/qualité :
  - `flutter analyze`
  - `flutter test`

