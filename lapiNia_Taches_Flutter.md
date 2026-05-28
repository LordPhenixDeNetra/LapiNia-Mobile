# lapiNia — Tâches Flutter (implémentation Supabase + Edge Functions)
 
## Légende des statuts
 
- **À faire** : pas démarré
- **En cours** : développement actif
- **Bloqué** : dépendance / décision manquante
- **Fait** : terminé
## Liste à cocher
 
- Cocher = **Fait**
---
 
### À faire
 
---
 
**Base app & architecture**
---
 
**Auth & sécurité**
- [ ] **(Flutter · P1)** Inscription OTP SMS (`supabase.auth.signInWithOtp(phone)`) — saisie numéro + sélecteur préfixe pays (+221, +223, +225…)
- [ ] **(Flutter · P1)** Vérification OTP (`supabase.auth.verifyOTP(phone, token)`) — écran 6 chiffres + compte à rebours 60s + renvoyer code
- [ ] **(Flutter · P1)** Reconnexion automatique — restore session JWT depuis `flutter_secure_storage` au démarrage
- [ ] **(Flutter · P1)** Refresh token — automatique via interceptor Supabase + retry requête échouée
- [ ] **(Flutter · P1)** Déconnexion (`supabase.auth.signOut()`) — clear storage + reset BLoCs + redirect login
- [ ] **(Flutter · P2)** Avatar upload (`POST /storage/v1/object/avatars/{user_id}`) — caméra/galerie + compression < 200 Ko + upload multipart
- [ ] **(Flutter · P2)** Suppression compte (`DELETE /rest/v1/users?id=eq.{id}`) — double confirmation + logout + clear SQLite local
---
 
**Onboarding**
- [ ] **(Flutter · P1)** Onboarding étape 1 — nombre de lapins (< 10 / 10–50 / 50–200 / > 200)
- [ ] **(Flutter · P1)** Onboarding étape 3 — région (sélecteur pays + ville)
- [ ] **(Flutter · P1)** Onboarding étape 4 — races possédées (multiselect sur `GET /rest/v1/races`)
- [ ] **(Flutter · P1)** Onboarding étape 5 — niveau d'expérience (débutant / intermédiaire / expert)
- [ ] **(Flutter · P1)** Conseil IA post-onboarding (`POST /functions/v1/daily-advice`) — premier conseil personnalisé basé sur le profil
- [ ] **(Flutter · P2)** Plan guard — UI conditionnelle selon `plan` (gratuit / éleveur / pro) sur chaque fonctionnalité premium
---
 
**Dashboard**
- [ ] **(Flutter · P1)** Dashboard global (`GET /rest/v1/lapins?user_id=eq.{id}` agrégé) — KPIs : nb lapins, gestantes, lapereaux attendus, prochaine naissance
- [ ] **(Flutter · P1)** Conseil IA du jour (`POST /functions/v1/daily-advice`) — carte avec cache 24h local (SQLite)
- [ ] **(Flutter · P1)** Alertes prioritaires (`GET /rest/v1/alertes?user_id=eq.{id}&lue=eq.false&order=priorite.asc`) — badges rouge/orange/vert
- [ ] **(Flutter · P1)** Marquer alerte comme lue (`PATCH /rest/v1/alertes?id=eq.{id}`) — `{ lue: true }`
- [ ] **(Flutter · P1)** Timeline 7 jours — calcul local depuis portées + vaccinations + pesées programmées
- [ ] **(Flutter · P1)** Widget saisie rapide — pesée en 2 taps accessible depuis le dashboard sans navigation
- [ ] **(Flutter · P1)** Score de rentabilité (`POST /functions/v1/rentability-score`) — note /100 + 3 actions prioritaires
- [ ] **(Flutter · P2)** Météo locale — intégration Open-Meteo API selon région du profil éleveur + alerte stress thermique si T° > 30°C
---
 
