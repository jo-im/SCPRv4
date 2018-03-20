require 'spec_helper'

describe PmpArticleImporter do
  before do
    # We don't care about, or need, the oauth token for these tests.
    PMP::CollectionDocument.any_instance.stub(:oauth_token) { "token" }

    stub_request(:get, %r|pmp\.io/?$|).to_return({
      :headers => {
        :content_type   => "application/json"
      },
      :body => load_fixture('api/pmp/root.json')
    })

    stub_request(:get, %r|api.publicradio.org/audio/v2|).to_return({
      :headers => {
        :content_type   => "application/json"
      },
      :body => load_fixture('api/pmp/audio.json')
    })
  end

  describe '::sync' do
    before do
      stub_request(:get, %r|pmp\.io/docs|)
        .with(query: {"limit" => "10", "profile" => "story", "tag" => "marketplace"}).to_return({
          :headers => {
            :content_type   => "application/json"
          },
          :body => load_fixture('api/pmp/marketplace_stories.json')
        })
      stub_request(:get, %r|pmp\.io/docs|)
          .with(query: {"collection" => '4c6e24e5-484f-49e8-be8d-452cfddd6252', "limit" => "10", "profile" => "story"}).to_return({
          :headers => {
            :content_type   => "application/json"
          },
          :body => load_fixture('api/pmp/ahp_stories.json')
        })
      stub_request(:get, %r|pmp\.io/docs|)
          .with(query: {"tag" => "CACounts", "limit" => "10", "profile" => "story"}).to_return({
          :headers => {
            :content_type   => "application/json"
          },
          :body => load_fixture('api/pmp/ahp_stories.json')
        })
    end

    it 'builds cached articles from the API response' do
      RemoteArticle.count.should eq 0
      added = PmpArticleImporter.sync
      RemoteArticle.count.should eq 12 # Two stories from Marketplace fixture and 10 from AHP fixture
      added.first.headline.should match /billions and billions/
    end

    it "sets the url for the stories" do
      added = PmpArticleImporter.sync
      added.first.url.should match /marketplace\.org/
    end

    it 'updates existing headlines' do
      added = PmpArticleImporter.sync
      added.first.headline.should match /billions and billions/
      stub_request(:get, %r|pmp\.io/docs|)
        .with(query: {"limit" => "10", "profile" => "story", "tag" => "marketplace"}).to_return({
          :headers => {
            :content_type   => "application/json"
          },
          :body => load_fixture('api/pmp/marketplace_stories_altered.json')
        })
      PmpArticleImporter.sync
      cached = RemoteArticle.all
      cached.first.headline.should match /trillions and trillions/
    end

  end

  describe '#import' do
    context "multiple enclosures" do
      before :each do
        stub_request(:get, %r|pmp\.io/docs\?guid=.+|).to_return({
          :headers => {
            :content_type   => "application/json"
          },
          :body => load_fixture('api/pmp/story.json')
        })
      end

      context 'remote article with news agency name' do
        it 'sets the matching source and news agency' do
          remote_article = create :pmp_article
          news_story = PmpArticleImporter.import(remote_article)
          news_story.source.should eq remote_article.news_agency.downcase
          news_story.news_agency.should eq remote_article.news_agency
        end
      end

      context 'remote article without news agency name' do
        it 'sets the matching source and news agency to fallback of PMP' do
          remote_article = create :pmp_article, news_agency: nil
          news_story = PmpArticleImporter.import(remote_article)
          news_story.source.should eq "pmp"
          news_story.news_agency.should eq "PMP"
        end
      end

      it 'imports the bylines' do
        remote_article = create :pmp_article
        news_story = PmpArticleImporter.import(remote_article)
        news_story.bylines.first.name.should match /Gura, David/
      end

      it 'sets new to false for imported stories' do
        remote_article = create :pmp_article
        PmpArticleImporter.import(remote_article)
        remote_article[:is_new].should eq false
      end

      it 'adds in related links if an HTML link is available' do
        remote_article = create :pmp_article
        news_story = PmpArticleImporter.import(remote_article)
        news_story.related_links.first.url.should match /marketplace\.org/
      end

      context "marketplace story" do
        it "adds audio if it's available" do
          remote_article = create :pmp_article
          news_story = PmpArticleImporter.import(remote_article)

          # The "story.json" file has 2 audio enclosures (they're the same,
          # it's fake).
          news_story.audio.size.should eq 2
          audio = news_story.audio.first
          audio.url.should eq("http://play.publicradio.org/pmp/d/podcast/marketplace/segments/2014/03/12/marketplace_segment09_20140312_64.mp3")
          audio.duration.should eq 80000 / 1000
          audio.description.should match /Marketplace Segment/
        end
      end

      context "ahp story" do
        it "adds audio if it's available" do
          stub_request(:get, %r|pmp\.io/docs\?guid=.+|).to_return({
            :headers => {
              :content_type   => "application/json"
            },
            :body => load_fixture('api/pmp/ahp_story.json')
          })
          remote_article = create :pmp_article, news_agency: "American Homefront Project"
          news_story = PmpArticleImporter.import(remote_article)

          news_story.audio.size.should eq 2
          audio = news_story.audio.first
          audio.url.should eq("http://ahp.org/segments/2014/03/12/segment09_20140312_64.mp3")
          audio.duration.should eq 80000 / 1000
          audio.description.should match /Obama seeks expanded overtime pay/
        end
      end

      it "creates an asset if image is available" do
        remote_article = create :pmp_article
        news_story = PmpArticleImporter.import(remote_article)
        news_story.assets.size.should eq 1
      end
    end

    context "single enclosure" do
      before :each do
        stub_request(:get, %r|pmp\.io/docs\?guid=.+|).to_return({
          :headers => {
            :content_type   => "application/json"
          },
          :body => load_fixture('api/pmp/story_single_enclosure.json')
        })
      end

      it "imports audio" do
        remote_article = create :pmp_article
        news_story = PmpArticleImporter.import(remote_article)

        news_story.audio.size.should eq 1
        news_story.audio.first.url.should eq("http://play.publicradio.org/pmp/d/podcast/marketplace/segments/2014/03/12/marketplace_segment09_20140312_64.mp3")
      end
    end

    context "No items" do
      before do
        stub_request(:get, %r|pmp\.io/docs\?guid=.+|).to_return({
          :headers => {
            :content_type   => "application/json"
          },
          :body => load_fixture('api/pmp/story_no_items.json')
        })
      end

      it "doesn't try to import audio and assets if no items are available" do
        remote_article = create :pmp_article
        news_story = PmpArticleImporter.import(remote_article)

        news_story.audio.should be_empty
        news_story.assets.should be_empty
      end
    end
  end
end
