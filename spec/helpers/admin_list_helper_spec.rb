require "spec_helper"

describe AdminListHelper do
  describe '#display_link' do
    it "returns a pretty link" do
      link = helper.display_link("http://kpcc.org")
      link.should match /kpcc\.org/
      link.should match /<a href/
    end
  end

  describe '#display_content' do
    it "links to the edit path of the content and shows headline" do
      story = build :test_class_story, headline: "Hello"
      story.stub(:admin_edit_path) { "/outpost/test_class_stories" }

      content = helper.display_content(story)
      content.should match /Hello/
      content.should match story.obj_key
      content.should match story.admin_edit_path
    end
  end

  describe '#display_status' do
    it "returns a nice status badge" do
      story = build :test_class_story, status: TestClass::Story.status_id(:live)

      status = helper.display_status(story.status, story)
      status.should match /Published/
      status.should match /label-success/
    end

    it "uses the default badge if status isn't available" do
      story = build :test_class_story, status: TestClass::Story.status_id(:live)

      status = helper.display_status(999, story)
      status.should match /Published/
      status.should match /label/
    end
  end

  describe '#display_article_status' do
    it "returns a nice status badge for articles" do
      story = build :test_class_story, status: TestClass::Story.status_id(:awaiting_edits)

      status = helper.display_article_status(story.status, story)
      status.should match /Awaiting Edits/
      status.should match /label-inverse/
    end
  end

  describe '#display_air_status' do
    it "returns the text for the air status" do
      status = helper.display_air_status("onair")
      status.should eq "Currently Airing"
    end
  end

  describe '#display_audio' do
    it "returns a status badge for the audio" do
      audio = build :audio, :direct, :live

      status = helper.display_audio(audio)
      status.should match /Live/
      status.should match /label-success/
    end

    it "can take an array of audio" do
      audio = build :audio, :direct, :live

      status = helper.display_audio([audio, audio.dup])
      status.should match /Live/
      status.should match /label-success/
    end

    it "shows None if there is no audio" do
      helper.display_audio([]).should match /None/
    end
  end

  describe '#status_bootstrap_map' do
    it "is STATUS_BOOTSTRAP_MAP" do
      helper.status_bootstrap_map.should equal AdminListHelper::STATUS_BOOTSTRAP_MAP
    end
  end
end
