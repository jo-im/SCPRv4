class ReloadHomepageCache < ActiveRecord::Migration
  def up
    Job::BetterHomepageCache.perform
  end
  def down
  end
end
