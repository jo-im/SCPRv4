class MakeCacheValuesBinary < ActiveRecord::Migration
  require 'rake'
  def up
    Cache.clear
    change_column :caches, :value, :binary, limit: 2.megabytes
    Rake::Task.clear
    Scprv4::Application.load_tasks
    Rake::Task['scprv4:cache'].invoke
  end
  def down
    Cache.clear
    change_column :caches, :value, :text, limit: 4294967295
    Rake::Task.clear
    Scprv4::Application.load_tasks
    Rake::Task['scprv4:cache'].invoke
  end
end
