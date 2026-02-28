# Session — kescomminges.fr OFN

_Dernière mise à jour : 2026-02-28_

## Résumé des échanges récents

### 2026-02-19 — Session 1
- Discussion sur la perte de contexte avec opencode (Ctrl+C accidentels)
  → Recommandation : utiliser `tmux new -s kescomminges`
- Mise en place du système session.md + instruction commit+push systématique dans CLAUDE.md

### 2026-02-19 — Session 2
- Erreur 500 sur /contact diagnostiquée et corrigée
  - Cause : `ContactController` n'incluait pas `Spree::Core::ControllerHelpers::Order`
  - Fix : ajout de `include Spree::Core::ControllerHelpers::Order`
  - Commit : `01ae84c25c`

### 2026-02-19 — Session 3
- Création de `bin/test_smtp` — outil de debug SMTP autonome (sans Rails)
  - Lit la config depuis `.env` automatiquement
  - Supporte les options --host, --port, --user, --pass, --from, --to, --tls, --ssl, --verbose
  - Mode --sidekiq pour tester via ActionMailer/Sidekiq
  - Commit : `6ba69d4738`
  - Config actuelle .env : MAIL_HOST=s-entraider.net, port 587, TLS, user=ne-pas-repondre@s-entraider.net
  - Objectif : trouver la config OVH pour contact@kescomminges.fr

### 2026-02-20 — Session 4
- Pages légales `/conditions-utilisation` et `/mentions-legales` corrigées et opérationnelles
  - Fix 1 : `legal:build` générait du HAML avec heredoc invalide → migré vers `.html.erb` (commit `e196951eb1`)
  - Fix 2 : `LegalController` héritait de `ApplicationController` au lieu de `BaseController`
    → `current_order` manquant dans le layout darkswarm (commit `4ab1a12cf7`)

### 2026-02-20 — Session 5
- Discussion modèle économique Kescomminges :
  - Structure juridique envisagée : SARL de famille (option IR possible au démarrage)
  - Compta : dougs.fr (service en ligne)
  - Modèle achat-revente validé pour le point relais (produits emballés uniquement, ex. viande sous vide)
  - Marges prévues :
    - 2,5% HT sur les ventes pour utilisation de la plateforme (facturé aux enterprises utilisatrices)
    - 3,5% HT pour le retrait au point relais Kescomminges
    - Total 6% pour les clients du point relais Kescomminges
  - Facturation des 2,5% aux enterprises : manuelle (mensuelle sur la base des ventes)
  - Analyse OFN : pas de mécanisme natif de "fee plateforme globale"
    → Pour l'instant : gestion manuelle (attacher la fee manuellement à chaque cycle)
    → À terme : développer une fee automatique (branche séparée, pas urgent)

### 2026-02-22 — Session 6
- **Migration KESCOMMINGES/ hors du dépôt OFN**
  - Problème : git-crypt irrécupérable sur serveur prod après push de nouveaux blobs chiffrés
  - Solution : dossier KESCOMMINGES/ migré vers dépôt privé séparé `github.com/kescomminges/KESCOMMINGES`
  - Règle `KESCOMMINGES/** filter=git-crypt` retirée de `.gitattributes`
  - `KESCOMMINGES/` retiré du dépôt OFN (commit `93a526dea6`)
  - Dépôt KESCOMMINGES initialisé et poussé sur GitHub (branche `main`)

- **Tracts PDF — nombreuses améliorations**
  - Format A5 portrait (était A4) — correction dans le script ET dans le CSS
  - Footer collé en bas : `.page { position:relative; height:210mm }` + `.footer { position:absolute; bottom:0 }`
  - Bullets ronds : cercle sorti du `table-cell` → `<span>` `inline-block` avec `width/height:18px` + `border-radius:50%`
  - Texte corps : `#adfcf9` (cyan clair illisible) → `#1a1a1a` (quasi-noir)
  - `kescomminges` tout en minuscules partout (HTML + variables.yml)
  - Délai commande : "avant le mardi midi" (au lieu de mercredi matin)
  - Frais : 6% HT tout compris (clients), 3,5% HT (producteurs), 2,5% HT (boutique)
  - "(phase 1)" supprimé du tract producteurs
  - Reformulation projet : "réseau de proximité ancré dans le territoire"
  - "L'Isle-en-Dodon" sans le (31)
  - Paiement comptant à la livraison (au lieu de "paiement sécurisé en ligne")
  - Produits simplifiés : Viandes, Fromages, Fruits & légumes, Boissons, Épicerie
  - **Poiscaille** : "Poisson *" dans la grille + note `* Commande directe sur poiscaille.fr.`

### 2026-02-24 — Session 7

- **Prod bloquée après git pull** : branches divergées sur master
  - Cause : `git pull` sans stratégie définie → `fatal: Need to specify how to reconcile divergent branches`
  - Fix : `git reset --hard origin/kesco_custom1` sur la prod

- **Rebase interrompu sur la prod** : état `interactive rebase in progress`
  - Fix : `git rebase --abort` puis `git checkout kesco_custom1`

