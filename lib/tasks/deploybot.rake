namespace :deploybot do
  task :updated => [:environment] do
    ## This task gets run by Deploybot on `deploy:updated`
    ## and occurs after `bundle install`.
    system 'npm install --silent --no-spin --cache-min Infinity'
  end
end