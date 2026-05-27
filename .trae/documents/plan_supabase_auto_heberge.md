## Resume

Vous utilisez Supabase auto-heberge sur votre propre serveur. Avant de continuer les autres phases, l’objectif est de:

- connecter l’app Flutter a votre instance Supabase (URL + ANON KEY) sans commiter de secrets
- remplacer l’authentification SMS/OTP actuelle par Email + mot de passe
- rendre l’app robuste quand les Edge Functions ne sont pas encore deployees (IA “plus tard”)

## Analyse De L Etat Actuel

- Initialisation Supabase: [main.dart](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/lib/main.dart) utilise `String.fromEnvironment('SUPABASE_URL')` et `String.fromEnvironment('SUPABASE_ANON_KEY')`. Si non fournis, c’est vide et ca cassera au runtime.
- Auth actuelle: [auth_bloc.dart](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/lib/presentation/blocs/auth/auth_bloc.dart) utilise `signInWithOtp(phone)` et `verifyOTP` (SMS).
- Ecrans auth: [login_screen.dart](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/lib/presentation/screens/auth/login_screen.dart) est base sur numero de telephone + route OTP.
- Vous ne voulez pas de SMS/OTP et preferez Email + mot de passe.
- Vous voulez fournir les secrets via un fichier local ignore (pas en dur, pas commite).
- Les Edge Functions seront utilisees plus tard; l’app doit afficher un message clair si elles ne sont pas disponibles.

## Decisions Validees

- Secrets: fichier local ignore, fourni au build (pas de dependance externe type dotenv).
- Auth: Email + mot de passe.
- Fonctions IA: conservees mais “graceful fallback” si non deployees/configurees.

## Changements Proposes

### 1) Identifier l’URL et l’ANON KEY de votre Supabase auto-heberge

Objectif: obtenir les 2 valeurs a injecter dans l’app:

- `SUPABASE_URL` (URL publique du gateway/API, ex: `https://supabase.mondomaine.tld`)
- `SUPABASE_ANON_KEY` (cle publique “anon”)

Sources possibles cote serveur:
- Supabase Studio (Project Settings > API): “Project URL” et “anon public key”
- Fichier d’environnement du stack (docker compose / `.env`): variables type `SUPABASE_PUBLIC_URL` / `ANON_KEY`

### 2) Mettre en place un fichier local ignore pour injecter les variables (recommande: dart-define-from-file)

Sans ajouter de package, Flutter supporte l’injection au build:

- creer (localement) un fichier JSON (ex: `supabase.env.json`) non commite
- lancer l’app avec `--dart-define-from-file=supabase.env.json`

Contenu attendu (exemple):
```json
{
  "SUPABASE_URL": "https://votre-url",
  "SUPABASE_ANON_KEY": "votre-anon-key"
}
```

Changements code/depots:
- Ajouter une regle `.gitignore` pour ignorer `supabase.env.json`
- Optionnel: proposer une variante `supabase.env.example.json` seulement si vous le demandez (sinon on n’ajoute aucun fichier).

### 3) Durcir l’initialisation Supabase (message clair si non configure)

Fichiers:
- [main.dart](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/lib/main.dart)

Changements:
- verifier que `SUPABASE_URL` et `SUPABASE_ANON_KEY` ne sont pas vides au demarrage
- si vide: afficher une erreur utilisateur (ecran simple) indiquant comment passer `--dart-define-from-file`

### 4) Migrer l’authentification vers Email + mot de passe

Fichiers:
- [auth_bloc.dart](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/lib/presentation/blocs/auth/auth_bloc.dart)
- [auth_event.dart](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/lib/presentation/blocs/auth/auth_event.dart)
- [auth_state.dart](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/lib/presentation/blocs/auth/auth_state.dart)
- [login_screen.dart](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/lib/presentation/screens/auth/login_screen.dart)
- [otp_screen.dart](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/lib/presentation/screens/auth/otp_screen.dart)
- [app_router.dart](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/lib/presentation/router/app_router.dart)

Changements BLoC:
- remplacer les events “phone/otp” par:
  - `AuthEmailPasswordSignInRequested(email, password)`
  - `AuthEmailPasswordSignUpRequested(email, password)` (si vous voulez permettre la creation de compte)
- appeler `supabaseClient.auth.signInWithPassword(email, password)`
- appeler `supabaseClient.auth.signUp(email, password)`

Changements UI:
- remplacer le formulaire telephone par Email + mot de passe
- retirer la navigation vers `/otp`
- soit:
  - un toggle “Se connecter / Creer un compte” sur le meme ecran
  - soit deux ecrans distincts (login + register)

Changements routing:
- supprimer ou desactiver la route OTP si elle n’est plus utilisee

### 5) IA / Edge Functions: fallback propre tant que non deploye

Fichiers:
- [ia_bloc.dart](file:///c:/Users/user/THIOR/FlutterApp/LapiNia-Mobile/lib/presentation/blocs/ia/ia_bloc.dart)

Changements:
- encapsuler les appels `supabase.functions.invoke(...)` avec:
  - gestion des erreurs reseau/404
  - message UI du type “Fonction IA non disponible (non deployee)”
- optionnel: gate via une variable `SUPABASE_FUNCTIONS_ENABLED` (par defaut false) pour eviter d’appeler les fonctions tant que vous n’avez pas deploye.

### 6) Compat reseau (si votre Supabase n’est pas en HTTPS valide)

Decision:
- Recommande: exposer Supabase en HTTPS avec un certificat reconnu (LetsEncrypt) pour eviter des erreurs TLS.

Si vous etes en HTTP ou cert self-signed:
- Android peut refuser; il faudra une config reseau Android specifique (cleartext/debug) ou corriger le certificat cote serveur.
Cette partie sera appliquee seulement si necessaire apres test de connexion.

## Verification

1. `flutter analyze` passe.
2. `flutter build apk --debug` passe.
3. Lancement avec config:
   - `flutter run --dart-define-from-file=supabase.env.json`
4. Auth:
   - login email/password OK
   - logout OK
5. IA:
   - si fonctions non deployees: l’app affiche un message propre (pas de crash)

## Perimetre

Inclus:
- configuration Supabase auto-heberge (URL/anon key)
- auth email/password
- robustesse IA tant que fonctions non deployees

Exclus (pour l’instant):
- deploiement/ops Supabase sur votre serveur (Docker/Kong/Studio), sauf instructions pour retrouver URL/keys
