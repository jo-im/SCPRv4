require "spec_helper"

describe EpisodeCell do
  describe "GET" do
    before :each do
      # Create a featured program
      @program = create :kpcc_program, slug: 'the-frame'
      @featured_episode = create :show_episode, show: @program, headline: "--ShowEpisodexx"
    end
    
    it "can render different data models" do
      # Create a show segment, news story, and event
      segment = create :show_segment, :published, headline: "--ShowSegmentxxx"
      story = create :news_story, :published, headline: "--NewsStoryxx"
      event = create :event, :published, headline: "--Eventxx"
      
      # Relate it to an episode and pass the published_content into @content
      @content = [segment, story, event].map(&:to_article)
      
      # Create a cell instance with the necessary properties
      cell_instance = cell(:episode, @featured_episode, program: @program, content: @content)
      
      # Expect these three content types to be listed
      expect(cell_instance.call(:show)).to include "--ShowSegmentxx"
      expect(cell_instance.call(:show)).to include "--NewsStoryxx"
      expect(cell_instance.call(:show)).to include "--Eventxx"
    end
  end
end