**Lapins**
- [ ] **(Flutter · P1)** Liste lapins paginée (`GET /rest/v1/lapins?user_id=eq.{id}&order=nom.asc&limit=20`) — cursor-based + pull-to-refresh
- [ ] **(Flutter · P1)** Filtres liste lapins — statut, race, sexe (query params Supabase : `&statut=eq.EN_GESTATION`)
- [ ] **(Flutter · P1)** Recherche lapins — filtre local sur nom + `numero_identification`
- [ ] **(Flutter · P1)** Créer un lapin (`POST /rest/v1/lapins`) — formulaire 3 étapes (identité + paramètres + généalogie) + idempotency key
- [ ] **(Flutter · P1)** Fiche lapin (`GET /rest/v1/lapins?id=eq.{id}&select=*,races(*)`) — onglets croissance / santé / reproductions / infos
- [ ] **(Flutter · P1)** Modifier un lapin (`PATCH /rest/v1/lapins?id=eq.{id}`) — formulaire pré-rempli + validation
- [ ] **(Flutter · P1)** Supprimer un lapin (`DELETE /rest/v1/lapins?id=eq.{id}`) — confirmation + cascade SQLite
- [ ] **(Flutter · P1)** Photo lapin — upload (`POST /storage/v1/object/lapins/{id}`) caméra/galerie + compression + affichage `cached_network_image`
- [ ] **(Flutter · P1)** Upload photo vers Supabase Storage — compression < 200 Ko avant envoi
- [ ] **(Flutter · P1)** Statut dynamique lapin — mise à jour automatique selon événements (saillie → EN_GESTATION, mise bas → LACTATION…)
---
 
**Pesées & Croissance**
- [ ] **(Flutter · P1)** Ajouter pesée (`POST /rest/v1/pesees`) — saisie rapide poids en grammes + date + idempotency key
- [ ] **(Flutter · P1)** Liste pesées (`GET /rest/v1/pesees?lapin_id=eq.{id}&order=date.desc&limit=50`) — offset-based
- [ ] **(Flutter · P1)** Calcul GMQ automatique — différence poids / nb jours entre deux pesées, calculé localement
- [ ] **(Flutter · P1)** Graphique croissance (`fl_chart`) — courbe réelle (bleu) vs courbe cible race (vert pointillé) + zones couleur
- [ ] **(Flutter · P1)** Alerte décrochage GMQ — si GMQ < 80% norme race pendant 7 jours → badge rouge sur fiche + alerte dashboard
- [ ] **(Flutter · P1)** Prédiction croissance (`POST /functions/v1/predict-growth`) — courbe prévisionnelle à 10/12/14 semaines + date vente optimale
- [ ] **(Flutter · P2)** Pesée groupée portée — saisie poids total portée avec répartition automatique par lapereau
---
 
**QR Code & Traçabilité**
- [ ] **(Flutter · P1)** Génération QR code (`qr_flutter`) — encodage `lapinia://lapin/{id}` à la création de chaque animal
- [ ] **(Flutter · P1)** Affichage + partage QR code — écran plein écran + bouton partager image + bouton imprimer (Bluetooth)
- [ ] **(Flutter · P1)** Scanner QR code (`mobile_scanner`) — accès direct fiche lapin depuis scan
- [ ] **(Flutter · P1)** Identifiant unique auto-généré — format `{PAYS}-{ANNÉE}-{RACE}-{NUMÉRO}` (ex : `SN-2026-NZW-0042`)
- [ ] **(Flutter · P2)** Passeport animal PDF (`POST /functions/v1/generate-passport`) — identité + pedigree + vaccins + performances + QR code + download
- [ ] **(Flutter · P2)** Registre d'élevage officiel PDF (`POST /functions/v1/generate-registre`) — format DIREL Sénégal + export mensuel
---
 
