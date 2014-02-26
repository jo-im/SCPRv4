require 'spec_helper'

describe PmpArticleImporter do
  describe '::sync' do
    before :each do
      PMP::CollectionDocument.any_instance.stub(:oauth_token) { "token" }

      stub_request(:get, %r|pmp\.io/?$|).to_return({
        :content_type => "application/json",
        :body => load_fixture('api/pmp/root.json')
      })

      stub_request(:get, %r|pmp\.io/docs|).to_return({
        :content_type => "application/json",
        :body => load_fixture('api/pmp/marketplace_stories.json')
      })
    end

    it 'builds cached articles from the API response' do
      RemoteArticle.count.should eq 0
      added = PmpArticleImporter.sync
      RemoteArticle.count.should eq 2 # Two stories in the JSON fixture
      added.first.headline.should match /billions and billions/
    end

    it "sets the url for the stories" do
      added = PmpArticleImporter.sync
      added.first.url.should match /marketplace\.org/
    end
  end

  describe '#import' do
    context "multiple enclosures" do
      before :each do
        # We don't care about, or need, the oauth token for these tests.
        PMP::CollectionDocument.any_instance.stub(:oauth_token) { "token" }

        stub_request(:get, %r|pmp\.io/?$|).to_return({
          :content_type => "application/json",
          :body => load_fixture('api/pmp/root.json')
        })

        stub_request(:get, %r|pmp\.io/docs\?guid=.+|).to_return({
          :content_type => "application/json",
          :body => load_fixture('api/pmp/story.json')
        })
      end

      it 'sets the source and news agency' do
        remote_article = create :pmp_article
        news_story = PmpArticleImporter.import(remote_article)
        news_story.source.should eq "marketplace"
        news_story.news_agency.should eq 'Marketplace'
      end

      it 'imports the bylines' do
        remote_article = create :pmp_article
        news_story = PmpArticleImporter.import(remote_article)
        news_story.bylines.first.name.should match /Brancaccio, David/
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

      it "adds audio if it's available" do
        remote_article = create :pmp_article
        news_story = PmpArticleImporter.import(remote_article)

        news_story.audio.size.should eq 1
        news_story.audio.first.url.should eq(
          "http://download.publicradio.org/podcast/marketplace/morning_report/2013/09/30/marketplace_morning_report_full_20130930_64.mp3")
      end

      it "creates an asset if image is available" do
        remote_article = create :pmp_article
        news_story = PmpArticleImporter.import(remote_article)
        news_story.assets.size.should eq 1
      end
    end

    context "single enclosure" do
      before :each do
        # We don't care about, or need, the oauth token for these tests.
        PMP::CollectionDocument.any_instance.stub(:oauth_token) { "token" }

        stub_request(:get, %r|pmp\.io/?$|).to_return({
          :content_type => "application/json",
          :body => load_fixture('api/pmp/root.json')
        })

        stub_request(:get, %r|pmp\.io/docs\?guid=.+|).to_return({
          :content_type => "application/json",
          :body => load_fixture('api/pmp/story_single_enclosure.json')
        })
      end

      it "imports audio" do
        remote_article = create :pmp_article
        news_story = PmpArticleImporter.import(remote_article)

        news_story.audio.size.should eq 1
        news_story.audio.first.url.should eq(
          "http://download.publicradio.org/podcast/marketplace/morning_report/2013/09/30/marketplace_morning_report_full_20130930_64.mp3")
      end
    end
  end
end
