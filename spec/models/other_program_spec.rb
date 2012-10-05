require "spec_helper"

describe OtherProgram do
  describe "associations" do
    it { should have_many(:schedules) }
  end
  
  #-----------------
  
  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:slug) }
    it { should validate_presence_of(:air_status) }
    
    context "validates rss_url or podcast_url are present" do
      it "allows only rss_url" do
        program = build :other_program, podcast_url: nil, rss_url: "cool-program-bro.com"
        program.should be_valid
      end
      
      it "allows only podcast_url" do
        program = build :other_program, podcast_url: "cool-podcast-bro.com", rss_url: ""
        program.should be_valid
      end
      
      it "allows both" do
        program = build :other_program, podcast_url: "cool-podcast-bro.com", rss_url: "cool-rss-bro.com"
        program.should be_valid        
      end
      
      it "rejects if both blank" do
        program = build :other_program, podcast_url: "", rss_url: nil
        program.should_not be_valid
        program.errors.keys.sort.should eq [:base, :podcast_url, :rss_url].sort
      end
    end
  end
  
  #-----------------
  
  describe "scopes" do
    describe "active" do
      it "selects programs with online or onair status" do
        onair   = create :other_program, air_status: "onair"
        online  = create :other_program, air_status: "online"
        hidden  = create :other_program, air_status: "hidden"
        archive = create :other_program, air_status: "archive"
        OtherProgram.active.sort.should eq [onair, online].sort
      end
    end
  end
  
  #-----------------
  
  describe "published?" do
    it "is true if air_status is not hidden" do
      onair   = build :other_program, air_status: "onair"
      online  = build :other_program, air_status: "online"
      archive = build :other_program, air_status: "archive"
      
      onair.published?.should eq true
      online.published?.should eq true
      archive.published?.should eq true
    end
    
    it "is false if air_status is hidden" do
      hidden = build :other_program, air_status: "hidden"
      hidden.published?.should eq false
    end
  end
  
  #-----------------
  
  describe "cache" do
    pending
  end
end