**Races**
- [ ] **(Flutter · P1)** Liste races (`GET /rest/v1/races`) — données de référence, cache local 7 jours
- [ ] **(Flutter · P1)** Fiche race — poids adulte, GMQ cible, taille portée, adaptation chaleur, sensibilités pathologiques
- [ ] **(Flutter · P1)** Comparateur de races — sélection 2–3 races + tableau comparatif interactif selon objectif
- [ ] **(Flutter · P1)** Recommandation de race (`POST /functions/v1/recommend-race`) — basée sur région, objectif, ressources disponibles
- [ ] **(Flutter · P2)** Reconnaissance race par photo (`POST /functions/v1/recognize-race`) — TFLite on-device + affichage top 3 résultats avec scores de confiance
---
 
**Portées & Reproduction**
- [ ] **(Flutter · P1)** Liste portées (`GET /rest/v1/portees?user_id=eq.{id}&order=date_saillie.desc`) — statut coloré + barre progression gestation
- [ ] **(Flutter · P1)** Enregistrer une saillie (`POST /rest/v1/portees`) — sélection femelle (filtre statut=REPOS) + sélection mâle + date + observations + idempotency key
- [ ] **(Flutter · P1)** Vérification consanguinité avant saillie (`POST /functions/v1/consanguinity-check`) — alerte orange si F > 6.25%, blocage rouge si F > 12.5%
- [ ] **(Flutter · P1)** Timeline gestation visuelle — barre J0–J31 avec jalons (J7 implantation, J25 préparer nid, J28 alerte, J31 mise bas)
- [ ] **(Flutter · P1)** Checklist pré-mise bas J25 — cage maternité, nid, température, aliments, isolement (stockée en SQLite local)
- [ ] **(Flutter · P1)** Enregistrer mise bas (`PATCH /rest/v1/portees?id=eq.{id}`) — nb vivants, nb morts, poids total portée, date réelle + mise à jour statut femelle → LACTATION
- [ ] **(Flutter · P1)** Lapereaux portée (`GET /rest/v1/lapereaux?portee_id=eq.{id}`) — liste individuelle avec poids + statut
- [ ] **(Flutter · P1)** Mise à jour lapereau (`PATCH /rest/v1/lapereaux?id=eq.{id}`) — poids, statut, destination (conserver / vendre / consommer)
- [ ] **(Flutter · P1)** Enregistrer sevrage — confirmation J28–J35 + poids final + destination de chaque lapereau + mise à jour statut femelle → REPOS
- [ ] **(Flutter · P1)** Notifications push mise bas — planifier FCM à J-3 et J-1 via Edge Function après saisie saillie
- [ ] **(Flutter · P2)** Calendrier production annuel (`POST /functions/v1/production-calendar`) — objectif lapereaux/mois + planification saillies sur 12 mois
---
 
**Fertilité & Génétique**
- [ ] **(Flutter · P1)** Score fertilité lapin (`GET /rest/v1/lapins?id=eq.{id}&select=score_fertilite`) — badge /100 + explications sur fiche
- [ ] **(Flutter · P1)** Calcul score fertilité local — taux acceptation × 25 + taille portées × 25 + survie lapereaux × 25 + régularité × 25
- [ ] **(Flutter · P1)** Alerte baisse fertilité — si score chute > 20 pts en 3 mois → alerte dashboard + recommandations IA
- [ ] **(Flutter · P1)** Arbre généalogique (`GET /rest/v1/genealogie?lapin_id=eq.{id}`) — visualisation 3 générations, chaque nœud cliquable
- [ ] **(Flutter · P1)** Suggestion mâles pour saillie (`POST /functions/v1/suggest-males`) — classement par score génétique selon objectifs éleveur
- [ ] **(Flutter · P2)** Plan amélioration génétique (`POST /functions/v1/genetic-plan`) — objectifs sélection + plan Claude sur 3 générations
- [ ] **(Flutter · P2)** Export pedigree PDF (`POST /functions/v1/generate-pedigree`) — document certifié pour vente reproducteurs + download
---
 
