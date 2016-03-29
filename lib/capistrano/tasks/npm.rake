task :npm_install do
  on roles(:all) do
    execute :npm, "install"
  end
end
before "deploy:updated", "npm_install"