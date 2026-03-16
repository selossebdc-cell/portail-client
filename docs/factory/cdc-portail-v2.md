# CDC — Portail Client V2 (version complète)

> Date : 16 mars 2026
> Auteur : Catherine Selosse / Claude
> Statut : EN VALIDATION

---

## 1. NAVIGATION — Onglets principaux

L'espace client comporte **8 onglets** + une page d'accueil dashboard :

| # | Onglet | Icône | Description |
|---|--------|-------|-------------|
| 0 | **Tableau de bord** | 🏠 | Page d'arrivée — résumé + raccourcis |
| 1 | **Actions** | ✅ | Checklist enrichie (fait/abandonné/tags) |
| 2 | **Brain Dump** | 💭 | Champ libre pour le client |
| 3 | **Mes outils** | 🔧 | Outils utilisés — client peut ajouter |
| 4 | **Sessions** | 📅 | Historique + CR + actions par séance |
| 5 | **Tutos & Guides** | 🎓 | Guides pas-à-pas, vidéos Loom, ressources pédagogiques |
| 6 | **Mon projet** | 📊 | KPI, avancement projet, tableaux de bord (nav dédiée + bouton retour) |
| 7 | **Mon contrat** | 📋 | Paiements + documents partagés |

**Tutos & Guides** = contenus pédagogiques (comment faire X, vidéo explicative, guide étape par étape).
**Mon projet** = vue d'ensemble business (KPI, avancement projet, feuille de route, tableaux de bord HTML personnalisés).

---

## 2. TABLEAU DE BORD (page d'arrivée)

### 2.1 Header
- **Logo client** (image uploadée par admin, fallback = initiales)
- Nom du client, entreprise, programme
- Stats : Séances X/Y, Avancement %, Actions à faire

### 2.2 Alerte RDV
- Si prochaine séance **planifiée** → bannière avec date + thème
- Si **aucune séance planifiée** → ⚠️ warning orange "Ton prochain RDV n'est pas encore calé"
- **Bouton "Prendre RDV"** → lien Fantastical (configurable par client dans admin)

### 2.3 Objectifs du programme
- Bloc visible en permanence dans le tableau de bord
- Défini par Catherine **après 2-3 séances** (pas au démarrage — les objectifs se clarifient avec le client)
- Tant que non renseigné → le bloc ne s'affiche pas (pas de placeholder vide)
- 2-4 objectifs (texte libre)
- Le client voit POURQUOI il est là (donne du sens aux micro-actions)
- Ex Fred (après S3) : "Centraliser mes outils", "Structurer FU Solutions", "Gagner 6h/semaine"
- Champ `objectives` (JSONB) dans `profiles` — null par défaut

### 2.4 Actions prioritaires
- Afficher les **3-5 actions non terminées** (triées par sort_order)
- Chaque action cliquable → va vers l'onglet Actions

### 2.4 Retroplanning mini
- Barre de progression globale du programme (date début → date fin)
- Marqueur "aujourd'hui"
- % d'avancement (séances complétées / total)

### 2.5 Raccourcis
- 💭 "Quelque chose à noter ?" → lien vers Brain Dump
- 📊 "Voir mes dashboards" → lien vers onglet Dashboards
- 📄 "Dernier CR de séance" → lien vers le CR le plus récent

### 2.6 Brain dumps non lus (admin only dans dashboard admin)
- Badge dans le dashboard admin si brain dumps non lus

---

## 2b. BADGES "NOUVEAU" (transversal)

Système de badges visuels sur les onglets pour signaler du nouveau contenu.

### Principe
- Petit point rouge (ou compteur) sur l'onglet concerné
- Se réinitialise quand le client clique sur l'onglet (= "vu")
- Pas de notifications push, juste des indicateurs visuels dans le portail

### Onglets concernés
| Onglet | Déclenché quand... |
|--------|-------------------|
| Actions | Catherine ajoute une nouvelle action |
| Sessions | Nouveau CR ajouté ou nouvelle session |
| Tutos & Guides | Nouveau tuto ajouté |
| Mon projet | Nouveau dashboard ajouté |
| Mon contrat | Nouveau document ou paiement mis à jour |

### Implémentation
- Champ `last_seen` par onglet dans localStorage (côté client)
- Comparer avec `created_at` des éléments de chaque table
- Si `created_at > last_seen` → afficher badge avec compteur
- Au clic sur l'onglet → mettre à jour `last_seen` = maintenant

---

## 3. ACTIONS (enrichi)

