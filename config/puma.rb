# config/puma.rb — Configuration Puma pour Kescomminges OFN
# Production : écoute uniquement sur localhost (derrière nginx)

workers ENV.fetch("WEB_CONCURRENCY") { 2 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Écoute uniquement sur localhost — nginx fait office de reverse proxy
bind "tcp://127.0.0.1:3000"

environment ENV.fetch("RAILS_ENV") { "production" }

app_dir = File.expand_path("..", __dir__)

pidfile    "#{app_dir}/tmp/pids/puma.pid"
state_path "#{app_dir}/tmp/pids/puma.state"

directory app_dir

# Précharge l'application avant de forker les workers (économise la mémoire)
preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Permet à systemd de détecter que Puma est prêt (gem sd_notify)
plugin :tmp_restart
