# Only import our assets on server start.
unless Rails.const_defined? 'Console'
  Rails.application.load_tasks
  Rake::Task["assets:import"].invoke
end