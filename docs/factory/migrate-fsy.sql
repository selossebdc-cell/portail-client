-- =============================================================
-- Portail Client V2 — Migration FSY (Face Soul Yoga / Aurélia)
-- À exécuter dans Supabase SQL Editor
-- =============================================================

-- ═══ ÉTAPE 1 : Créer le user dans Supabase Auth AVANT d'exécuter ce script ═══
-- Dashboard Supabase → Authentication → Users → Add user
-- Email : aurelia@facesoulyoga.com
-- Mot de passe temporaire : FSY2026
-- Copier l'UUID généré et le coller ci-dessous :

-- ⚠️ REMPLACER cet UUID par celui généré dans Supabase Auth ⚠️
-- DO $$
-- DECLARE fsy_id UUID := 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX';
-- BEGIN ... END $$;

-- Pour l'instant on utilise un placeholder — à remplacer après création du user Auth
-- NOTE : exécuter la section 1 (profile) en premier, puis copier l'UUID réel

-- =============================================================
-- 1. PROFIL AURÉLIA
-- =============================================================
-- ⚠️ Remplacer l'UUID ci-dessous par celui créé dans Supabase Auth
INSERT INTO profiles (id, email, full_name, role, program, total_sessions, start_date, status, company, logo_url, booking_url, whatsapp_url, end_date, objectives)
VALUES (
  '00000000-0000-0000-0000-000000000000',  -- ← REMPLACER par l'UUID Auth
  'aurelia@facesoulyoga.com',
  'Aurélia Del Sol',
  'client',
  'Clarté & Autonomie — 6 mois',
  19,
  '2026-02-19',
  'active',
  'Face Soul Yoga',
  NULL,  -- logo_url : à ajouter quand disponible
  'https://fantastical.app/consulting-strategique/rdv1h',
  'https://wa.me/33661864016',
  '2026-08-18',
  '["Devenir une vraie CEO qui pilote avec recul et fluidité", "Rendre FSY Studio 100% autonome (géré par Laurie)", "Lancer Aurélia Del Sol (marque premium)", "Unifier le stack technique (Circle + Brevo + Bunny)"]'::jsonb
);

-- =============================================================
-- 2. CONTRAT
-- =============================================================
INSERT INTO contracts (client_id, program_name, total_amount, start_date, end_date, payment_schedule, documents, automations_included, automations)
VALUES (
  '00000000-0000-0000-0000-000000000000',  -- ← REMPLACER
  'Clarté & Autonomie — 6 mois',
  8000,
  '2026-02-19',
  '2026-08-18',
  '[
    {"date": "2026-02-17", "amount": 2500, "status": "paid", "label": "Acompte signature"},
    {"date": "2026-03-17", "amount": 2750, "status": "pending", "label": "2e échéance"},
    {"date": "2026-04-17", "amount": 2750, "status": "pending", "label": "3e échéance"}
  ]'::jsonb,
  '[
    {"name": "Contrat signé", "type": "contrat", "date": "2026-02-17", "url": ""},
    {"name": "Facture #1 — Acompte", "type": "facture", "date": "2026-02-17", "url": ""}
  ]'::jsonb,
  1,
  '[
    {"name": "Chatbot Telegram FSY", "status": "delivered", "description": "Bot IA pour la communauté WhatsApp/Telegram — mention-only, FAQ, rappels"},
    {"name": "Contrat e-signature B2B automatisé", "status": "planned", "description": "Achat Circle → webhook → envoi contrat → signature → accès formation"},
    {"name": "Séquences email Brevo automatisées", "status": "planned", "description": "Welcome, rétention, churn, upsell, lancement MTM, licence annuelle"}
  ]'::jsonb
);

