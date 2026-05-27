# 🐇 lapiNia — Dossier Complet

**Application Mobile Intelligente d'Élevage Cunicole**

---

> **Version** 3.0 · Mai 2026 · Document confidentiel
> **Plateforme** Flutter (iOS & Android)
> **Backend** Supabase Cloud (PostgreSQL + Edge Functions)
> **IA** Claude Sonnet (Anthropic) · Mistral AI · TensorFlow Lite
> **Standards** Principes SOLID · Best Practices API Design · UML

---

## Table des Matières

1. [Présentation du Projet](#1-présentation-du-projet)
2. [Modules Fonctionnels Détaillés](#2-modules-fonctionnels-détaillés)
3. [Fonctionnalités Intelligence Artificielle](#3-fonctionnalités-intelligence-artificielle)
4. [Principes SOLID Appliqués](#4-principes-solid-appliqués)
5. [Best Practices API Design](#5-best-practices-api-design)
6. [Diagrammes UML](#6-diagrammes-uml)
7. [Architecture Technique](#7-architecture-technique)
8. [Sécurité et Performance](#8-sécurité-et-performance)
9. [Stratégie de Tests](#9-stratégie-de-tests)
10. [Modèle Économique](#10-modèle-économique)
11. [Planification de Développement](#11-planification-de-développement)
12. [Critères de Succès et KPIs](#12-critères-de-succès-et-kpis)
13. [Annexes](#13-annexes)

---

## 1. Présentation du Projet

### 1.1 Vision

lapiNia est une application mobile intelligente conçue pour démocratiser l'élevage cunicole professionnel en Afrique de l'Ouest. Pilotée par l'intelligence artificielle, elle accompagne l'éleveur de son premier lapin jusqu'à la constitution d'un élevage rentable et autonome, en remplaçant l'expertise vétérinaire et zootechnique habituellement inaccessible.

### 1.2 Problèmes Résolus

- Absence d'accès à des vétérinaires spécialisés en cuniculture en zones rurales
- Perte économique liée aux maladies détectées trop tardivement
- Consanguinité non contrôlée qui dégrade les performances sur plusieurs générations
- Rations alimentaires approximatives entraînant sous-performance et gaspillage
- Absence de traçabilité pour la vente de lapins reproducteurs certifiés
- Mauvaise gestion des cycles de reproduction réduisant la productivité annuelle

### 1.3 Public Cible

| Profil | Description |
|--------|-------------|
| **Débutants** | Éleveurs 0–20 lapins sans formation, objectif : apprendre et structurer rapidement |
| **Intermédiaires** | Éleveurs 20–200 lapins, objectif : professionnaliser et maximiser la rentabilité |
| **Experts / ONG** | Conseillers agricoles, vétérinaires, groupements d'éleveurs — suivi multi-élevages |

### 1.4 Géographie et Langues

- **Langue principale :** Français
- **Langues V2 :** Wolof, Pulaar, Bambara, Haoussa, Dioula
- **Marchés prioritaires :** Sénégal, Mali, Côte d'Ivoire, Burkina Faso, Guinée, Cameroun
- **Monnaies :** FCFA (XOF/XAF), GNF avec conversion automatique

### 1.5 Contraintes Techniques Clés

- Connexion réseau dégradée ou absente fréquente (zones rurales Afrique de l'Ouest)
- Appareils Android milieu de gamme (2 Go RAM, Android 8+) comme cible principale
- Taille application **< 80 Mo** (contrainte téléchargement 3G)
- Latence IA locale < 300ms, IA cloud < 5s sur connexion 3G
- Isolation totale des données entre éleveurs (RLS PostgreSQL)
- Coût IA maîtrisé : routage Mistral/Claude selon complexité (-70% coût vs Claude seul)

---

## 2. Modules Fonctionnels Détaillés

### 2.1 Tableau de Bord Intelligent

Centre névralgique de l'application. Synthèse en temps réel avec conseils IA proactifs, alertes priorisées et indicateurs de performance.

| Fonctionnalité | Description | Priorité |
|---|---|---|
| Conseil IA personnalisé | Message quotidien généré par l'IA selon l'état exact de l'élevage | Essentielle |
| Alertes priorisées | Système rouge/orange/vert : mise bas imminente, stock critique, animal malade | Essentielle |
| KPIs élevage | Taux fertilité, taux survie lapereaux, GMQ moyen, coût/lapereau, revenu mensuel estimé | Essentielle |
| Timeline 7 jours | Calendrier des événements : mises bas, vaccinations, sevrages, saillies planifiées | Essentielle |
| Météo & ambiance | Température locale pour adapter les conseils — alerte stress thermique si > 30°C | Importante |
| Score de rentabilité | Note globale /100 avec les 3 actions prioritaires du moment | Importante |
| Saisie rapide | Pesée, événement santé, entrée/sortie d'animal en 2 taps | Optionnelle |

### 2.2 Module Reconnaissance et Gestion des Races ✦ NOUVEAU

| Fonctionnalité | Description | Priorité |
|---|---|---|
| Reconnaissance photo IA | Photo d'un lapin → identification de race avec score de confiance (%). 15 races supportées | Essentielle |
| Base de 15 races | NZW, Californien, Rex, Angora, Géant des Flandres, Fauve de Bourgogne, Satin, Bélier... | Essentielle |
| Fiche race complète | Poids adulte, GMQ, taille portées, sensibilités pathologiques, adaptation climatique | Essentielle |
| Profil alimentaire par race | Besoins nutritionnels spécifiques intégrés dans le module alimentation | Essentielle |
| Comparateur de races | Tableau interactif : comparer 2–3 races selon objectif (viande, reproduction, fourrure) | Importante |
| Recommandation de race | L'IA recommande selon le climat local, l'objectif et les ressources disponibles | Importante |

### 2.3 Module Génétique et Croisements ✦ NOUVEAU

| Fonctionnalité | Description | Priorité |
|---|---|---|
| Arbre généalogique | Visualisation graphique sur 3 générations avec performances enregistrées | Essentielle |
| Coefficient de consanguinité | Calcul F selon Wright avant chaque saillie. Alerte rouge si F > 12.5%, orange si F > 6.25% | Essentielle |
| Suggestion de croisement | L'IA classe les mâles par score selon diversité génétique, complémentarité et objectifs | Essentielle |
| Objectifs de sélection | L'éleveur définit ses priorités (taille portées, croissance, rusticité) — IA pondère ses recommandations | Importante |
| Plan amélioration génétique | Plan sur 3 générations pour atteindre un objectif précis | Optionnelle |
| Export pedigree certifié | Document PDF de pedigree pour la vente de reproducteurs | Optionnelle |

### 2.4 Module Fertilité et Reproduction Avancée ✦ ENRICHI

| Fonctionnalité | Description | Priorité |
|---|---|---|
| Score de fertilité individuel | Score /100 par animal basé sur taux d'acceptation, taille portées, survie lapereaux | Essentielle |
| Détection baisse de fertilité | Alerte si 2 refus consécutifs, portée < 3, ou intervalle > 45 jours | Essentielle |
| Optimisation timing de saillie | Calcul de la fenêtre ovulatoire optimale selon comportement et saison | Essentielle |
| Suivi gestation J0–J31 | Timeline visuelle avec jalons automatiques (J7, J14, J25, J28, J31) | Essentielle |
| Gestion repos reproducteur | Calcul du temps de repos optimal après sevrage | Essentielle |
| Prédiction taille de portée | Modèle IA : race, âge, rang de portée, saison, état nutritionnel, historique | Importante |
| Détection gestation nerveuse | Détection de pseudo-gestation et alerte | Importante |
| Suivi mâle reproducteur | Taux de succès, nombre saillies/semaine recommandé (max 5–7), rotation | Importante |
| Calendrier production annuel | Planification des portées sur 12 mois avec objectif de production | Importante |
| Suivi post-partum | Surveillance 48h post-mise bas : mastite, agalaxie, cannibalisme | Importante |

### 2.5 Module Santé, Diagnostic IA et Pharmacologie ✦ ENRICHI

> ⚠️ Module critique pour la réduction de la mortalité

| Fonctionnalité | Description | Priorité |
|---|---|---|
| Diagnostic par symptômes IA | Sélection symptômes → 2–3 diagnostics avec probabilité (%), urgence et conduite à tenir | Essentielle |
| Bibliothèque 25 maladies | Fiches complètes avec photos de référence, maladies locales africaines incluses | Essentielle |
| Pharmacologie vétérinaire | Base 40+ médicaments : dosage automatique selon poids, voie d'administration, durée | Essentielle |
| Contre-indications automatiques | Alerte si médicament contre-indiqué chez femelle gestante/allaitante + alternative | Essentielle |
| Délais d'abattage | Affichage du délai obligatoire après traitement + rappel automatique | Essentielle |
| Interactions médicamenteuses | Alerte si deux traitements simultanés incompatibles | Essentielle |
| Carnet de santé numérique | Historique complet chronologique par animal, exportable en PDF | Essentielle |
| Protocole de vaccination | Calendrier vaccinal personnalisé avec rappels (VHD J70, rappel annuel) | Essentielle |
| Alerte épidémique | Si 3+ animaux mêmes symptômes en 48h → alerte rouge + protocole isolement | Essentielle |
| Journal observation quotidien | Saisie 30s : appétit, comportement, selles, aspect | Importante |
| Analyse photo symptômes | Photo d'une lésion analysée par vision IA (V2) | Optionnelle |
| Téléconsultation vétérinaire | Chat/vidéo avec vétérinaire partenaire — partage dossier automatique (Premium) | Optionnelle |

### 2.6 Module Alimentation et Nutrition ✦ ENRICHI

| Fonctionnalité | Description | Priorité |
|---|---|---|
| Ration IA dynamique | Calcul quotidien selon race, poids, stade (gestation +20%, lactation +40%), saison | Essentielle |
| Base aliments locaux | 50+ aliments africains : foin luzerne, son de mil, fanes carottes, tourteau arachide, moringa | Essentielle |
| Optimisation coût alimentaire | Même niveau nutritionnel au prix le plus bas selon les prix du marché local | Importante |
| Gestion des stocks | Inventaire temps réel, alertes rupture, prédiction consommation 30 jours | Essentielle |
| Qualité de l'eau | Rappels nettoyage (48h), volume quotidien recommandé | Essentielle |
| Plan de transition alimentaire | Plan progressif 7 jours lors du sevrage pour éviter entérites | Essentielle |
| Compléments minéraux | Recommandations supplémentation selon race et stade | Importante |
| Analyse croissance vs alimentation | Corrélation rations / performances GMQ. Détection déficits nutritionnels | Importante |
| Plantes médicinales locales | Fiches moringa, neem, papaye : bénéfices prouvés, risques, dosages | Optionnelle |

### 2.7 Module Suivi de Croissance et Prédictions

| Fonctionnalité | Description | Priorité |
|---|---|---|
| Pesée rapide | Saisie du poids en 2 taps depuis n'importe quel écran | Essentielle |
| Courbe de croissance | Graphique réelle vs cible de la race. Détection automatique des décrochages | Essentielle |
| GMQ (Gain Moyen Quotidien) | Calcul automatique entre chaque pesée. Alerte si GMQ < 80% de la norme 7 jours | Essentielle |
| Prédiction poids à maturité | Estimation à 10/12/14 semaines. Calcul date optimale de vente | Essentielle |
| FCR (Indice de consommation) | Ratio kg aliment / kg poids vif gagné. Benchmarking vs norme de race | Importante |
| Classement lapereaux | Dans une portée, classement par performance. Candidats reproduction identifiés dès sevrage | Importante |
| Alerte retard de croissance | < 10g/j dans les 10 premiers jours → alerte avec causes probables | Essentielle |
| Estimation poids par photo | Photo → estimation visuelle ±15% par vision IA (V2) | Optionnelle |

### 2.8 Module Finance et Rentabilité ✦ ENRICHI

| Fonctionnalité | Description | Priorité |
|---|---|---|
| Journal des ventes | Animal(s), race, poids, acheteur, prix, mode de paiement (cash/Orange Money/Wave) | Essentielle |
| Journal des dépenses | Catégorisation auto : alimentation, médicaments, équipements, main-d'œuvre | Essentielle |
| Coût de production réel | (alimentation + soins + amortissement + charges) / lapereaux sevrés | Essentielle |
| Tableau de bord financier | Revenus, dépenses, bénéfice net par mois/trimestre/année avec graphiques | Essentielle |
| Prix de vente suggéré | L'IA recommande selon race, poids, âge, destination et marché local | Importante |
| Simulation d'investissement | Si j'achète 2 femelles supplémentaires → ROI à 6/12 mois ? | Importante |
| Seuil de rentabilité | Nombre minimum de lapereaux à vendre pour couvrir les charges | Importante |
| Rapport comptable PDF | Export mensuel/annuel pour déclaration fiscale ou demande de crédit agricole | Importante |
| Gestion des créances | Ventes à crédit avec échéances et rappels automatiques (SMS via Twilio) | Optionnelle |

### 2.9 Module Infrastructure, Cages et Ambiance

| Fonctionnalité | Description | Priorité |
|---|---|---|
| Plan visuel de l'élevage | Cartographie interactive des cages avec affectation et statut coloré | Importante |
| Gestion des maternités | Disponibilité, état du nid, température recommandée (28–30°C J1–J7) | Essentielle |
| Protocole de nettoyage | Planning désinfection automatique (toutes les 2 semaines) avec protocole détaillé | Essentielle |
| Contrôle de densité | Alerte si > 4 lapins/m² hors lapereaux | Importante |
| Monitoring ambiance | Saisie manuelle ou capteur Bluetooth (V2) : température, humidité | Importante |
| Séparation par groupe | Organisation : mâles seuls, femelles gestantes, lapereaux sevrés, quarantaine | Essentielle |

### 2.10 Module Traçabilité et Certification ✦ NOUVEAU

| Fonctionnalité | Description | Priorité |
|---|---|---|
| Identifiant unique | Code unique auto-généré (ex : SN-2026-NZW-0042) dès l'enregistrement | Essentielle |
| QR Code individuel | QR code imprimable à fixer sur la cage → accès instantané à la fiche complète | Importante |
| Passeport animal numérique | PDF certifié : identité, race, pedigree, vaccins, performances, origine | Importante |
| Registre d'élevage officiel | Tenue automatique du registre DIREL (Direction de l'Élevage du Sénégal) | Importante |
| Traçabilité de la viande | Lot, date abattage, délais médicamenteux respectés | Optionnelle |
| Certification de race | Attestation race pure ou croisement contrôlé basée sur l'arbre généalogique | Optionnelle |

### 2.11 Assistant IA Conversationnel ✦ ENRICHI

| Fonctionnalité | Description | Priorité |
|---|---|---|
| Chat langage naturel | Questions/réponses en français. L'IA connaît tous les animaux et l'historique | Essentielle |
| Analyse contextuelle | Avant de répondre, l'IA consulte fiches animaux, stocks, météo, historique santé | Essentielle |
| Conseils proactifs | L'IA surveille et envoie des conseils non sollicités quand une situation le justifie | Importante |
| Réponses hors-ligne | Base de 200+ questions fréquentes embarquée. Disponible sans connexion | Importante |
| Mode vocal | Reconnaissance et synthèse vocale en français (V2) | Optionnelle |
| Analyse mensuelle auto | Chaque 1er du mois : rapport complet + 5 actions prioritaires pour le mois suivant | Importante |

### 2.12 Module Formation et Communauté

| Fonctionnalité | Description | Priorité |
|---|---|---|
| Parcours débutant | 12 leçons progressives avec quiz de validation à chaque étape | Essentielle |
| Vidéos pratiques téléchargeables | Courtes vidéos (2–5 min) sur les gestes essentiels | Importante |
| Fiches pratiques imprimables | PDF A4 : fiches races, calendrier vaccinal, protocoles désinfection | Importante |
| Glossaire illustré | 200+ termes en français, wolof et pulaar avec illustrations | Importante |
| Actualités sanitaires | Alertes épizooties en cours dans la région + recommandations préventives | Importante |
| Forum communautaire | Espace d'échange éleveurs modéré par un vétérinaire partenaire (V2) | Optionnelle |
| Marketplace lapins | Petites annonces achat/vente reproducteurs entre éleveurs lapiNia (V2) | Optionnelle |

### 2.13 Module Notifications Intelligentes

| Fonctionnalité | Description | Priorité |
|---|---|---|
| Alertes mise bas | J-3 : checklist. J-1 : alerte haute. Jour J : monitoring toutes les 4h | Essentielle |
| Rappels vaccination | J-7, J-3 et jour J avec protocole complet et produit disponible localement | Essentielle |
| Alertes stock critique | Seuil personnalisable + suggestion quantité à commander + contact fournisseur | Essentielle |
| Rapport hebdomadaire | Chaque lundi : résumé, événements à venir, indicateurs, 3 tâches prioritaires | Importante |
| Rappels de pesée | Notification hebdomadaire pour lapereaux en croissance | Importante |
| Personnalisation | Choix des catégories, heures de réception, mode silencieux nocturne | Importante |

---

## 3. Fonctionnalités Intelligence Artificielle

### 3.1 Stratégie IA Multi-niveaux

```
┌──────────────────────────────────────────────────────────────────────┐
│  NIVEAU 1 — IA Locale (TensorFlow Lite)                              │
│  On-device · Hors-ligne · Latence < 300ms · Zéro coût               │
│  · Reconnaissance de races par photo (MobileNetV3)                   │
│  · 200+ questions/réponses fréquentes embarquées                     │
│  · Prédictions de croissance simples                                 │
├──────────────────────────────────────────────────────────────────────┤
│  NIVEAU 2 — IA Économique (Mistral AI)                               │
│  Via Edge Functions Supabase · ~10x moins cher que Claude            │
│  · Conseils nutritionnels et rations standards                       │
│  · Interprétation de 1–2 symptômes simples                          │
│  · Calculs financiers et prévisions basiques                         │
├──────────────────────────────────────────────────────────────────────┤
│  NIVEAU 3 — IA Premium (Claude Sonnet — Anthropic)                   │
│  Via Edge Functions Supabase · Réservé aux analyses critiques        │
│  · Diagnostic différentiel complexe (3+ symptômes)                  │
│  · Analyse génétique et plan de croisement                           │
│  · Conseils stratégiques d'élevage à long terme                      │
└──────────────────────────────────────────────────────────────────────┘

Routage automatique et transparent → réduction des coûts IA de 60–70%
```

### 3.2 Règles de Routage IA

```
Requête reçue
     │
     ├── Hors-ligne ?  ──────────────────────────► TFLite (on-device)
     │
     ├── 200+ Q&R connues ?  ───────────────────► TFLite (on-device)
     │
     ├── 1–2 symptômes simples / ration / finance ?  ► Mistral AI
     │
     └── 3+ symptômes / génétique / stratégie ?  ───► Claude Sonnet
```

### 3.3 Capacités IA par Domaine

| Domaine | Capacité | Modèle | Priorité |
|---|---|---|---|
| Vision — Reconnaissance races | MobileNetV3 fine-tuné sur 15 races. Précision > 85% | TFLite | Essentielle |
| Vision — Analyse symptômes | Photo lésion → aide au diagnostic (V2) | Claude Vision | Optionnelle |
| Prédictif — Croissance | Courbe prévisionnelle ±8% à 10 semaines | TFLite / Mistral | Essentielle |
| Prédictif — Fertilité | Prédiction taille portée ±1.5 lapereaux | Mistral | Importante |
| Génétique — Consanguinité | Algorithme Wright, calcul temps réel sur 3 générations | Algorithmique | Essentielle |
| NLP — Diagnostic | Classification symptômes → diagnostic différentiel pondéré | Claude Sonnet | Essentielle |
| NLP — Chat contextuel | Claude avec contexte complet de l'élevage injecté | Claude Sonnet | Essentielle |
| Optimisation — Nutrition | Programmation linéaire : ration optimale au coût minimal | Mistral | Importante |
| Apprentissage — Perso. | Fine-tuning implicite selon corrections de l'éleveur | Tous | Optionnelle |

---

## 4. Principes SOLID Appliqués

### Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────────────┐
│               SOLID — Application à lapiNia                             │
│        TypeScript (Edge Functions) · Dart (Flutter)                     │
├────────────────┬────────────────────────────────────────────────────────┤
│  S  Single     │  diagnose-symptoms.ts → diagnostic IA uniquement       │
│  Responsibility│  send-alert.ts        → notifications FCM uniquement   │
│                │  calculate-ration.ts  → calcul nutritionnel uniquement │
│                │  predict-growth.ts    → prédiction croissance          │
├────────────────┼────────────────────────────────────────────────────────┤
│  O  Open/      │  Nouvelle race    → INSERT INTO races (0 code modifié) │
│  Closed        │  Nouveau médicament → INSERT INTO medicaments          │
│                │  Nouvelle langue  → ajouter fichier ARB uniquement     │
├────────────────┼────────────────────────────────────────────────────────┤
│  L  Liskov     │  ClaudeProvider   ──┐                                  │
│  Substitution  │  MistralProvider  ──┼── implements AIProvider          │
│                │  TFLiteProvider   ──┘  (interchangeables)              │
├────────────────┼────────────────────────────────────────────────────────┤
│  I  Interface  │  ILapinSummary    → Dashboard (id, nom, statut)        │
│  Segregation   │  ILapinFull       → Fiche détail (tout + historique)   │
│                │  ISanteWriter     → DiagnosticService (write only)     │
├────────────────┼────────────────────────────────────────────────────────┤
│  D  Dependency │  AIRouter(low: MistralProvider, high: ClaudeProvider)  │
│  Inversion     │  ReproductionService(repo: ILapinRepository)           │
│                │  AlerteService(notif: INotificationService)            │
└────────────────┴────────────────────────────────────────────────────────┘
```

### 4.1 S — Single Responsibility (Responsabilité Unique)

> Chaque Edge Function assume **une seule responsabilité**.

```typescript
// ✅ Correct — Une Edge Function = Une responsabilité
// diagnose-symptoms.ts  → Diagnostic IA uniquement
// send-alert.ts         → Notifications FCM uniquement
// calculate-ration.ts   → Calcul nutritionnel uniquement
// predict-growth.ts     → Prédiction croissance uniquement

// ❌ Incorrect — Responsabilités mélangées
// lapin-service.ts → diagnostic + notifications + ration + prédiction
```

| Composant | Responsabilité unique |
|---|---|
| `diagnose-symptoms.ts` | Recevoir symptômes, appeler Claude/Mistral, retourner diagnostic |
| `send-alert.ts` | Construire message FCM, appeler Firebase, logger résultat |
| `LapinBloc` (Flutter) | Gestion d'état des lapins uniquement |
| `LapinCard` (Flutter) | Affichage d'un lapin uniquement. Aucun appel API direct |

### 4.2 O — Open/Closed (Ouvert/Fermé)

> Ouvert à l'extension, fermé à la modification du code existant.

```sql
-- Ajouter une nouvelle race SANS toucher au code Flutter ou TypeScript
INSERT INTO races (nom, poids_adulte_kg, gmq_cible_g, taille_portee_moy,
                   age_1ere_mise_bas_jours, adaptation_chaleur_score)
VALUES ('Vienne Bleu', 4.2, 38, 7.5, 150, 72);

-- Le module alimentation s'adapte automatiquement via JOIN
-- La courbe de croissance Flutter se met à jour sans re-déploiement
```

Tout ce qui est extensible (races, médicaments, langues, aliments) est dans la **base de données**, pas dans le code.

### 4.3 L — Liskov Substitution (Substitution de Liskov)

> Toute implémentation peut remplacer une autre sans altérer le comportement.

```typescript
// Interface commune — contrat garanti
interface AIProvider {
  complete(prompt: string, maxTokens: number): Promise<string>;
  isAvailable(): Promise<boolean>;
  getEstimatedCost(tokens: number): number;
}

// Les trois implémentations sont substituables — Liskov respecté
class ClaudeProvider  implements AIProvider { ... } // analyses complexes
class MistralProvider implements AIProvider { ... } // requêtes standard
class TFLiteProvider  implements AIProvider { ... } // hors-ligne on-device
```

```dart
// Dart — SupabaseLapinRepo et LocalLapinRepo sont interchangeables
abstract class BaseRepository<T> {
  Future<T?> findById(String id);
  Future<List<T>> findAll();
  Future<T> save(T entity);
  Future<void> delete(String id);
}

class SupabaseLapinRepo extends BaseRepository<Lapin> { ... }
class LocalLapinRepo    extends BaseRepository<Lapin> { ... } // offline
```

### 4.4 I — Interface Segregation (Ségrégation des Interfaces)

> Les clients ne dépendent que des méthodes dont ils ont besoin.

```dart
// Interface minimale pour le Dashboard
abstract class ILapinSummary {
  String get id;
  String get nom;
  StatutLapin get statut;
  bool get hasAlerte;
}

// Interface complète pour la fiche détail
abstract class ILapinFull extends ILapinSummary {
  Race get race;
  List<Pesee> get historiquePoids;
  List<EvenementSante> get sante;
  Genealogie get genealogie;
}

// DiagnosticService n'a besoin que d'écrire
abstract class ISanteWriter {
  Future<void> enregistrerDiagnostic(String lapinId, Diagnostic d);
  Future<void> enregistrerTraitement(String lapinId, Traitement t);
}
```

### 4.5 D — Dependency Inversion (Inversion des Dépendances)

> Les modules de haut niveau dépendent d'abstractions, pas d'implémentations concrètes.

```typescript
// Edge Function — Dependency Inversion complet
class AIRouter {
  constructor(
    private lowComplexity:  AIProvider,  // injecté : MistralProvider
    private highComplexity: AIProvider,  // injecté : ClaudeProvider
  ) {}

  async route(prompt: string, complexity: 'low' | 'high'): Promise<string> {
    const provider = complexity === 'high'
      ? this.highComplexity
      : this.lowComplexity;
    if (!await provider.isAvailable()) {
      return this.lowComplexity.complete(prompt, 500); // fallback
    }
    return provider.complete(prompt, 1000);
  }
}

// Composition root — injection à l'initialisation (jamais dans les services)
const router = new AIRouter(
  new MistralProvider(env.MISTRAL_KEY),
  new ClaudeProvider(env.ANTHROPIC_KEY)
);
```

---

## 5. Best Practices API Design

### Vue d'ensemble des 7 pratiques appliquées à lapiNia

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                  Best Practices API Design — lapiNia                        │
├───────────────────────┬─────────────────────────────────────────────────────┤
│  1. Clear Naming      │  POST /api/v1/lapins                                │
│                       │  GET  /api/v1/lapins/:id/pesees  (cross-resource)   │
│                       │  GET  /api/v1/portees/:id/lapereaux                 │
├───────────────────────┼─────────────────────────────────────────────────────┤
│  2. Idempotency       │  Header: Idempotency-Key: <uuid>                    │
│                       │  Critique en zone 2G — évite les doublons           │
│                       │  GET/PUT/DELETE = idempotents par nature            │
├───────────────────────┼─────────────────────────────────────────────────────┤
│  3. Pagination        │  Cursor-based : lapins, alertes (listes croissantes)│
│                       │  Offset-based : historique pesées (lecture seq.)    │
├───────────────────────┼─────────────────────────────────────────────────────┤
│  4. Sorting &         │  GET /api/v1/lapins?statut=gestation&race=NZW       │
│     Filtering         │       &sort_by=date_saillie&order=asc&limit=20      │
├───────────────────────┼─────────────────────────────────────────────────────┤
│  5. Cross Resource    │  ✅ /api/v1/lapins/42/pesees      (correct)         │
│     References        │  ❌ /api/v1/pesees?lapin_id=42    (moins lisible)   │
├───────────────────────┼─────────────────────────────────────────────────────┤
│  6. Rate Limiting     │  Gratuit : 500 req/h · Éleveur : 2000 · Pro : 5000 │
│                       │  Edge Functions IA limitées séparément par plan     │
├───────────────────────┼─────────────────────────────────────────────────────┤
│  7. Versioning        │  /api/v1/ → stable (maintenu 18 mois après v2)     │
│                       │  /api/v2/ → breaking changes sans rupture           │
├───────────────────────┼─────────────────────────────────────────────────────┤
│  + Security           │  Authorization: Bearer <JWT>                        │
│                       │  RLS PostgreSQL : filtre auto par user_id           │
└───────────────────────┴─────────────────────────────────────────────────────┘
```

### 5.1 Clear Naming — Routes REST v1

| Méthode | Route | Action | Notes |
|---|---|---|---|
| `POST` | `/api/v1/lapins` | Créer un lapin | Idempotency-Key requis |
| `GET` | `/api/v1/lapins` | Lister mes lapins | filter + sort + pagination |
| `GET` | `/api/v1/lapins/:id` | Fiche complète | ILapinFull |
| `PUT` | `/api/v1/lapins/:id` | Modifier | Idempotent par nature |
| `DELETE` | `/api/v1/lapins/:id` | Supprimer | `confirm=true` requis |
| `POST` | `/api/v1/lapins/:id/pesees` | Ajouter pesée | Cross-resource ✅ |
| `GET` | `/api/v1/portees/:id/lapereaux` | Lapereaux d'une portée | Relation parent/enfant |
| `GET` | `/api/v1/stocks?aliment=foin` | Filtrer les stocks | Sorting + Filtering |
| `POST` | `/api/v1/edge/diagnose` | Diagnostic IA | Edge Function |
| `POST` | `/api/v1/edge/predict-growth` | Prédiction croissance | Edge Function |
| `POST` | `/api/v1/edge/calculate-ration` | Calcul ration | Edge Function |

### 5.2 Idempotency

```dart
// Flutter — Idempotency-Key UUID généré localement avant chaque mutation
Future<void> enregistrerPesee(String lapinId, double poidsG) async {
  final key = IdempotencyKey.generate(); // UUID v4 stocké localement
  await _localQueue.add(PeseeRequest(lapinId, poidsG, key));

  final response = await _api.post(
    '/api/v1/lapins/$lapinId/pesees',
    headers: {'Idempotency-Key': key},
    body: {'poids_g': poidsG, 'date': DateTime.now().toIso8601String()},
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    await _localQueue.markDone(key); // ne sera plus rejoué
  }
}
```

### 5.3 Pagination

```
# Cursor-based — Liste des lapins (stable à grande échelle)
GET /api/v1/lapins?limit=20&cursor=uuid_last&sort_by=nom

# Réponse
{
  "data": [...],
  "meta": { "next_cursor": "uuid_xxx", "has_more": true, "total": 42 }
}

# Offset-based — Historique pesées (lecture séquentielle)
GET /api/v1/lapins/:id/pesees?limit=50&offset=0&sort_by=date&order=desc
```

### 5.4 Versioning

```
# v1 — Stable, maintenu 18 mois minimum après sortie de v2
https://project.supabase.co/api/v1/lapins   → poids en grammes

# v2 — Breaking change sans casser les anciennes installations
https://project.supabase.co/api/v2/lapins   → poids_kg + score_fertilite
```

### 5.5 Security — RLS PostgreSQL

```sql
-- Isolation automatique par user_id sur toutes les tables
CREATE POLICY lapins_isolation ON lapins
  FOR ALL USING (user_id = auth.uid());

-- Chaque SELECT/INSERT/UPDATE/DELETE filtre automatiquement
-- Même si un token est compromis → l'attaquant ne voit que ses propres données
```

```
Authorization: Bearer <supabase_jwt_token>   ← dans chaque requête Flutter
```

---

## 6. Diagrammes UML

### 6.1 Diagramme de Classes

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     DIAGRAMME DE CLASSES — lapiNia                          │
│            Principes SOLID appliqués · Flutter + Supabase                   │
└─────────────────────────────────────────────────────────────────────────────┘

╔══════════════════════════╗  ╔══════════════════════════╗
║     <<interface>>        ║  ║     <<interface>>        ║
║    BaseRepository<T>     ║  ║       AIProvider         ║
╠══════════════════════════╣  ╠══════════════════════════╣
║ + findById(id): T        ║  ║ + complete(prompt): str  ║
║ + findAll(): List<T>     ║  ║ + isAvailable(): bool    ║
║ + save(entity): T        ║  ║ + getCost(tokens): num   ║
║ + delete(id): void       ║  ╚══════════════════════════╝
╚══════════════════════════╝           △ implements
         △ implements          ┌────────┼────────────┐
  ┌──────┼──────────┐    ClaudeProvider MistralProvider TFLiteProvider
  │      │          │
  │      │          │
╔══════════╗ ╔══════════════╗ ╔═══════════════╗ ╔═════════════╗
║  Lapin   ║ ║   Portee     ║ ║EvenementSante ║ ║    Stock    ║
╠══════════╣ ╠══════════════╣ ╠═══════════════╣ ╠═════════════╣
║-id: UUID ║ ║-id: UUID     ║ ║-id: UUID      ║ ║-id: UUID    ║
║-nom: str ║ ║-mere: Lapin  ║ ║-lapin: Lapin  ║ ║-aliment:str ║
║-race:Race║ ║-pere: Lapin  ║ ║-type:TypeSante║ ║-quantite:dbl║
║-sexe:Sexe║ ║-dateSaillie  ║ ║-medicament:Md ║ ║-seuil:double║
║-poids:dbl║ ║-nbVivants:int║ ║-dosage:double ║ ║-prix:int    ║
╠══════════╣ ╠══════════════╣ ╠═══════════════╣ ╠═════════════╣
║+calcAge()║ ║+dureeGest()  ║ ║+delaiAbatt()  ║ ║+estCritique ║
║+estDispo ║ ║+estEnRetard()║ ║+estActif()    ║ ║+joursRest() ║
║+getScore ║ ║+getStatut()  ║ ║+toString()    ║ ║+commander() ║
╚══════════╝ ╚══════════════╝ ╚═══════════════╝ ╚═════════════╝
      △               △               △               △
  implements      implements      implements      implements
      │               │               │               │
╔════════════╗ ╔══════════════╗ ╔═══════════════╗ ╔══════════════╗
║LapinRepo   ║ ║PorteeRepo    ║ ║ SanteRepo     ║ ║ StockRepo    ║
║impl Base<L>║ ║impl Base<P>  ║ ║ impl Base<S>  ║ ║ impl Base<St>║
╠════════════╣ ╠══════════════╣ ╠═══════════════╣ ╠══════════════╣
║+findByStatut║ ║+findEnGest() ║ ║+findByLapin() ║ ║+findCritiq() ║
║+findByRace  ║ ║+findByMere() ║ ║+findActifs()  ║ ║+updateQte()  ║
║+findMales() ║ ║+findRecentes ║ ║+findVaccins() ║ ║+historique() ║
╚═════════════╝ ╚══════════════╝ ╚═══════════════╝ ╚══════════════╝
      │ uses              │ uses              │ uses
      ▼                   ▼                   ▼
╔══════════════════╗ ╔═══════════════════════╗ ╔═══════════════════╗
║ DiagnosticService║ ║ ReproductionService   ║ ║   AlerteService   ║
╠══════════════════╣ ╠═══════════════════════╣ ╠═══════════════════╣
║-ai: AIProvider   ║ ║-lapinRepo:ILapinRepo  ║ ║-notif:INotifSvc   ║
║-repo:ISanteRepo  ║ ║-porteeRepo:IPorteeRepo║ ║-stock:IStockRepo  ║
╠══════════════════╣ ╠═══════════════════════╣ ╠═══════════════════╣
║+diagnostiquer()  ║ ║+planifierSaillie()    ║ ║+verifierStocks()  ║
║+proposerTrait()  ║ ║+calcConsanguinite()   ║ ║+alerterMiseBas()  ║
║+alerterEpidemie()║ ║+predirePortee()       ║ ║+envoyerRapport()  ║
╚══════════════════╝ ╚═══════════════════════╝ ╚═══════════════════╝
```

### 6.2 Diagramme de Séquence — Diagnostic IA

```
┌─────────────────────────────────────────────────────────────────────────────┐
│           DIAGRAMME DE SÉQUENCE — Diagnostic IA Symptômes                  │
│    Flutter → Edge Function → Claude API → PostgreSQL → FCM                 │
└─────────────────────────────────────────────────────────────────────────────┘

  Flutter     DiagnosticSvc   AIRouter      Claude API   PostgreSQL    FCM
  (Éleveur)   (Edge Fn)       (SOLID-D)     (Anthropic)  (Supabase)  (Firebase)
     │              │              │              │            │           │
     │──①POST /edge/diagnose──────►│              │            │           │
     │  {symptomes[], lapinId,     │              │            │           │
     │   Idempotency-Key: uuid}    │              │            │           │
     │              │              │              │            │           │
     │              │──evaluerComplexite()────────►│            │           │
     │              │◄── provider = ClaudeProvider─┤            │           │
     │              │    (SOLID-D: injection)       │            │           │
     │              │              │              │            │           │
     │              │──②SELECT * FROM lapins────────────────────►│           │
     │              │              │              │  WHERE id = lapinId    │
     │              │◄── LapinContext{race, age, ──────────────┤           │
     │              │    historique, alimentation}  │            │           │
     │              │              │              │            │           │
     │              │──③POST /v1/messages──────────►│            │           │
     │              │  {system + context            │            │           │
     │              │   + symptomes}                │            │           │
     │              │              │              │            │           │
     │              │◄─────────────────────────────┤            │           │
     │              │  {diagnostic[], probabilités, │            │           │
     │              │   urgence, traitement}         │            │           │
     │              │              │              │            │           │
     │              │──④INSERT INTO sante────────────────────────►│           │
     │              │  {lapinId, diagnostic, traitement}          │           │
     │              │◄────────────────────────────────────────────┤           │
     │              │  {id: uuid, created_at}        │            │           │
     │              │              │              │            │           │
     │              │──⑤CHECK autres animaux mêmes symptômes 48h─►│           │
     │              │◄────────────────────────────────────────────┤           │
     │              │  {epidemie: true, nb: 4} ⚠️    │            │           │
     │              │              │              │            │           │
     │              │──⑥sendPush(userId, "Alerte épidémique: 4 animaux")────►│
     │              │◄──────────────────────────────────────────────────────┤
     │              │  {success: true}               │            │           │
     │              │              │              │            │           │
     │◄──⑦DiagnosticResult{────────┤              │            │           │
     │   diagnostics,              │              │            │           │
     │   urgence: "HAUTE",         │              │            │           │
     │   traitement,               │              │            │           │
     │   alerte_epidemique: true}  │              │            │           │
     │              │              │              │            │           │
```

**Points clés du flux :**
1. Flutter génère un `Idempotency-Key` UUID → envoyé dans le header (API Design)
2. L'AIRouter évalue la complexité et sélectionne le provider (SOLID-D)
3. Le contexte complet de l'animal est récupéré dans PostgreSQL avant l'appel IA
4. Claude API reçoit : symptômes + historique santé + race + alimentation + météo
5. Le diagnostic est persisté dans la table `sante`
6. Détection automatique si d'autres animaux présentent les mêmes symptômes
7. FCM envoie la notification push si alerte épidémique détectée

### 6.3 Diagramme d'Activités — Cycle de Reproduction

```
┌─────────────────────────────────────────────────────────────────────────────┐
│       DIAGRAMME D'ACTIVITÉS — Cycle Complet de Reproduction lapiNia         │
│          Saillie → Gestation → Mise bas → Sevrage → Vente                   │
└─────────────────────────────────────────────────────────────────────────────┘

                              ●  DÉBUT
                              │
                              ▼
                  ┌─────────────────────────┐
                  │  Sélectionner femelle   │
                  │  disponible             │
                  │  (statut = REPOS)       │
                  └───────────┬─────────────┘
                              │
                              ▼
                  ┌─────────────────────────┐
                  │  Vérifier score fertilité│
                  │  + durée repos           │
                  │  (ReproductionService)  │
                  └───────────┬─────────────┘
                              │
                    ┌─────────▼──────────┐
                    │  Score > 60 ET     │
                    │  repos > 14 jours? │
                    └─────────┬──────────┘
              Non ────────────┘ Oui
              │                │
              │  (attendre)    ▼
              │    ┌─────────────────────────┐
              │    │  IA suggère meilleurs   │
              │    │  mâles (score génétique │
              │    │  + consanguinité F)     │
              │    └───────────┬─────────────┘
              │                │
              │      ┌─────────▼──────────┐
              │      │  F (consanguinité) │
              │      │  < 6.25% ?         │
              │      └─────────┬──────────┘
              │  Non ──────────┘ Oui
              │  (autre mâle)   │
              │                 ▼
              │    ┌─────────────────────────┐
              │    │  Enregistrer saillie    │
              │    │  statut = EN_GESTATION  │
              │    └───────────┬─────────────┘
              │                │
              │                ▼
              │    ┌─────────────────────────┐
              │    │  Planifier alertes auto │
              │    │  J7, J14, J25, J28, J31 │
              │    └───────────┬─────────────┘
              │                │
              │   ┌────────────┴─────────────┐
              │   │   ACTIVITÉS PARALLÈLES   │ ← J25–J31
              │   │  J28  ──────────────────────────────────────┐
              │   │  ┌──────────────────┐  ┌──────────────────┐│
              │   │  │ Préparer cage    │  │ Alerte push J-3  ││
              │   │  │ maternité        │  │ + checklist      ││
              │   │  │ (28–30°C J1–J7)  │  │ éleveur          ││
              │   │  └──────────────────┘  └──────────────────┘│
              │   └────────────┬─────────────────────────────────┘
              │                │
              │                ▼
              │    ┌─────────────────────────┐
              │    │  Enregistrer mise bas   │
              │    │  (nb vivants, poids     │
              │    │   portée)               │
              │    └───────────┬─────────────┘
              │                │
              │                ▼
              │    ┌─────────────────────────┐
              │    │  Suivi lactation        │
              │    │  J1 / J7 / J14 / J21   │
              │    │  (pesée + alertes GMQ) │
              │    └───────────┬─────────────┘
              │                │
              │      ┌─────────▼──────────┐
              │      │  GMQ normal ET     │
              │      │  J > 28 ?          │
              │      └─────────┬──────────┘
              │  Non ──────────┘ Oui
              │  (alerte)       │
              │                 ▼
              │    ┌─────────────────────────┐
              │    │  Sevrage + identification│
              │    │  (QR code par lapereau) │
              │    └───────────┬─────────────┘
              │                │
              │      ┌─────────▼──────────┐
              │      │  Conserver comme   │
              │      │  reproducteur ?    │
              │      └─────────┬──────────┘
              │  Oui ──────────┘ Non (vente)
              │  (créer fiche)  │
              │                 ▼
              │    ┌─────────────────────────┐
              │    │  Enregistrer vente      │
              │    │  (Finance + stock MAJ)  │
              │    └───────────┬─────────────┘
              │                │
              └────────────────┘
                              │
                           ◉  FIN
```

### 6.4 Diagramme d'Architecture Système

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ARCHITECTURE SYSTÈME — lapiNia                           │
│          Flutter · Supabase · Claude · Mistral · TFLite · FCM               │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────┐
│         📱 Flutter App (Dart)         │
│                                      │
│  ┌────────────────────────────────┐  │
│  │   UI Layer (Screens)           │  │
│  │   Dashboard · Lapins · Portées │  │
│  │   Santé · IA · Finance         │  │
│  └───────────────┬────────────────┘  │
│                  │                   │
│  ┌───────────────▼────────────────┐  │
│  │   BLoC / State Management      │  │
│  │   LapinBloc · PorteeBloc       │  │
│  │   AlerteBloc · FinanceBloc     │  │
│  └────────┬──────────────┬────────┘  │
│           │              │           │
│  ┌────────▼───┐  ┌───────▼────────┐  │
│  │ Repository │  │  SQLite Local  │  │
│  │ Interface  │  │  (Drift/Moor)  │  │
│  │ (SOLID-I)  │  │  Mode offline  │  │
│  └────────────┘  │  Sync différée │  │
│                  └────────────────┘  │
│  ┌────────────────────────────────┐  │
│  │  Supabase Flutter SDK          │  │
│  │  HTTP Client · FCM Plugin      │  │
│  └───────────────┬────────────────┘  │
└──────────────────┼───────────────────┘
                   │ HTTPS + JWT Bearer
                   ▼
┌──────────────────────────────────────────────────────────────────┐
│                    ☁️  Supabase Cloud (Frankfurt EU)              │
│                                                                   │
│  ┌─────────────────┐   ┌──────────────────────────────────────┐  │
│  │  Auth (OTP SMS)  │   │         PostgreSQL (RLS)             │  │
│  │  JWT · OAuth     │   │  lapins · portees · sante · stocks   │  │
│  │  RLS Policies   │   │  finances · alertes · genealogie     │  │
│  └─────────────────┘   │  Triggers auto-alertes · Indexes     │  │
│                         └──────────────────────────────────────┘  │
│  ┌─────────────────────────────┐  ┌──────────────────────────┐   │
│  │  Edge Functions (Deno/TS)   │  │  Storage (S3-compatible) │   │
│  │  diagnose-symptoms          │  │  Photos lapins           │   │
│  │  predict-growth             │  │  Vidéos formation        │   │
│  │  calculate-ration           │  │  PDF générés             │   │
│  │  send-weekly-report (CRON)  │  │  QR codes                │   │
│  │  check-stock-alerts (CRON)  │  └──────────────────────────┘   │
│  └──────────────┬──────────────┘                                  │
│                 │                                                  │
│  ┌──────────────▼──────────────────────────────────────────────┐  │
│  │             AI Router (SOLID-D — Dependency Inversion)      │  │
│  │  interface AIProvider { complete(prompt) }                  │  │
│  │  ├── ClaudeProvider  → api.anthropic.com  (complexe)       │  │
│  │  ├── MistralProvider → api.mistral.ai     (standard)       │  │
│  │  └── TFLiteProvider  → on-device model    (hors-ligne)     │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  API REST v1  (Clear Naming · Versioning · Rate Limiting     │  │
│  │               · Idempotency · Sorting/Filtering · Security)  │  │
│  └──────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
          │                      │                    │
          ▼                      ▼                    ▼
┌─────────────────┐  ┌───────────────────┐  ┌──────────────────┐
│  Anthropic API  │  │   Mistral AI API  │  │  Firebase (FCM)  │
│  claude-sonnet  │  │  mistral-large    │  │  Push iOS+Android│
│  Diagnostic     │  │  ~10x moins cher  │  │  Alertes temps   │
│  complexe       │  │  Cas standard     │  │  réel            │
└─────────────────┘  └───────────────────┘  └──────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  📲 On-Device IA (Flutter)                                        │
│  TensorFlow Lite : Reconnaissance races (MobileNetV3) < 300ms    │
│  Base 200+ Q&R locales : Fonctionne sans connexion               │
│  SyncManager : Queue mutations · Conflict resolution             │
└──────────────────────────────────────────────────────────────────┘
```

### 6.5 Diagramme de Séquence — Synchronisation Hors-ligne

```
┌─────────────────────────────────────────────────────────────────────────────┐
│           DIAGRAMME DE SÉQUENCE — Synchronisation Offline → Online          │
└─────────────────────────────────────────────────────────────────────────────┘

  Flutter        SyncManager       SQLite Local      Supabase API
  (Éleveur)      (Dart)            (Drift)           (Cloud)
     │                │                 │                 │
     │ (Hors-ligne)   │                 │                 │
     │──Peser lapin──►│                 │                 │
     │                │──WRITE pesee────►│                 │
     │                │  + Idempotency  │                 │
     │                │  Key en attente │                 │
     │◄─OK local──────│                 │                 │
     │                │                 │                 │
     │ (Reconnexion réseau détectée)    │                 │
     │                │                 │                 │
     │                │──READ queue────►│                 │
     │                │◄─[mutation1,   │                 │
     │                │   mutation2]   │                 │
     │                │                 │                 │
     │                │────POST /api/v1/lapins/:id/pesees─►│
     │                │  Header: Idempotency-Key: uuid     │
     │                │◄────────────────────────────────── │
     │                │  200 OK {id, created_at}           │
     │                │                 │                 │
     │                │──MARK DONE──────►│                 │
     │                │──Prochaine mutation────────────────►│
     │                │  ...                               │
     │◄─Sync terminée─│                 │                 │
```

### 6.6 Diagramme d'Activités — Flux API Design (Middleware Stack)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FLUX API — Middleware Stack lapiNia (Supabase)                 │
└─────────────────────────────────────────────────────────────────────────────┘

  Client Flutter          Middleware Stack               PostgreSQL / Edge Fn
       │                        │                               │
       │──POST /api/v1/lapins──►│                               │
       │  Headers:              │                               │
       │  Authorization: Bearer │                               │
       │  Idempotency-Key: uuid │                               │
       │                        │                               │
       │                ┌───────▼────────┐                      │
       │                │ 1. Rate Limiter │                     │
       │                │ 500/h (Gratuit)│                     │
       │                │ 2000/h (Pro)   │                     │
       │                └───────┬────────┘                      │
       │  429 Too Many ◄────────┤ (si dépassé)                 │
       │                        │                               │
       │                ┌───────▼────────┐                      │
       │                │ 2. JWT Auth    │                      │
       │                │ Verify Bearer  │                      │
       │                │ Extract user_id│                      │
       │                └───────┬────────┘                      │
       │  401 Unauthorized◄─────┤ (si invalide)                │
       │                        │                               │
       │                ┌───────▼────────┐                      │
       │                │ 3. Idempotency │                      │
       │                │ Check key cache│                      │
       │                │ Skip duplicate │                      │
       │                └───────┬────────┘                      │
       │  200 (cached) ◄────────┤ (si clé déjà traitée)        │
       │                        │                               │
       │                ┌───────▼────────┐                      │
       │                │ 4. Validator   │                      │
       │                │ Schema check   │                      │
       │                │ Type coercion  │                      │
       │                └───────┬────────┘                      │
       │  400 Bad Request◄──────┤ (si invalide)                │
       │                        │                               │
       │                ┌───────▼────────┐                      │
       │                │ 5. RLS (PG)    │──────────────────────►│
       │                │ Filter user_id │  SELECT/INSERT        │
       │                │ Auto in SQL    │  WHERE user_id=auth() │
       │                └───────┬────────┘◄─────────────────────┤
       │                        │          {data}               │
       │                ┌───────▼────────┐                      │
       │                │ 6. Logger      │                      │
       │                │ Sentry + Logs  │                      │
       │                │ Perf metrics   │                      │
       │                └───────┬────────┘                      │
       │◄─ 201 Created ─────────┤                               │
       │   {id, created_at}     │                               │
```

### 6.7 Diagramme de Déploiement

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                  DIAGRAMME DE DÉPLOIEMENT — lapiNia v3.0                    │
│              GitHub Actions · Supabase · Firebase · Sentry                  │
└─────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────┐         ┌─────────────────────────────────────────┐
  │  📱 Android Device  │         │            ⚙️  GitHub Actions            │
  │  Flutter App        │         │  Push feature → flutter test + analyze  │
  │  SQLite (Drift)     │         │  PR main     → build + deploy staging   │
  │  TFLite model       │         │  Tag vX.Y.Z  → stores (auto-submit)     │
  │  FCM receiver       │         └────────────────────┬────────────────────┘
  └──────────┬──────────┘                              │ deploy
             │ HTTPS + JWT                             ▼
  ┌──────────▼──────────┐    ┌────────────────────────────────────────────┐
  │  🍎 iOS Device      │    │           ☁️  Supabase Cloud (Frankfurt EU) │
  │  Flutter App        │    │                                            │
  │  SQLite (Drift)     ├───►│  ┌──────────────┐  ┌────────────────────┐ │
  │  TFLite model       │    │  │ Auth (OTP SMS)│  │   PostgreSQL 15    │ │
  │  APNs receiver      │    │  │ JWT · RLS    │  │   lapins · portees │ │
  └─────────────────────┘    │  └──────────────┘  │   sante · stocks   │ │
                             │                     │   Triggers · Index │ │
  ┌─────────────────────┐    │  ┌──────────────┐  └────────────────────┘ │
  │  🏪 App Stores      │    │  │   Storage    │  ┌────────────────────┐ │
  │  Google Play Store  │    │  │  Photos · PDF│  │  Edge Functions    │ │
  │  Apple App Store    │    │  │  QR codes    │  │  (TypeScript/Deno) │ │
  │  TestFlight (beta)  │    │  └──────────────┘  │  AIRouter (SOLID-D)│ │
  └─────────────────────┘    │                     │  Diagnose · Ration │ │
                             │  ┌──────────────────┴────────────────────┘ │
                             │  │  API REST v1 (Versioning · Rate Limiting)│ │
                             │  └──────────────────────────────────────────┘ │
                             └──────────────────────────────────────────────┘
                                        │              │             │
                                        ▼              ▼             ▼
                             ┌──────────────┐ ┌──────────────┐ ┌──────────┐
                             │Anthropic API │ │  Mistral AI  │ │ Firebase │
                             │claude-sonnet │ │ mistral-large│ │   FCM    │
                             │Diagnostic    │ │ ~10x moins   │ │ Push iOS │
                             │complexe      │ │ cher         │ │ +Android │
                             └──────────────┘ └──────────────┘ └──────────┘

                             ┌─────────────────────────────────────────────┐
                             │  📊 Monitoring Stack                         │
                             │  Sentry : erreurs & crashes · alertes        │
                             │  Supabase Dashboard : DB perf · slow queries │
                             │  Supabase Logs : Edge Fn · API usage         │
                             │  Mixpanel : comportement utilisateur         │
                             └─────────────────────────────────────────────┘

  Environnements :
  ┌────────────────────────────┐  ┌─────────────────────────────┐  ┌──────────────────────────────┐
  │  Development               │  │  Staging                    │  │  Production                  │
  │  Supabase local (Docker)   │  │  Supabase projet staging    │  │  Supabase Frankfurt EU       │
  │  Mocks IA · hot reload     │  │  Claude sandbox             │  │  Claude Sonnet production    │
  │                            │  │  TestFlight + Firebase dist │  │  App Store + Google Play     │
  └────────────────────────────┘  └─────────────────────────────┘  └──────────────────────────────┘
```

---

## 7. Architecture Technique

### 7.1 Stack Technologique Complète

| Composant | Technologie | Justification |
|---|---|---|
| Application mobile | Flutter 3.x (Dart) | Cross-platform iOS/Android, performances natives |
| Base de données locale | SQLite via Drift | Mode hors-ligne complet, sync différée automatique |
| Backend principal | Supabase Cloud | PostgreSQL + Auth + Storage + Realtime + Edge Functions |
| Base de données cloud | PostgreSQL (Supabase) | Relationnel, RLS, triggers automatiques alertes |
| Logique IA et métier | Edge Functions (Deno/TS) | Appels sécurisés aux APIs IA, calculs, notifications |
| IA conversationnelle | Claude Sonnet (Anthropic) | Analyses complexes, diagnostic, conseil stratégique |
| IA économique | Mistral AI | Requêtes standard, ~10x moins cher que Claude |
| IA locale | TensorFlow Lite | Reconnaissance races, prédictions hors-ligne |
| Notifications push | Firebase Cloud Messaging | iOS + Android, gratuit, intégré à Supabase |
| Authentification | Supabase Auth | OTP SMS (prioritaire Afrique), JWT sécurisé |
| Stockage fichiers | Supabase Storage | Photos, vidéos formation, PDF générés |
| Paiement | Orange Money, Wave, Stripe | Modes de paiement locaux prioritaires |
| Monitoring | Sentry + Supabase Logs | Erreurs, performance Edge Functions, usage IA |
| CI/CD | GitHub Actions | Tests auto, build, déploiement stores |

### 7.2 Structure du Projet Flutter (Clean Architecture + BLoC)

```
lib/
  core/
    interfaces/         # AIProvider, BaseRepository, NotificationService (SOLID-I)
    models/             # Lapin, Portee, Stock, EvenementSante (entités pures)
    utils/              # IdempotencyKey, ApiVersionDetector, SyncManager
  data/
    repositories/       # LapinRepository, PorteeRepository (impl BaseRepository)
    local/              # SQLite schemas via Drift (offline-first)
    remote/             # Supabase client calls, HTTP interceptors
  domain/               # Services métier purs (sans dépendance Flutter)
  presentation/
    blocs/              # LapinBloc, PorteeBloc, AlerteBloc (SOLID-S)
    screens/            # Dashboard, Lapins, Portees, Sante, Finance
    widgets/            # LapinCard, GrowthChart, AlerteBanner (atomiques)
```

### 7.3 Structure Edge Functions Supabase

```
supabase/functions/
  _shared/
    ai-router.ts            # AIRouter (SOLID-D) — ClaudeProvider | MistralProvider
    base-repository.ts      # BaseRepository<T> générique (SOLID-O)
    notification-service.ts # NotificationService (SOLID-I) — FCM
    auth-middleware.ts      # JWT validation + user_id extraction
    rate-limiter.ts         # Sliding window rate limiting par plan
    idempotency.ts          # Idempotency-Key check + cache
  diagnose-symptoms/        # POST /edge/diagnose (SOLID-S)
  predict-growth/           # POST /edge/predict-growth
  calculate-ration/         # POST /edge/calculate-ration
  send-weekly-report/       # CRON lundi 7h — rapport hebdomadaire
  check-stock-alerts/       # CRON quotidien 8h — alertes stocks
```

### 7.4 Schéma de Base de Données PostgreSQL

```
                        SCHÉMA POSTGRESQL — lapiNia
                        (RLS activé sur toutes les tables)

users ◄──────────────────────────────────────── (auth.uid())
  │
  ├──► lapins
  │      id · user_id · nom · race_id · sexe · poids_g
  │      statut · photo_url · numero_identification · notes
  │         │
  │         ├──► pesees
  │         │      id · lapin_id · date · poids_g · gmq
  │         │
  │         ├──► sante
  │         │      id · lapin_id · type · medicament_id
  │         │      dosage_ml · duree_jours · delai_abattage_jours
  │         │
  │         └──► genealogie
  │                id · lapin_id · parent_id · role · generation
  │
  ├──► races
  │      id · nom · poids_adulte_kg · gmq_cible_g
  │      taille_portee_moy · adaptation_chaleur
  │      profil_nutritionnel_json
  │
  ├──► portees
  │      id · user_id · mere_id · pere_id
  │      date_saillie · date_mise_bas_prevue · date_reelle
  │      nb_vivants · nb_morts · poids_total_g · statut
  │         │
  │         └──► lapereaux
  │                id · portee_id · sexe · poids_naissance_g
  │                date_sevrage · statut · lapin_id (si conservé)
  │
  ├──► medicaments
  │      id · nom · classe · posologie_kg_poids
  │      voie_administration · contre_indications_json
  │      delai_abattage_jours
  │
  ├──► stocks
  │      id · user_id · aliment · quantite_kg
  │      seuil_alerte_kg · prix_kg_fcfa · fournisseur_id
  │
  ├──► finances
  │      id · user_id · date · type (recette/depense)
  │      categorie · montant_fcfa · lapin_id · mode_paiement
  │
  └──► alertes
         id · user_id · lapin_id · type · message
         priorite (1-3) · date_echeance · lue · action_effectuee
```

### 7.5 Synchronisation Hors-ligne (Offline First)

```dart
// SyncManager — Last-Write-Wins sur timestamp
class SyncManager {
  final _queue = PersistentQueue<PendingMutation>();

  Future<void> syncWhenOnline() async {
    await for (final _ in Connectivity().onConnectivityChanged) {
      while (_queue.isNotEmpty) {
        final mutation = _queue.peek();
        final result = await _api.execute(mutation,
          headers: {'Idempotency-Key': mutation.key}); // API Design

        if (result.success) {
          _queue.dequeue();
        } else if (result.isConflict) {
          _resolveConflict(mutation, result);
        }
      }
    }
  }

  void _resolveConflict(mutation, result) {
    // Last-Write-Wins basé sur timestamp
    if (mutation.timestamp > result.serverTimestamp) {
      _queue.forceRetry(mutation); // local plus récent → override
    } else {
      _queue.discard(mutation);    // serveur plus récent → garder serveur
    }
  }
}
```

---

## 8. Sécurité et Performance

### 8.1 Modèle de Sécurité

| Couche | Mécanisme | Détail |
|---|---|---|
| Transport | TLS 1.3 | Obligatoire sur toutes les communications réseau |
| Authentification | JWT Supabase (HS256) | Expiration 1h, refresh token 7 jours |
| Autorisation | RLS PostgreSQL | Filtre automatique par `auth.uid()` sur chaque requête SQL |
| Clés API IA | Variables d'env Supabase | Jamais dans Flutter ni dans le dépôt Git |
| Données au repos | AES-256 | PostgreSQL Supabase + SQLite local |
| Injection SQL | ORM Supabase | Requêtes paramétrées systématiques — impossible |

### 8.2 Indicateurs de Performance Cibles

| Métrique | Cible | Condition |
|---|---|---|
| Démarrage application | < 3 secondes | Android 2 Go RAM, cold start |
| Requête API REST simple | < 800ms | 3G, 50ms latence réseau |
| IA locale (TFLite) | < 300ms | Hors-ligne, on-device |
| IA cloud (Mistral) | < 3 secondes | Requête simple, 3G |
| IA cloud (Claude Sonnet) | < 6 secondes | Diagnostic complexe, 3G |
| Sync hors-ligne → cloud | < 5 secondes | 50 mutations en attente, 3G |
| Chargement liste lapins (20) | < 500ms | SQLite local, premier affichage |
| Disponibilité service cloud | > 99.5% | SLA Supabase Pro |

---

## 9. Stratégie de Tests

### 9.1 Pyramide de Tests

```
                        ┌──────────┐
                        │ E2E (10%)│  Flutter integration tests
                        │          │  Parcours onboarding complet
                        └────┬─────┘  Cycle reproduction · Sync offline
                             │
                    ┌────────▼─────────┐
                    │ Intégration (20%)│  Edge Functions + Supabase local
                    │                  │  Routes API · RLS policies
                    └────────┬─────────┘  Vérification rate limiting
                             │
           ┌─────────────────▼─────────────────────┐
           │          Unitaires (70%)               │
           │  Logique métier pure (SOLID-D : mocks) │
           │  Calcul consanguinité · GMQ · rations  │
           │  Prédictions · Règles de routage IA    │
           └───────────────────────────────────────-┘
```

### 9.2 Exemple de Test Unitaire (SOLID-D)

```dart
// Dart — Test DiagnosticService avec mock AIProvider (SOLID-D)
void main() {
  test('diagnostic retourne alerte épidémique si 3+ animaux touchés', () async {
    // Arrange — injection de mocks (Dependency Inversion)
    final mockAI   = MockAIProvider();
    final mockRepo = MockSanteRepository();
    final service  = DiagnosticService(ai: mockAI, repo: mockRepo);

    when(mockAI.complete(any, any)).thenAnswer((_) async =>
      '{"diagnostic": "pasteurellose", "urgence": "haute"}');
    when(mockRepo.countSimilarSymptomes(any, any)).thenAnswer((_) async => 4);

    // Act
    final result = await service.diagnostiquer(
      ['ecoulement_nasal', 'dyspnee'], 'lapin-id-42');

    // Assert
    expect(result.alerteEpidemique, isTrue);
    expect(result.animauxTouches, equals(4));
    verify(mockRepo.countSimilarSymptomes(any, any)).called(1);
  });
}
```

---

## 10. Modèle Économique

### 10.1 Plans Tarifaires (Freemium)

| Plan | Prix | Fonctionnalités incluses |
|---|---|---|
| **Gratuit** | 0 FCFA | Jusqu'à 10 lapins, tableau de bord, gestion basique, 15 questions IA/mois |
| **Éleveur** | 2 500 FCFA/mois | Lapins illimités, IA complète, prédictions, finance, QR codes, export PDF, alertes SMS |
| **Pro** | 6 500 FCFA/mois | Tout Éleveur + multi-élevages (5), téléconsultation vétérinaire 2h/mois, API accès |
| **ONG / Coopérative** | Prix négocié | Groupements > 20 membres, tableau de bord agrégé, rapport de filière |

### 10.2 Revenus Complémentaires

- Commission 3% sur ventes entre éleveurs via la Marketplace intégrée
- Partenariats fournisseurs d'aliments et médicaments vétérinaires
- Données agrégées anonymisées pour instituts de recherche agricole (avec consentement)
- Formation certifiante en ligne (module payant avancé)
- Téléconsultation à l'acte pour utilisateurs gratuits (1 500 FCFA/session)

---

## 11. Planification de Développement

### 11.1 Phases

| Phase | Durée | Livrables | SOLID |
|---|---|---|---|
| **Phase 0 — Setup** | 2 semaines | Supabase projet, schéma DB, CI/CD, conventions SOLID, skeleton Flutter BLoC | Tous |
| **Phase 1 — Core** | 6 semaines | Auth OTP, CRUD lapins/portées, SQLite + sync, API REST v1 | S · D |
| **Phase 2 — IA Base** | 4 semaines | Edge Functions SOLID, AIRouter, Mistral (rations, conseils), TFLite races | D · L |
| **Phase 3 — IA Avancée** | 4 semaines | Claude API diagnostic, algorithme Wright, prédictions ML, alertes épidémiques | D · S |
| **Phase 4 — Finance & QR** | 3 semaines | Module finance complet, QR codes, passeport animal PDF, idempotency | O · I |
| **Phase 5 — Polish** | 3 semaines | Performance, tests charge k6, sécurité, onboarding UX, soumission stores | Tous |
| **Phase 6 — V1.5** | 3 mois post-launch | Wolof/Pulaar, mode vocal, forum, téléconsultation, marketplace | O |
| **Phase 7 — V2.0** | 6 mois post-launch | Capteurs IoT, poids par photo, API publique partenaires, version web | O |

### 11.2 Équipe Recommandée

| Profil | Rôle |
|---|---|
| Chef de projet / Product Owner | Cuniculture + tech, SOLID owner |
| 2× Développeurs Flutter senior | iOS & Android, BLoC, SQLite, offline sync |
| Développeur Backend Supabase | TypeScript/Deno, Edge Functions, PostgreSQL |
| Ingénieur IA / ML | TFLite fine-tuning, modèles prédictifs, routing |
| Designer UX/UI | Spécialiste apps mobiles Afrique, accessibilité |
| Expert vétérinaire / Zootechnicien | Validation contenu médical et protocoles |
| Chargé de terrain / Community Manager | Tests utilisateurs Sénégal + Mali |

### 11.3 Budget Estimatif (Phase 0–5, 8 mois)

| Poste | Estimation |
|---|---|
| Développement (équipe locale Sénégal) | 15–25 millions FCFA |
| Infrastructure cloud | Supabase Pro (~25$/mois) + Claude API + Mistral + FCM : ~150 000 FCFA/mois |
| Contenu & validation vétérinaire | 3–5 millions FCFA |
| Marketing & tests terrain | 2–4 millions FCFA |

---

## 12. Critères de Succès et KPIs

### 12.1 KPIs Produit

| Métrique | Cible |
|---|---|
| Rétention J30 | > 45% |
| Rétention J90 | > 25% |
| NPS (Net Promoter Score) | > 55 |
| Taux conversion Gratuit → Payant | > 8% dans les 3 premiers mois |
| Sessions/semaine/utilisateur actif | > 5 |
| Précision diagnostic IA | > 80% de concordance avec diagnostic vétérinaire réel |
| Précision prédiction croissance | Écart ±8% max sur poids réel à 10 semaines |

### 12.2 KPIs d'Impact Terrain

| Indicateur | Objectif à 12 mois |
|---|---|
| Réduction mortalité lapereaux | -25% chez les utilisateurs actifs |
| Amélioration taux de fertilité | +15% grâce à l'optimisation du timing |
| Réduction gaspillage alimentaire | -20% grâce aux rations optimisées |
| Augmentation revenu net moyen | +30% en 12 mois d'utilisation active |
| Consanguinité contrôlée | 0 croisement avec F > 12.5% chez les utilisateurs du module génétique |

### 12.3 Jalons Business

| Jalon | Objectif |
|---|---|
| M3 | 500 utilisateurs bêta actifs au Sénégal |
| M6 | 5 000 utilisateurs, 400 abonnements payants, 1 partenariat vétérinaire |
| M12 | 25 000 utilisateurs dans 5 pays, seuil de rentabilité atteint |
| M24 | 100 000 utilisateurs, 8 pays, marketplace avec 500+ annonces/mois |

---

## 13. Annexes

### 13.1 Base Pathologique — 25 Maladies Documentées

| # | Maladie | Cause | Urgence |
|---|---|---|---|
| 1 | Myxomatose | Myxoma virus | 🔴 Haute — vaccin obligatoire |
| 2 | VHD type 1 & 2 | RHDV1/RHDV2 | 🔴 Haute — vaccin obligatoire |
| 3 | Pasteurellose | Pasteurella multocida | 🔴 Haute — rhinite, septicémie |
| 4 | Coccidiose intestinale | Eimeria spp. | 🔴 Haute — principale mortalité J4–J12 |
| 5 | Coccidiose hépatique | E. stiedae | 🔴 Haute — jaunisse, ascite |
| 6 | Staphylococcie | S. aureus | 🟡 Moyenne — mammite, abcès |
| 7 | Colibacillose | E. coli | 🔴 Haute — diarrhée néonatale J3–J10 |
| 8 | Entérotoxémie | Clostridium spp. | 🔴 Critique — mort soudaine |
| 9 | Gale sarcoptique | Sarcoptes scabiei | 🟡 Moyenne — prurit intense |
| 10 | Gale otodectique | Psoroptes cuniculi | 🟡 Moyenne — otite |
| 11 | Trichophytie (teigne) | Trichophyton mentagrophytes | 🟡 Moyenne — zoonose |
| 12 | Listériose | Listeria monocytogenes | 🔴 Haute — avortements, torticolis |
| 13 | Encéphalitozoonose | Encephalitozoon cuniculi | 🟡 Moyenne — torticolis, paralysie |
| 14 | Tyzzer's disease | Clostridium piliforme | 🔴 Critique — nécrose hépatique |
| 15 | Spirochétose | Treponema cuniculi | 🟡 Moyenne — lésions génitales |
| 16 | Pseudo-tuberculose | Yersinia pseudotuberculosis | 🔴 Haute |
| 17 | Toxoplasmose | Toxoplasma gondii | 🔴 Haute — avortements |
| 18 | Malocclusion dentaire | Héréditaire | 🟠 Chronique — amaigrissement |
| 19 | Météorisme caecal | Déséquilibre flore | 🔴 Critique — mort subite |
| 20 | Trichobezoards | Boules de poils | 🟡 Moyenne — anorexie |
| 21 | Coup de chaleur | T° > 32°C | 🔴 Critique — mort rapide |
| 22 | Fracture vertébrale | Traumatisme | 🔴 Critique — paralysie |
| 23 | Néphrite chronique | Multifactorielle | 🟠 Chronique — amaigrissement |
| 24 | Urolithiase | Calculs urinaires | 🟡 Moyenne — hématurie |
| 25 | Mammite | Staphylocoque / traumatisme | 🔴 Haute — agalaxie |

### 13.2 Base Pharmacologique — 40 Médicaments Référencés

**Antibiotiques**
- Enrofloxacine, Marbofloxacine, Trimétoprime-Sulfaméthoxazole
- Oxytétracycline, Tylosine, Pénicilline G (injectable uniquement)

**Antiparasitaires**
- Ivermectine, Fenbendazole, Toltrazuril, Diclazuril, Sulfadimidine

**Anti-inflammatoires**
- Méloxicam, Kétoprofène (sous contrôle vétérinaire uniquement)

**Vitamines et Compléments**
- Vitamine C, Vitamine D3, Calcium gluconate, Complexe B, Électrolytes de réhydratation

**Vaccins**
- VHD monovalent, VHD bivalent (V1+V2), Myxomatose, Pasteurellose

**Désinfectants**
- Glutaraldéhyde, Ammoniums quaternaires, Hypochlorite de sodium, Crésyl, Chaux vive

**Compléments Digestifs**
- Probiotiques lapins, Levures, Kaolin-pectine (anti-diarrhéique)

### 13.3 Races Documentées dans l'Application

| Race | Poids adulte | GMQ cible | Taille portée | Chaleur |
|---|---|---|---|---|
| Nouvelle-Zélande Blanc (NZW) | 4.0–5.0 kg | 40–45 g/j | 8–10 | ✅ Bonne |
| Californien | 3.5–4.5 kg | 38–42 g/j | 7–9 | ✅ Bonne |
| Rex | 3.0–4.5 kg | 30–35 g/j | 6–8 | 🟡 Moyenne |
| Angora | 2.5–4.0 kg | 25–30 g/j | 5–7 | ❌ Faible |
| Géant des Flandres | 6.0–10 kg | 45–55 g/j | 8–12 | ❌ Faible |
| Fauve de Bourgogne | 3.5–4.5 kg | 35–40 g/j | 7–9 | ✅✅ Excellente |
| Lapin de case local | 1.5–2.5 kg | 20–28 g/j | 6–8 | ✅✅ Excellente |
| Vienne Bleu | 3.5–4.5 kg | 32–38 g/j | 6–8 | ✅ Bonne |
| Satin | 3.5–4.5 kg | 33–38 g/j | 6–8 | ✅ Bonne |
| Bélier | 3.0–5.0 kg | 28–33 g/j | 5–7 | 🟡 Moyenne |

### 13.4 Aliments Locaux Référencés

| Aliment | Protéines | Fibres | Énergie | Disponibilité |
|---|---|---|---|---|
| Foin de luzerne | 17–20% | 28–32% | 2 200 kcal/kg | ✅ Bonne |
| Son de mil | 14–16% | 8–10% | 2 800 kcal/kg | ✅✅ Excellente |
| Fanes de carottes | 14–18% | 22–28% | 1 800 kcal/kg | 🟡 Saisonnière |
| Tourteau d'arachide | 42–48% | 6–8% | 3 200 kcal/kg | ✅ Bonne |
| Feuilles de moringa | 25–30% | 12–16% | 2 100 kcal/kg | ✅✅ Excellente |
| Herbe de Guinée | 8–12% | 30–35% | 1 600 kcal/kg | ✅✅ Excellente |
| Graines de niébé | 22–26% | 6–8% | 3 400 kcal/kg | ✅ Bonne |
| Oseille de Guinée | 12–16% | 18–22% | 1 900 kcal/kg | 🟡 Saisonnière |

### 13.5 Références Normatives

- **FAO** : Directives pour la production cunicole dans les pays en développement (2021)
- **OIE / WOAH** : Standards sanitaires internationaux — Code terrestre chapitre lapins
- **ITURC** : Normes de croissance, reproduction et alimentation cunicole
- **DIREL Sénégal** : Réglementation sanitaire et registre d'élevage national
- **OHADA** : Cadre comptable pour l'activité agricole

### 13.6 Glossaire Technique

| Terme | Définition |
|---|---|
| **Cuniculture** | Science et pratique de l'élevage des lapins domestiques |
| **Saillie** | Accouplement contrôlé entre mâle (lapin) et femelle (lapine) |
| **Gestation** | Durée de la grossesse : 28–32 jours (moyenne 31 jours) |
| **Sevrage** | Séparation des lapereaux de leur mère, J28–J35 |
| **GMQ** | Gain Moyen Quotidien : prise de poids par jour (indicateur de performance) |
| **FCR** | Feed Conversion Ratio : kg aliment consommé / kg poids vif gagné |
| **Coefficient F** | Coefficient de consanguinité selon l'algorithme de Wright |
| **RLS** | Row Level Security : isolation automatique des données par utilisateur (PostgreSQL) |
| **Edge Function** | Fonction serverless exécutée côté serveur Supabase (TypeScript/Deno) |
| **BLoC** | Business Logic Component : pattern de gestion d'état Flutter |
| **TFLite** | TensorFlow Lite : modèle IA léger exécuté directement sur l'appareil mobile |
| **OTP SMS** | One-Time Password par SMS : authentification sans email |
| **SOLID** | Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion |

---

*lapiNia — Dossier Complet v3.0 — Mai 2026*
*Flutter · Supabase · Claude AI · Principes SOLID · Best Practices API Design*
*Document confidentiel — Tous droits réservés*
