# Requirements — Portail Client V2

> Projet : Portail Client Interactif CS Consulting Stratégique
> Version : V1 (greenfield sur nouvelle stack, migration depuis portail V1 statique)
> Date : 2026-03-16
> Auteur : Catherine Selosse

---

## 1. Contexte

CS Consulting Stratégique accompagne des dirigeants TPE (40-65 ans) sur des programmes de 6 à 9 mois (Accélération / Transformation). Actuellement, chaque client a un portail HTML statique chiffré AES-256 hébergé sur GitHub Pages (V1). Ce portail est read-only : Catherine publie, le client consulte. Aucun échange bidirectionnel n'est possible.

**Problèmes identifiés :**
- Le client ne peut rien envoyer (pas de brain dump, pas de feedback)
- Catherine n'a pas de vue consolidée multi-clients
- Notion est jugé trop complexe/bordélique par Catherine
- La mise à jour manuelle (éditer HTML + protect.py + push) est lente
- Pas de récap hebdo visuel pour Catherine

## 2. Vision produit

Un espace client interactif où :
- Le client retrouve TOUT son accompagnement (actions, tutos, sessions, contrat)
- Le client peut écrire librement (brain dump) entre les sessions
- Catherine voit tous ses clients d'un coup d'œil dans un dashboard navigateur
- Chaque lundi, un récap DG HTML est généré automatiquement

## 3. Utilisateurs

| Persona | Description | Besoin principal |
|---------|-------------|-----------------|
| **Client** | Dirigeant TPE, 40-65 ans, peu tech-savvy | Espace simple, beau, tout au même endroit |
| **Catherine** | Consultante, TDAH, multi-clients | Vue d'ensemble, pas de surcharge, actions claires |
| **Agent DG** | Agent IA interne | Générer le récap hebdo automatiquement |

## 4. Périmètre fonctionnel

### 4.1 Portail Client (espace individuel)

**Existant à migrer (V1) :**
- Onglet Actions : checklist avec bouton Annuler, persistance localStorage
- Onglet Tutos : contenus HTML + vidéos Loom
- Onglet Sessions : historique des sessions (CR, dates)
- Onglet Mon contrat : paiements, documents, infos contrat

**Nouveau V2 :**
- **Brain dump** : champ libre texte (textarea), le client écrit quand il veut, chaque entrée est horodatée et sauvegardée en base
- **Historique brain dump** : le client voit ses entrées précédentes
- **Indicateur "lu par Catherine"** : le client sait que Catherine a lu son message
- **Login sécurisé** : email + mot de passe classique via Supabase Auth (remplace protect.py)

### 4.2 Dashboard Admin Catherine (`espace.csbusiness.fr/admin`)

Même URL que le portail client. Catherine se connecte avec son email admin → le système détecte le rôle et affiche le dashboard au lieu du portail client.

**Onglet "Mes clients" :**
- Liste de tous les clients actifs avec : nom, programme, session en cours (ex: 7/18), prochaine session, statut
- Brain dumps non lus (badge compteur)
- Actions en retard par client
- Progression globale (barre visuelle)
- Filtres : tous / alertes / brain dump non lu
- Actions cochables directement depuis le dashboard

**Onglet "Récap semaine" :**
- Récap DG hebdo intégré (généré chaque lundi par l'agent DG)
- Contenu : 3 priorités semaine, actions par jour, alertes, cockpit
- Actions cochables (checkbox persistées en base)
- Historique des récaps précédents consultable

**Onglet "Dashboards" :**
- Liens vers les dashboards existants (financier, KPIs, etc.)
- Point d'entrée unique — Catherine n'a qu'une URL à retenir

**Notifications brain dump :**
- Badge compteur dans le dashboard uniquement (pas d'email)

## 5. Exigences non-fonctionnelles

### 5.1 UX/UI
- Charte CS Consulting : terracotta #C27A5A, fond sombre #0f0f0f, police moderne
- Mobile-first (les clients consultent sur téléphone)
- Temps de chargement < 2s
- Interface épurée — TDAH-friendly (pas de surcharge visuelle)
- Pas de formulaire complexe — le brain dump est un simple textarea + bouton Envoyer

### 5.2 Sécurité
- Authentification Supabase (email/mdp)
- Row Level Security (RLS) : chaque client ne voit que ses données
- Catherine voit tout (rôle admin)
- HTTPS obligatoire

### 5.3 Performance
- Supabase plan gratuit (50 000 lignes, 500 Mo, auth illimitée)
- Hébergement GitHub Pages (statique) — le JS appelle Supabase directement
- Pas de serveur backend nécessaire

### 5.4 Scalabilité
- Doit supporter 24 clients simultanés (objectif 2026)
- Structure de données extensible (futurs modules)

## 6. Stack technique

| Couche | Choix | Justification |
|--------|-------|---------------|
| Frontend | HTML + CSS + JS vanilla | Cohérent avec V1, pas de framework, Claude Code maîtrise |
| Base de données | Supabase (PostgreSQL) | Gratuit, auth intégrée, RLS, API REST auto |
| Auth | Supabase Auth | Email/mdp, session tokens, gratuit |
| Hébergement | GitHub Pages | Déjà en place (espace.csbusiness.fr), gratuit |
| Récap DG | HTML statique généré | Agent DG Python → fichier HTML |

## 7. Migration V1 → V2

- Fred : migrer données existantes (actions, sessions, tutos) vers Supabase
- Aurélia/FSY : idem
- Nouveaux clients : onboarding directement en V2
- Conserver l'URL espace.csbusiness.fr
- Période de transition : V1 accessible en parallèle pendant 2 semaines

## 8. Contraintes

- Catherine gère seule (pas d'équipe dev) — Claude Code est le développeur
- Budget : 0 € (Supabase gratuit + GitHub Pages gratuit)
- Pas de dépendance à un outil tiers payant (pas de Lovable, pas de Vercel Pro)
- Méthode Spec-to-Code Factory obligatoire
- Le portail doit rester fonctionnel même si Supabase est temporairement indisponible (graceful degradation)

## 9. Livrables attendus

1. Portail client V2 (HTML/JS + Supabase) déployé sur espace.csbusiness.fr
2. Dashboard admin Catherine intégré (espace.csbusiness.fr/admin — même app, rôle admin)
3. Récap DG hebdo intégré dans l'onglet "Récap semaine" du dashboard
4. Migration Fred + Aurélia depuis V1
5. Documentation : guide d'onboarding nouveau client (comment créer un espace)

**Ordre de livraison :** Portail client d'abord → Dashboard admin ensuite

## 10. Critères d'acceptation

- [ ] Un client peut se connecter, voir ses actions, écrire un brain dump
- [ ] Catherine voit tous les clients dans son dashboard
- [ ] Les brain dumps apparaissent en temps réel dans le dashboard Catherine
- [ ] Le récap DG est généré en HTML chaque lundi
- [ ] Fred est migré et fonctionnel en V2
- [ ] L'interface est belle et utilisable sur mobile
- [ ] Le plan gratuit Supabase suffit

## 11. Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Client perd son mdp | Bloqué | Supabase reset password par email |
| Supabase hors service | Portail inaccessible | Graceful degradation (cache local) |
| Limites plan gratuit | Données perdues | Monitoring usage, export régulier |
| Client non tech-savvy | N'utilise pas le brain dump | UX ultra simple, démo en session |

## 12. Hors périmètre (V2)

- Messagerie temps réel (chat)
- Notifications push
- Intégration calendrier dans le portail
- Paiement en ligne dans le portail
- App mobile native
