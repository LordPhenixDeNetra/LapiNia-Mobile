# 🐇 lapiNia — Plan de Développement Complet

**De l'idée au lancement — Toutes les phases détaillées**

---

> **Projet** : lapiNia — Application Mobile Intelligente d'Élevage Cunicole
> **Stack** : Flutter · Supabase · Claude AI · Mistral · TFLite
> **Durée totale** : 13 semaines (MVP → Stores) + 9 mois (V1.5 + V2.0)
> **Équipe** : 7 personnes

---

## Vue d'ensemble des phases

```
PHASE 0   Setup & Fondations          ████░░░░░░░░░░░░░░░░   2 semaines
PHASE 1   Core (Auth + Lapins)        ████████░░░░░░░░░░░░   6 semaines
PHASE 2   IA Base                     ████░░░░░░░░░░░░░░░░   4 semaines
PHASE 3   IA Avancée                  ████░░░░░░░░░░░░░░░░   4 semaines
PHASE 4   Finance & QR                ███░░░░░░░░░░░░░░░░░   3 semaines
PHASE 5   Polish & Lancement          ███░░░░░░░░░░░░░░░░░   3 semaines
─────────────────────────────────────────────────────────
          MVP → App Store / Play Store         13 semaines

PHASE 6   V1.5 (Langues + Vocal)      ░░░░░░░░░░░░████░░░░   3 mois
PHASE 7   V2.0 (IoT + Marketplace)    ░░░░░░░░░░░░░░░░████   6 mois
```

---

## PHASE 0 — Setup et Fondations

> **Durée** : 2 semaines
> **Objectif** : Poser les bases techniques solides avant d'écrire la moindre fonctionnalité

---

### Semaine 1 — Infrastructure

#### Jour 1–2 : Supabase Cloud