**Santé & Diagnostic IA**
- [ ] **(Flutter · P1)** Journal observation quotidien — saisie rapide appétit / comportement / selles / aspect + bouton "Tout va bien" en 1 tap
- [ ] **(Flutter · P1)** Historique observations (`GET /rest/v1/sante?lapin_id=eq.{id}&type=eq.OBSERVATION&order=date.desc`)
- [ ] **(Flutter · P1)** Alerte 2 jours anormaux consécutifs — détection locale sur SQLite + badge rouge sur fiche lapin
- [ ] **(Flutter · P1)** Sélection symptômes — chips multiselect (respiratoires / digestifs / cutanés / comportementaux / locomoteurs)
- [ ] **(Flutter · P1)** Diagnostic IA (`POST /functions/v1/diagnose-symptoms`) — affichage top 3 diagnostics avec probabilité (%) + urgence (IMMÉDIATE / 48H / SURVEILLANCE) + traitement recommandé
- [ ] **(Flutter · P1)** Alerte épidémique — si résultat diagnostic contient `alerte_epidemique: true` → écran rouge + protocole isolement + notification push
- [ ] **(Flutter · P1)** Enregistrer traitement (`POST /rest/v1/sante`) — type=TRAITEMENT + médicament + dosage calculé auto selon poids + durée + idempotency key
- [ ] **(Flutter · P1)** Compte à rebours délai d'abattage — calculé depuis `date_fin_traitement + delai_abattage_jours`, affiché sur fiche sante
- [ ] **(Flutter · P1)** Alerte contre-indication automatique — si médicament sélectionné + femelle gestante/allaitante → warning orange avant confirmation
- [ ] **(Flutter · P1)** Bibliothèque 25 maladies (`GET /rest/v1/maladies`) — fiches détaillées avec symptômes, traitement, prévention + recherche
- [ ] **(Flutter · P1)** Carnet de santé lapin (`GET /rest/v1/sante?lapin_id=eq.{id}&order=date.desc`) — historique chronologique complet
- [ ] **(Flutter · P1)** Export carnet santé PDF (`POST /functions/v1/export-sante`) — historique complet + vaccinations + download + partage
- [ ] **(Flutter · P1)** Calendrier vaccinal — rappels VHD (J70 + rappel annuel) + Myxomatose selon région + notifications FCM J-7, J-3, J0
- [ ] **(Flutter · P1)** Enregistrer vaccination (`POST /rest/v1/sante`) — type=VACCIN + produit + date + prochaine date calculée auto
- [ ] **(Flutter · P2)** Pharmacologie (`GET /rest/v1/medicaments`) — base 40 médicaments + calcul dosage auto selon poids lapin + interactions dangereuses
- [ ] **(Flutter · P2)** Analyse photo symptômes (`POST /functions/v1/analyze-symptom-photo`) — upload photo lésion/comportement + analyse vision IA + aide diagnostic
---
 
**Alimentation & Stocks**
- [ ] **(Flutter · P1)** Inventaire stocks (`GET /rest/v1/stocks?user_id=eq.{id}`) — jauges visuelles couleur (vert > 50%, orange 20–50%, rouge < 20%)
- [ ] **(Flutter · P1)** Ajouter / modifier stock (`POST /rest/v1/stocks` / `PATCH /rest/v1/stocks?id=eq.{id}`) — aliment + quantité kg + prix + fournisseur + seuil alerte
- [ ] **(Flutter · P1)** Ration IA du jour (`POST /functions/v1/calculate-ration`) — rations par animal + ajustement stade (gestation +20%, lactation +40%) + coût total FCFA
- [ ] **(Flutter · P1)** Alerte stock critique — si `quantite_kg < seuil_alerte_kg` → badge rouge + suggestion quantité à commander
- [ ] **(Flutter · P1)** Prédiction consommation 30 jours — calcul local selon nb animaux + stades physiologiques actuels
- [ ] **(Flutter · P1)** Fiches aliments locaux (`GET /rest/v1/aliments_locaux`) — 50 aliments africains + valeurs nutritives + disponibilité saisonnière
- [ ] **(Flutter · P1)** Plan transition alimentaire sevrage — affichage plan 7 jours progressifs à la confirmation du sevrage
- [ ] **(Flutter · P2)** Optimisation coût ration (`POST /functions/v1/optimize-ration`) — combinaison d'aliments équivalente au prix minimum selon stocks disponibles
- [ ] **(Flutter · P2)** Gestion fournisseurs — répertoire nom + contact + prix + note qualité + historique commandes
---
 