-- =============================================================
-- 3. SESSIONS (4 réalisées + 1 planifiée)
-- =============================================================
INSERT INTO sessions (client_id, session_number, title, date, summary, status, cr_url, decisions) VALUES
(
  '00000000-0000-0000-0000-000000000000',  -- ← REMPLACER
  1,
  'Lancement stratégique & cadrage des priorités',
  '2026-02-19',
  'Audit initial, mapping des process, identification des 5 piliers. Cadrage priorités : process > outils. Objectif 500K€ CA 2026. CEO time 2h/semaine.',
  'completed',
  NULL,
  '["Process mapping = priorité n°1", "CEO time : 2h/semaine bloquées", "Pricing B2C : 299€ → 399€ coaching sommeil", "Migration plateforme mi-mars", "Objectif CA 500K€ 2026"]'::jsonb
),
(
  '00000000-0000-0000-0000-000000000000',
  2,
  'Migration Kajabi + Bunny, Architecture offre FSY',
  '2026-03-02',
  'Validation stack Circle + Bunny.net. Séparation FSY (mass-market) vs Aurélia Del Sol (premium). Arrêt des lives hebdo → evergreen. Freelance pour migration.',
  'completed',
  NULL,
  '["Kajabi + Bunny.net confirmés comme stack cible", "Circle éliminé puis réintégré session 4", "FSY = mass-market (17-1950€) vs Aurélia Del Sol = premium (3-15K€)", "Arrêt des lives hebdo → contenu evergreen", "Recruter freelance pour migration"]'::jsonb
),
(
  '00000000-0000-0000-0000-000000000000',
  3,
  'Stratégie offre FSY (evergreen + pricing) & Chatbot Telegram',
  '2026-03-11',
  'Session avec Laurie seule (Aurélia absente). Formation evergreen mai 2026. Pricing verrouillé : MTM 1950€ (early bird 1550€), abo 17€/mois, coaching sommeil 399€. Chatbot mention-only validé. Projection CA 634K€/an.',
  'completed',
  NULL,
  '["Formation evergreen : lancement mai 2026", "MTM : 1 950€ (early bird 1 550€) — relevé à 2 900€ en session 4", "Abonnement Studio : 17€/mois", "Coaching sommeil : 399€ (lancement juin)", "Uscreen gardé 1 an pendant migration", "Chatbot Telegram : mode mention-only uniquement", "Projection CA réaliste : 634K€/an"]'::jsonb
),
(
  '00000000-0000-0000-0000-000000000000',
  4,
  'Repositionnement des marques & feuille de route opérationnelle',
  '2026-03-16',
  'SESSION PIVOT. 3 entités distinctes actées : FSY Studio B2C (17€/mois, Laurie gère), Master The Method B2B (2 900€ evergreen), Aurélia Del Sol Premium (390€+). Migration Uscreen+Kajabi → Circle avant juillet 2026. VA recrutée (Upwork, 500$). Prix MTM relevé de 1 950€ à 2 900€.',
  'completed',
  'https://espace.csbusiness.fr/clients/aurelia/cr-session4-fsy.html',
  '["3 entités distinctes : FSY Studio B2C + MTM B2B + Aurélia Del Sol Premium", "Migration Uscreen+Kajabi → Circle avant juillet 2026", "VA recrutée Upwork (Anam, 500$) pour migration vidéos", "Prix MTM : 1 950€ → 2 900€ (early bird 2 500€)", "Site FSY = purement éducatif (exit lifestyle)", "4 challenges/an pour FSY Studio", "Licence annuelle MTM 100€/an", "Programme ambassadrices MTM (10-15% commission)"]'::jsonb
),
(
  '00000000-0000-0000-0000-000000000000',
  5,
  'Validation parcours clients + Circle + session Claude',
  '2026-03-24',
  NULL,
  'planned',
  NULL,
  '[]'::jsonb
);

-- =============================================================
-- 4. ACTIONS — Feuille de route V2 (19 actions)
-- =============================================================