### Statuts
| Statut | Icône | Couleur |
|--------|-------|---------|
| À faire | ○ | Gris |
| Fait | ✓ | Vert #4ade80 |
| Abandonné | ✕ | Gris barré |

### Fonctionnalités
- Bouton ✓ (fait) et ✕ (abandonner) sur chaque action
- Tags colorés (urgent, tuto, session, admin)
- Lien externe optionnel
- Badge session d'origine (S6, S7...)
- Section "Déjà fait" dépliable (fait + abandonné séparés)
- Bouton "Reprendre" / "Annuler" pour changer le statut

### Données
- Table `actions` : title, status, tags, link_url, link_label, origin_session, sort_order

---

## 4. BRAIN DUMP (enrichi)

### Fonctionnalités existantes
- Textarea libre
- Historique des notes précédentes
- Badge "Lu" / "En attente"
- Catherine lit avant chaque session

### NOUVEAU : Réponses de Catherine
- Sous chaque brain dump, Catherine peut laisser un commentaire
- Affiché en style "bulle réponse" (fond légèrement différent, aligné à droite)
- Le client voit la réponse directement sous sa note
- Ex : "Vu, on en parle mardi" ou "Bonne réflexion, avance sur X en attendant"

### Table ajoutée
```sql
CREATE TABLE brain_dump_replies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brain_dump_id UUID REFERENCES brain_dumps(id) ON DELETE CASCADE,
  author_id UUID REFERENCES profiles(id),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### RLS
- Le client voit les réponses sur ses propres brain dumps
- Seul l'admin peut créer des réponses

---

## 5. MES OUTILS (NOUVEAU)

### Fonctionnalité
Le client peut **ajouter et décrire** ses outils. Catherine peut aussi en ajouter.

### Champs par outil
| Champ | Type | Qui remplit |
|-------|------|------------|
| Nom | texte | Client ou Admin |
| À quoi ça sert | texte libre | Client |
| Statut | adopté / en cours / abandonné / prévu | Admin |
| Icône | emoji | Admin (optionnel) |
| URL | lien | Admin (optionnel) |

### UX
- Liste de cartes (style tuto-card V1)
- Bouton "+ Ajouter un outil" en bas
- Formulaire simple : nom + description
- L'admin peut ensuite enrichir (statut, icône, URL)

### Statuts visuels
| Statut | Couleur | Badge |
|--------|---------|-------|
| Adopté | Vert #4ade80 | ✅ Adopté |
| En cours | Bleu #60a5fa | 🔄 En cours |
| Prévu | Orange #fb923c | 📋 Prévu |
| Abandonné | Gris #666 | ✕ Abandonné |

### Table SQL
```sql
CREATE TABLE tools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,          -- "à quoi ça sert"
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('adopted', 'in_progress', 'planned', 'abandoned')),
  icon TEXT,                 -- emoji
  url TEXT,
  added_by UUID REFERENCES profiles(id),  -- qui l'a ajouté
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 6. SESSIONS (enrichi)

### Contenu par séance
- Numéro + titre + date
- Résumé
- **Bouton CR** : "📄 Voir le compte-rendu complet" → ouvre cr_url dans nouvel onglet
- **Décisions clés** (liste)
- **Actions assignées** à cette séance (avec leur statut actuel)

### Champ ajouté
```sql
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS cr_url TEXT;
```

---

## 7. TUTOS & GUIDES (onglet dédié)

### Contenu
Guides pas-à-pas, vidéos Loom, ressources pédagogiques préparées par Catherine.

### UX
- Liste de cartes V1 (icône + titre + description + bouton)
- Chaque carte ouvre le guide/vidéo dans un nouvel onglet
- Affichage du nombre d'étapes ou "📹 Vidéo" selon le type

### Données
Table `tutos` existante, filtrée sur `tuto_type IN ('guide', 'video')` :
- `tuto_type` : 'guide' | 'video'
- `icon`, `steps`, `loom_url`, `content_html`

### Exemples pour Fred
| Titre | Type | Icône |
|-------|------|-------|
| Tuto Dashlane | guide (8 étapes) | 🔐 |
| Outlook — Catégories couleurs | guide (3 étapes) | 📬 |
| Attestations de formation | vidéo | 🎓 |
| Firefox — Favoris rangés | guide | 🦊 |

---

## 7b. MON PROJET (onglet dédié — NOUVEAU)

### Contenu
Vue d'ensemble business et avancement : KPI, tableaux de bord, feuille de route, suivi de projet.

