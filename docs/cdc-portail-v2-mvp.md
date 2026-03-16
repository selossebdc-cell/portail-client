# CDC — Portail Client V2 (MVP)

> **Principe** : construire le minimum qui débloque, pas un outil de gestion de projet.
> **Cible immédiate** : Face Soul Yoga (Aurélia + Laurie)
> **Cible secondaire** : Fred (migration V1 → V2 quand prêt)
> **Stack** : Lovable (front) + Supabase (back) + espace.csbusiness.fr

---

## 1. Ce que le portail V1 fait déjà bien (garder)

- ✅ 4 onglets : Actions, Tutos, Sessions, Mon contrat
- ✅ Charte CS Consulting (terracotta #C27A5A, fond sombre)
- ✅ Données structurées (actions, sessions, paiements)
- ✅ Responsive mobile
- ✅ CR de session accessible depuis l'historique

---

## 2. Ce qui manque (le vrai besoin)

### 2.1 Actions avec statuts (pas juste fait/pas fait)

**Actuel** : checkbox binaire (fait/pas fait), stocké en localStorage (local au navigateur, pas partagé)

**Cible** :

| Statut | Couleur | Description |
|--------|---------|-------------|
| ⬜ À faire | Gris | Action non démarrée |
| 🔵 En cours | Bleu | Action démarrée |
| 🔴 Bloqué | Rouge | Action bloquée (nécessite un commentaire) |
| ✅ Fait | Vert | Action terminée |

**UX** : clic sur un bouton de statut (pas de drag & drop) → change l'état → sauvegarde dans Supabase → visible par tout le monde (Aurélia, Laurie, Catherine)

**Filtre rapide** : en haut de la liste, 4 boutons-filtres pour voir seulement "À faire", "En cours", etc.

**Filtre par responsable** : toggle "Aurélia / Laurie / Catherine / Tous"

### 2.2 Commentaire par action

**Quand une action est "Bloqué"** → champ texte obligatoire : "Qu'est-ce qui bloque ?"

**Pour toute action** → petit champ "Note" optionnel (ex: "J'ai commencé mais j'attends le retour de la VA")

**Stockage** : table `action_comments` dans Supabase

```sql
CREATE TABLE action_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action_id UUID REFERENCES actions(id) ON DELETE CASCADE,
  author TEXT NOT NULL, -- "Aurélia", "Laurie", "Catherine"
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2.3 Timeline de progression (pas un Gantt)

**Ce que c'est** : une barre horizontale avec les 4 phases, mois par mois, et un indicateur "on est ici"

```
Mars        Avril       Mai         Juin        Juillet     Août
|===========|===========|===========|===========|===========|
[Phase 0 ██████]
            [Phase 1 ████████████]
                        [Phase 2 ████████████████]
                                    [Phase 3 ████████████████████]
                  ▲
              ON EST ICI
```

**Par phase** : nombre d'actions faites / total (ex: "3/5 fait")

**Pas besoin de** : dates par action individuelle, dépendances, drag des barres. C'est une VUE, pas un outil d'édition.

### 2.4 Vue "Ma semaine" (alternative au Kanban)

**Plutôt qu'un Kanban complet**, une vue simple :

**Cette semaine** (max 3 actions prioritaires)
- 🔴 [Action urgente 1] — Laurie — En cours
- 🔴 [Action urgente 2] — Aurélia — À faire
- 🟠 [Action moyenne] — Laurie — Bloqué → "J'attends les accès Circle"

**Prochaine semaine** (preview)
- 🟠 [Action à venir]

**Comment ça se remplit** : Catherine définit les actions de la semaine dans le back. Ou : les actions sont triées par priorité + date d'échéance.

---

## 3. Architecture technique

### 3.1 Front (Lovable)

```
/app
  /dashboard        ← page d'accueil (stats + "ma semaine")
  /actions          ← liste des actions avec filtres + statuts
  /timeline         ← vue timeline phases
  /tutos            ← ressources (HTML embedé ou liens)
  /sessions         ← historique + liens vers CR HTML
  /contrat          ← paiements + documents
  /login            ← auth Supabase (email + password)
```

### 3.2 Back (Supabase)

Tables existantes (déjà dans setup-database.sql) :
- `profiles` — utilisateurs (client + admin)
- `actions` — checklist avec phase, priorité, statut
- `sessions` — historique séances
- `tutos` — ressources
- `contracts` — paiements + docs
- `brain_dumps` — champ libre client
- `weekly_recaps` — récaps Catherine

**Tables à ajouter** :

```sql
-- Commentaires sur les actions
CREATE TABLE action_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action_id UUID REFERENCES actions(id) ON DELETE CASCADE,
  author_id UUID REFERENCES profiles(id),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Modifier la table actions : ajouter les champs manquants
ALTER TABLE actions ADD COLUMN status TEXT DEFAULT 'todo'
  CHECK (status IN ('todo', 'in_progress', 'blocked', 'done'));
ALTER TABLE actions ADD COLUMN assignee TEXT; -- "Aurélia", "Laurie", "Catherine"
ALTER TABLE actions ADD COLUMN entity TEXT; -- "FSY Studio", "MTM", "Aurélia Del Sol", "Transverse"
ALTER TABLE actions ADD COLUMN due_date DATE;
ALTER TABLE actions ADD COLUMN priority TEXT DEFAULT 'medium'
  CHECK (priority IN ('high', 'medium', 'low'));
```

### 3.3 Auth & permissions

| Rôle | Voir | Modifier actions | Modifier statut | Commenter | Créer actions |
|------|------|-----------------|----------------|-----------|--------------|
| Client (Aurélia/Laurie) | Tout le portail | Non | Oui | Oui | Non |
| Admin (Catherine) | Tout + tous les clients | Oui | Oui | Oui | Oui |

RLS Supabase : `client_id = auth.uid()` pour les clients, `is_admin()` pour Catherine.

---

## 4. Ce qu'on ne fait PAS dans le MVP

| Feature | Pourquoi non |
|---------|-------------|
| Drag & drop Kanban | Complexité front disproportionnée. Les boutons de statut suffisent. |
| Gantt interactif | Aurélia n'est pas chef de projet. La timeline en lecture suffit. |
| Notifications push | Overkill pour 2 utilisatrices. WhatsApp suffit. |
| Chat intégré | WhatsApp existe. Ne pas réinventer. |
| Multi-client dashboard Catherine | V2.1, pas MVP. Catherine regarde Supabase directement. |
| Import/export données | Manuel via SQL pour l'instant. |
| Rôles granulaires | 2 rôles suffisent : client et admin. |

---

## 5. Écrans détaillés

### 5.1 Dashboard (page d'accueil)

```
┌─────────────────────────────────────────────┐
│ CS Consulting Stratégique                    │
│ Bonjour Aurélia 👋                          │
│ Clarté & Autonomie — 4/19 séances           │
│ ████████░░░░░░░░░░░░ 21%                    │
├─────────────────────────────────────────────┤
│ 📅 Prochaine séance : 24 mars 10h           │
│ Focus : Validation parcours clients + Circle │
├─────────────────────────────────────────────┤
│ ⚡ CETTE SEMAINE                             │
│ 🔴 Prendre la main sur VA Anam     [Laurie] │
│    ○ À faire  ● En cours  ○ Bloqué  ○ Fait  │
│ 🔴 Explorer Circle Business        [Laurie] │
│    ○ À faire  ● En cours  ○ Bloqué  ○ Fait  │
│ 🟠 Réécrire page vente MTM 2900€ [Aurélia] │
│    ● À faire  ○ En cours  ○ Bloqué  ○ Fait  │
├─────────────────────────────────────────────┤
│ 📊 PROGRESSION                               │
│ Phase 0 — Ancrage ████████░░ 3/5            │
│ Phase 1 — FSY Studio ░░░░░░░░░░ 0/5        │
│ Phase 2 — MTM + Brevo ░░░░░░░░░░ 0/5       │
│ Phase 3 — Autonomie ░░░░░░░░░░ 0/4         │
└─────────────────────────────────────────────┘
```

### 5.2 Actions (liste filtrée)

```
┌─────────────────────────────────────────────┐
│ Filtres :                                    │
│ [Tous] [À faire] [En cours] [Bloqué] [Fait] │
│ [Aurélia] [Laurie] [Catherine]              │
│ [FSY Studio] [MTM] [Del Sol] [Transverse]   │
├─────────────────────────────────────────────┤
│ PHASE 0 — Ancrage & migrations (3/5)        │
│                                              │
│ ☐ Mapper les 3 parcours clients             │
│   Catherine · 🔴 Haute · Transverse         │
│   ○ À faire  ○ En cours  ○ Bloqué  ○ Fait  │
│   💬 1 commentaire                           │
│                                              │
│ ☐ Lancer migration vidéos → Bunny           │
│   Laurie · 🔴 Haute · Transverse            │
│   ○ À faire  ● En cours  ○ Bloqué  ○ Fait  │
│   💬 "VA Anam a démarré, 120 vidéos faites" │
│                                              │
│ ...                                          │
├─────────────────────────────────────────────┤
│ PHASE 1 — Process FSY Studio (0/5)          │
│ ...                                          │
└─────────────────────────────────────────────┘
```

### 5.3 Timeline

```
┌─────────────────────────────────────────────┐
│ 🗓 TIMELINE — Clarté & Autonomie            │
│                                              │
│ Mars  Avr   Mai   Juin  Juil  Août          │
│ ├─────┼─────┼─────┼─────┼─────┤            │
│ ▲                                            │
│ Aujourd'hui                                  │
│                                              │
│ Phase 0 ██████░░                    3/5 ✓   │
│ Ancrage & migrations                         │
│ Mars — Avril                                 │
│                                              │
│ Phase 1 ░░░░░░░░░░                  0/5     │
│ Process FSY Studio                           │
│ Avril — Mai                                  │
│                                              │
│ Phase 2 ░░░░░░░░░░                  0/5     │
│ Process MTM + Brevo                          │
│ Mai — Juin                                   │
│                                              │
│ Phase 3 ░░░░░░░░░░                  0/4     │
│ Autonomie & Premium                          │
│ Juin — Août                                  │
│                                              │
│ ── Jalons clés ──                            │
│ 🔴 Mai : Communication migration membres    │
│ 🔴 Juin : Fermeture Uscreen                 │
│ 🟠 Juillet : MTM evergreen 1er lancement    │
│ ✅ Août : Bilan & plan de continuité         │
└─────────────────────────────────────────────┘
```

---

## 6. Données FSY à migrer (quand prêt)

| Table | Nb entrées | Source |
|-------|-----------|--------|
| profiles | 3 | Aurélia, Laurie, Catherine |
| actions | 19 | Feuille de route V2 |
| sessions | 4 | Historique sessions 1-4 |
| tutos | 6 | Dashboard KPI, Process formation, Écosystème, Miro, Feuille de route, CR session 4 |
| contracts | 1 | 8 000 € TTC, 3 échéances |
| action_comments | 0 | Vide au départ |

---

## 7. Priorité de développement

| Sprint | Quoi | Durée estimée |
|--------|------|--------------|
| **Sprint 1** | Auth Supabase + profils + actions avec statuts (4 états) + filtres | 2-3 jours |
| **Sprint 2** | Timeline progression + dashboard "ma semaine" | 1-2 jours |
| **Sprint 3** | Commentaires par action + onglets tutos/sessions/contrat | 1-2 jours |
| **Sprint 4** | Migration données FSY + déploiement espace.csbusiness.fr | 1 jour |
| **V2.1** | Dashboard multi-clients Catherine, brain dump, notifications | Plus tard |

---

## 8. Questions ouvertes (à trancher)

1. **Aurélia et Laurie ont-elles le même compte ?** Ou 2 logins séparés ? (implication : 2 profils Supabase, RLS différent)
2. **Catherine édite depuis le portail ou depuis Supabase ?** Si portail → il faut un mode admin. Si Supabase → plus simple mais moins fluide.
3. **Les tutos restent en HTML externe ou intégrés ?** HTML externe = simple, intégré = plus pro mais plus de dev.
4. **Domaine** : on garde `espace.csbusiness.fr` ? Redirection vers l'app Lovable ?
5. **Les CR de session** : page dans l'app ou lien vers HTML externe ?

---

## 9. Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Scope creep → "et si on ajoutait..." | Retarde le lancement | Règle : MVP d'abord, on itère après |
| Catherine dev au lieu de consulter | Perte de CA | Time-boxer : max 2h/jour de dev |
| Aurélia/Laurie n'utilisent pas | Effort perdu | Valider l'UX en session 5 avant de dev |
| Stack Lovable limitée | Fonctionnalité manquante | Avoir un plan B (React custom) |
