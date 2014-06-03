class CleanupVersions < ActiveRecord::Migration
  def up
    Secretary::Version.where(versioned_type: [
      "DataPoint",
      "Promotion",
      "VideoShell",
      "Ticket"
    ]).destroy_all
  end

  def down; end
end