**Finance & Rentabilité**
- [ ] **(Flutter · P1)** Journal des ventes — ajouter (`POST /rest/v1/finances`) type=RECETTE + animal(s) + prix + acheteur + mode paiement (cash / Orange Money / Wave) + idempotency key
- [ ] **(Flutter · P1)** Journal des dépenses — ajouter (`POST /rest/v1/finances`) type=DEPENSE + catégorie auto + montant + description + idempotency key
- [ ] **(Flutter · P1)** Liste transactions (`GET /rest/v1/finances?user_id=eq.{id}&order=date.desc&limit=50`) — offset-based + filtres type/catégorie/mois
- [ ] **(Flutter · P1)** Tableau de bord financier — revenus vs dépenses (graphique barres `fl_chart`) + bénéfice net + évolution 12 mois
- [ ] **(Flutter · P1)** Coût de production par lapereau — calcul local : (total dépenses période) / (nb lapereaux sevrés période)
- [ ] **(Flutter · P1)** Seuil de rentabilité — calcul local temps réel : charges fixes mensuelles / marge unitaire par lapereau
- [ ] **(Flutter · P1)** Prix de vente suggéré (`POST /functions/v1/suggest-price`) — coût production + marché local + marge cible éleveur
- [ ] **(Flutter · P1)** Prévision revenus 3 mois — calcul local depuis portées en cours + historique ventes
- [ ] **(Flutter · P2)** Simulateur investissement (`POST /functions/v1/simulate-investment`) — si j'achète X femelles → ROI à 6/12 mois
- [ ] **(Flutter · P2)** Export rapport comptable PDF (`POST /functions/v1/export-finances`) — bilan mensuel/annuel format OHADA + download
- [ ] **(Flutter · P2)** Gestion créances — ventes à crédit avec date échéance + rappels automatiques (SMS Twilio)
---
 
**Paiements & Abonnements**
- [ ] **(Flutter · P1)** Écran plans tarifaires — Gratuit (0 FCFA) / Éleveur (2 500/mois) / Pro (6 500/mois) avec liste des fonctionnalités incluses
- [ ] **(Flutter · P1)** Checkout Orange Money (`POST /functions/v1/payments/checkout`) — ouvrir URL paiement (webview / navigateur externe)
- [ ] **(Flutter · P1)** Checkout Wave (`POST /functions/v1/payments/checkout`) — même flux, provider différent
- [ ] **(Flutter · P1)** Statut abonnement (`GET /rest/v1/users?id=eq.{id}&select=plan,plan_expires_at`) — affichage badge plan + date expiration
- [ ] **(Flutter · P1)** Historique paiements (`GET /rest/v1/paiements?user_id=eq.{id}&order=date.desc`) — liste + statut (payé / en attente / échoué)
- [ ] **(Flutter · P2)** Portail facturation (`POST /functions/v1/payments/portal`) — ouvrir URL gestion abonnement
- [ ] **(Flutter · P2)** Factures PDF (`GET /functions/v1/payments/invoice/{id}`) — download + partage
---
 
