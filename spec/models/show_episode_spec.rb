require "spec_helper"

describe ShowEpisode do
  describe "callbacks" do
    describe "generate_headline" do
      let(:program) { build :kpcc_program, title: "Cool Show" }

      it "generates headline if headline is blank" do
        episode = build :show_episode, show: program, air_date: Chronic.parse("January 1, 2012"), headline: ""
        episode.save!
        episode.reload.headline.should eq "Cool Show for January 1, 2012"
      end
    
      it "doesn't generate headline if headline was given" do
        episode = build :show_episode, headline: "Cool Episode, Bro!"
        episode.save!
        episode.reload.headline.should eq "Cool Episode, Bro!"
      end
    end
  end
  
  #------------------
  
  describe "validations" do
    it { should validate_presence_of(:show) }
    
    it "validates air date on publish" do
      ShowEpisode.any_instance.stub(:published?) { true }
      should validate_presence_of(:air_date)
    end
  end

  #------------------
  
  describe "scopes" do
    describe "#published" do
      it "orders published content by air_date descending" do
        episodes = create_list :show_episode, 3, status: ContentBase::STATUS_LIVE
        ShowEpisode.published.first.should eq episodes.last
        ShowEpisode.published.last.should eq episodes.first
      end
    end
  end
  
  #------------------
  
  describe "#teaser" do
    it "is the body" do
      show_episode = build :show_episode, body: "hello"
      show_episode.teaser.should eq show_episode.body
    end
  end

  #------------------

  describe '#rundown_json' do
    it "uses simple_json for the join model" do
      episode = create :show_episode
      segment = create :show_segment
      rundown = episode.rundowns.build(segment: segment, segment_order: 0)
      rundown.save!

      episode.rundown_json.should eq [rundown.simple_json].to_json
      episode.segments.should eq [segment]
    end
  end

  #------------------

  describe '#rundown_json=' do
    let(:episode)  { create :show_episode }
    let(:segment1) { create :show_segment }
    let(:segment2) { create :show_segment }


    it "adds them ordered by position" do
      episode.rundown_json = "[{ \"id\": \"#{segment2.obj_key}\", \"position\": 1 }, {\"id\": \"#{segment1.obj_key}\", \"position\": 0 }]"
      episode.segments.should eq [segment1, segment2]
    end
    
    it "parses the json and sets the content" do
      episode.segments.should be_empty
      episode.rundown_json = "[{\"id\": \"#{segment1.obj_key}\", \"position\": 0 }, { \"id\": \"#{segment2.obj_key}\", \"position\": 1 }]"
      episode.segments.should eq [segment1, segment2]
    end
    
    it 'does not do anything if json is an empty string' do
      episode.segments.should be_empty
      episode.rundown_json = "[{\"id\": \"#{segment1.obj_key}\", \"position\": 0 }, { \"id\": \"#{segment2.obj_key}\", \"position\": 1 }]"
      episode.segments.should_not be_empty
      
      episode.rundown_json = ""
      episode.segments.should_not be_empty
      
      episode.rundown_json = "[]"
      episode.segments.should be_empty
    end

    context "when no content has changed" do
      it "doesn't set the rundowns" do
        original_json = "[{ \"id\": \"#{segment1.obj_key}\", \"position\": 1 }]"
        record = create :show_episode, rundown_json: original_json

        record.should_not_receive :rundowns=
        record.rundown_json = original_json
      end
    end
  end
end
