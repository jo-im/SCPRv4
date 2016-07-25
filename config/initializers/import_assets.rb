# Only import our assets on server start.
if Rails.const_defined? 'Server'
  puts 'kaboom'
  Rails.application.load_tasks
  Rake::Task["assets:import"].invoke
end