**Notifications**
- [ ] **(Flutter · P1)** Enregistrer device token FCM (`POST /rest/v1/device_tokens`) — à la connexion + à chaque nouvelle session
- [ ] **(Flutter · P1)** Retirer device token (`DELETE /rest/v1/device_tokens?token=eq.{token}`) — au logout + désactivation notifications
- [ ] **(Flutter · P1)** Handler notification foreground — affichage in-app banner (flutter_local_notifications)
- [ ] **(Flutter · P1)** Handler notification background — notification système OS standard
- [ ] **(Flutter · P1)** Handler notification terminated — deep link vers écran concerné (go_router)
- [ ] **(Flutter · P1)** Paramètres notifications — choix catégories (mise bas / vaccination / stock / rapport) + heures de réception + mode silencieux nocturne
- [ ] **(Flutter · P2)** Rapport hebdomadaire push — réception lundi 7h + navigation vers écran résumé semaine
- [ ] **(Flutter · P2)** Scheduling local — notifs locales pour rappels hors-ligne (flutter_local_notifications)
---
 
**Assistant IA (Chat)**
- [ ] **(Flutter · P1)** Écran chat — bulles messages (utilisateur droite / IA gauche) + historique scrollable + indicateur de frappe (3 points animés)
- [ ] **(Flutter · P1)** Envoyer message (`POST /functions/v1/chat`) — injection contexte élevage complet (lapins + portées + stocks + alertes) dans le prompt
- [ ] **(Flutter · P1)** Sessions chat (`GET /rest/v1/chat_sessions?user_id=eq.{id}&order=updated_at.desc`) — liste des conversations
- [ ] **(Flutter · P1)** Messages session (`GET /rest/v1/chat_messages?session_id=eq.{id}&order=created_at.asc`) — pagination offset
- [ ] **(Flutter · P1)** Questions rapides prédéfinies — boutons chips (symptômes / prix vente / taux survie / races) + envoi automatique
- [ ] **(Flutter · P1)** Réponses hors-ligne — recherche dans `local_knowledge_base.json` (200 Q&R embarquées) si IA cloud indisponible
- [ ] **(Flutter · P1)** Routing IA automatique — TFLite (offline) → Mistral (simple) → Claude (complexe) selon connectivité + type question
- [ ] **(Flutter · P2)** Mode vocal — saisie `speech_to_text` + réponse `flutter_tts` (optionnel, activable dans paramètres)
- [ ] **(Flutter · P2)** Rapport mensuel IA auto (`POST /functions/v1/monthly-report`) — généré le 1er du mois + notification push + écran dédié
---
 
**Infrastructure & Cages**
- [ ] **(Flutter · P1)** Plan visuel élevage — grille de cages avec couleur selon statut occupant + tap → fiche lapin
- [ ] **(Flutter · P1)** Affectation cage — drag & drop lapin vers cage (stocké en SQLite local)
- [ ] **(Flutter · P1)** Protocole nettoyage — planning désinfection toutes les 2 semaines + checklist + historique (`POST /rest/v1/maintenances`)
- [ ] **(Flutter · P1)** Alerte densité — calcul local : si nb lapins / surface > 4/m² → badge orange sur plan
- [ ] **(Flutter · P2)** Monitoring ambiance — saisie manuelle température + humidité (`POST /rest/v1/ambiance_logs`) + graphique historique + alerte si T° > 30°C
---
 
**Formation**
- [ ] **(Flutter · P1)** Liste leçons (`GET /rest/v1/lecons`) — 12 leçons avec statut (non commencé / en cours / terminé) stocké SQLite local
- [ ] **(Flutter · P1)** Contenu leçon (`GET /rest/v1/lecons?id=eq.{id}`) — texte + illustrations + conseils pratiques
- [ ] **(Flutter · P1)** Quiz validation leçon (`POST /rest/v1/quiz_resultats`) — 5 questions + score + badge de completion
- [ ] **(Flutter · P1)** Progression formation — barre globale (leçons complétées / 12) sur écran formation
- [ ] **(Flutter · P1)** Glossaire (`GET /rest/v1/glossaire`) — 200+ termes + recherche full-text + cache local
- [ ] **(Flutter · P1)** Actualités sanitaires (`GET /rest/v1/actualites?type=eq.SANITAIRE&order=date.desc`) — alertes épizooties régionales + recommandations
- [ ] **(Flutter · P2)** Fiches pratiques PDF (`GET /storage/v1/object/fiches/{slug}`) — download + consultation hors-ligne
- [ ] **(Flutter · P2)** Forum communautaire (`GET /rest/v1/forum_posts?order=created_at.desc`) — fil par sujet + créer post + modération (V1.5)
- [ ] **(Flutter · P2)** Marketplace reproducteurs (`GET /rest/v1/annonces?order=created_at.desc`) — annonce auto depuis fiche lapin + contact WhatsApp/appel (V1.5)
---
 