-- Phase 0 — Ancrage & migrations (Mars-Avril 2026)
INSERT INTO actions (client_id, phase, title, description, status, tags, origin_session, sort_order) VALUES
(
  '00000000-0000-0000-0000-000000000000',
  0, 'Mapper les 3 parcours clients',
  'FSY Studio B2C, MTM B2B, Aurélia Del Sol — de l''acquisition à la sortie, chaque étape, chaque outil, chaque email. Livrable Catherine.',
  'todo', '["urgent", "session"]'::jsonb, 4, 1
),
(
  '00000000-0000-0000-0000-000000000000',
  0, 'Lancer la migration vidéos Uscreen → Bunny.net',
  'VA Anam gère la migration, Laurie supervise. Ajouter clause NDA dans contrat Upwork. ~550 vidéos / 550 Go.',
  'todo', '["urgent"]'::jsonb, 4, 2
),
(
  '00000000-0000-0000-0000-000000000000',
  0, 'Explorer Circle Business',
  'Créer les 2 espaces (Studio B2C + MTM B2B), tester communautés séparées, calendrier, checkout Stripe. Laurie lead.',
  'todo', '["urgent"]'::jsonb, 4, 3
),
(
  '00000000-0000-0000-0000-000000000000',
  0, 'Auditer Brevo',
  'Se connecter, lister les listes existantes (13 000 contacts), comprendre la segmentation, proposer architecture. Catherine.',
  'todo', '["urgent"]'::jsonb, 4, 4
),
(
  '00000000-0000-0000-0000-000000000000',
  0, 'Rechercher connexion Circle ↔ Brevo',
  'Webhook, API, Zapier, n8n ? Documenter les options possibles pour synchroniser les données. Catherine.',
  'todo', '["session"]'::jsonb, 4, 5
);

-- Phase 1 — Process & automatisations FSY Studio (Avril-Mai 2026)
INSERT INTO actions (client_id, phase, title, description, status, tags, origin_session, sort_order) VALUES
(
  '00000000-0000-0000-0000-000000000000',
  1, 'Construire l''espace Circle Studio',
  'Importer vidéos depuis Bunny, créer les collections, configurer calendrier, checkout Stripe, communauté. Laurie + VA.',
  'todo', '[]'::jsonb, 4, 6
),
(
  '00000000-0000-0000-0000-000000000000',
  1, 'Créer les séquences email FSY Studio dans Brevo',
  'Bienvenue (J+1/3/7), rétention (J+30/60/90), relance churn, upsell vers MTM (M+3). Catherine.',
  'todo', '[]'::jsonb, 4, 7
),
(
  '00000000-0000-0000-0000-000000000000',
  1, 'Refondre le site facesoulyoga.com',
  'Purement éducatif, exit lifestyle/immersions, nouveaux articles SEO (sommeil, mâchoire, bruxisme). Laurie + Claude.',
  'todo', '[]'::jsonb, 4, 8
),
(
  '00000000-0000-0000-0000-000000000000',
  1, 'Planifier le calendrier éditorial annuel FSY',
  '4 challenges/an + contenu hebdo batch + communication associée (emails + Instagram). Laurie + Catherine.',
  'todo', '[]'::jsonb, 4, 9
),
(
  '00000000-0000-0000-0000-000000000000',
  1, 'Plan de communication migration',
  'Prévenir les abonnés dès mai (app FSY custom va disparaître), emails progressifs, FAQ, redirection vers Circle. Catherine + Laurie.',
  'todo', '["urgent"]'::jsonb, 4, 10
);

