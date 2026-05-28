# Plan — Terminer P1 « Onboarding »

## 1) Résumé
Objectif : terminer toutes les tâches **P1** de la section **Onboarding** dans `lapiNia_Taches_Flutter.md`, en rendant l’onboarding complet (étapes 1–5) et en ajoutant un **premier conseil post‑onboarding** sur un **écran dédié**.

Décisions validées :
- Stockage des réponses : **Local** (SharedPreferences).  
- Étape “races possédées” : **sélection vide autorisée** (utile pour “je débute”).  
- “Premier conseil IA” : **écran dédié** après validation onboarding.

## 2) État actuel (constats)
Fichiers principaux :
- Onboarding UI : [onboarding_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/auth/onboarding_screen.dart)
- Flag onboarding_done (SharedPreferences) : [onboarding_service.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/domain/services/onboarding_service.dart) + [bootstrap_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/bootstrap_provider.dart)

Constats :
- L’onboarding actuel contient 4 questions statiques :
  - Nb lapins (P1) ✅
  - Objectifs multi-select (P1 étape 2) ✅
  - Région (P1 étape 3) ❌ (actuellement choix pays fixe, pas ville)
  - Expérience (P1 étape 5) ✅
- Étape 4 “races possédées” ❌ absente.
- Les réponses ne sont pas persistées (seulement un `onboarding_done = true`).
- Pas de “conseil post‑onboarding” (navigation directe dashboard).

## 3) Périmètre exact des tâches P1 « Onboarding » à terminer
Selon [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md) :
- Étape 1 : nombre de lapins ✅ déjà présent
- Étape 3 : région (sélecteur pays + ville) ❌
- Étape 4 : races possédées (multiselect via `GET /rest/v1/races`) ❌
  - Réutilisation de `racesProvider` déjà existant dans [lapin_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/providers/lapin_provider.dart#L270-L274)
- Étape 5 : niveau d’expérience ✅ déjà présent
- Conseil IA post-onboarding ❌ (implémentation Flutter côté client + fallback si function absente)

## 4) Changements proposés (décision-complete)

### 4.1 Modèle de données local « profil onboarding »
Créer un modèle simple et stable (stockage local) :
- **Nouveau** `lib/core/models/onboarding_profile.dart`
  - Champs :
    - `String rabbitsCountRange` (ex: `<10`, `10-50`, `50-200`, `>200`)
    - `List<String> goals` (multi-select)
    - `String country`
    - `String city` (vide autorisé, mais UI conseille de renseigner)
    - `List<String> raceIds` (vide autorisé)
    - `String experienceLevel` (`beginner|intermediate|expert` ou labels actuels)
  - `toJson/fromJson` (Map<String, dynamic>) pour persistance.

Créer un service de persistance :
- **Nouveau** `lib/domain/services/onboarding_profile_service.dart`
  - `Future<OnboardingProfile?> getProfile()`
  - `Future<void> saveProfile(OnboardingProfile profile)`
  - `Future<void> clearProfile()`
  - Stockage via `SharedPreferences` (clé unique: `onboarding_profile_json`).

Ajouter le provider :
- Modifier `lib/presentation/providers/core_providers.dart`
  - `final onboardingProfileServiceProvider = Provider<OnboardingProfileService>((ref) => serviceLocator<OnboardingProfileService>());`
- Modifier `lib/core/di/service_locator.dart`
  - Enregistrer `OnboardingProfileService`.

### 4.2 Refactor OnboardingScreen : 5 étapes complètes + validation
Modifier [onboarding_screen.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/screens/auth/onboarding_screen.dart) :

1) Remplacer la liste `_questions` “statique” par une structure d’étapes typées.
2) Implémenter les étapes :
   - Étape 1 (nb lapins) : garder UI actuelle (4 choix).
   - Étape 2 (objectifs multi-select) : garder UI actuelle (déjà multiSelect).
   - Étape 3 (région) :
     - Dropdown pays (liste minimale : Sénégal, Mali, Côte d’Ivoire, Autre)
     - Champ texte ville (obligatoire si pays ≠ “Autre” ?)
       - Décision : **ville non bloquante** (on autorise vide, mais helper text).
   - Étape 4 (races possédées) :
     - Charger les races via `racesProvider` (FutureProvider existant).
     - UI multi-select (chips / list tiles sélectionnables).
     - Sélection **0+** autorisée.
     - Si `racesProvider` en erreur (offline) : `ErrorDisplayWidget` + bouton retry + bouton “Continuer sans sélectionner”.
   - Étape 5 (niveau d’expérience) : garder UI actuelle.
3) Au submit final :
   - Construire `OnboardingProfile` depuis les réponses.
   - `onboardingProfileService.saveProfile(profile)`
   - `onboardingDoneProvider.setDone(true)`
   - Naviguer vers l’écran conseil : route dédiée (voir 4.3)

### 4.3 Écran “Conseil post-onboarding” (écran dédié)
Créer un écran dédié pour afficher un conseil initial :
- **Nouveau** `lib/presentation/screens/onboarding/onboarding_advice_screen.dart`
  - Affiche :
    - Un titre (ex: “Votre premier conseil”)
    - Le contenu du conseil (texte)
    - Bouton “Continuer” → `/dashboard` (via `context.go('/dashboard')` pour remplacer la stack onboarding)
  - La source du conseil :
    1) Tentative d’appel Edge Function : `supabase.functions.invoke('daily-advice', body: profile.toJson())`
    2) Si function absente / erreur : fallback (message local) basé sur :
       - objectifs (ex: si “Vente lapereaux” → conseil reproduction/gestion)
       - pays (ex: chaleur → eau/ombre)
       - expérience (débutant → checklist simple)

Routing :
- Modifier [router_provider.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/presentation/router/router_provider.dart)
  - Ajouter une route top-level : `/onboarding-advice` → `OnboardingAdviceScreen`
  - Modifier `OnboardingScreen` pour naviguer vers `/onboarding-advice` à la fin (au lieu de `/dashboard` direct).

### 4.4 i18n (minimum viable pour Onboarding P1)
Objectif : éviter du texte “en dur” sur les nouveaux écrans/labels.
- Modifier `lib/l10n/app_fr.arb` + `lib/l10n/app_en.arb`
  - Ajouter clés onboarding manquantes (pays, ville, titres, boutons, conseil).
- Régénérer l10n (`flutter gen-l10n`).

### 4.5 Mise à jour du fichier tâches (exigence projet)
Après implémentation et vérification :
- Mettre à jour [lapiNia_Taches_Flutter.md](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lapiNia_Taches_Flutter.md)
  - Cocher les tâches P1 Onboarding terminées
  - Les déplacer dans la section **Fait**.

## 5) Ordre d’exécution
1) Ajouter `OnboardingProfile` + `OnboardingProfileService` + DI/provider.
2) Refactor `OnboardingScreen` pour inclure étapes 3 (pays+ville) et 4 (races multi-select).
3) Ajouter `OnboardingAdviceScreen` + route `/onboarding-advice`.
4) Ajouter i18n, régénérer l10n.
5) Vérifier : `flutter analyze` + `flutter test`.
6) Mettre à jour `lapiNia_Taches_Flutter.md` (déplacer vers “Fait”).

## 6) Vérifications / critères d’acceptation
- Onboarding comporte 5 étapes et se valide.
- Région : pays sélectionné + ville saisissable (ville vide autorisée mais UI incite à renseigner).
- Races : liste chargée depuis Supabase si online, et onboarding reste possible si offline.
- Fin onboarding : affichage de l’écran conseil, puis “Continuer” mène au dashboard.
- `flutter analyze` et `flutter test` passent.