**Synchronisation hors-ligne**
- [ ] **(Flutter · P1)** SyncManager — écoute `ConnectivityStream` + vide queue SQLite vers Supabase à la reconnexion
- [ ] **(Flutter · P1)** Persistent queue — toute mutation (POST/PATCH/DELETE) stockée en SQLite avec `idempotency_key` avant envoi réseau
- [ ] **(Flutter · P1)** Retry automatique — x3 avec backoff exponentiel (1s, 3s, 9s) sur erreur réseau
- [ ] **(Flutter · P1)** Résolution conflits — Last-Write-Wins sur `updated_at` entre SQLite local et Supabase
- [ ] **(Flutter · P1)** Indicateur mode hors-ligne — bandeau orange en haut d'écran si `ConnectivityResult.none`
- [ ] **(Flutter · P1)** Pré-chargement données critiques — races + médicaments + aliments locaux + base Q&R IA chargés au démarrage et mis en cache
---
 
**Admin (optionnel — app interne)**
- [ ] **(Flutter · P2)** Admin — lister éleveurs (`GET /rest/v1/users?select=*&order=created_at.desc`) — liste + recherche
- [ ] **(Flutter · P2)** Admin — changer plan éleveur (`PATCH /rest/v1/users?id=eq.{id}`) — `{ plan: 'eleveur' }`
- [ ] **(Flutter · P2)** Admin — statistiques globales (`GET /functions/v1/admin/stats`) — nb utilisateurs, portées actives, chiffre d'affaires
- [ ] **(Flutter · P2)** Admin — supprimer compte (`DELETE /rest/v1/users?id=eq.{id}`) — confirmation + cascade
---
 
**Webhooks (non mobile)**
- [ ] **(Backend uniquement)** Orange Money webhook (`POST /functions/v1/payments/om-webhook`) — confirmation paiement → mise à jour plan — pas de tâche Flutter
- [ ] **(Backend uniquement)** Wave webhook (`POST /functions/v1/payments/wave-webhook`) — même logique — pas de tâche Flutter
- [ ] **(Backend uniquement)** CRON alertes stocks (`/functions/v1/check-stock-alerts`) — quotidien 8h — pas de tâche Flutter
- [ ] **(Backend uniquement)** CRON rapport hebdo (`/functions/v1/send-weekly-report`) — lundi 7h — pas de tâche Flutter
- [ ] **(Backend uniquement)** CRON mise bas imminente (`/functions/v1/check-upcoming-births`) — quotidien 6h — pas de tâche Flutter
---
 
### Bloqué
 
- [ ] *(aucune pour le moment)*
---
 
### En cours
 
- [ ] *(aucune pour le moment)*
---
 
### Fait
 
