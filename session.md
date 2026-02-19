# Session — kescomminges.fr OFN

_Dernière mise à jour : 2026-02-19_

## Résumé des échanges récents

### 2026-02-19 — Session 1
- Discussion sur la perte de contexte avec opencode (Ctrl+C accidentels)
  → Recommandation : utiliser `tmux new -s kescomminges`
- Mise en place du système session.md + instruction commit+push systématique dans CLAUDE.md

### 2026-02-19 — Session 2
- Erreur 500 sur /contact diagnostiquée et corrigée
  - Cause : `ContactController < ApplicationController` n'incluait pas `Spree::Core::ControllerHelpers::Order`
  - Le layout darkswarm rend `_cart_sidebar.html.haml` qui appelle `current_order` → méthode absente
  - Fix : ajout de `include Spree::Core::ControllerHelpers::Order` dans ContactController
  - Commit : `01ae84c25c` — poussé sur kesco_custom1
  - **À faire sur le serveur** : `bin/deploy deploy` pour déployer le fix

## Todos en cours

- [ ] Déployer le fix /contact sur le serveur : `bin/deploy deploy`

## Tâches TODO connues (backlog projet)

- [ ] Branding : remplacer couleurs dans les fichiers SCSS (`$brand-colour`, `$ofn-brand`)
- [ ] Branding : remplacer logos dans `public/default_images/`
- [ ] Traductions : remplacer ~40 occurrences "CoopCircuits" → "Kescomminges" dans `config/locales/fr.yml`
- [ ] Traductions : remplacer ~15 occurrences "Open Food Network"/"OFN" dans `config/locales/en_FR.yml`
