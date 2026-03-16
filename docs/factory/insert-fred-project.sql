-- Ressources "Mon projet" pour Fred
-- tuto_type = 'dashboard' ou 'project' pour apparaître dans l'onglet Mon projet

INSERT INTO tutos (client_id, title, content_html, loom_url, icon, tuto_type, sort_order) VALUES
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Organisation fichiers Dropbox', 'Arborescence cible pour Dropbox : par entite (V8, FU Solutions, Perso) avec dossiers standardises.', NULL, '📂', 'project', 1),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Schema Firefox — Favoris par activite', 'Vue visuelle des favoris Firefox organises par containers et couleurs.', NULL, '🦊', 'project', 2),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Architecture emails — 4 boites Outlook', 'Mapping des 4 adresses mail centralisees dans Outlook avec labels et regles.', NULL, '📧', 'project', 3),
('83e6c2be-f9cc-47d8-9232-e80e1626fa62', 'Structure FU Solutions (holding)', 'Organigramme des 3 branches : V8 Equipment, Fu-Fight, Sourcing + gouvernance.', NULL, '🏢', 'project', 4);
