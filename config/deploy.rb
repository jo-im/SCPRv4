DEPLOY_CONFIG = YAML.load_file(
  File.expand_path("../deploy_config.yml", __FILE__)
)

# --------------
# Requires and Multistage setup
set :thinking_sphinx_roles, :sphinx

require "bundler/capistrano"

set :stages, %w{ production staging }
set :default_stage, "production"
require 'capistrano/ext/multistage'


# --------------
# Universal Variables

set :application, "scprv4"
set :scm, :git
set :repository,  "git@github.com:SCPR/SCPRv4.git"
set :scm_verbose, true
set :deploy_via, :remote_cache
set :deploy_to, "/web/scprv4"
set :keep_releases, 5

set :user, "scprv4"
set :use_sudo, false
set :group_writable, false

set :maintenance_template_path, "public/maintenance.erb"
set :maintenance_basename, "maintenance"

# Pass these in with -s to override:
#    cap deploy -s force_assets=true
set :force_assets,  false # If assets wouldn't normally be precompiled, force them to be
set :skip_assets,   false # If assets are going to be precompiled, force them NOT to be
set :ts_index,      false # Staging only - Whether or not to run the sphinx index on drop
set :syncdb,        false # Staging only - Whether or not to run a dbsync to mercer_staging
set :restart_delay, 60


# --------------
# Universal Callbacks
before "deploy:assets:precompile", "deploy:symlink_config"
after "deploy:update", "deploy:cleanup"

# --------------
# Universal Tasks
namespace :deploy do
  task :symlink_config do
    %w{ database.yml api_config.yml app_config.yml thinking_sphinx.yml newrelic.yml }.each do |file|
      run "ln -nfs #{shared_path}/config/#{file} #{release_path}/config/#{file}"
    end
  end
end