- **KESCOMMINGES/.env avec nouveaux mots de passe** non pushé
  - Pull rebase + push depuis la machine locale → résolu

- **`.env.dev` bloquait systématiquement les rebases**
  - Cause : commit `0bac58a9cf` versionnait `.env.dev` (chiffré git-crypt), mais le fichier existait déjà comme symlink non tracké sur le serveur
  - Solution : `git filter-repo --path .env.dev --invert-paths --refs kesco_custom1 --force`
  - `.env.dev` retiré de tout l'historique de `kesco_custom1` en une passe
  - Force-push sur `origin/kesco_custom1`
  - Confirmé : le contenu était chiffré git-crypt (binaire illisible), aucun secret en clair dans l'historique

- **`./bin/deploy update --env dev`** : rebase sur `v5.4.3` réussi après reset --hard sur la prod
- **Les deux instances** (prod + dev) opérationnelles et à jour

### 2026-02-25 — Session 8

- **GitHub Actions désactivées** sur le fork kescomminges
  - Les builds échouaient (secrets CI manquants : `KNAPSACK_PRO_TEST_SUITE_TOKEN` etc.)
  - Pas critique pour une instance perso sans CI collaborative
  - Solution : suppression des 5 fichiers `.github/workflows/` (build, linters, stage, auto-author-assign, move-dependency-pr)
  - Commit : `c10bf7163c`

### 2026-02-27 — Session 9

- **Vérification du contexte** — lecture session.md et état du projet
  - Tout bon, prêt à bosser demain
  - Langue de communication : français confirmé

### 2026-02-28 — Session 10

- **Implémentation Plan — Basculement domaine e-commerce vers kesco.fr**
  - Décision stratégique : plateforme OFN = `kesco.fr` (court, mémorisable)
  - `kescomminges.fr` réservé pour vitrine phase 2 (conserverie/atelier)
  - Dénomination légale SARL : **KESCOMMINGES** (inchangé)
  - Emails :
    - `contact@kesco.fr` → commerce (clients, commandes OFN)
    - `contact@kescomminges.fr` → legal (comptable, partenaires institutionnels)

  **Modifications dans dépôt KESCOMMINGES (privé) :**
  - `variables.yml` : site `kescomminges.fr` → `kesco.fr`, email commerce + ajout email_legal
  - `.env` (prod) : SITE_URL, SITE_NAME, SMTP_USERNAME, MAILS_FROM, SCHEDULE_NOTIFICATIONS
  - `.env.dev` : SITE_URL, SITE_NAME
  - `CLAUDE.md` : update documentation (site url, email)
  - Commit : `chore: basculement domaine principal kesco.fr (e-commerce)`
  - Push sur `github.com/kescomminges/KESCOMMINGES` ✅

  **Modifications dans dépôt OFN (public) :**
  - `CLAUDE.md` : section "Configuration de l'instance (.env)"
  - Commit : `docs: mise à jour CLAUDE.md — domaine principal kesco.fr`
  - Push sur `github.com/kescomminges/openfoodnetwork` ✅

  **Prérequis avant déploiement (hors code) :**
  - ⚠️ Créer boîte `contact@kesco.fr` chez OVH (SMTP)
  - ⚠️ Pointer DNS `kesco.fr` vers serveur
  - Redirection `kescomminges.fr` → `kesco.fr` (après switch)
  - Ajouter `kesco.fr` dans Plausible Analytics

## Todos en cours

- [ ] **Créer boîte `contact@kesco.fr` chez OVH** (avant déploiement)
- [ ] **Pointer DNS `kesco.fr` vers le serveur** (avant déploiement)
- [ ] Tester SMTP de la nouvelle boîte `contact@kesco.fr` avec `bin/test_smtp`
- [ ] Déployer sur prod : `bin/deploy update` depuis `kesco_custom1`
- [ ] Ajouter `kesco.fr` dans Plausible Analytics (interface)
- [ ] Mettre en place redirection `kescomminges.fr` → `kesco.fr` (Nginx ou DNS)
- [ ] Contacter Poiscaille pour formaliser le partenariat point relais

## Tâches TODO connues (backlog projet)

- [ ] Juridique : rédiger CGV B2B pour les enterprises utilisant la plateforme (distinct des CGU acheteurs)
- [ ] Branding : remplacer couleurs dans les fichiers SCSS (`$brand-colour`, `$ofn-brand`)
- [ ] Branding : remplacer logos dans `public/default_images/`
- [ ] Traductions : remplacer ~40 occurrences "CoopCircuits" → "kescomminges" dans `config/locales/fr.yml`
- [ ] Traductions : remplacer ~15 occurrences "Open Food Network"/"OFN" dans `config/locales/en_FR.yml`

## Backlog développement (future branche feature)

- [ ] Fee plateforme automatique (branche séparée à créer)
  - Nouvelle préférence `Spree::Config.platform_fee_id`
  - Callback `after_create` sur `OrderCycle` pour attacher automatiquement la fee
  - Interface admin pour configurer la fee plateforme
  - Similaire en complexité à l'intégration Plausible