-- Phase 2 — Process & automatisations MTM + Brevo (Mai-Juin 2026)
INSERT INTO actions (client_id, phase, title, description, status, tags, origin_session, sort_order) VALUES
(
  '00000000-0000-0000-0000-000000000000',
  2, 'Migrer MTM de Kajabi vers Circle',
  'Formation, quiz certification, communauté certifiées séparée. Laurie.',
  'todo', '[]'::jsonb, 4, 11
),
(
  '00000000-0000-0000-0000-000000000000',
  2, 'Réécrire la page de vente MTM à 2 900 €',
  'Avec vrais témoignages (Léa, Agnès), passage evergreen. Aurélia + Claude.',
  'todo', '[]'::jsonb, 4, 12
),
(
  '00000000-0000-0000-0000-000000000000',
  2, 'Automatiser le contrat e-signature B2B',
  'Achat Circle → webhook n8n → envoi contrat auto → signature → accès Circle. Catherine.',
  'todo', '[]'::jsonb, 4, 13
),
(
  '00000000-0000-0000-0000-000000000000',
  2, 'Créer la séquence de lancement MTM dans Brevo',
  'Template 7-8 emails réutilisable 2x/an (nurturing + urgence douce + early bird 2 500 €). Catherine.',
  'todo', '[]'::jsonb, 4, 14
),
(
  '00000000-0000-0000-0000-000000000000',
  2, 'Automatiser la licence annuelle MTM',
  'Relance email M-3 avant échéance + renouvellement Stripe + accès communauté + CPD. Catherine.',
  'todo', '[]'::jsonb, 4, 15
);

-- Phase 3 — Autonomie, Premium & pilotage (Juin-Août 2026)
INSERT INTO actions (client_id, phase, title, description, status, tags, origin_session, sort_order) VALUES
(
  '00000000-0000-0000-0000-000000000000',
  3, 'Installer la routine CEO hebdomadaire',
  '30 min/sem : dashboard KPIs + décisions + briefing Laurie. Aurélia.',
  'todo', '[]'::jsonb, 4, 16
),
(
  '00000000-0000-0000-0000-000000000000',
  3, 'Valider le plan de délégation définitif',
  'Quoi reste chez Aurélia (création, vision, premium) vs quoi passe chez Laurie (opérations FSY, MTM, com). Aurélia + Laurie.',
  'todo', '[]'::jsonb, 4, 17
),
(
  '00000000-0000-0000-0000-000000000000',
  3, 'Poser les fondations Aurélia Del Sol',
  'Identité visuelle, site séparé, premier programme (sommeil ou respiration), parcours client ébauché. Aurélia.',
  'todo', '[]'::jsonb, 4, 18
),
(
  '00000000-0000-0000-0000-000000000000',
  3, 'Bilan mi-parcours & plan de continuité',
  'Ce qui fonctionne, ce qui reste à faire, autonomie acquise, plan post-accompagnement. Catherine + Aurélia.',
  'todo', '[]'::jsonb, 4, 19
);

-- =============================================================
-- 5. TUTOS & GUIDES (type = 'guide' ou 'video')
-- =============================================================
INSERT INTO tutos (client_id, title, content_html, loom_url, icon, tuto_type, sort_order) VALUES
(
  '00000000-0000-0000-0000-000000000000',
  'Process création de formation',
  'Guide en 7 étapes : de l''idée au lancement d''une formation evergreen.',
  'https://espace.csbusiness.fr/clients/aurelia/process-creation-formation-fsy.html',
  '🎓', 'guide', 1
),
(
  '00000000-0000-0000-0000-000000000000',
  'Écosystème outils & données',
  'Comment tous tes outils se connectent, où sont les données, les liens manquants.',
  'https://espace.csbusiness.fr/clients/aurelia/ecosysteme-outils-fsy.html',
  '🔧', 'guide', 2
);

-- =============================================================
-- 6. MON PROJET (type = 'dashboard', 'project', 'roadmap')
-- =============================================================
INSERT INTO tutos (client_id, title, content_html, loom_url, icon, tuto_type, sort_order) VALUES
(
  '00000000-0000-0000-0000-000000000000',
  'Dashboard KPI — Suivi business',
  'Revenus par offre, abonnés, coûts outils, projections.',
  'https://espace.csbusiness.fr/clients/aurelia/dashboard-kpi-fsy.html',
  '📊', 'dashboard', 1
),
(
  '00000000-0000-0000-0000-000000000000',
  'Feuille de route V2',
  '19 actions en 4 phases — mars à août 2026. Post-session 4.',
  'https://espace.csbusiness.fr/clients/aurelia/feuille-de-route-fsy.html',
  '🗺️', 'roadmap', 2
),
(
  '00000000-0000-0000-0000-000000000000',
  'Architecture chatbot & workflows',
  '3 diagrammes Miro : flux principal, enrichissement FAQ, planification.',
  'https://miro.com/app/board/uXjVG2eDpcA=/',
  '🤖', 'project', 3
),
(
  '00000000-0000-0000-0000-000000000000',
  'CR Session 4 — Repositionnement des marques',
  'Compte-rendu complet de la session pivot du 16 mars 2026.',
  'https://espace.csbusiness.fr/clients/aurelia/cr-session4-fsy.html',
  '📋', 'project', 4
);

