namespace :deploy do
  namespace :npm do
    task :install do
      on roles(:all) do
        execute :npm, "install", "--production --silent --no-spin"
      end
    end
  end
  after 'deploy:updated', 'deploy:npm:install'
end
