# Configuration Supabase (auto-hébergé) ↔ Flutter (lapiNia) — version “terre à terre”

## Objectif (simple)

Pour que l’app se connecte à ton Supabase, il te faut seulement 2 infos :

1) **SUPABASE_URL** = l’adresse de ton serveur Supabase (ex: `https://supabase.mondomaine.com`)  
2) **SUPABASE_ANON_KEY** = la clé publique “anon” (un long texte qui commence souvent par `eyJ...`)

Une fois que tu as ces 2 infos, tu les colles dans un fichier et l’app démarre.

## Étape A — Vérifier que ton Supabase est accessible

1) Prends ton URL publique Supabase (celle que tu as mise derrière ton domaine).
2) Ouvre dans le navigateur :

- `https://TON_URL/auth/v1/health`

Résultat attendu : une réponse “ok” / “healthy” (ou similaire).  
Si ça ne répond pas, l’app ne pourra pas se connecter (problème reverse-proxy / DNS / SSL).

## Étape B — Trouver la clé ANON (sur ton serveur)

Sur un Supabase auto-hébergé, les clés sont dans la config du serveur (souvent un `.env` ou un `docker-compose.yml`).

Cherche ces noms (selon les setups, ça varie) :

- `ANON_KEY`
- `SUPABASE_ANON_KEY`

Important :
- Ne prends pas `SERVICE_ROLE_KEY` (c’est une clé “admin”, interdite dans une app mobile).

## Étape B2 — Configurer l’envoi d’email (SMTP Gmail) pour l’inscription

Si, à l’inscription, tu vois une erreur du type “Error sending confirmation email”, il faut configurer SMTP sur ton serveur.

### B2.1 Créer un “App Password” Gmail (obligatoire)

1) Sur ton compte Google, active la **validation en 2 étapes**  
2) Va dans “Mots de passe des applications”  
3) Crée un mot de passe d’application (ex: “Supabase”)  
4) Copie ce mot de passe (format souvent: `xxxx xxxx xxxx xxxx`)

### B2.2 Mettre les variables SMTP dans ton serveur Supabase

Dans la configuration de ton Supabase (souvent un `.env` / docker-compose), ajoute les variables GoTrue :

- `GOTRUE_SMTP_HOST=smtp.gmail.com`
- `GOTRUE_SMTP_PORT=587`
- `GOTRUE_SMTP_USER=ton.adresse@gmail.com`
- `GOTRUE_SMTP_PASS=<APP_PASSWORD_GMAIL>`
- `GOTRUE_SMTP_ADMIN_EMAIL=ton.adresse@gmail.com`
- `GOTRUE_SMTP_SENDER_NAME=lapiNia`
- `GOTRUE_SITE_URL=https://TON_URL_SUPABASE`
- `GOTRUE_EXTERNAL_EMAIL_ENABLED=true`

Un modèle est disponible ici : [.env.exemple](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/.env.exemple)

Ensuite : **redémarre Supabase** (pour que GoTrue recharge les variables).

## Étape B3 — Personnaliser le design des emails (templates)

Oui, c’est possible, avec une contrainte importante en self-hosted : Supabase Auth (GoTrue) ne lit pas des templates “montés en volume”. Il charge les templates via des **URLs HTTP** accessibles depuis le service `auth`. Source : https://supabase.com/docs/guides/self-hosting/custom-email-templates

### B3.1 Templates prêts dans ce repo

- [confirmation.html](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/email_templates/confirmation.html)
- [recovery.html](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase/email_templates/recovery.html)

### B3.2 Exemple de variables serveur

Un modèle est disponible ici : [supabase_server.env.example](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase_server.env.example)

### B3.3 Héberger les fichiers HTML (simple)

Tu peux héberger ces fichiers via un petit serveur HTTP dans le même réseau Docker que Supabase (ex: un service `templates-server`), puis mettre :

- `GOTRUE_MAILER_TEMPLATES_CONFIRMATION=http://templates-server/confirmation.html`
- `GOTRUE_MAILER_TEMPLATES_RECOVERY=http://templates-server/recovery.html`

Puis redémarrer le service `auth`.

## Étape C — Donner l’URL + ANON KEY à l’app Flutter

L’app lapiNia lit la config Supabase depuis [main.dart](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/lib/main.dart#L18-L86).

Tu as 3 façons. La plus simple pour débuter est l’Option 1.

### Option 1 (la plus simple) — fichier local dans assets

1) Duplique ce fichier :
- [supabase.local.json.example](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/assets/data/supabase.local.json.example)

2) Crée le fichier suivant (exactement ce nom) :
- `assets/data/supabase.local.json`

3) Colle dedans tes valeurs :

```json
{
  "SUPABASE_URL": "https://supabase.mondomaine.com",
  "SUPABASE_ANON_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

4) Lance :

```bash
flutter pub get
flutter run
```

### Option 2 (simple) — fichier .env dans assets

1) Duplique ce fichier :
- [assets/data/.env.example](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/assets/data/.env.example)

2) Crée `assets/data/.env` (non commité)
3) Mets tes valeurs dedans :

```env
SUPABASE_URL=https://supabase-api.hopitalia-dantec.com
SUPABASE_ANON_KEY=eyJ...
```

4) Lance :

```bash
flutter pub get
flutter run
```

### Option 3 (propre) — fichier de variables + dart-define

1) Duplique ce fichier :
- [supabase.env.json.example](file:///n:/AndroidStudioProjects/Flutter/lapinia_mobile/supabase.env.json.example)

2) Crée `supabase.env.json` à la racine (même dossier que `pubspec.yaml`)
3) Mets tes valeurs dedans
4) Lance :

```bash
flutter run --dart-define-from-file=supabase.env.json
```

## Étape D — Mettre la base Supabase au bon format pour l’app (tables)

Sur Supabase Studio (interface web), ouvre le “SQL Editor” et exécute dans cet ordre :

1) `supabase/migrations/001_initial_schema.sql`
2) `supabase/migrations/002_reference_data.sql`

Tant que ces scripts ne sont pas exécutés, l’app ne pourra pas lire/écrire les données attendues.

## Étape E — Activer les permissions (si l’app a “permission denied / RLS”)

Si l’app affiche des erreurs du genre “permission denied”, “RLS”, ou qu’elle ne peut pas insérer des lignes :

1) Dans Supabase Studio → SQL Editor, exécute :
- `supabase/migrations/003_permissions_rls_fix.sql`

2) Relance l’app et réessaie de créer un lapin.
