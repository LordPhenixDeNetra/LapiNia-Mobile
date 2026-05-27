-- =====================================================
-- lapiNia - Données de Référence
-- Version: 1.0
-- =====================================================

-- =====================================================
-- Insertion des 15 races
-- =====================================================
INSERT INTO races (nom, poids_adulte_min_kg, poids_adulte_max_kg, gmq_cible_g, taille_portee_moyenne, age_1ere_mise_bas_jours, adaptation_chaleur_score, profil_nutritionnel, sensibilites_pathologiques) VALUES
('Nouvelle-Zélande Blanc (NZW)', 4.0, 5.0, 42, 8.5, 150, 4, '{"proteines": 16, "fibres": 14}', ARRAY['Pasteurellose', 'Coccidiose']),
('Californien', 3.5, 4.5, 40, 8.0, 150, 4, '{"proteines": 15, "fibres": 14}', ARRAY['Rhinite', 'Pododermatite']),
('Rex', 3.0, 4.5, 32, 7.0, 160, 3, '{"proteines": 15, "fibres": 15}', ARRAY['Malocclusion', 'Pododermatite']),
('Angora', 2.5, 4.0, 27, 6.0, 180, 2, '{"proteines": 17, "fibres": 16}', ARRAY['Cheyletiellose', 'Bol alimentaire']),
('Géant des Flandres', 6.0, 10.0, 50, 9.5, 180, 2, '{"proteines": 16, "fibres": 13}', ARRAY['Arthrose', 'Pododermatite']),
('Fauve de Bourgogne', 3.5, 4.5, 38, 8.0, 150, 5, '{"proteines": 15, "fibres": 14}', ARRAY['Pasteurellose']),
('Lapin de case local', 1.5, 2.5, 24, 7.0, 120, 5, '{"proteines": 14, "fibres": 15}', ARRAY['Coccidiose']),
('Vienne Bleu', 3.5, 4.5, 35, 7.0, 150, 4, '{"proteines": 15, "fibres": 14}', ARRAY['Rhinite']),
('Satin', 3.5, 4.5, 36, 7.0, 150, 4, '{"proteines": 15, "fibres": 14}', ARRAY['Pasteurellose']),
('Bélier Français', 3.0, 5.0, 30, 6.5, 160, 3, '{"proteines": 15, "fibres": 15}', ARRAY['Otite', 'Gale auriculaire']),
('Chinchilla', 3.5, 4.5, 35, 7.5, 150, 3, '{"proteines": 15, "fibres": 15}', ARRAY['Pododermatite']),
('Papillon Français', 3.0, 4.0, 35, 7.0, 150, 4, '{"proteines": 15, "fibres": 14}', ARRAY['Pasteurellose']),
('Blanc de Hotot', 4.0, 5.0, 40, 8.0, 150, 4, '{"proteines": 15, "fibres": 14}', ARRAY['Coccidiose']),
('Géant Blanc du Bouscat', 5.0, 7.0, 45, 8.5, 170, 3, '{"proteines": 16, "fibres": 13}', ARRAY['Pododermatite']),
('Normand', 3.5, 5.0, 38, 8.0, 150, 4, '{"proteines": 15, "fibres": 14}', ARRAY['Pasteurellose', 'Gale']);

-- =====================================================
-- Insertion des médicaments
-- =====================================================
INSERT INTO medicaments (nom, classe, posologie_ml_par_kg, voie_administration, contre_indications, delai_abattage_jours, description) VALUES
-- Antibiotiques
('Enrofloxacine 10%', 'Antibiotique', 0.5, 'Oral (eau)', '{"gestation": true, "lactation": true}', 14, 'Fluoroquinolone à large spectre'),
('Marbofloxacine 5%', 'Antibiotique', 1.0, 'Oral', '{"gestation": true}', 14, 'Fluoroquinolone'),
('Oxytétracycline 20%', 'Antibiotique', 1.0, 'Oral (eau)', '{"lactation": true}', 7, 'Tétracycline'),
('Triméthoprime-Sulfaméthoxazole', 'Antibiotique', 1.5, 'Oral', '{"gestation": true, "lactation": true}', 14, 'Association antibactérienne'),
('Tylosine', 'Antibiotique', 0.5, 'Injectable', '{}', 7, 'Macrolide'),
('Pénicilline G', 'Antibiotique', 0.1, 'Injectable', '{}', 14, 'Bêta-lactamine'),

