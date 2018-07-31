require "spec_helper"

describe PodcastsController, :indexing do
  render_views

  describe "GET /index" do
    it "orders by title asc" do
      get :index
      assigns(:podcasts).to_sql.should match /order by title/i
    end

    it "only shows listed" do
      unlisted = create :podcast, is_listed: false
      listed   = create :podcast, is_listed: true
      get :index
      assigns(:podcasts).should eq [listed]
    end
  end

  #---------------

  describe "GET /podcast" do
    it "returns RecordNotFound if no podcast is found" do
      -> {
        get :podcast, slug: "nonsense"
      }.should raise_error ActiveRecord::RecordNotFound
    end

    it "finds the correct podcast" do
      podcast = create :podcast, slug: "podcast"
      Podcast.any_instance.stub(:content) { [] }
      get :podcast, slug: "podcast"
      assigns(:podcast).should eq podcast
    end

    it "redirects to podcast_url if podcast_url is not from scpr.org" do
      podcast = create :podcast, podcast_url: 'http://example.com/external_podcast.xml'
      get :podcast, slug: podcast.slug
      response.should redirect_to podcast.podcast_url
    end

    context "consumer key provided" do
      it "is included in item links" do
        entry   = create :blog_entry
        audio   = create :audio, :uploaded, content: entry
        entry.reload
        podcast = create :podcast, slug: "podcast", source: entry.blog
        get :podcast, slug: "podcast", consumer: "spotify"
        doc = Nokogiri::XML response.body
        items = doc.css("item")

        all_items_have_consumer_key = items.any? && items.all? do |item|
          uri = URI.parse(item.css("enclosure").first.attributes["url"].to_s)
          query_params = uri.query
          query_params.include?("consumer=spotify")
        end
        expect(all_items_have_consumer_key).to eq(true)
      end
    end

    context "Content search" do
      it "assigns the content for entry" do
        entry   = create :blog_entry
        audio   = create :audio, :uploaded, content: entry

        entry.reload

        podcast = create :podcast, slug: "podcast", source: entry.blog

        get :podcast, slug: "podcast"
        response.body.should match entry.headline

        purge_uploaded_audio
      end

      it "assigns the content for episode" do
        episode   = create :show_episode
        audio     = create :audio, :uploaded, content: episode

        podcast = create :podcast,
          :slug         => "podcast",
          :source       => episode.show,
          :item_type    => "episodes"

        get :podcast, slug: "podcast"
        response.body.should match episode.headline

        purge_uploaded_audio
      end
    end
  end
end
