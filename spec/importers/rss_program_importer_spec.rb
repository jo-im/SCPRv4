require 'spec_helper'

describe RssProgramImporter do
  describe '::sync' do
    before :each do
      FakeWeb.register_uri(:get, %r{californiareport},
        :content_type   => 'text/xml',
        :body           => load_fixture('rss/rss_feed.xml')
      )
    end

    it "imports segments if it's a segment feed" do
      external_program = create :external_program, :from_rss, feed_type: "rss-segments"
      RssProgramImporter.sync(external_program)
      external_program.external_segments.should_not be_empty
      external_program.external_episodes.should be_empty
    end

    it "imports episodes if it's an episode feed" do
      external_program = create :external_program, :from_rss, feed_type: "rss-episodes"
      RssProgramImporter.sync(external_program)
      external_program.external_segments.should be_empty
      external_program.external_episodes.should_not be_empty
    end

    it "doesn't import episodes that have already been imported" do
      external_program = create :external_program, :from_rss, feed_type: "rss-episodes"
      external_program.external_episodes.count.should eq 0
      RssProgramImporter.sync(external_program)
      count = external_program.external_episodes.count
      count.should_not eq 0

      RssProgramImporter.sync(external_program)
      external_program.external_episodes.count.should eq count
    end
  end
end
