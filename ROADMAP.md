# Feuille de route ForeverKit

Beta Forever : **17 septembre 2026** (après le Q&A 10:30 PDT), cap niveau **20** puis **30**. Client Mainline 12.1.5, game type **Camelot**, désarmement Midnight actif.

## Phase 0 — Ce soir (livré)

Pack installable `ForeverKit` :

- Qualité de vie hors combat (vendeur, carte, tooltips, chat, durabilité, mail, XP, loot, or)
- `/fk debug` pour verrouiller le vrai numéro TOC du client beta
- Options natives, modules indépendants, FR / EN
- Aucune logique de combat (secrets / AuraContainer)

**À faire pendant la session :**

1. Installer, cocher l’addon, jouer 30–60 min
2. Copier `/fk debug` (build, TOC, locale, project ID, carte)
3. Noter les erreurs Lua (BugGrabber si tu en as, sinon screenshot)
4. Dire quels modules tu veux en priorité ensuite (quête, métiers, sacs, UI)

## Phase 1 — Calibrage client (après la 1re session)

Dépend du dump `/fk debug` :

- Corriger `## Interface:` si ce n’est ni `16001` ni `120105`
- Confirmer le dossier `_forever_` vs `_camelot_`
- Désactiver / corriger tout module qui error en masse
- Ajuster les templates UI (mail, copie chat, barre d’XP) si FrameXML Forever diffère

## Phase 2 — Classic+ QoL

À prio selon tes retours, toujours sans parse de combat :

- Suivi de quêtes (tracker plus lisible, pas un Questie complet d’emblée)
- Métiers : recettes connues, CD de craft si exposés hors secret
- Sacs : recherche, tri simple, restack
- Carte : notes de farm / coffres (données communautaires, pas de radar de mobs en combat)
- Groupe : prêt, rolls, marqueurs **manuels** uniquement
- Accessibilité : plus gros textes, contrastes, click-cast si l’API le permet encore

## Phase 3 — Présentation UI (pas de décision auto)

Uniquement ce que le UI de base affiche déjà, ré-habillé :

- Barres d’actions (visuel, pas de rotation)
- Nameplates / raid frames via **AuraContainer** (affichage, zéro branche Lua sur les auras secrètes)
- Caméra / Edit Mode presets Forever

## Hors scope (API Midnight / Forever)

- WeakAuras / Custom auras computationnelles
- Helpers de rotation (Hekili, etc.)
- Threat meters basés sur des secrets
- Marks / assignments automatiques en combat
- Sync addon privé en instance

## Découpage repo (plus tard)

Aujourd’hui : un seul addon modulaire, plus simple à coller dans `Interface/AddOns`.

Si le pack grossit : extraire `ForeverQuest`, `ForeverBags`, etc. avec `## Group: ForeverKit`.
