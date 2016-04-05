task :deploybot => [:environment] do
  ## This task gets run by Deploybot after `bundle install`.
  system 'npm install --silent --no-spin'
end