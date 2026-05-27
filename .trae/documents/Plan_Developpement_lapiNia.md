# Plan de Développement - lapiNia Mobile App

**Date** : 27 mai 2026  
**Version** : 1.0

---

## 1. Contexte et Objectifs

**lapiNia** est une application mobile Flutter d'élevage cunicole pilotée par l'IA, destinée aux éleveurs d'Afrique de l'Ouest (Sénégal, Mali, Côte d'Ivoire). L'application fonctionne **hors-ligne en priorité** et se synchronise avec Supabase Cloud quand le réseau est disponible.

### Stack Technique
- **Frontend** : Flutter 3.x (Dart) — iOS & Android
- **Backend** : Supabase Cloud (PostgreSQL + Edge Functions TypeScript/Deno)
- **Base locale** : SQLite via Drift (mode hors-ligne)
- **IA** : Claude Sonnet API (Anthropic) + Mistral AI via Edge Functions + TensorFlow Lite on-device
- **Notifications** : Firebase Cloud Messaging (FCM)
- **Paiement** : Orange Money + Wave + Stripe

### Principes Architecturaux
- **SOLID** (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion)
- **Clean Architecture** (Core / Data / Domain / Presentation)
- **API Design Best Practices** (Idempotency, Pagination, Clear Naming, Versioning, Rate Limiting)

---

## 2. Phases de Développement

### Phase 0 : Setup et Fondations (2 semaines)

#### 2.0.1 Infrastructure Supabase
- [ ] Créer projet Supabase sur supabase.com
- [ ] Exécuter scripts SQL de création des 11 tables (races, lapins, portees, lapereaux, pesees, medicaments, sante, stocks, finances, alertes, genealogie)
- [ ] Activer RLS sur toutes les tables utilisateur
- [ ] Créer indexes PostgreSQL critiques
- [ ] Insérer données de référence (15 races, 40 médicaments, 50 aliments)
- [ ] Configurer OTP SMS (Twilio/Vonage)
- [ ] Configurer variables d'environnement (ANTHROPIC_API_KEY, MISTRAL_API_KEY, FCM_SERVER_KEY)

#### 2.0.2 Firebase Configuration
- [ ] Créer projet Firebase
- [ ] Activer FCM
- [ ] Télécharger google-services.json (Android)
- [ ] Télécharger GoogleService-Info.plist (iOS)
- [ ] Configurer topics FCM

#### 2.0.3 Projet Flutter
- [ ] Créer projet Flutter avec `flutter create --org com.lapinia --platforms android,ios lapinia`
- [ ] Structurer Clean Architecture (core/, data/, domain/, presentation/)
- [ ] Configurer pubspec.yaml avec packages nécessaires (supabase_flutter, drift, flutter_bloc, go_router, fl_chart, qr_flutter, etc.)
- [ ] Créer constantes UI (AppColors, typographie)

#### 2.0.4 Base Locale SQLite (Drift)
- [ ] Créer schéma Drift avec tables locales
- [ ] Implémenter SyncQueue pour mutations hors-ligne
- [ ] Implémenter SyncManager (écoute connectivity, vidage queue, résolution conflits Last-Write-Wins)

#### 2.0.5 CI/CD GitHub Actions
- [ ] Configurer dépôt GitHub avec branches (main, staging, develop, feature/*)
- [ ] Créer workflows CI (test, analyze, build)
- [ ] Configurer secrets GitHub

---

### Phase 1 : Core - Authentification et Modules Principaux (6 semaines)

#### 1.1 Authentification OTP SMS (Semaine 3)
- [ ] Écran bienvenue avec sélection langue
- [ ] Écran saisie numéro téléphone (+221, +223, +225...)
- [ ] Écran saisie OTP (6 champs, countdown 60s)
- [ ] Gestion tokens JWT (stockage sécurisé, refresh auto)
- [ ] Onboarding questionnaire 5 questions

#### 1.2 Module Lapins - Partie 1 (Semaine 4)
- [ ] Liste lapins avec ListView.builder, filtres (statut, race, sexe), tri, recherche
- [ ] Carte lapin (LapinCard) avec photo, nom, race, statut, GMQ
- [ ] Formulaire ajout lapin multi-étapes (3 étapes : identité, paramètres initiaux, généalogie)
- [ ] Upload photo vers Supabase Storage avec compression (< 200 Ko)

#### 1.3 Module Lapins - Partie 2 (Semaine 5)
- [ ] Fiche individuelle lapin (en-tête, onglets : croissance, santé, reproductions, informations)
- [ ] Widget saisie rapide pesée
- [ ] Calcul automatique GMQ
- [ ] Graphique croissance (fl_chart) courbe réelle vs cible race
- [ ] Alerte GMQ < 80% norme
- [ ] Génération QR code (qr_flutter)

#### 1.4 Module Portées - Partie 1 (Semaine 6)
- [ ] Liste femelles disponibles (REPOS + score fertilité)
- [ ] Formulaire saillie avec vérification consanguinité
- [ ] Timeline gestation J0-J31 avec jalons
- [ ] Checklist pré-mise bas
- [ ] Planification alertes FCM

#### 1.5 Module Portées - Partie 2 (Semaine 7)
- [ ] Formulaire mise bas (nb vivants, morts, poids portée)
- [ ] Création automatique lapereaux
- [ ] Suivi lactation avec pesées J1/J7/J14/J21
- [ ] Alertes GMQ lapereau < 10g/j
- [ ] Formulaire sevrage avec destinations

#### 1.6 Dashboard et Notifications (Semaine 8)
- [ ] Carte "Conseil IA du jour"
- [ ] KPIs grille (nb lapins, gestantes, lapereaux attendus)
- [ ] Section alertes prioritaires
- [ ] Timeline 7 jours
- [ ] Handlers FCM (foreground, background, terminated)
- [ ] Edge Function CRON check-stock-alerts
- [ ] Edge Function CRON send-weekly-report
- [ ] Paramètres notifications

---

### Phase 2 : IA Base (4 semaines)

#### 2.1 Infrastructure IA (Semaine 9)
- [ ] Créer _shared/ai-router.ts (AIProvider interface, ClaudeProvider, MistralProvider, AIRouter)
- [ ] Créer _shared/auth-middleware.ts
- [ ] Créer _shared/idempotency.ts
- [ ] Créer _shared/rate-limiter.ts
- [ ] System prompt cuniculture commun
- [ ] Tests unitaires Edge Functions

#### 2.2 Edge Functions Base
- [ ] calculate-ration (calcule rations par lapin selon race + stade + température)
- [ ] predict-growth (projette courbe croissance jusqu'à poids adulte)
- [ ] daily-advice (conseil IA personnalisé quotidien)

#### 2.3 Module Alimentation (Semaine 10)
- [ ] Écran inventaire stocks avec jauges visuelles
- [ ] Formulaire ajout/modification stock
- [ ] Calcul jours restants selon consommation
- [ ] Affichage rations IA quotidiennes
- [ ] Plan transition alimentaire sevrage
- [ ] Fiches 50 aliments locaux africains

#### 2.4 TFLite Reconnaissance Races (Semaine 11)
- [ ] Préparer modèle MobileNetV3 fine-tuné sur 15 races (< 15 Mo)
- [ ] Intégrer tflite_flutter dans Flutter
- [ ] RaceRecognitionService avec inférence
- [ ] Écran reconnaissance (capture/galerie, top 3 races)
- [ ] Base 200+ Q&R hors-ligne (OfflineKnowledgeService)

#### 2.5 Assistant IA Chat (Semaine 12)
- [ ] Interface chat avec historique
- [ ] Bulles message (utilisateur droite, IA gauche)
- [ ] Indicateur génération
- [ ] Boutons questions rapides
- [ ] Contexte élevage injecté dans prompt
- [ ] Routing Mistral/Claude selon complexité
- [ ] Historique conversation SQLite

---

### Phase 3 : IA Avancée (4 semaines)

#### 3.1 Module Santé et Diagnostic IA (Semaine 13)
- [ ] Widget observation quotidien (appétit, comportement, selles, aspect)
- [ ] Formulaire sélection symptômes (chips multiselect)
- [ ] Edge Function diagnose-symptoms
- [ ] Affichage diagnostic (2-3 probables avec %, urgence, traitement)
- [ ] Détection épidémique (3+ animaux mêmes symptômes/48h)
- [ ] Base 25 maladies avec fiches détaillées
- [ ] Pharmacologie (40 médicaments, dosage auto, contre-indications, délais abattage)
- [ ] Carnet vaccination avec rappels

#### 3.2 Module Génétique (Semaine 14)
- [ ] Visualisation arbre généalogique 3 générations
- [ ] Edge Function consanguinity-check (algorithme Wright)
- [ ] Affichage coefficient F avec seuils (6.25%, 12.5%)
- [ ] Suggestion meilleurs mâles disponibles
- [ ] Plan amélioration génétique (Claude)

#### 3.3 Prédictions Avancées (Semaine 15)
- [ ] Score fertilité individuel (/100)
- [ ] Badge score sur fiches (🟢🟡🟠🔴)
- [ ] Prédiction taille portée
- [ ] Calendrier production annuel

#### 3.4 Traçabilité et Certifications (Semaine 16)
- [ ] Identifiant unique auto-généré (SN-2026-NZW-0042)
- [ ] QR code par animal avec fiche complète
- [ ] Passeport animal PDF
- [ ] Registre élevage officiel DIREL

---

### Phase 4 : Finance et QR (3 semaines)

#### 4.1 Module Finance (Semaine 17)
- [ ] Journal ventes (animal, prix, acheteur, mode paiement)
- [ ] Journal dépenses avec catégories (Alimentation, Médicaments, Équipements...)
- [ ] Tableau bord financier (graphiques revenus/dépenses, bénéfice)
- [ ] Calcul coût production par lapereau
- [ ] Prix vente suggéré (IA)
- [ ] Simulateur investissement
- [ ] Export rapport PDF mensuel/annuel

#### 4.2 Module Infrastructure (Semaine 18)
- [ ] Plan visuel élevage (grille cages, drag & drop)
- [ ] Protocole nettoyage avec rappels
- [ ] Cages maternité avec disponibilité
- [ ] Optimisations performances (lazy loading, cache, pagination)

#### 4.3 Intégrations Finales (Semaine 19)
- [ ] Écrans souscription (Gratuit, Éleveur 2500 FCFA, Pro 6500 FCFA)
- [ ] Intégration Orange Money
- [ ] Intégration Wave
- [ ] Module formation (12 leçons + quiz + glossaire 200 termes)

---

### Phase 5 : Polish et Lancement (3 semaines)

#### 5.1 Tests et Qualité (Semaine 20)
- [ ] Tests unitaires (70% couverture)
- [ ] Tests intégration (routes Supabase, RLS, Edge Functions)
- [ ] Tests charge k6
- [ ] Tests manuels terrain (10 appareils réels)
- [ ] Tests utilisateurs (10 éleveurs)

#### 5.2 Sécurité et Monitoring (Semaine 21)
- [ ] Audit OWASP Mobile Top 10
- [ ] Tests pénétration JWT et RLS
- [ ] Scan dépendances flutter pub audit
- [ ] Configuration Sentry
- [ ] Dashboard monitoring (uptime, coûts IA)

#### 5.3 Lancement Stores (Semaine 22)
- [ ] Préparation App Store (certificats, assets, build .ipa)
- [ ] Préparation Google Play (keystore, assets, build .aab)
- [ ] Soumission review stores
- [ ] Communication lancement (page vitrine, vidéo démo)

---

## 3. Livrables par Phase

| Phase | Durée | Livrables |
|-------|-------|-----------|
| Phase 0 | 2 semaines | Infrastructure Supabase + Firebase + Flutter prêt |
| Phase 1 | 6 semaines | App fonctionnelle (Auth + Lapins + Portées + Dashboard) |
| Phase 2 | 4 semaines | Mistral + TFLite intégrés, Module Alimentation, Chat IA |
| Phase 3 | 4 semaines | Diagnostic IA, Génétique, Prédictions, Traçabilité |
| Phase 4 | 3 semaines | Finance, Infrastructure, Formation, Paiements |
| Phase 5 | 3 semaines | Tests, Sécurité, Lancement stores |

**Total MVP : 22 semaines (~5 mois)**

---

## 4. Structure du Projet Flutter

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   ├── interfaces/
│   │   ├── ai_provider.dart
│   │   ├── base_repository.dart
│   │   ├── notification_service.dart
│   │   └── storage_service.dart
│   ├── models/
│   │   ├── lapin.dart
│   │   ├── portee.dart
│   │   ├── lapereau.dart
│   │   ├── pesee.dart
│   │   ├── race.dart
│   │   ├── medicament.dart
│   │   ├── evenement_sante.dart
│   │   ├── stock.dart
│   │   ├── finance.dart
│   │   └── alerte.dart
│   └── utils/
│       ├── idempotency_key.dart
│       ├── sync_manager.dart
│       └── connectivity_checker.dart
├── data/
│   ├── repositories/
│   │   ├── lapin_repository.dart
│   │   ├── portee_repository.dart
│   │   ├── sante_repository.dart
│   │   ├── stock_repository.dart
│   │   └── finance_repository.dart
│   ├── local/
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   └── daos/
│   └── remote/
│       ├── supabase_client.dart
│       └── http_interceptors.dart
├── domain/
│   └── services/
│       ├── diagnostic_service.dart
│       ├── reproduction_service.dart
│       ├── alerte_service.dart
│       ├── nutrition_service.dart
│       ├── genetique_service.dart
│       └── finance_service.dart
└── presentation/
    ├── blocs/
    │   ├── auth/
    │   ├── lapin/
    │   ├── portee/
    │   ├── sante/
    │   ├── alerte/
    │   ├── finance/
    │   └── ia/
    ├── screens/
    │   ├── auth/
    │   ├── dashboard/
    │   ├── lapins/
    │   ├── portees/
    │   ├── sante/
    │   ├── alimentation/
    │   ├── finance/
    │   ├── formation/
    │   └── ia/
    └── widgets/
        ├── lapin_card.dart
        ├── growth_chart.dart
        ├── alerte_banner.dart
        ├── ration_card.dart
        ├── portee_timeline.dart
        └── common/
```

---

## 5. Structure Edge Functions Supabase

```
supabase/functions/
├── _shared/
│   ├── ai-router.ts
│   ├── base-repository.ts
│   ├── notification-service.ts
│   ├── auth-middleware.ts
│   ├── rate-limiter.ts
│   └── idempotency.ts
├── diagnose-symptoms/
├── predict-growth/
├── calculate-ration/
├── consanguinity-check/
├── send-weekly-report/
└── check-stock-alerts/
```

---

## 6. Ordre de Priorité de Développement

1. **Setup Supabase** (tables + RLS + Auth)
2. **Projet Flutter** (structure + Drift)
3. **Authentification** (OTP SMS)
4. **Module Lapins** (CRUD + pesées + courbe)
5. **Module Portées** (saillie + gestation + mise bas)
6. **Dashboard** (KPIs + alertes)
7. **Edge Functions IA** (AIRouter + diagnose)
8. **Module Santé** (diagnostic IA)
9. **Module Alimentation** (rations IA)
10. **Module Finance**
11. **Tests + Lancement**

---

## 7. Critères de Succès

- Application fonctionnelle sans connexion (offline-first)
- Temps de démarrage < 3 secondes sur Android 2 Go RAM
- Taille app < 80 Mo
- Tous les principes SOLID respectés
- Couverture tests > 70%
- Audit sécurité OWASP validé
