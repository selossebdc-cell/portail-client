# INTAKE — Feature: Sync Tâches Mobile + Supabase + Paperclip

**Status**: ✅ GATE 0 VALIDÉ

## Brief

Créer un système centralisé de gestion des tâches :
- **App mobile** (dictée vocale) → Supabase au lieu de localStorage
- **Portail admin** (onglet Mes tâches) → sync temps réel
- **Agents Paperclip** (CEO, Pixou) → lisent/mettent à jour
- **Filtres perso/pro** → segmentation des tâches
- **URL dynamique** → `/todo-semaine-17avril.html` (pas hardcoder date)

## Scope

**Inclus** :
1. Modifier app mobile (todo-semaine-*.html) pour Supabase
2. Connecter agents Paperclip à table `tasks`
3. Ajouter sélecteur perso/pro à l'app mobile
4. Sync bidirectionnelle (app ↔ portail ↔ agents)
5. CR du CEO incluent les tâches de la semaine

**Exclus** :
- Changer architecture existante des clients
- Modifier RLS des clients
- Ajouter nouveaux onglets aux clients
- Changements design system (terracotta, dark mode intact)

## Acceptance Criteria

- [ ] Tâche dictée sur mobile → apparaît en Supabase + portail admin
- [ ] Filtres perso/pro fonctionnels sur app + portail
- [ ] Agents Paperclip voient/mettent à jour les tâches
- [ ] CEO peut générer CR avec tâches de la semaine
- [ ] URL dynamique `/todo-semaine-{JJMMMM}.html`
- [ ] Mobile responsive (iPhone + Android)
- [ ] Pas de console errors/warnings
- [ ] RLS correctement configurées (Catherine = owner)

## Dépendances

- **Supabase** : table `tasks` (existante, dcynlifggjiqqihincbp)
- **Paperclip agents** : accès TOOLS.md DEVINIT
- **GitHub Pages** : déploiement app mobile
- **Auth** : Supabase Auth (déjà en place)

## Questions ouvertes

- [ ] Tâches fixes (Accord parental, CAF, etc.) : hardcoded en HTML ou Supabase ?
- [ ] Historique des tâches : garder les anciennes semaines ?
- [ ] Permissions agents : Pixou peut-il modifier ou juste lire ?

## GATE 0 STATUS: ✅ PRÊT POUR SPEC