- [ ] Créer un compte sur [supabase.com](https://supabase.com)
- [ ] Créer le projet `lapinia-production` (région : Europe Frankfurt)
- [ ] Créer le projet `lapinia-staging` (région : Europe Frankfurt)
- [ ] Noter les clés `SUPABASE_URL` et `SUPABASE_ANON_KEY` des deux projets
- [ ] Activer l'authentification OTP SMS (Twilio ou Vonage)
- [ ] Configurer les variables d'environnement :
  ```
  ANTHROPIC_API_KEY=sk-ant-...
  MISTRAL_API_KEY=...
  FCM_SERVER_KEY=...
  ```

#### Jour 2–3 : Base de données

- [ ] Exécuter les scripts SQL de création des 11 tables :
  ```
  races · lapins · portees · lapereaux
  pesees · medicaments · sante · stocks
  finances · alertes · genealogie
  ```
- [ ] Activer RLS sur toutes les tables (sauf `races` et `medicaments`)
- [ ] Créer les politiques d'isolation par `user_id` :
  ```sql
  CREATE POLICY "isolation" ON lapins
    FOR ALL USING (user_id = auth.uid());
  ```
- [ ] Créer les indexes PostgreSQL critiques :
  ```sql
  CREATE INDEX idx_lapins_user_id ON lapins(user_id);
  CREATE INDEX idx_portees_mere_id ON portees(mere_id);
  CREATE INDEX idx_pesees_lapin_date ON pesees(lapin_id, date DESC);
  CREATE INDEX idx_sante_lapin_date ON sante(lapin_id, created_at DESC);
  CREATE INDEX idx_alertes_user_lue ON alertes(user_id, lue);
  ```
- [ ] Insérer les données de référence :
  - 15 races (NZW, Californien, Rex, Angora, etc.)
  - 40 médicaments avec dosages et délais d'abattage
  - 50 aliments locaux africains avec valeurs nutritives

#### Jour 3–4 : Firebase

- [ ] Créer un projet Firebase `lapinia`
- [ ] Activer Firebase Cloud Messaging (FCM)
- [ ] Télécharger `google-services.json` (Android)
- [ ] Télécharger `GoogleService-Info.plist` (iOS)
- [ ] Configurer les topics FCM :
  ```
  lapinia-alertes-critiques
  lapinia-rappels-vaccination
  lapinia-rapport-hebdo
  ```

#### Jour 4–5 : Dépôt Git et CI/CD

- [ ] Créer le dépôt GitHub `lapinia-app`
- [ ] Configurer la structure des branches :
  ```
  main        → production (protégée)
  staging     → pré-production
  develop     → intégration
  feature/*   → fonctionnalités
  ```
- [ ] Créer le fichier `.github/workflows/ci.yml` :
  ```yaml
  name: CI lapiNia
  on: [push, pull_request]
  jobs:
    test:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: subosito/flutter-action@v2
          with:
            flutter-version: '3.x'
        - run: flutter pub get
        - run: flutter analyze
        - run: flutter test
    deploy-staging:
      if: github.ref == 'refs/heads/staging'
      needs: test
      steps:
        - run: supabase functions deploy --project-ref $STAGING_REF
    deploy-production:
      if: startsWith(github.ref, 'refs/tags/v')
      needs: test
      steps:
        - run: flutter build appbundle --release
        - run: flutter build ipa --release
  ```
- [ ] Configurer les secrets GitHub :
  ```
  SUPABASE_ACCESS_TOKEN
  STAGING_PROJECT_REF
  PRODUCTION_PROJECT_REF
  ANTHROPIC_API_KEY
  MISTRAL_API_KEY
  ```

---

### Semaine 2 — Projet Flutter

#### Jour 1–2 : Création et Structure

- [ ] Créer le projet Flutter :
  ```bash
  flutter create --org com.lapinia --platforms android,ios lapinia
  ```
- [ ] Mettre en place la structure Clean Architecture :
  ```
  lib/
    core/
      interfaces/
        ai_provider.dart
        base_repository.dart
        notification_service.dart
        storage_service.dart
      models/
        lapin.dart · portee.dart · stock.dart
        evenement_sante.dart · race.dart
        medicament.dart · finance.dart · alerte.dart
      utils/
        idempotency_key.dart
        sync_manager.dart
        connectivity_checker.dart
    data/
      repositories/
      local/
      remote/
    domain/
      services/
    presentation/
      blocs/
      screens/
      widgets/
  ```
- [ ] Configurer `pubspec.yaml` avec tous les packages nécessaires
- [ ] Créer `lib/core/constants/app_colors.dart` :
  ```dart
  class AppColors {
    static const primary    = Color(0xFF2E7D32);
    static const alert      = Color(0xFFE65100);
    static const danger     = Color(0xFFB71C1C);
    static const ia         = Color(0xFF4A148C);
    static const background = Color(0xFFF1F8E9);
    static const textDark   = Color(0xFF263238);
  }
  ```

#### Jour 2–3 : SQLite Local (Drift)

- [ ] Créer le schéma Drift (`lib/data/local/app_database.dart`) :
  ```dart
  @DriftDatabase(tables: [
    LapinsLocal, PorteesLocal, PeseesLocal,
    SanteLocal, StocksLocal, FinancesLocal,
    AlertesLocal, SyncQueueLocal
  ])
  class AppDatabase extends _$AppDatabase { ... }
  ```
- [ ] Créer la table `sync_queue` pour les mutations hors-ligne :
  ```dart
  class SyncQueueLocal extends Table {
    TextColumn get id => text()();
    TextColumn get tableName => text()();
    TextColumn get operation => text()(); // INSERT/UPDATE/DELETE
    TextColumn get payload => text()();   // JSON
    TextColumn get idempotencyKey => text()();
    DateTimeColumn get createdAt => dateTime()();
    BoolColumn get processed => boolean().withDefault(const Constant(false))();
  }
  ```
- [ ] Implémenter le `SyncManager` :
  - Écoute `ConnectivityStream`
  - Vide la `SyncQueue` dès reconnexion
  - Gestion des conflits (Last-Write-Wins sur `updated_at`)
  - Retry automatique x3 avec backoff exponentiel

#### Jour 3–4 : Supabase SDK et Repositories

- [ ] Configurer `SupabaseClient` dans `main.dart`
- [ ] Implémenter `BaseRepository<T>` :
  ```dart
  abstract class BaseRepository<T> {
    Future<T?> findById(String id);
    Future<List<T>> findAll({int? limit, String? cursor});
    Future<T> save(T entity);
    Future<void> delete(String id);
  }
  ```
- [ ] Implémenter `LapinRepository` (Supabase + SQLite)
- [ ] Implémenter `IdempotencyKey` :
  ```dart
  class IdempotencyKey {
    static String generate() => const Uuid().v4();
  }
  ```

#### Jour 4–5 : Tests de Base et Validation

- [ ] Tester la connexion Supabase ↔ Flutter
- [ ] Tester l'écriture/lecture SQLite hors-ligne
- [ ] Tester le cycle SyncManager : offline → reconnexion → sync
- [ ] Valider les politiques RLS (tentative cross-user bloquée)
- [ ] Code review SOLID : vérifier les principes sur tout le code existant

---

## PHASE 1 — Core : Authentification et Modules Principaux

> **Durée** : 6 semaines
> **Objectif** : Application fonctionnelle avec les modules essentiels

---

### Semaine 3 — Authentification et Onboarding

#### Authentification OTP SMS

- [ ] Écran de bienvenue :
  - Logo lapiNia animé
  - Sélection de langue (Français en priorité)
  - Boutons "Créer un compte" / "Se connecter"
- [ ] Écran de saisie du numéro de téléphone :
  - Sélecteur de préfixe pays (+221 Sénégal, +223 Mali, etc.)
  - Validation format numéro
  - Bouton "Recevoir le code SMS"
- [ ] Écran de saisie OTP :
  - 6 champs automatiquement focalisés
  - Compte à rebours 60 secondes (renvoyer le code)
  - Validation automatique à 6 chiffres
- [ ] Gestion des tokens JWT :
  - Stockage sécurisé (`flutter_secure_storage`)
  - Refresh automatique avant expiration
  - Déconnexion si refresh échoue

#### Onboarding (questionnaire 5 questions)

- [ ] Question 1 : Combien de lapins avez-vous ?
  - `< 10` / `10–50` / `50–200` / `> 200`
- [ ] Question 2 : Quel est votre objectif principal ?
  - `Vente lapereaux` / `Viande familiale` / `Reproducteurs` / `Loisir`
- [ ] Question 3 : Votre région ?
  - Sélecteur de pays + ville principale
- [ ] Question 4 : Quelle(s) race(s) possédez-vous ?
  - Sélection multiple dans la liste des 15 races
- [ ] Question 5 : Votre niveau d'expérience ?
  - `Débutant (< 1 an)` / `Intermédiaire` / `Expert`
- [ ] Génération du profil éleveur basé sur les réponses
- [ ] Premier conseil IA personnalisé (appel Claude avec le profil)

---

### Semaine 4 — Module Lapins (partie 1)

#### Liste des Lapins

- [ ] Écran liste avec `ListView.builder` (lazy loading)
- [ ] Filtres par statut (REPOS, GESTATION, LACTATION, MALADE...)
- [ ] Filtres par race et sexe
- [ ] Tri par nom, poids, date d'ajout
- [ ] Barre de recherche par nom ou numéro d'identification
- [ ] Carte lapin (`LapinCard`) :
  - Photo ou avatar par défaut selon race/sexe
  - Nom + race + statut (badge coloré)
  - Dernier poids + GMQ
  - Icône d'alerte si anomalie détectée
- [ ] Bouton flottant "Ajouter un lapin"
- [ ] Pull-to-refresh

#### Ajout d'un Lapin

- [ ] Formulaire multi-étapes (3 étapes) :
  - **Étape 1** : Identité
    - Photo (caméra ou galerie)
    - Nom, Race (picker), Sexe
    - Date de naissance ou âge estimé
    - Numéro d'identification (auto-généré ou manuel)
  - **Étape 2** : Paramètres initiaux
    - Poids actuel (avec clavier numérique)
    - Statut initial
    - Notes libres
  - **Étape 3** : Généalogie (optionnel)
    - Sélection du père (parmi les mâles de l'élevage)
    - Sélection de la mère (parmi les femelles)
- [ ] Validation en temps réel de chaque champ
- [ ] Compression photo avant upload (< 200 Ko)
- [ ] Upload photo vers Supabase Storage
- [ ] Sauvegarde locale SQLite + sync Supabase

---

### Semaine 5 — Module Lapins (partie 2)

#### Fiche Individuelle d'un Lapin

- [ ] En-tête avec photo, nom, statut, race
- [ ] Indicateurs rapides : âge, poids, GMQ, score santé
- [ ] Onglets de navigation :
  - **Croissance** : graphique courbe réelle vs cible (fl_chart)
  - **Santé** : historique chronologique des événements
  - **Reproductions** : liste des portées (si femelle)
  - **Informations** : fiche complète + arbre généalogique

#### Suivi Pondéral

- [ ] Widget de saisie rapide (accessible depuis la liste)
- [ ] Formulaire de pesée :
  - Date (aujourd'hui par défaut)
  - Poids en grammes (clavier numérique)
  - Notes optionnelles
- [ ] Calcul automatique GMQ entre chaque pesée
- [ ] Graphique fl_chart interactif :
  - Courbe réelle (points + ligne bleue)
  - Courbe cible de la race (ligne verte pointillée)
  - Zones de couleur (vert/orange/rouge selon performance)
- [ ] Alerte si GMQ < 80% de la norme pendant 7 jours consécutifs
- [ ] Prédiction poids à 10/12/14 semaines (Edge Function)

#### QR Code par Animal

- [ ] Génération QR code unique à la création (`qr_flutter`)
- [ ] QR code encodant l'URL : `lapinia.app/lapin/{id}`
- [ ] Écran d'affichage du QR avec partage/impression
- [ ] Scanner QR code pour accéder directement à la fiche

---

### Semaine 6 — Module Portées (partie 1)

#### Planning des Saillies

- [ ] Liste des femelles disponibles (statut = REPOS + score > 60)
- [ ] Formulaire de saillie :
  - Sélection femelle (avec score de fertilité affiché)
  - Sélection mâle (avec score de fertilité)
  - Vérification consanguinité automatique avant validation
    → Si F > 6.25% : avertissement orange
    → Si F > 12.5% : blocage rouge avec explication
  - Date de saillie
  - Observations (acceptation, comportement)
- [ ] Création automatique de l'enregistrement portée
- [ ] Planification des alertes FCM (J7, J14, J25, J-3, J-1)
- [ ] Mise à jour automatique du statut de la femelle → EN_GESTATION

#### Suivi de Gestation

- [ ] Timeline visuelle J0–J31 :
  ```
  J0  ●──────────────────────────────────● J31
      │ J7       J14      J25    J28  J31│
      │ Implant  Contrôle Nid    Alerte  │
      ●    ●        ●       ●      ●     ●
  ```
- [ ] Jalons automatiques avec dates calculées
- [ ] Barre de progression (% gestation écoulée)
- [ ] Checklist pré-mise bas à J25 :
  - [ ] Cage de maternité nettoyée
  - [ ] Nid garni (foin, paille)
  - [ ] Température vérifiée (28–30°C)
  - [ ] Aliments et eau abondants
  - [ ] Isolement de la femelle

---

### Semaine 7 — Module Portées (partie 2)

#### Enregistrement de la Mise Bas

- [ ] Formulaire de mise bas :
  - Date et heure réelles
  - Nombre de lapereaux vivants
  - Nombre de lapereaux morts-nés
  - Poids total de la portée (grammes)
  - Observations (comportement de la mère, anomalies)
- [ ] Création automatique des enregistrements lapereaux
- [ ] Mise à jour statut femelle → LACTATION
- [ ] Calcul automatique date de sevrage (J+28 à J+35)

#### Suivi de Lactation

- [ ] Rappels de pesée J1, J7, J14, J21 (notifications push)
- [ ] Formulaire pesée rapide portée :
  - Poids individuel ou poids total portée
  - Calcul automatique GMQ par lapereau
- [ ] Alertes si GMQ lapereau < 10g/j
- [ ] Détection lapereau en danger (poids < 50g à J7)
- [ ] Suivi de la mère (alimentation, observation mammelles)

#### Sevrage

- [ ] Notification à J25 : "Sevrage dans 3–10 jours"
- [ ] Formulaire de sevrage :
  - Confirmation du sevrage
  - Poids final par lapereau
  - Destination de chaque lapereau :
    - Conserver comme reproducteur → créer fiche lapin
    - Vente → enregistrer transaction
    - Consommation familiale
- [ ] Mise à jour statut femelle → REPOS
- [ ] Calcul automatique de la date de prochaine saillie recommandée

---

### Semaine 8 — Dashboard et Notifications

#### Tableau de Bord

- [ ] Carte "Conseil IA du jour" :
  - Appel Edge Function `/v1/edge/daily-advice` au démarrage
  - Cache 24h (pas de rappel inutile)
  - Icône pulsante si nouveau conseil disponible
- [ ] Grille de 4 KPIs :
  ```
  ┌──────────────┬──────────────┐
  │  8 Lapins    │  3 Gestantes │
  ├──────────────┼──────────────┤
  │  5j Naissance│  12 Attendus │
  └──────────────┴──────────────┘
  ```
- [ ] Section "Alertes du jour" (max 5, triées par priorité)
- [ ] Timeline "Cette semaine" (événements des 7 prochains jours)
- [ ] Widget saisie rapide (pesée en 2 taps)

#### Système de Notifications

- [ ] Configuration FCM dans Flutter
- [ ] Handlers de notification :
  - Foreground (notification in-app)
  - Background (notification système)
  - Terminated (deep link vers l'écran concerné)
- [ ] Edge Function CRON `check-stock-alerts` (quotidienne 8h) :
  - Vérifier tous les stocks sous le seuil
  - Créer alertes en base
  - Envoyer FCM aux utilisateurs concernés
- [ ] Edge Function CRON `send-weekly-report` (lundi 7h) :
  - Générer résumé de la semaine
  - Envoyer notification push + email optionnel
- [ ] Paramètres de notification (heures, catégories, mode silencieux)

---

## PHASE 2 — IA Base

> **Durée** : 4 semaines
> **Objectif** : Intégrer Mistral AI et TFLite pour les fonctionnalités IA de base

---

### Semaine 9 — Edge Functions et AIRouter

#### Infrastructure IA (SOLID-D)

- [ ] Créer `_shared/ai-router.ts` avec :
  - Interface `AIProvider` (complete, isAvailable, getCost)
  - `ClaudeProvider` (claude-sonnet-4-5)
  - `MistralProvider` (mistral-large-latest)
  - `AIRouter` avec injection et fallback automatique
- [ ] Créer `_shared/auth-middleware.ts` (validation JWT)
- [ ] Créer `_shared/idempotency.ts` (check + cache Redis/KV)
- [ ] Créer `_shared/rate-limiter.ts` (sliding window par plan)
- [ ] System prompt `SYSTEM_PROMPT_CUNICULTURE_FR` commun à tous les providers
- [ ] Tests unitaires des Edge Functions en local :
  ```bash
  supabase functions serve --env-file .env.local
  ```

#### Edge Function : calculate-ration

- [ ] Input : `{ userId, date }` (calcule pour tous les lapins)
- [ ] Récupérer tous les lapins actifs de l'utilisateur
- [ ] Pour chaque lapin : calculer les besoins selon race + stade :
  ```
  Besoins de base selon race (depuis table races)
  × facteur_stade (REPOS=1.0, GESTATION=1.2, LACTATION=1.4)
  × facteur_temperature (si T° > 30°C → -10% appétit)
  ```
- [ ] Appel Mistral (complexité low) pour suggestions d'optimisation
- [ ] Output : `{ rations[], coutTotal_fcfa, alertesStock[] }`
- [ ] Cacher le résultat 6h (pas de recalcul inutile)

#### Edge Function : predict-growth

- [ ] Input : `{ lapinId, semainesAvenir: 10 }`
- [ ] Récupérer race + historique pesées du lapin
- [ ] Calculer GMQ moyen sur les 3 dernières semaines
- [ ] Projeter la courbe jusqu'au poids adulte cible de la race
- [ ] Calculer la date optimale de vente (poids commercial atteint)
- [ ] Output : `{ courbe[], poidsVenteEstime_g, dateVenteOptimale }`

---

### Semaine 10 — Module Alimentation

#### Gestion des Stocks

- [ ] Écran inventaire avec jauges de stock :
  ```
  Foin luzerne  ███████░░░ 72%  ✅ OK
  Granulés      ████░░░░░░ 40%  🟡 Attention
  Son de mil    █░░░░░░░░░ 12%  🔴 Critique
  ```
- [ ] Formulaire ajout/modification de stock :
  - Sélection aliment (liste + recherche)
  - Quantité en kg
  - Prix/kg en FCFA
  - Nom et contact fournisseur
  - Seuil d'alerte personnalisable
- [ ] Calcul automatique des jours restants selon consommation estimée

#### Rations IA Quotidiennes

- [ ] Bouton "Calculer les rations d'aujourd'hui"
  - Appel Edge Function `/v1/edge/calculate-ration`
  - Affichage d'un loader avec message humoristique
- [ ] Affichage des rations par animal ou par groupe :
  ```
  Nala (Gestation J28)
  ├── Foin luzerne   : 250g (+20% gestation)
  ├── Granulés       : 180g
  └── Bloc minéral Ca: 1 bloc
  ```
- [ ] Plan de transition alimentaire au sevrage (7 jours progressifs)
- [ ] Fiches aliments locaux africains (50 fiches)

---

### Semaine 11 — TFLite et Reconnaissance de Races

#### Modèle TFLite On-Device

- [ ] Préparer le modèle MobileNetV3 fine-tuné sur 15 races
  - Dataset : 150+ photos par race (sources ouvertes)
  - Fine-tuning avec TensorFlow puis conversion TFLite
  - Taille cible du modèle : < 15 Mo
- [ ] Intégrer dans Flutter via `tflite_flutter`
- [ ] Créer `RaceRecognitionService` :
  ```dart
  class RaceRecognitionService {
    Future<RaceRecognitionResult> analyzePhoto(File photo) async {
      // Prétraitement : resize 224x224, normalisation
      // Inférence TFLite
      // Top-3 résultats avec scores de confiance
    }
  }
  ```
- [ ] Écran de reconnaissance :
  - Capture photo ou sélection galerie
  - Affichage du résultat avec score de confiance
  - Top 3 races probables
  - Bouton "Confirmer" ou "Corriger"

#### Base de Connaissances Hors-ligne

- [ ] Créer `local_knowledge_base.json` (200+ Q&R)
- [ ] Catégories couvertes :
  - Reproduction (50 Q&R)
  - Santé et maladies (60 Q&R)
  - Alimentation (40 Q&R)
  - Croissance (30 Q&R)
  - Commercialisation (20 Q&R)
- [ ] Service `OfflineKnowledgeService` :
  - Recherche par mots-clés
  - Score de pertinence
  - Fallback si IA cloud indisponible

---

### Semaine 12 — Module Assistant IA (Chat)

#### Interface Chat

- [ ] Écran chat avec historique scrollable
- [ ] Bulles de message (utilisateur à droite, IA à gauche)
- [ ] Zone de saisie avec bouton envoi + icône micro (V2)
- [ ] Indicateur de frappe (3 points animés pendant la génération)
- [ ] Boutons de questions rapides :
  ```
  🩺 Symptômes à surveiller
  💰 Prix de vente actuel
  📈 Améliorer le taux de survie
  🐇 Meilleures races pour ma région
  ```

#### Logique IA Contextuelle

- [ ] Injecter le contexte complet de l'élevage dans chaque prompt :
  ```
  Éleveur: {nom}, région: {region}
  Lapins: {nb_total} dont {nb_gestantes} gestantes
  Dernière alerte: {derniere_alerte}
  Stocks critiques: {stocks_critiques}
  ```
- [ ] Routing automatique Mistral/Claude selon complexité :
  - Mot-clé simple → TFLite hors-ligne
  - Question standard → Mistral
  - Diagnostic / génétique / stratégie → Claude
- [ ] Historique de conversation stocké en SQLite
- [ ] Rapport IA mensuel automatique (1er du mois)

---

## PHASE 3 — IA Avancée

> **Durée** : 4 semaines
> **Objectif** : Diagnostic complet, génétique, prédictions avancées

---

### Semaine 13 — Module Santé et Diagnostic IA

#### Journal d'Observation Quotidien

- [ ] Widget de saisie rapide sur la fiche de chaque lapin :
  - Appétit : 😋 Normal / 😐 Réduit / 😞 Absent
  - Comportement : Actif / Calme / Prostré / Agité
  - Selles : Normales / Molles / Diarrhée / Absent
  - Aspect : Brillant / Terne / Poils hérissés
  - Bouton "Tout va bien" (saisie en 1 tap)
- [ ] Alerte automatique si 2 jours consécutifs anormaux

#### Diagnostic IA par Symptômes

- [ ] Formulaire de sélection des symptômes (chips multiselect) :
  ```
  Respiratoires    Digestifs      Cutanés
  □ Éternuements   □ Diarrhée     □ Alopécie
  □ Écoulement nez □ Ballonnement □ Croûtes
  □ Dyspnée        □ Anorexie     □ Prurit
  □ Toux           □ Diarrhée sang□ Abcès
  ```
- [ ] Bouton "Analyser avec l'IA"
  - Appel Edge Function `/v1/edge/diagnose-symptoms`
  - Loader avec message rassurant
- [ ] Affichage du résultat :
  ```
  🔴 URGENCE IMMÉDIATE

  Diagnostic probable #1 : Pasteurellose (78%)
  ──────────────────────────────────────────
  Traitement : Enrofloxacine
  Dosage     : 5mg/kg/jour pendant 5–7 jours
  Voie       : Oral (eau de boisson)
  Délai abattage : 14 jours après arrêt

  ⚠️ Contre-indication : Ne pas utiliser si gestante

  Diagnostic probable #2 : Myxomatose (15%)
  Diagnostic probable #3 : Rhinite allergique (7%)

  → Isoler l'animal immédiatement
  → Consulter un vétérinaire si pas d'amélioration à 48h
  ```
- [ ] Détection épidémique automatique :
  - Si 3+ animaux mêmes symptômes en 48h → alerte rouge
  - Protocole d'isolement et de désinfection affiché
  - Notification push critique envoyée

#### Pharmacologie

- [ ] Base de 40 médicaments avec fiches détaillées :
  - Classe thérapeutique
  - Posologie calculée automatiquement selon poids de l'animal
  - Voie d'administration avec illustration
  - Contre-indications (gestation, lactation, âge)
  - Délai d'abattage avec compte à rebours
  - Interactions dangereuses
- [ ] Carnet de vaccination :
  - Calendrier VHD (J70 + rappel annuel)
  - Calendrier Myxomatose (selon région)
  - Rappels automatiques J-7, J-3, J0

---

### Semaine 14 — Module Génétique

#### Arbre Généalogique

- [ ] Visualisation graphique 3 générations :
  ```
       Grand-père  Grand-mère   Grand-père Grand-mère
           │            │            │          │
           └────────────┘            └──────────┘
                 │                        │
               Père                     Mère
                 └────────────────────────┘
                               │
                             LAPIN
  ```
- [ ] Chaque nœud cliquable → ouvre la fiche de l'animal
- [ ] Affichage des performances (GMQ, taille portée, score santé)

#### Calcul de Consanguinité (Algorithme Wright)

- [ ] Implémentation de l'algorithme de Wright :
  ```typescript
  // Coefficient F = Σ (1/2)^(n1+n2+1) × (1+FA)
  // n1 = nombre de générations entre femelle et ancêtre commun
  // n2 = nombre de générations entre mâle et ancêtre commun
  // FA = coefficient de consanguinité de l'ancêtre commun
  function calculerCoefficientF(
    femelle_id: string,
    male_id: string,
    genealogie: GenealogyNode[]
  ): ConsanguinityResult
  ```
- [ ] Affichage visuel du résultat :
  ```
  Coefficient F : 3.13%  ✅ Faible risque
  Niveau : Acceptable (< 6.25%)
  Recommandation : Croisement autorisé

  ──── ou ────

  Coefficient F : 9.38%  ⚠️ Risque modéré
  Niveau : Élevé (entre 6.25% et 12.5%)
  Recommandation : Déconseillé — chercher un autre mâle
  ```
- [ ] Suggestion automatique des 3 meilleurs mâles disponibles
  (classés par score génétique décroissant)

#### Plan d'Amélioration Génétique

- [ ] Définition des objectifs de sélection par l'éleveur :
  - Taille des portées (priorité 1–5)
  - Vitesse de croissance (priorité 1–5)
  - Rusticité et résistance chaleur (priorité 1–5)
  - Qualité de la viande (priorité 1–5)
- [ ] Appel Claude pour générer un plan sur 3 générations
- [ ] Affichage du plan avec jalons et animaux cibles

---

### Semaine 15 — Prédictions Avancées et Fertilité

#### Score de Fertilité Individuel

- [ ] Calcul automatique du score /100 pour chaque animal :
  ```
  Femelle :
    Taux d'acceptation saillie   : 25 pts
    Taille moyenne portées        : 25 pts
    Taux de survie lapereaux      : 25 pts
    Régularité des cycles         : 25 pts

  Mâle :
    Taux de succès des saillies   : 40 pts
    Vigueur et comportement       : 30 pts
    Qualité de la descendance     : 30 pts
  ```
- [ ] Badge de score sur chaque fiche animal :
  ```
  🟢 Excellent (80–100)
  🟡 Bon (60–79)
  🟠 Passable (40–59)
  🔴 Faible (< 40)
  ```
- [ ] Alerte si score chute de > 20 points en 3 mois
- [ ] Recommandations IA pour améliorer le score

#### Prédiction Taille de Portée

- [ ] Modèle prédictif basé sur :
  - Race de la femelle (taille portée historique de la race)
  - Rang de portée (1ère portée généralement plus petite)
  - Âge et état corporel de la femelle
  - Historique personnel de la femelle
  - Saison et température
  - Score de fertilité du mâle
- [ ] Affichage : `Portée estimée : 6–8 lapereaux`

#### Calendrier de Production Annuel

- [ ] Vue calendrier 12 mois avec planification :
  - Objectif : X lapereaux/mois à vendre
  - L'IA calcule le nombre de saillies nécessaires
  - Répartition équitable de la charge de travail
  - Prise en compte des saisons (moins de saillies en forte chaleur)

---

### Semaine 16 — Traçabilité et Certifications

#### Traçabilité Complète

- [ ] Identifiant unique auto-généré :
  - Format : `{PAYS}-{ANNÉE}-{RACE}-{NUMÉRO}`
  - Exemple : `SN-2026-NZW-0042`
- [ ] QR Code rattaché à chaque animal :
  - Scan → fiche complète (même hors-ligne via SQLite local)
  - Impression via Bluetooth ou partage image
- [ ] Passeport animal numérique (PDF) :
  - Identité complète
  - Pedigree sur 3 générations
  - Historique vaccinal complet
  - Performances de croissance
  - Origine de l'élevage + coordonnées éleveur
  - Logo lapiNia + QR code
- [ ] Registre d'élevage officiel :
  - Format conforme DIREL Sénégal
  - Entrées et sorties d'animaux horodatées
  - Export PDF mensuel

---

## PHASE 4 — Finance et QR

> **Durée** : 3 semaines
> **Objectif** : Module financier complet et fonctionnalités de traçabilité

---

### Semaine 17 — Module Finance

#### Journal des Ventes

- [ ] Formulaire de vente rapide :
  - Sélection du ou des animaux vendus
  - Prix unitaire ou global en FCFA
  - Acheteur (nom + contact, enregistré pour réutilisation)
  - Mode de paiement : Cash / Orange Money / Wave / Virement
  - Photo du reçu (optionnel)
- [ ] Enregistrement idempotent (UUID généré avant la saisie)
- [ ] Mise à jour automatique du statut des animaux → VENDU

#### Journal des Dépenses

- [ ] Catégories :
  ```
  🌾 Alimentation   💊 Médicaments   🔧 Équipements
  👷 Main-d'œuvre   🚗 Transport     📋 Charges fixes
  ```
- [ ] Formulaire de dépense avec catégorisation automatique
  (IA détecte la catégorie selon la description)

#### Tableau de Bord Financier

- [ ] Graphique revenus vs dépenses (barres mensuelles)
- [ ] Graphique évolution bénéfice (ligne 12 mois)
- [ ] Indicateurs temps réel :
  - Bénéfice net du mois
  - Coût de production par lapereau
  - Seuil de rentabilité (nb lapereaux à vendre ce mois)
  - Prévision revenus mois prochain

#### Outils de Rentabilité

- [ ] Calculateur de prix de vente suggéré :
  - Appel Mistral avec coût de production + marché local
  - Prix minimum (seuil rentabilité) + prix recommandé
- [ ] Simulateur d'investissement :
  ```
  Si j'achète 2 femelles NZW à 15 000 FCFA chacune :
  → Coût total : 30 000 FCFA
  → Portées estimées/an : 8 × 2 = 16 portées
  → Lapereaux/an : ~112 lapereaux
  → Revenu brut estimé : 560 000 FCFA
  → ROI : 6 mois
  ```
- [ ] Export rapport comptable PDF (mensuel/annuel)

---

### Semaine 18 — Module Infrastructure et Optimisations

#### Gestion des Cages

- [ ] Plan visuel de l'élevage :
  - Grille de cages avec couleurs selon statut de l'occupant
  - Drag & drop pour réaffecter un animal
  - Vue densité (nb lapins/m²) avec alerte surpopulation
- [ ] Protocole de nettoyage :
  - Rappels automatiques toutes les 2 semaines
  - Checklist de désinfection
  - Historique des nettoyages
- [ ] Cages de maternité :
  - Disponibilité en temps réel
  - Température recommandée avec alerte si non-respect

#### Optimisations Techniques

- [ ] Optimisation des performances :
  - Lazy loading sur toutes les listes
  - Mise en cache des requêtes fréquentes (24h)
  - Compression des images avant affichage
  - Pagination cursor-based sur toutes les listes
- [ ] Optimisation hors-ligne :
  - Pré-chargement des données critiques au démarrage
  - Indicateur clair du mode hors-ligne (bandeau orange)
  - Résolution des conflits de synchronisation testée

---

### Semaine 19 — Intégrations Finales

#### Paiements (Plans Abonnement)

- [ ] Écran de souscription avec les 3 plans :
  ```
  GRATUIT        ÉLEVEUR         PRO
  0 FCFA/mois    2 500/mois      6 500/mois
  10 lapins      Illimité        Illimité
  15 IA/mois     IA complète     IA + Véto
  ```
- [ ] Intégration Orange Money API
- [ ] Intégration Wave API
- [ ] Gestion des abonnements (activation, renouvellement, expiration)
- [ ] Vérification du plan avant chaque fonctionnalité premium

#### Module Formation

- [ ] 12 leçons avec progression :
  - Leçon 1 : Choisir sa race
  - Leçon 2 : Construire son élevage
  - Leçon 3 : L'alimentation de base
  - Leçon 4 : La reproduction
  - Leçon 5 : Les soins quotidiens
  - Leçon 6 : Reconnaître les maladies
  - Leçon 7 : Les vaccinations
  - Leçon 8 : La génétique simplifiée
  - Leçon 9 : La croissance et la pesée
  - Leçon 10 : Vendre ses lapins
  - Leçon 11 : Tenir sa comptabilité
  - Leçon 12 : Agrandir son élevage
- [ ] Quiz de validation à chaque leçon (5 questions)
- [ ] Badge de completion par leçon
- [ ] Glossaire illustré (200+ termes)

---

## PHASE 5 — Polish et Lancement

> **Durée** : 3 semaines
> **Objectif** : Finalisation, tests, soumission aux stores

---

### Semaine 20 — Tests et Qualité

#### Tests Automatisés

- [ ] Tests unitaires (cible : 70% couverture) :
  ```bash
  flutter test --coverage
  ```
  - Tests `DiagnosticService` avec mock `AIProvider`
  - Tests `ReproductionService` (algorithme Wright)
  - Tests `NutritionService` (calculs de rations)
  - Tests `SyncManager` (résolution de conflits)
  - Tests `IdempotencyKey` (unicité)

- [ ] Tests d'intégration :
  - Routes Supabase (CRUD + filtres)
  - Politiques RLS (cross-user bloqué)
  - Edge Functions en local (`supabase functions serve`)
  - SyncManager : offline → reconnexion → sync

- [ ] Tests de charge avec k6 :
  ```javascript
  // 1000 utilisateurs simultanés sur GET /rest/v1/lapins
  // Vérification : p95 < 800ms
  // Vérification : rate limiting 429 après seuil
  ```

#### Tests Manuels Terrain

- [ ] Tests sur appareils réels :
  - Android bas de gamme (Tecno Spark 2 Go RAM)
  - Android milieu de gamme (Samsung A13)
  - iPhone SE (iOS 13)
- [ ] Tests de connectivité :
  - Mode avion complet → fonctionnalités de base OK
  - Connexion 2G simulée → synchronisation OK
  - Coupure réseau en cours de saisie → pas de perte de données
- [ ] Tests utilisateurs terrain (10 éleveurs au Sénégal) :
  - Session de 2h avec observations
  - Questionnaire NPS
  - Liste des bugs et friction points

---

### Semaine 21 — Corrections et Sécurité

#### Corrections Issues Terrain

- [ ] Prioriser et corriger tous les bugs remontés
- [ ] Améliorer les points de friction UX identifiés
- [ ] Optimiser les performances si nécessaire
- [ ] Compléter les messages d'erreur utilisateur

#### Audit de Sécurité

- [ ] Vérification OWASP Mobile Top 10 :
  - M1 : Mauvaise utilisation des credentials → ✅ (clés en Edge Fn)
  - M2 : Stockage de données non sécurisé → ✅ (SQLite chiffré)
  - M3 : Communication non sécurisée → ✅ (TLS 1.3)
  - M4 : Authentification faible → ✅ (OTP SMS + JWT)
  - M5 : Cryptographie faible → ✅ (AES-256)
- [ ] Test de pénétration JWT (tentative de forge de token)
- [ ] Test RLS final (tentative d'accès cross-user)
- [ ] Scan des dépendances Flutter (`flutter pub audit`)
- [ ] Revue des variables d'environnement Supabase

#### Monitoring

- [ ] Configurer Sentry Flutter :
  - Capture automatique des crashs
  - Reporting des erreurs réseau
  - Performance monitoring
- [ ] Configurer Supabase Logs :
  - Alertes sur les Edge Functions en erreur
  - Alertes sur les queries lentes (> 2s)
- [ ] Dashboard de monitoring :
  - Uptime Supabase
  - Coût IA hebdomadaire (Claude + Mistral)
  - Nombre de requêtes Edge Functions

---

### Semaine 22 — Lancement sur les Stores

#### Préparation App Store (iOS)

- [ ] Créer le compte Apple Developer (99$/an)
- [ ] Configurer les certificats et profils de provisioning
- [ ] Préparer les assets App Store :
  - Icône 1024×1024 (fond vert #2E7D32, lapin blanc stylisé)
  - Captures d'écran iPhone 6.7" (6 écrans)
  - Captures d'écran iPad (si supporté)
  - Description en français (4000 caractères max)
  - Mots-clés : élevage lapin, cuniculture, agriculture, Sénégal
- [ ] Build et soumission :
  ```bash
  flutter build ipa --release
  xcrun altool --upload-app -f build/ios/ipa/lapinia.ipa
  ```
- [ ] Soumettre pour review (délai estimé : 1–3 jours)

#### Préparation Google Play Store (Android)

- [ ] Créer le compte Google Play Console (25$ une fois)
- [ ] Générer la clé de signature :
  ```bash
  keytool -genkey -v -keystore lapinia.keystore
          -alias lapinia -keyalg RSA -keysize 2048
  ```
- [ ] Préparer les assets Play Store :
  - Icône 512×512 PNG
  - Feature graphic 1024×500
  - Captures d'écran téléphone (8 écrans minimum)
  - Description courte (80 caractères)
  - Description longue (4000 caractères)
- [ ] Build et upload :
  ```bash
  flutter build appbundle --release
  # Uploader le .aab sur Play Console
  ```
- [ ] Passer la review (délai estimé : 1–7 jours)

#### Communication de Lancement

- [ ] Page de présentation lapiNia (site vitrine simple)
- [ ] Vidéo de démonstration (2–3 minutes)
- [ ] Communication sur les réseaux agricoles sénégalais
- [ ] Partenariats avec organisations agricoles :
  - ANSD (Agence Nationale de Statistiques)
  - DIREL (Direction de l'Élevage)
  - ONG agricoles locales (ENDA, etc.)
- [ ] Programme de bêta-testeurs (100 éleveurs sélectionnés)

---

## PHASE 6 — Version 1.5

> **Durée** : 3 mois post-lancement
> **Objectif** : Langues locales, mode vocal, communauté

---

### Mois 1 post-lancement : Internationalisation

- [ ] Traduction en Wolof (avec traducteur natif)
  - Toutes les chaînes UI
  - Base de connaissances hors-ligne
  - Leçons de formation simplifiées
- [ ] Traduction en Pulaar
- [ ] Détection automatique de la langue du téléphone
- [ ] Switcher de langue accessible depuis les paramètres

### Mois 2 post-lancement : Mode Vocal

- [ ] Intégration `speech_to_text` Flutter
- [ ] Intégration `flutter_tts` (text-to-speech)
- [ ] Commandes vocales pour :
  - Saisie d'une pesée : "Nala pèse 2400 grammes"
  - Question à l'IA : "Comment traiter la diarrhée ?"
  - Navigation : "Ouvrir la fiche de Thor"
- [ ] Mode dictée dans le formulaire de saisie rapide
- [ ] Réponses IA lues à voix haute (optionnel)

### Mois 3 post-lancement : Communauté et Marketplace

- [ ] Forum communautaire :
  - Fil de discussion par sujet (santé, alimentation, vente...)
  - Modération par vétérinaire partenaire
  - Système de réputation (éleveurs certifiés)
- [ ] Marketplace lapins :
  - Annonce auto-générée depuis la fiche de l'animal
  - Photos, pedigree, performances affichés
  - Contact via WhatsApp ou appel direct
  - Commission 3% sur ventes confirmées

---

## PHASE 7 — Version 2.0

> **Durée** : 6 mois post-lancement
> **Objectif** : IoT, vision avancée, API publique

---

### Trimestre 1 : Capteurs IoT

- [ ] Intégration capteur température/humidité Bluetooth (SHT30)
- [ ] Interface de configuration des capteurs par cage
- [ ] Alertes automatiques si T° > 30°C (stress thermique)
- [ ] Historique des données ambiantes avec graphiques
- [ ] Corrélation température → performances de reproduction

### Trimestre 2 : Vision IA Avancée

- [ ] Estimation du poids par photo (±15%) :
  - Modèle de vision entraîné sur photos lapins pesés
  - Utile sans balance disponible en urgence
- [ ] Analyse photo des symptômes :
  - Photo d'une lésion, déjection, comportement
  - Aide au diagnostic par vision Claude
- [ ] Reconnaissance automatique de l'animal par photo
  (identification sans scan du QR code)

### Trimestre 3 : Écosystème

- [ ] API publique `/api/v2/` pour partenaires :
  - Documentation OpenAPI (Swagger)
  - Clés API par partenaire
  - Webhooks pour événements (mise bas, maladie...)
- [ ] Version web (dashboard éleveurs et ONG) :
  - Flutter Web ou React admin
  - Vue multi-élevages pour conseillers agricoles
  - Rapports agrégés pour ONG
- [ ] OCR sur reçus de dépenses (photo reçu → saisie auto)
- [ ] Intégration données météo en temps réel (Open-Meteo API)

---

## Récapitulatif Global

```
┌────────────────────────────────────────────────────────────────────┐
│                    TIMELINE GLOBALE lapiNia                        │
├──────────┬─────────────────────────────────┬───────────────────────┤
│ Semaine  │ Phase                           │ Livrable              │
├──────────┼─────────────────────────────────┼───────────────────────┤
│  1–2     │ Phase 0 : Setup                 │ Infrastructure prête  │
│  3–8     │ Phase 1 : Core                  │ App fonctionnelle     │
│  9–12    │ Phase 2 : IA Base               │ Mistral + TFLite      │
│  13–16   │ Phase 3 : IA Avancée            │ Claude + Génétique    │
│  17–19   │ Phase 4 : Finance & QR          │ Module complet        │
│  20–22   │ Phase 5 : Polish & Lancement    │ 🚀 App Store + Play   │
├──────────┼─────────────────────────────────┼───────────────────────┤
│  M4–M6   │ Phase 6 : V1.5                  │ Wolof + Vocal + Forum │
│  M7–M13  │ Phase 7 : V2.0                  │ IoT + Vision + API    │
└──────────┴─────────────────────────────────┴───────────────────────┘
```

### Critères de Passage entre les Phases

| Passage | Critère obligatoire |
|---|---|
| Phase 0 → Phase 1 | CI/CD vert · Supabase opérationnel · SQLite sync OK |
| Phase 1 → Phase 2 | Auth OTP · CRUD Lapins · Portées · Notifications |
| Phase 2 → Phase 3 | AIRouter opérationnel · Rations calculées · TFLite intégré |
| Phase 3 → Phase 4 | Diagnostic IA fonctionnel · Consanguinité OK · Score fertilité |
| Phase 4 → Phase 5 | Finance · QR codes · Formation · Toutes fonctionnalités V1 |
| Phase 5 → Lancement | Tests passants · Audit sécurité OK · Review stores approuvée |

### Métriques de Succès à 6 Mois

| Métrique | Cible |
|---|---|
| Utilisateurs actifs | 5 000 |
| Abonnements payants | 400 (plan Éleveur ou Pro) |
| Rétention J30 | > 45% |
| NPS | > 55 |
| Note App Store / Play Store | > 4.3 ⭐ |
| Précision diagnostic IA | > 80% |
| Réduction mortalité (terrain) | -25% |

---

*lapiNia — Plan de Développement Complet v1.0 — Mai 2026*
*Flutter · Supabase · Claude AI · SOLID · API Design*
MARKDOWN_EOF