# WoWAddon — pack Forever

Addons pour la beta **World of Warcraft: Forever** (client Mainline 12.1.5, game type Camelot, désarmement Midnight).

## 1. LumièreUI — patte Paladin (addon principal)

Skin de l’interface de base : chrome or, sceau sacré (croix pattée), palettes **Sacré / Protection / Vindicte**.

- Cadres joueur / cible, barres d’actions, minimap, chat, tooltips, incantation, panneaux
- Gryphons remplacés par le sceau Paladin
- Aucune logique de combat (pas de lecture de PV/auras pour décider)

| Commande | Action |
| --- | --- |
| `/lumiere` | Options |
| `/lumiere holy` | Palette Sacré (or) |
| `/lumiere prot` | Palette Protection (argent) |
| `/lumiere ret` | Palette Vindicte (or et cramoisi) |
| `/lumiere auto` | Palette selon la spé |
| `/lumiere debug` | Dump client / cadres (à coller si le skin ne se voit pas) |

## 2. ForeverKit — qualité de vie

Réparation, coords, tooltips, chat, durabilité, mail, XP, loot, or. Voir le détail plus bas.

## Installation

1. Battle.net → **WoW: Forever Beta** → engrenage → **Afficher dans l’explorateur**.
2. Copier **les deux dossiers** `LumiereUI` et `ForeverKit` dans :

```
World of Warcraft\_forever_\Interface\AddOns\
```

(ou `_camelot_` si le dossier client s’appelle encore ainsi)

3. Chaque dossier doit contenir son `.toc` à la racine (`LumiereUI\LumiereUI.toc`).
4. Relancer. Cocher les addons. S’ils sont « obsolètes » : charger les addons périmés, puis `/fk debug`.

---

### ForeverKit — commandes

| Commande | Action |
| --- | --- |
| `/fk` | Aide |
| `/fk options` | Réglages |
| `/fk debug` | Diagnostic client (TOC, build, carte) |
| `/fk coords` | Coordonnées |
| `/fk copy` | Copier le chat |
| `/fk gold` | Or de la session |
| `/fk reload` | Recharger l’UI |

### ForeverKit — modules

Vendeur, carte, infobulles, chat, erreurs, durabilité, courrier, XP, minimap, caméra, butin, or. Social (auto-invit) **off** par défaut.

## Compatibilité

- TOC : `16001` (Forever Beta) et `120105` (Mainline 12.1.5)
- Secrets Midnight : pas de WeakAuras, rotations, marks auto

## Plan

[ROADMAP.md](ROADMAP.md) — après la 1re session, coller `/fk debug` pour caler le numéro d’interface.