### UX
- Liste de cartes cliquables (icône + titre + description)
- Chaque carte ouvre un **HTML externe** dans un nouvel onglet (iframe ou nouvelle page)
- **Bouton "← Retour à mon espace"** en haut si ouverture dans la même page
- Contenu personnalisé par client (certains ont un KPI, d'autres un suivi projet)

### Données
Table `tutos` existante, filtrée sur `tuto_type IN ('dashboard', 'project', 'roadmap')` :
- `tuto_type` : 'dashboard' | 'project' | 'roadmap'
- `icon`, `loom_url` (= URL du HTML), `content_html` (description)
- Ajouter un champ `thumbnail_url` optionnel

### Exemples pour Fred
| Titre | Type | URL |
|-------|------|-----|
| (pas encore de dashboard) | — | — |

### Exemples pour FSY
| Titre | Type | URL |
|-------|------|-----|
| Dashboard KPI | dashboard | dashboard-kpi-fsy.html |
| Process création formation | guide | process-creation-formation-fsy.html |
| Écosystème outils | dashboard | ecosysteme-outils-fsy.html |
| Feuille de route V2 | dashboard | feuille-de-route-fsy.html |

---

## 8. MON CONTRAT (enrichi)

### 8.1 Programme + Paiements
Inchangé, avec **logique dynamique** :
- Payé → vert
- Échéance passée non payée → rouge "En retard"
- Échéance future → orange "Échéance [date]"

### 8.2 Documents partagés (NOUVEAU)
Section sous les paiements :
- Liste de documents avec icône + nom + date
- Lien cliquable si URL renseigné
- "Bientôt disponible" si pas d'URL
- Types : contrat, facture, attestation, autre

### Données
Réutiliser le champ JSONB `documents` dans `contracts` :
```json
[
  {"name": "Contrat signé", "type": "contrat", "date": "2026-01-22", "url": ""},
  {"name": "Facture #1", "type": "facture", "date": "2026-01-22", "url": ""},
  {"name": "Guide OneDrive", "type": "autre", "date": "2026-03-15", "url": "https://..."}
]
```

---

## 9. RETROPLANNING

### Vue dans le tableau de bord
- Barre horizontale : date début → date fin du programme
- Marqueur "aujourd'hui"
- Pourcentage global (séances complétées / total)

### Vue détaillée (optionnel, dans Dashboards)
- Si le client a des phases (comme FSY), afficher une timeline par phase
- Jalons clés avec dates et statuts

### Données
Utiliser les données existantes :
- `profiles.start_date` + durée programme → calculer date fin
- `sessions` → progression
- Optionnel : table `milestones` pour les jalons

---

## 10. PROFIL CLIENT — Champs admin

### Champs existants
- full_name, email, role, program, total_sessions, start_date, status

### Champs à ajouter
```sql
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS company TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS logo_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS booking_url TEXT;  -- lien Fantastical
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS whatsapp_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS end_date DATE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS objectives JSONB DEFAULT '[]'::jsonb;
  -- Ex : ["Centraliser mes outils", "Structurer FU Solutions", "Gagner 6h/semaine"]
```

---

## 11. RÉSUMÉ DES TABLES

| Table | Existante | Modifiée |
|-------|-----------|----------|
| profiles | ✅ | + company, logo_url, booking_url, whatsapp_url, end_date, objectives |
| actions | ✅ | + status, tags, link_url, link_label, origin_session |
| brain_dumps | ✅ | inchangée |
| brain_dump_replies | 🆕 | réponses Catherine aux brain dumps |
| sessions | ✅ | + cr_url, decisions |
| tutos | ✅ | sert aux 2 onglets (Tutos & Guides + Mon projet), + icon, tuto_type, steps, thumbnail_url |
| contracts | ✅ | + start_date, end_date |
| tools | 🆕 | nom, description, statut, icône, URL, added_by |
| weekly_recaps | ✅ | inchangée (admin) |

---

## 12. ORDRE DE PRIORITÉ

1. **Tableau de bord** (page d'arrivée + objectifs + warning RDV + raccourcis + retroplanning mini)
2. **Actions** (déjà codé, polir)
3. **Brain Dump** (ajouter réponses Catherine)
4. **Sessions** (CR link + actions liées — déjà codé)
5. **Tutos & Guides** (onglet existant, renommer)
6. **Mon projet** (NOUVEAU — KPI, avancement, dashboards HTML)
7. **Mes outils** (NOUVEAU — client peut ajouter)
8. **Mon contrat** (documents partagés)
9. **Badges "Nouveau"** (transversal — localStorage)
10. **Profil client** (logo, booking URL, company, objectives)