-- =============================================================
-- 7. OUTILS (table tools)
-- =============================================================
INSERT INTO tools (client_id, name, description, status, icon, sort_order) VALUES
('00000000-0000-0000-0000-000000000000', 'Circle', 'Plateforme communauté + formation — remplace Uscreen et Kajabi', 'planned', '⭕', 1),
('00000000-0000-0000-0000-000000000000', 'Uscreen', 'Plateforme vidéo actuelle — migration vers Circle avant juillet 2026', 'adopted', '📺', 2),
('00000000-0000-0000-0000-000000000000', 'Kajabi', 'Formation MTM — coexistence temporaire pendant migration Circle', 'adopted', '🎯', 3),
('00000000-0000-0000-0000-000000000000', 'Brevo', 'Email marketing — 13 000 contacts, segmentation par listes', 'adopted', '📧', 4),
('00000000-0000-0000-0000-000000000000', 'Bunny.net', 'CDN vidéo — stockage des 550+ vidéos FSY', 'in_progress', '🐰', 5),
('00000000-0000-0000-0000-000000000000', 'Wix', 'Site web facesoulyoga.com — à refondre (éducatif uniquement)', 'adopted', '🌐', 6),
('00000000-0000-0000-0000-000000000000', 'ManyChat', 'Chatbot Instagram — lead magnet et automation DM', 'adopted', '💬', 7),
('00000000-0000-0000-0000-000000000000', 'Telegram Bot FSY', 'Chatbot IA communauté — mention-only, FAQ, rappels', 'adopted', '🤖', 8),
('00000000-0000-0000-0000-000000000000', 'Claude AI', 'Agent IA — adopté par Aurélia (connecteurs Canva, Drive, Calendar)', 'adopted', '🧠', 9),
('00000000-0000-0000-0000-000000000000', 'Canva', 'Création visuelle — connecté à Claude', 'adopted', '🎨', 10),
('00000000-0000-0000-0000-000000000000', 'Google Calendar', 'Agenda partagé — intégrations actives', 'adopted', '📅', 11),
('00000000-0000-0000-0000-000000000000', 'Google Drive', 'Stockage cloud — partagé équipe', 'adopted', '📁', 12),
('00000000-0000-0000-0000-000000000000', 'WhatsApp', 'Communauté 300 membres — mention-only, support', 'adopted', '📱', 13),
('00000000-0000-0000-0000-000000000000', 'Stripe', 'Paiements — checkout Circle + abonnements', 'adopted', '💳', 14),
('00000000-0000-0000-0000-000000000000', 'CapCut', 'Montage vidéo — contenu batch', 'adopted', '🎬', 15);

-- =============================================================
-- ⚠️ IMPORTANT : APRÈS EXÉCUTION
-- =============================================================
-- 1. Créer le user dans Supabase Auth (email: aurelia@facesoulyoga.com, mdp: FSY2026)
-- 2. Copier l'UUID généré
-- 3. Faire un FIND & REPLACE de '00000000-0000-0000-0000-000000000000' par l'UUID réel
-- 4. Exécuter ce script dans Supabase SQL Editor
-- 5. Tester : se connecter sur espace.csbusiness.fr avec aurelia@facesoulyoga.com / FSY2026
