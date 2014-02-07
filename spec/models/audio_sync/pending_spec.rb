require "spec_helper"

describe AudioSync::Pending do
  describe "::bulk_sync" do
    it "finds audio from the past 2 weeks and publishes it if file exists" do
      old_enco   = create :audio, :enco
      new_enco   = create :audio, :enco

      # Pretend this was created 4 weeks ago
      old_enco.update_column(:created_at, 4.weeks.ago)

      old_enco.published?.should eq false
      new_enco.published?.should eq false

      AudioSync::Pending.bulk_sync

      # We have to reload because ::bulk_sync queries the database again
      old_enco.reload.published?.should eq false
      new_enco.reload.published?.should eq true
    end

    it "doesn't publish if the file doesn't exist" do
      audio = create :audio, :enco
      audio.published?.should eq false

      Audio.any_instance.should_receive(:file)
      AudioSync::Pending.bulk_sync

      audio.reload.published?.should eq false
    end

    it "only looks for awaiting audio" do
      audio = create :audio, :direct
      Audio.any_instance.should_not_receive(:publish)
      AudioSync::Pending.bulk_sync
    end
  end
end
