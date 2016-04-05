namespace :npm do
  set :npm_flags, '--silent --no-spin'
  set :npm_roles, :all
  set :npm_env_variables, {}
  task :install do
    on roles(:all) do
      within fetch(:npm_target_path, release_path) do
        with fetch(:npm_env_variables, {}) do
          execute :npm, "install", fetch(:npm_flags)
        end
      end
    end
  end
  after 'deploy:updated', 'deploy:npm:install'
end