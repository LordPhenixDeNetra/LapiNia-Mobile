# Fertilité & Génétique (P1) Spec

## Why
Les fonctionnalités P1 “Fertilité & Génétique” existent dans la roadmap mais ne sont pas implémentées, ce qui empêche de piloter la reproduction (fertilité) et de limiter la consanguinité (génétique).

## What Changes
- Ajout d’un score de fertilité (/100) calculé localement et persisté dans `lapins.score_fertilite`, affiché sur la fiche lapin.
- Ajout d’une alerte “baisse fertilité” si le score chute de > 20 points en 3 mois, avec recommandations via Edge Function LLM (fallback texte si clés absentes).
- Ajout de la visualisation de l’arbre généalogique (3 générations) basé sur `public.genealogie`, avec nœuds cliquables.
- Ajout d’une suggestion de mâles pour une saillie (Edge Function `suggest-males`) avec un mode “Mix simple”.

## Impact
- Affected specs: Portées & Reproduction, Lapins (fiche), Alertes (dashboard)
- Affected code: Flutter UI (Lapin detail + Saillie form + nouvel écran), Riverpod providers/services, Drift cache, Supabase migrations + Edge Functions

## ADDED Requirements

### Requirement: Score fertilité lapin
Le système SHALL fournir un score de fertilité `/100` pour chaque lapin reproducteur.

#### Détails de calcul (P1)
- Le score total = somme de 4 sous-scores (0..25) :
  - Acceptation (0..25)
  - Taille de portées (0..25)
  - Survie des lapereaux (0..25)
  - Régularité (0..25)
- Fenêtres temporelles :
  - Calcul basé sur les données des 6 derniers mois (ou moins si données insuffisantes).
  - Historisation locale mensuelle (1 point/mois minimum) pour comparaison “il y a 3 mois”.
- Compatibilité sexe :
  - Femelle : basé sur portées où `mere_id = lapin.id`
  - Mâle : basé sur portées où `pere_id = lapin.id`

#### Scenario: Affichage fiche lapin
- **WHEN** l’utilisateur ouvre la fiche d’un lapin
- **THEN** l’onglet “Repro” affiche un badge `Score fertilité: XX/100` + un bouton “Détails du score”
- **AND** le score est recalculé localement si des événements de reproduction/lapereaux ont changé
- **AND** `lapins.score_fertilite` est mis à jour via la sync offline-first

### Requirement: Alerte baisse fertilité + recommandations IA
Le système SHALL créer une alerte de fertilité si le score baisse de plus de 20 points en 3 mois.

#### Scenario: Déclenchement
- **GIVEN** un lapin avec un score historisé il y a ~3 mois
- **WHEN** un nouveau score est calculé et `score_now <= score_3_months_ago - 21`
- **THEN** une alerte est créée (table `alertes`) attachée au lapin
- **AND** le détail de l’alerte inclut un texte de recommandations

#### Scenario: Recommandations IA
- **WHEN** l’app demande des recommandations pour un cas “baisse fertilité”
- **THEN** elle appelle une Edge Function (ex: `fertility-advice`) qui génère 3–6 recommandations concrètes
- **AND** si aucun provider IA n’est configuré, la function renvoie un fallback (templates) sans erreur

### Requirement: Arbre généalogique (3 générations)
Le système SHALL afficher un arbre généalogique à 3 générations basé sur `public.genealogie`.

#### Scenario: Consultation
- **WHEN** l’utilisateur ouvre la fiche lapin → onglet “Repro” → “Arbre généalogique”
- **THEN** l’app affiche un arbre avec le lapin au centre et ses ascendants jusqu’à 3 générations
- **AND** chaque nœud est cliquable et ouvre la fiche du lapin correspondant
- **AND** si une branche est manquante, l’UI affiche “Inconnu”

### Requirement: Suggestion mâles pour saillie (Mix simple)
Le système SHALL proposer une liste triée de mâles candidats pour une femelle.

#### UI (P1)
- L’écran “Nouvelle saillie” affiche une action “Suggérer des mâles”.
- Mode “Mix simple” = 3 objectifs :
  - Anti-consanguinité
  - Croissance
  - Équilibré

#### Scenario: Suggestion
- **WHEN** l’utilisateur clique “Suggérer des mâles”
- **THEN** l’app appelle `POST /functions/v1/suggest-males`
- **AND** l’écran affiche un classement avec un score et une explication courte (ex: “Consanguinité faible”, “Race plus adaptée croissance”)
- **AND** l’utilisateur peut sélectionner un mâle et remplir le champ “Mâle”

## MODIFIED Requirements

### Requirement: Alertes (types)
Le système SHALL supporter un type d’alerte supplémentaire `FERTILITE`.

## REMOVED Requirements
N/A

