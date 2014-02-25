require 'new_relic/recipes'
require 'net/http'

# --------------
# Variables
set :branch, "master"
set :rails_env, "production"

# --------------
# Roles
web1  = "66.226.4.226"
web2  = "66.226.4.227"
web4  = "66.226.4.240"
media = "66.226.4.228"

role :app,      web2, web4
role :web,      web2, web4
role :workers,  media
role :db,       web2, :primary => true
role :sphinx,   media

namespace :deploy do
  namespace :assets do
    if ENV['SKIP_PRECOMPILE']
      task :precompile, roles: [:app] do
        # noop
      end
    end
  end

  desc "Restart Application"
  task :restart, roles: [:app, :workers] do
    restart_file = "#{current_release}/tmp/restart.txt"
    run "touch #{restart_file}"
  end

  # --------------

  task :notify do
    if token = YAML.load_file(
      File.expand_path("../../api_config.yml", __FILE__)
    )["production"]["kpcc"]["private"]["api_token"]
      data = {
        :token       => token,
        :user        => `whoami`.gsub("\n", ""),
        :datetime    => Time.now.strftime("%F %T"),
        :application => application
      }

      url = "http://www.scpr.org/api/private/v2/utility/notify"
      logger.info "Sending notification to #{url}"
      begin
        Net::HTTP.post_form(URI.parse(URI.encode(url)), data)
      rescue Errno::ETIMEDOUT => e
        logger.info "Timed out while trying to notify. Moving forward."
      end

    else
      logger.info "No API token specified. Moving on."
    end
  end
end


# --------------
# Callbacks
before "deploy:update_code", "deploy:notify"
after "deploy:restart", "newrelic:notice_deployment"
