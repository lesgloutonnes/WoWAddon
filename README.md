# WoWAddon — ForeverKit

Pack d’addons **qualité de vie** pour la beta **World of Warcraft: Forever** (17 septembre 2026).

Forever tourne sur l’architecture UI Mainline (patch **12.1.5**), game type interne **Camelot**, avec le **désarmement d’addons Midnight** (valeurs secrètes, AuraContainer). Ce pack ne fait **aucune logique de combat** : pas de WeakAuras, pas de rotations, pas de marks auto.

## Installation (ce soir)

1. Dans le launcher Battle.net, sélectionner **WoW: Forever Beta** → icône d’engrenage → **Afficher dans l’explorateur**.
2. Copier le dossier `ForeverKit` dans :

```
World of Warcraft\_forever_\Interface\AddOns\ForeverKit
```

Si le dossier client s’appelle encore Camelot :

```
World of Warcraft\_camelot_\Interface\AddOns\ForeverKit
```

3. Le chemin final doit contenir `ForeverKit\ForeverKit.toc` (pas un dossier en trop).
4. Relancer le client. À l’écran de sélection des personnages, bouton **AddOns** → cocher ForeverKit. Si « obsolète », cocher **Charger les addons périmés** et envoyer la sortie de `/fk debug`.

## Commandes

| Commande | Action |
| --- | --- |
| `/fk` | Aide |
| `/fk options` | Réglages (Échap → Options → AddOns) |
| `/fk debug` | Diagnostic client (TOC, build, carte, secrets) — **à coller après la 1re session** |
| `/fk coords` | Coordonnées actuelles |
| `/fk copy` | Copier le chat de la fenêtre 1 |
| `/fk gold` | Or de la session |
| `/fk reload` | Recharger l’UI |

Le compartiment d’addons de la minimap ouvre aussi les options.

## Modules (tous désactivables)

| Module | Par défaut | Rôle |
| --- | --- | --- |
| Vendeur | on | Réparation auto, vente des gris |
| Carte | on | Coordonnées carte + minimap |
| Infobulles | on | Prix vendeur, ID d’objet (utile en beta) |
| Chat | on | Horodatage, couleurs de classe, `/fk copy` |
| Erreurs | on | Filtre mana/énergie/rage/CD |
| Durabilité | on | % global + alerte < 25 % |
| Courrier | on | Bouton « Tout prendre » (ignore les COD) |
| XP | on | XP + bonus reposé |
| Minimap | on | Zoom molette |
| Caméra | on | Distance max |
| Butin | on | Loot plus rapide si auto-loot |
| Or | on | Gain/perte de session (`/fk gold`) |
| Social | **off** | Auto-accept invits amis / guilde |

## Compatibilité API

- TOC : `16001` (Forever Beta d’après Warcraft Wiki) **et** `120105` (Mainline 12.1.5)
- Fichiers : `ForeverKit.toc`, `ForeverKit_Camelot.toc`, `ForeverKit_Mainline.toc`
- APIs : `C_Item`, `C_Container`, `C_Map`, `Settings`, `TooltipDataProcessor`
- Secrets : aucune branche sur PV, auras, ou identités d’unités en combat

## Ce que ce pack ne fera pas

Blizzard bloque les addons « computationnels » de combat sur Forever comme sur Midnight. Pas de WeakAuras, Hekili, marks auto, sync d’assignments, ni parse de fight.

## Plan

Voir [ROADMAP.md](ROADMAP.md). Après ta première soirée : `/fk debug` + Lua errors → on ajuste le numéro d’interface et on priorise les modules suivants.
