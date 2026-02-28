# frozen_string_literal: true

# config/initializers/kesco.rb
#
# Personnalisations Kescomminges centralisées
# Ce fichier est le SEUL point d'entrée des customisations dans le code upstream.
# Routes et préférences sont injectées sans modifier les fichiers upstream.
#
# Structure du fichier :
# 1. Préférences Plausible Analytics
# 2. Routes Kescomminges (contact, pages légales)
# 3. Routes admin (Plausible settings)

# === Préférences Plausible Analytics ===
# Préférences stockées dans Spree::Config :
# - plausible_domain : domaine tracké (ex: 'kescomminges.fr')
# - plausible_script_url : URL complète du script JS Plausible
Rails.application.reloader.to_prepare do
  Spree::AppConfiguration.class_eval do
    preference :plausible_domain, :string, default: nil
    preference :plausible_script_url, :string, default: nil
  end
end

# === Routes Kescomminges ===
# Formulaire de contact et pages légales
# Routes injectées dynamiquement sans modifier config/routes.rb
Rails.application.reloader.to_prepare do
  Openfoodnetwork::Application.routes.append do
    # Formulaire de contact
    get  '/contact', to: 'contact#show',   as: :contact
    post '/contact', to: 'contact#submit', as: :contact_submit

    # Pages légales
    get '/conditions-utilisation', to: 'legal#cgu',               as: :legal_cgu
    get '/mentions-legales',       to: 'legal#mentions_legales',   as: :legal_mentions_legales
  end
end

# === Routes admin Plausible ===
# Configuration Plausible Analytics dans le backoffice admin
Rails.application.reloader.to_prepare do
  Openfoodnetwork::Application.routes.append do
    namespace :admin do
      resource :plausible_settings, only: [:edit, :update]
    end
  end
end