-- Antiparasitaires
('Ivermectine 1%', 'Antiparasitaire', 0.2, 'Injectable', '{}', 28, 'Endectocide'),
('Fenbendazole 10%', 'Antiparasitaire', 5.0, 'Oral', '{}', 14, 'Benzimidazolé'),
('Toltrazuril 2.5%', 'Antiparasitaire', 0.3, 'Oral', '{}', 21, 'Anti-coccidien'),
('Diclazuril', 'Antiparasitaire', 0.5, 'Oral', '{}', 21, 'Anti-coccidien'),
('Sulfadimidine', 'Antiparasitaire', 2.0, 'Oral', '{"gestation": true}', 14, 'Anti-coccidien'),

-- Anti-inflammatoires
('Méloxicam 0.5%', 'Anti-inflammatoire', 0.1, 'Oral', '{}', 7, 'AINS coxib'),
('Kétoprofène', 'Anti-inflammatoire', 0.1, 'Injectable', '{}', 7, 'AINS propionique'),

-- Vitamines et Compléments
('Vitamine C', 'Vitamine', 10.0, 'Oral (eau)', '{}', 0, 'Acide ascorbique'),
('Vitamine D3', 'Vitamine', 500.0, 'Oral', '{}', 0, 'Cholécalciférol'),
('Calcium gluconate 10%', 'Complement', 1.0, 'Injectable', '{}', 0, 'Correction hypocalcémie'),
('Complexe B injectable', 'Vitamine', 0.5, 'Injectable', '{}', 0, 'Vitamines B1, B6, B12'),
('Electrolytes réhydratation', 'Complement', 2.0, 'Oral (eau)', '{}', 0, 'Sels de réhydratation'),

-- Vaccins
('Vaccin VHD monovalent', 'Vaccin', 1.0, 'Injectable', '{}', 0, 'Hémorragique virale'),
('Vaccin VHD bivalent (V1+V2)', 'Vaccin', 1.0, 'Injectable', '{}', 0, 'Hémorragique virale types 1 et 2'),
('Vaccin Myxomatose', 'Vaccin', 1.0, 'Injectable', '{}', 0, 'Myxomatose'),
('Vaccin Pasteurella', 'Vaccin', 1.0, 'Injectable', '{}', 0, 'Pasteurellose'),

-- Désinfectants
('Glutaraldéhyde 2%', 'Desinfectant', 0, 'Topique', '{}', 0, 'Désinfection cages'),
('Ammonium quaternaire', 'Desinfectant', 0, 'Topique', '{}', 0, 'Désinfection surfaces'),
('Hypochlorite de sodium', 'Desinfectant', 0, 'Topique', '{}', 0, 'Désinfection'),
('Crésyl', 'Desinfectant', 0, 'Topique', '{}', 0, 'Désinfection'),
('Chaux vive', 'Desinfectant', 0, 'Topique', '{}', 0, 'Désinfection sols'),

-- Compléments Digestifs
('Probiotiques lapins', 'Probiotique', 1.0, 'Oral', '{}', 0, 'Flore digestive'),
('Levures vivantes', 'Probiotique', 1.0, 'Oral', '{}', 0, 'Levure Saccharomyces'),
('Kaolin-pectine', 'Anti-diarrhéique', 2.0, 'Oral', '{}', 0, 'Anti-diarrhéique');

-- =====================================================
-- Insertion des aliments locaux africains
-- =====================================================
INSERT INTO stocks (user_id, aliment, quantite_kg, seuil_alerte_kg, prix_kg_fcfa, fournisseur_nom, fournisseur_contact) VALUES
(uuid_nil(), 'Foin de luzerne', 10.0, 2.0, 500, 'Fournisseur local', '+221 77 000 0000'),
(uuid_nil(), 'Son de mil', 15.0, 3.0, 200, 'Moulin local', '+221 77 000 0001'),
(uuid_nil(), 'Granulés complets', 20.0, 5.0, 800, 'Agrovet', '+221 77 000 0002'),
(uuid_nil(), 'Fanes de carottes', 5.0, 1.0, 0, 'Marché local', NULL),
(uuid_nil(), 'Tourteau d arachide', 10.0, 2.0, 400, 'Huilerie', '+221 77 000 0003'),
(uuid_nil(), 'Feuilles de moringa', 3.0, 0.5, 0, 'Jardin', NULL),
(uuid_nil(), 'Herbe de Guinée', 8.0, 2.0, 0, 'Prairie', NULL),
(uuid_nil(), 'Graines de niébé', 5.0, 1.0, 600, 'Coopérative', '+221 77 000 0004');
