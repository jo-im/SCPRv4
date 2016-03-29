task :npm_install do
  on roles(:all) do
    execute :npm, "install", "--production --silent --no-spin"
  end
end
before "deploy:updated", "npm_install"