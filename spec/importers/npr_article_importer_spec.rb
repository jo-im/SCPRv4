require 'spec_helper'

describe NprArticleImporter do
  describe '::sync' do
    before :each do
      stub_request(:get, %r|api\.npr|).to_return({
        :headers => {
          :content_type   => "application/json"
        },
        :body => load_fixture('api/npr/stories.json')
      })
    end

    it 'builds cached articles from the API response' do
      RemoteArticle.count.should eq 0
      added = NprArticleImporter.sync
      RemoteArticle.count.should eq 2 # Two stories in the JSON fixture
      added.first.headline.should match /Small Boat/
    end

    it 'updates existing headlines, teasers, and hyperlinks' do
      added = NprArticleImporter.sync
      RemoteArticle.count.should eq 2
      added.first.headline.should match /Small Boat/
      added.first.teaser.should_not match /sail/
      added.first.url.should_not match /four-men-in-a-small-ship/
      stub_request(:get, %r|api\.npr|).to_return({
        :headers => {
          :content_type   => "application/json"
        },
        :body => load_fixture('api/npr/stories-altered.json')
      })
      NprArticleImporter.sync
      cached = RemoteArticle.all
      cached.count.should eq 2 # The two same stories should remain, not be duplicated
      cached.first.headline.should match /Small Ship/
      cached.first.teaser.should match /sail/
      cached.first.url.should match /four-men-in-a-small-ship/
    end

    it 'calls import after a successful sync' do
      expect(NprArticleImporter).to receive(:import).at_least(:once)
      NprArticleImporter.sync
    end

    it 'does not call import if the npr story is a live video' do
      # There are three stories in the fixture, but the third story has "Watch Live:" in its title.
      # Therefore, import should only be called for the first two, and not the last one.
      expect(NprArticleImporter).to receive(:import).at_most(:twice)
      added = NprArticleImporter.sync
      expect(added.length).to eq 2
      added.each do |story|
        expect(story.headline).not_to match /Watch Live/
      end
    end
  end

  describe '#import' do
    before :each do
      stub_request(:get, %r|api\.npr|).to_return({
        :headers => {
          :content_type   => "application/json"
        },
        :body => load_fixture('api/npr/story.json')
      })
    end

    it 'imports the bylines' do
      remote_article = create :npr_article
      news_story = NprArticleImporter.import(remote_article)
      news_story.bylines.first.name.should match /Scott Neuman/
    end

    it 'sets new to false for imported stories' do
      remote_article = create :npr_article
      NprArticleImporter.import(remote_article)
      remote_article[:is_new].should eq false
    end

    it 'adds in related links if an HTML link is available' do
      remote_article = create :npr_article
      news_story = NprArticleImporter.import(remote_article)
      news_story.related_links.first.url.should match /thetwo-way/
    end

    it "adds audio if it's available and if it gives stream rights" do
      remote_article = create :npr_article
      news_story = NprArticleImporter.import(remote_article)
      news_story.audio.size.should eq 1
      news_story.audio.first.url.should eq "http://pd.npr.org/anon.npr-mp3/npr/atc/2013/07/20130722_atc_07.mp3?orgId=1&topicId=1122&ft=3&f=204570329"
    end

    # Temporarily silencing this test until ship to production. I don't want to add assets unnecessarily. -J.A.
    it "creates an asset if image is available" do
      remote_article = create :npr_article
      news_story = NprArticleImporter.import(remote_article)
      news_story.assets.size.should eq 1
      news_story.assets.first.caption.should match /European Space Agency/
    end

    it "adds a category if NPR's primaryTopic matches one of our categories" do
      # Create a category with the title 'US & World'.
      # This should match the response defined in the npr_article fixture (currently "World") - J.A.
      create :category, title: 'US & World'

      remote_article = create :npr_article
      news_story = NprArticleImporter.import(remote_article)
      news_story.category.title.should eq 'US & World'
    end

    it "does not call the API if options[:npr_story] is given" do
      remote_article = create :npr_article

      # Call the api once to get an NPR::Entity (id is taken from the fixture, 'api/npr/story.json')
      npr_story = NPR::Story.find(187325945)

      # Pass the NPR::Entity into the import method. Normally .import would perform an API call,
      # but if an `npr_story` is already passed in, we want to use that instead
      news_story = NprArticleImporter.import(remote_article, { npr_story: npr_story })

      # Webmock should only call once because we performed an NPR::Story.find earlier
      # for the purposes of this test.
      expect(WebMock).to have_requested(:get, %r|api\.npr|).once
    end
  end
end
