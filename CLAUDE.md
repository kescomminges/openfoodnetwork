# claude.md — Documentation de l'instance kescomminges.fr

Ce fichier documente les décisions d'architecture, les personnalisations et les procédures de maintenance
de l'instance Open Food Network déployée pour kescomminges.fr.

## Instruction pour Claude

**Au début de chaque session**, lire `session.md` (s'il existe) pour reprendre le contexte.
**Après chaque réponse**, mettre à jour `session.md` avec :
- Le résumé de ce qui a été fait dans cet échange
- L'état des todos en cours (non terminés)

**Après chaque modification de fichier**, commiter et pousser immédiatement :
```bash
git add -A
git commit -m "message court et descriptif"
git push origin HEAD
```

---

## Contexte

**Instance :** kescomminges.fr
**Objet :** Point relais direct producteur — marketplace alimentaire locale (Comminges, France)
**Licence :** AGPL-3.0 (toute modification du code source doit être publiée)
**Basé sur :** [openfoodfoundation/openfoodnetwork](https://github.com/openfoodfoundation/openfoodnetwork)
**Instance de référence FR :** [coopcircuits.fr](https://coopcircuits.fr) (instance nationale française)

### Pourquoi une instance propre ?

CoopCircuits.fr prend 3.5% HT sur toutes les ventes. En opérant notre propre instance,
nous contrôlons nos frais de plateforme et notre branding, tout en bénéficiant du logiciel libre OFN.

---

## Architecture du projet

### Stack technique

| Couche | Technologie |
|---|---|
| Ruby | 3.4.x (voir `.ruby-version`) |
| Rails | 7.1 |
| Base de données | PostgreSQL 16 |
| Cache / Jobs | Redis + Sidekiq |
| Serveur web | Puma |
| Build JS | Shakapacker 8 (Webpack 5) |
| Frontend public | AngularJS 1.8 "Darkswarm" (en migration vers Hotwire/Stimulus) |
| Frontend moderne | Stimulus, Turbo, StimulusReflex |
| CSS | SCSS + Foundation 5 |
| Vues | HAML + ViewComponents |
| Tests | RSpec + Capybara + FactoryBot + Jest |

### Patterns utilisés

- **Service Objects** → `app/services/`
- **Query Objects** → `app/queries/`
- **Form Objects** → `app/forms/`
- **ViewComponents** → `app/components/`
- **4 engines Rails** : `catalog`, `order_management`, `dfc_provider`, `web`
- La fondation e-commerce est **Spree** (intégré directement dans le code source)

### Modèles de données centraux

- `Enterprise` — entité centrale (producteur, hub ou les deux)
- `OrderCycle` — fenêtre temporelle d'ouverture des commandes
- `Exchange` — liaison fournisseur/distributeur dans un cycle
- `Subscription` / `Schedule` / `ProxyOrder` — abonnements récurrents (AMAP)
- `EnterpriseFee` — frais configurables par enterprise et par cycle
- `VariantOverride` — écrasements de prix/stock par hub
- `Voucher` — bons de réduction
- `Customer` — client lié à une enterprise
- Spree : `Order`, `Product`, `Variant`, `Payment`, `Shipment`, `Adjustment`...

---

## Stratégie Git

```
openfoodfoundation/openfoodnetwork  ← upstream (officiel)
        ↓  fork
votre-org/openfoodnetwork           ← origin (votre fork)
```

### Remotes configurés

```bash
git remote -v
# origin   git@github.com:VOTRE-ORG/openfoodnetwork.git (fetch/push)
# upstream https://github.com/openfoodfoundation/openfoodnetwork (fetch)
```

### Mettre à jour depuis l'upstream officiel

```bash
git fetch upstream
git rebase upstream/master
# Résoudre les conflits éventuels sur les fichiers personnalisés
git push origin master --force-with-lease
```

### Règle AGPL importante

Toute modification du code source **doit être publiée** (rendu public sur le fork GitHub).
Les personnalisations via variables d'environnement et interface admin ne sont pas du code source
et n'ont pas d'obligation de publication.

---

## Branding Kescomminges

### Couleurs

| Usage | Couleur |
|---|---|
| Couleur principale (`$brand-colour`, `$ofn-brand`) | `#45602e` (vert foncé) |
| Couleur secondaire | `#ca693c` (orange) |

### Fichiers SCSS à modifier (TODO)

| Fichier | Variable | Valeur actuelle → Cible |
|---|---|---|
| `app/webpacker/css/darkswarm/variables.scss` | `$brand-colour` | `#f27052` → `#45602e` |
| `app/webpacker/css/darkswarm/branding.scss` | `$ofn-brand` | `#f27052` → `#ca693c` |
| `app/webpacker/css/admin_v3/globals/palette.scss` | palette | tons verts/oranges |

### Logos (TODO — en attente de finalisation)

Remplacer les 4 fichiers dans `public/default_images/` :

```
public/default_images/ofn-logo.png         → logo principal couleur
public/default_images/ofn-logo-footer.png  → logo blanc/clair pour footer
public/default_images/ofn-logo-mobile.svg  → logo mobile SVG
public/                favicon.ico          → favicon
```

Formats nécessaires : PNG (logo couleur), PNG blanc (sur fond sombre), SVG mobile.

### Textes et traductions (TODO)

Le fichier `config/locales/fr.yml` contient ~40 occurrences de "CoopCircuits" à remplacer par "Kescomminges".
Zones critiques :
- Ligne 476 : `title: "CoopCircuits"` → `"Kescomminges"` (affiché dans tous les titres)
- Lignes 2191-2201 : footer
- Lignes 408-414 : emails de bienvenue enterprise
- Lignes 1469, 1515-1552 : formulaires d'inscription
- Lignes 2357-2381 : section cookies
- Ligne 3374 : objet des commandes par email

Le fichier `config/locales/en_FR.yml` contient ~15 occurrences "Open Food Network"/"OFN" à remplacer.

### Configuration admin (via interface, pas de code)

Une fois l'instance lancée, configurer dans l'admin :
- Logo header, logo footer, image hero → `ContentConfiguration`
- Liens réseaux sociaux du footer
- Email de contact
- CGU (upload PDF) + activer `shoppers_require_tos`
- URL politique de confidentialité → `Spree::Config.privacy_policy_url`
- Activer le bandeau cookies si besoin

---

## Configuration de l'instance (.env)

Variables d'environnement à définir pour la France :

```bash
SITE_NAME="Kescomminges"
SITE_URL="kescomminges.fr"
TIMEZONE="Paris"
DEFAULT_COUNTRY_CODE="FR"
LOCALE="fr"
AVAILABLE_LOCALES="fr,en"
CURRENCY="EUR"
CHECKOUT_ZONE="France"   # ou "European Union" selon la config TVA

MAIL_HOST="..."
MAIL_DOMAIN="kescomminges.fr"
MAILS_FROM="hello@kescomminges.fr"

# Stripe (si activé)
# STRIPE_INSTANCE_SECRET_KEY=...
# STRIPE_INSTANCE_PUBLISHABLE_KEY=...

# S3 (si activé)
# S3_BUCKET=...
# S3_ACCESS_KEY=...
```

---

## Frais de plateforme

Sur notre instance, les frais Enterprise sont configurés à 0% (ou au taux choisi pour couvrir
les coûts d'hébergement). Configurable dans l'admin → Frais d'enterprise.

Sur CoopCircuits.fr, ces frais sont à 3.5% HT — c'est la raison d'être de notre instance propre.

---

## Personnalisations réalisées

### 1. Intégration Plausible Analytics

**Date :** 2026-02
**Motivation :** Monitoring du trafic via notre instance Plausible self-hosted (`plausible.s-entraider.net`).
Plausible est une alternative privacy-first à Google Analytics, sans cookies tiers.

**Architecture** (calquée sur l'intégration Matomo existante) :

| Élément | Fichier |
|---|---|
| Préférences | `app/models/spree/app_configuration.rb` (lignes autour de 120) |
| Partial d'injection | `app/views/layouts/_plausible_tag.html.haml` |
| Contrôleur admin | `app/controllers/admin/plausible_settings_controller.rb` |
| Vue admin | `app/views/admin/plausible_settings/edit.html.haml` |
| Route | `config/routes/admin.rb` → `resource :plausible_settings` |
| Menu admin | `app/views/spree/admin/shared/_configuration_menu.html.haml` |
| Layouts | `darkswarm.html.haml`, `registration.html.haml`, `_admin_body.html.haml` |
| Spec | `spec/controllers/admin/plausible_settings_controller_spec.rb` |

**Préférences stockées dans `Spree::Config` :**
- `plausible_script_url` — URL complète du script JS Plausible
  (ex: `https://plausible.s-entraider.net/js/script.file-downloads.hash.outbound-links.js`)
- `plausible_domain` — domaine tracké (ex: `kescomminges.fr`)

**Snippet Plausible de référence (notre instance) :**
```html
<script defer data-domain="kescomminges.fr"
  src="https://plausible.s-entraider.net/js/script.file-downloads.hash.outbound-links.js">
</script>
<script>
  window.plausible = window.plausible || function() {
    (window.plausible.q = window.plausible.q || []).push(arguments)
  }
</script>
```

**Accès admin :** Configuration → Plausible Analytics

**Suivi des navigations Turbo/SPA :**
Le fichier `app/webpacker/js/plausible.js` écoute les événements `turbo:load` et `ujs:afterMorph`
pour envoyer un `pageview` à chaque navigation côté client (même comportement que `matomo.js`).

---

## Gestion des secrets — git-crypt

Le dépôt est **public sur GitHub**. Les fichiers sensibles sont chiffrés avec
[git-crypt](https://github.com/AGWA/git-crypt) — ils apparaissent comme des
binaires illisibles sur GitHub mais sont déchiffrés automatiquement sur les
machines qui possèdent la clé.

### Fichiers chiffrés (déclarés dans `.gitattributes`)

| Fichier | Contient |
|---|---|
| `.env` | SMTP_PASSWORD, clés Stripe, clés AR encryption, etc. |
| `config/master.key` | Clé Rails credentials |
| `config/newrelic.yml` | Clé API NewRelic |

### Initialisation (une seule fois, sur la machine de dev)

```bash
# Installer git-crypt
sudo apt install git-crypt

# Initialiser dans le dépôt
git-crypt init

# Exporter la clé symétrique → stocker dans Bitwarden / KeePass
git-crypt export-key ~/kescomminges-ofn-secrets.key

# Le .env existant était en clair — le retirer du cache et recommiter
git rm --cached .env
git add .env .gitattributes
git commit -m "chore: encrypt .env with git-crypt"
git push origin kesco_custom1 --force-with-lease
```

> **⚠ Important :** changer le mot de passe SMTP (et tout autre secret présent
> dans l'historique git avant le chiffrement) — l'historique passé reste lisible.

### Déverrouiller sur le serveur (une seule fois)

```bash
# Installer git-crypt sur le serveur
sudo apt install git-crypt

# Copier la clé sur le serveur (via scp ou coller depuis Bitwarden)
scp ~/kescomminges-ofn-secrets.key kescomminges@serveur:~/

# Déverrouiller le dépôt
cd /home/kescomminges/ofn/openfoodnetwork
git-crypt unlock ~/kescomminges-ofn-secrets.key

# Supprimer la clé du serveur (elle est désormais dans .git/git-crypt/)
rm ~/kescomminges-ofn-secrets.key
```

Une fois déverrouillé, les `git pull` / rebases déchiffrent automatiquement.
Le dépôt reste déverrouillé de façon permanente sur cette machine.

### Ajouter un nouveau secret

```bash
# Éditer .env localement (déjà déverrouillé)
nano .env

# Commiter — git-crypt chiffre automatiquement
git add .env
git commit -m "chore: add new secret to .env"
git push origin kesco_custom1
```

### Intégration dans `bin/deploy`

Le script vérifie au démarrage que git-crypt est déverrouillé (étape 5 de
`preflight_checks`). Si ce n'est pas le cas, le déploiement est bloqué avec
le message :

```
✘ git-crypt non déverrouillé — les secrets sont inaccessibles
  → git-crypt unlock /chemin/vers/kescomminges-ofn-secrets.key
```

Après chaque rebase, le script force un `git checkout HEAD -- .env` pour
s'assurer que git-crypt a bien rejoué les filtres de déchiffrement.

---

## Procédures de maintenance

### Script de déploiement — `bin/deploy`

Toutes les opérations de déploiement et de mise à jour passent par le script `bin/deploy`,
versionné dans ce dépôt. Il doit être lancé depuis l'user qui possède le code
(ou un user dédié `deploy` avec les droits sudo appropriés).

#### Commandes disponibles

| Commande | Description |
|---|---|
| `bin/deploy status` | Affiche l'état : commit déployé, retard upstream, services, backups |
| `bin/deploy update` | Mise à jour complète depuis upstream (fetch → diff → confirmation → rebase → deploy) |
| `bin/deploy deploy` | Déploie le code courant sans toucher à git (post-rebase manuel) |
| `bin/deploy rollback` | Revient au commit avant le dernier déploiement |
| `bin/deploy backup` | Sauvegarde manuelle de la BDD PostgreSQL |
| `bin/deploy help` | Aide en ligne |

#### Flux `update` (usage normal — mise à jour OFN)

```
1. Vérifications pré-vol (espace disque, PostgreSQL, git propre, sudo)
2. git fetch upstream/master
3. Affichage des commits, fichiers modifiés, migrations, conflits potentiels
4. Confirmation interactive
5. Sauvegarde automatique de la BDD (backup horodaté dans ~/backups/ofn/)
6. git rebase upstream/master
   └─ En cas de conflit → abort + instructions manuelles
7. Push sur le fork (origin)
8. Déploiement :
   a. Vérification/installation Ruby (rbenv) si .ruby-version a changé
   b. Vérification/installation Node (nodenv) si .node-version a changé
   c. bundle install
   d. yarn install
   e. db:migrate (avec détection et confirmation si migration destructive)
   f. assets:precompile
   g. systemctl reload puma (ou restart) + restart sidekiq
   h. Health check HTTP (rollback automatique si échec)
```

#### Configuration du script

Éditez les variables en tête de `bin/deploy` :

```bash
APP_DIR="/home/kescomminges/ofn/openfoodnetwork"
PUMA_SERVICE="puma"        # ← à ajuster selon votre systemd
SIDEKIQ_SERVICE="sidekiq"  # ← à ajuster selon votre systemd
DB_NAME="openfoodnetwork_production"
DB_USER="ofn"
BACKUP_DIR="$HOME/backups/ofn"
BACKUP_KEEP=7              # nombre de backups à conserver
```

#### Configuration sudoers (si user dédié)

Si le script est lancé depuis un user différent du propriétaire du code,
créer `/etc/sudoers.d/deploy-ofn` :

```
deploy ALL=(root) NOPASSWD: /bin/systemctl restart puma
deploy ALL=(root) NOPASSWD: /bin/systemctl reload puma
deploy ALL=(root) NOPASSWD: /bin/systemctl restart sidekiq
```

#### Rollback

Un backup PostgreSQL est créé automatiquement avant chaque déploiement.
En cas d'échec du health check, le rollback git est automatique.
Le rollback de schéma BDD reste **manuel** (risque de perte de données) :

```bash
# Lister les backups disponibles
ls -lht ~/backups/ofn/

# Restaurer un backup
zcat ~/backups/ofn/pre-deploy-20260219-143022.sql.gz \
  | psql -h localhost -U ofn openfoodnetwork_production
```

#### Gestion automatique des versions Ruby/Node

Lors d'une mise à jour upstream, si `.ruby-version` ou `.node-version` changent,
le script détecte la nouvelle version requise et l'installe automatiquement via
`rbenv install` / `nodenv install` (avec mise à jour préalable de ruby-build/node-build).
rbenv et nodenv doivent être installés dans `$HOME` de l'user qui lance le script.

### Fichiers susceptibles d'avoir des conflits lors des rebases

Ces fichiers sont personnalisés et peuvent entrer en conflit avec les mises à jour upstream :

- `config/locales/fr.yml` (textes remplacés "CoopCircuits" → "Kescomminges")
- `app/models/spree/app_configuration.rb` (ajout préférences Plausible)
- `app/views/layouts/darkswarm.html.haml` (ajout `render "layouts/plausible_tag"`)
- `app/views/layouts/registration.html.haml` (ajout `render "layouts/plausible_tag"`)
- `app/views/spree/layouts/_admin_body.html.haml` (ajout `render "layouts/plausible_tag"`)
- `app/views/spree/admin/shared/_configuration_menu.html.haml` (entrée menu Plausible)
- `app/webpacker/css/darkswarm/variables.scss` (couleurs)
- `app/webpacker/css/darkswarm/branding.scss` (couleurs)

### Feature flags (Flipper)

Accès : `/admin/feature-toggle` (admin uniquement)

Features disponibles : `api_reports`, `api_v1`, `invoices`, `connected_apps`,
`match_shipping_categories`, `variant_tag`, `inventory`, etc.

### Monitoring

- **Plausible** : https://plausible.s-entraider.net (analytics trafic)
- **Sidekiq** : `/admin/sidekiq` (jobs en arrière-plan — admin uniquement)
- **Bugsnag** : erreurs en production (si configuré)
- **NewRelic** : APM (si configuré)

### Background jobs (Sidekiq)

Jobs planifiés automatiquement (via `config/sidekiq.yml`) :
- `HeartbeatJob` — monitoring de la file de jobs
- `SubscriptionPlacementJob` — création des commandes d'abonnement
- `OrderCycleClosingJob` — fermeture des cycles de commande à l'heure prévue

---

## Structure des fichiers clés

```
openfoodnetwork/
├── app/
│   ├── controllers/admin/          # Contrôleurs backoffice
│   ├── models/
│   │   ├── spree/app_configuration.rb  # Préférences globales de l'instance
│   │   └── content_configuration.rb    # Logos, liens footer, hero image
│   ├── views/
│   │   ├── layouts/
│   │   │   ├── darkswarm.html.haml     # Layout principal (frontend public)
│   │   │   ├── registration.html.haml  # Layout inscription
│   │   │   ├── _matomo_tag.html.haml   # Partial analytics Matomo
│   │   │   └── _plausible_tag.html.haml # Partial analytics Plausible (ajout custom)
│   │   ├── admin/
│   │   │   ├── matomo_settings/        # Config Matomo (existant)
│   │   │   └── plausible_settings/     # Config Plausible (ajout custom)
│   │   └── spree/
│   │       ├── layouts/_admin_body.html.haml  # Layout backoffice
│   │       └── admin/shared/
│   │           └── _configuration_menu.html.haml  # Menu Configuration admin
│   └── webpacker/
│       ├── css/darkswarm/
│       │   ├── branding.scss       # $ofn-brand (couleur principale)
│       │   └── variables.scss      # $brand-colour (couleur topbar)
│       ├── css/admin_v3/globals/
│       │   └── palette.scss        # Palette couleurs admin
│       ├── images/                 # Images (non servies directement en prod)
│       └── js/
│           ├── matomo.js           # Suivi navigation Turbo pour Matomo
│           └── plausible.js        # Suivi navigation Turbo pour Plausible (ajout custom)
├── config/
│   ├── locales/
│   │   ├── fr.yml                  # Textes FR (remplacer "CoopCircuits" → "Kescomminges")
│   │   └── en_FR.yml               # Textes EN pour FR (remplacer "Open Food Network" → "Kescomminges")
│   └── routes/admin.rb             # Routes backoffice
└── public/
    └── default_images/             # Logos servis statiquement (à remplacer)
        ├── ofn-logo.png
        ├── ofn-logo-footer.png
        └── ofn-logo-mobile.svg
```

---

## Ressources

- **Documentation officielle OFN :** https://guide.openfoodnetwork.org/
- **Communauté OFN :** https://community.openfoodnetwork.org/
- **Dépôt officiel :** https://github.com/openfoodfoundation/openfoodnetwork
- **Ansible (déploiement) :** https://github.com/openfoodfoundation/ofn-install
- **Transifex (traductions) :** https://www.transifex.com/open-food-foundation/open-food-network/
- **Plausible (notre instance analytics) :** https://plausible.s-entraider.net
