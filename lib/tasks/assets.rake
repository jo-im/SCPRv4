namespace :assets do
  desc "Import assets from style guide."
  task import: :environment do
    FileUtils.cp_r "#{Rails.root}/node_modules/scpr-style-guide/src/img", "#{Rails.root}/public/"
  end
end