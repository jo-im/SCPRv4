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

    it "creates an asset if image is available" do
      remote_article = create :npr_article
      news_story = NprArticleImporter.import(remote_article)
      news_story.assets.size.should eq 1
      news_story.assets.first.caption.should match /European Space Agency/
    end
  end
end