- **Base app & architecture**
- [x] **(Flutter · P0)** Setup projet — conventions lint + routing `go_router` + DI `get_it` + environnements dev/staging/prod
- [x] **(Flutter · P0)** Configuration runtime — Supabase URL + anon key selon environnement + timeouts + feature flags
- [x] **(Flutter · P0)** Client Supabase — initialisation `Supabase.initialize()` + singleton + gestion token (Supabase gère le JWT)
- [x] **(Flutter · P0)** Gestion session — stockage sécurisé JWT `flutter_secure_storage` + restore au démarrage + clear au logout
- [x] **(Flutter · P0)** Structure Clean Architecture — `core/interfaces` + `data/repositories` + `domain/services` + `presentation/providers`
- [x] **(Flutter · P0)** Interface `BaseRepository<T>` — `findById`, `findAll`, `save`, `delete` (SOLID-I)
- [x] **(Flutter · P0)** Interface `AIProvider` — `complete`, `isAvailable`, `getEstimatedCost` (SOLID-D)
- [x] **(Flutter · P0)** `IdempotencyKey` — génération UUID v4 + persistance via `sync_queue` (Drift) avant envoi + suppression après succès
- [x] **(Flutter · P0)** SQLite local (Drift) — schéma 11 tables + `sync_queue` (création auto Drift)
- [x] **(Flutter · P0)** `SyncManager` skeleton — queue persistante + connectivité + structure retry
- [x] **(Flutter · P0)** Splash / Boot — init Supabase + restore session + redirect (onboarding / dashboard / login)
- [x] **(Flutter · P0)** Auth guard (`go_router` redirect) — routes protégées selon session active
- [x] **(Flutter · P0)** AppColors — palette complète (`primary #2E7D32`, `alert #E65100`, `danger #B71C1C`, `ia #4A148C`)
- [x] **(Flutter · P0)** AppTheme — `ThemeData` Poppins + Nunito + couleurs lapiNia + mode sombre
- [x] **(Flutter · P0)** Bottom Navigation Bar — 5 onglets : 🏠 Accueil · 🐇 Lapins · 🤰 Portées · 🍃 Aliments · 🧠 IA
- [x] **(Flutter · P1)** Modèles & sérialisation — `Lapin`, `Portee`, `Pesee`, `EvenementSante`, `Stock`, `Finance`, `Alerte`, `Race` + `fromJson/toJson`
- [x] **(Flutter · P1)** Gestion erreurs UI — mapping erreurs Supabase (400/401/403/404/409/429/5xx) → messages utilisateur + états (vide / chargement / erreur)
- [x] **(Flutter · P1)** Téléchargements fichiers — sauvegarde `path_provider` + partage OS `share_plus` (PDF / exports)
- [x] **(Flutter · P1)** Internationalisation — FR + EN (Wolof plus tard) + formats dates DD/MM/YYYY + monnaie FCFA
- [x] **(Flutter · P1)** Observabilité — logs structurés + handlers globaux (Sentry plus tard)

- **UI**
- [x] Fix overflow clavier sur l’écran Connexion (Login) — scroll + padding clavier
- [x] Fix overflow sur Onboarding (questions) — page scrollable si écran petit

- **Onboarding**
- [x] **(Flutter · P1)** Onboarding étape 2 — objectifs (multi-select) : vente lapereaux / viande / reproducteurs / loisir

- **Maintenance**
- [x] Mise à jour Flutter SDK + dépendances (go_router, Riverpod, Drift, etc.)

- **Offline & thème**
- [x] **(Flutter · P0)** Mode hors ligne (base) — cache local Drift (Lapins + Portées) + lecture local-first + file `sync_queue`
- [x] **(Flutter · P0)** CRUD Lapins hors ligne — create/update/delete optimistes + mutations en attente + synchro à la reconnexion
- [x] **(Flutter · P0)** Portées hors ligne (base) — création optimiste + mutation en attente + lecture depuis cache
- [x] **(Flutter · P0)** Thème persisté — Système / Clair / Sombre (SharedPreferences) + application au démarrage
- [x] **(Flutter · P0)** Écran Réglages — statut online/offline + compteur actions en attente + bouton “Synchroniser”
- [x] **(Flutter · P1)** Nettoyage dark mode (base) — retrait des couleurs hardcodées sur écrans clés (Dashboard/Auth/Lapins/Portées)
