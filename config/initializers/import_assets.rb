# Only import our assets on server start.
if Rails.const_defined? 'Server'
  Rails.application.load_tasks
  Rake::Task["assets:import"].invoke
end