namespace :deploybot
  task :updated => [:environment] do
    ## This task gets run by Deploybot on `deploy:updated`
    ## and occurs after `bundle install`.
    system 'npm install --silent --no-spin'
  end
end