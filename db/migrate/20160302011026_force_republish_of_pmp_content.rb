class ForceRepublishOfPmpContent < ActiveRecord::Migration
  def up
    PmpStory.where.not(guid: nil).map(&:content).each(&:publish_pmp_content)
  end
  def down
    # sorry, amigo
  end
end
