require 'spec_helper'

describe ApplicationHelper do

  describe '#render_content' do
    describe 'feedxml' do
      it "renders XML for the article(s)" do
        entry = build :blog_entry
        xml = helper.render_content(entry, 'feedxml')
        xml.should match entry.headline
      end

      it "renders audio enclosure if asked" do
        entry = build :blog_entry
        audio = create :audio, :direct, :live, content: entry
        entry.save!
        entry.reload

        xml = helper.render_content(entry, 'feedxml', enclosure_type: :audio)
        xml.should match audio.url
      end

      it "renders image enclosure if asked" do
        entry = build :blog_entry
        asset = create :asset, content: entry
        entry.save!
        entry.reload

        xml = helper.render_content(entry, 'feedxml', enclosure_type: :image)
        xml.should match asset.full.url
      end
    end
  end


  describe '#safe_render' do
    it "renders the partial if it exists" do
      helper.lookup_context.stub(:exists?) { true }
      helper.stub(:render) { "hello" }

      helper.safe_render('path/to/existing/partial')
        .should match /hello/
    end

    it "returns nil if the partial does not exist" do
      helper.safe_render('nope/nope/doublenope').should be_nil
    end
  end

  describe "sphinx category searches" do
    let(:category) { create :category }

    sphinx_spec

    it "#latest_news gets all objects with limit" do
      story1 = create :news_story, category: category, published_at: 1.week.ago
      story2 = create :news_story, category: category, published_at: 1.day.ago

      index_sphinx

      ts_retry(2) do
        helper.latest_news.should eq [story2, story1].map(&:to_article)
      end
    end
  end

  #------------------------

  describe "render_asset" do
    it "should render a fallback image if there are no assets and fallback is true" do
      content = build :content_shell
      content.stub(:assets) { [] }

      helper.render_asset(content, display: 'thumbnail', fallback: true)
        .should match "fallback"
    end

    it "should move on to render_asset if there are assets" do
      content = build :content_shell
      content.stub(:assets) { [1, 2, 3] }
      view.stub(:render) { "asset rendered" }

      helper.render_asset(content, display: 'thumbnail', fallback: true)
        .should match "asset rendered"
    end

    it "should return a blank string if object does not have assets and no fallback is requested" do
      content = create :content_shell

      helper.render_asset(content, display: 'thumbnail', fallback: false)
        .should eq ''
    end

    it "renders the specified template" do
      content = create :content_shell
      asset = create :asset, content: content

      # Use a real template name here so it passes the lookup context check
      helper.render_asset(content, template: "default/video")
        .should render_template "shared/assets/default/_video"
    end

    it "renders with specified display" do
      content = create :content_shell
      asset = create :asset, content: content

      helper.render_asset(content, display: "small")
        .should render_template "shared/assets/default/_small"
    end

    it "renders with specified context" do
      content = create :content_shell
      asset = create :asset, content: content

      helper.render_asset(content, context: "pij_query")
        .should render_template "shared/assets/pij_query/_photo"
    end

    it "uses the object's asset_display_id to figure out display" do
      content = create :news_story, asset_display: :slideshow
      asset = create :asset, content: content

      helper.render_asset(content)
        .should render_template "shared/assets/default/_slideshow"
    end
  end

  #------------------------

  describe "#render_byline" do
    context "for object without bylines association" do
      it "returns KPCC if the object doesn't have bylines" do
        helper.render_byline(Object.new).should eq "KPCC"
      end
    end

    context "for object with bylines association" do
      let(:user) { create :bio, name: "Bryan" }

      before :each do
        @content = create :news_story

        primary   = create :byline, content: @content, role: ContentByline::ROLE_PRIMARY, user: user
        secondary = create :byline, content: @content, role: ContentByline::ROLE_SECONDARY, name: "Danny"

        @content.reload
      end

      it "turns the bylines with a user into links if links=true" do
        byline = helper.render_byline(@content)
        byline.should match /a href/
        byline.should match user.public_path
        byline.should match /Danny/
      end

      it "is does not use links if links=false" do
        byline = helper.render_byline(@content, false)
        byline.should_not match /a href/
        byline.should_not match user.public_path
        byline.should match /Bryan/
        byline.should match /Danny/
      end
    end
  end

  #------------------------

  describe "#render_contributing_byline" do
    let(:user) { create :bio, name: "Bryan" }
    let(:content) { create :news_story }

    it "returns contributing bylines as a sentence" do
      contributing1 = create :byline, content: content, role: ContentByline::ROLE_CONTRIBUTING, user: user
      contributing2 = create :byline, content: content, role: ContentByline::ROLE_CONTRIBUTING, name: "Danny"
      content.reload

      helper.render_contributing_byline(content, false).should match /Bryan and Danny/
    end

    it "returns a blank string if no contributing bylines are present" do
      primary = create :byline, content: content, role: ContentByline::ROLE_PRIMARY, user: user
      content.reload

      helper.render_contributing_byline(content, false).should eq ""
    end
  end

  #------------------------

  describe "#smart_date_js" do # These tests could be dryed up
    it "returns a time tag with all attributes filled in if some sort of Timestamp object is passed in" do
      time = Time.now
      tag = helper.smart_date_js(time)
      tag.should match /\<time/
      tag.should match /smart smarttime/
      tag.should match /#{time.to_i.to_s}/
    end

    it "returns empty string if passed-in object can't respond to strftime" do
      helper.smart_date_js("invalid").should eq ''
    end

    it "accepts an optional options hash and merges it into the options for the content_tag" do
      time = Time.now
      helper.smart_date_js(time, "data-window" => "8h").should match "data-window"
    end

    it "overrides the default options in the content_tag with any passed-in options" do
      time = Time.now
      helper.smart_date_js(time, "datetime" => "new format").should match "datetime=\"new format\""
    end

    it "merges a passed-in class with the required smarttime class" do
      time = Time.now
      helper.smart_date_js(time, class: "newClass").should match "newClass smart smarttime"
    end

    it "uses the specified tag" do
      helper.smart_date_js(Time.now, tag: "span").should match /<span/
    end
  end

  #------------------------

  describe "below_standard_ratio" do
    it "returns true if the image dimensions are equal to or less than the specified ratio and greater than 951px" do
      image_width = 1200
      image_height = 900

      helper.below_standard_ratio(width: image_width, height: image_height).should eq true
    end

    it "returns false if the image dimensions are greater than the specified ratio" do
      image_width = 400
      image_height = 400
      helper.below_standard_ratio(width: image_width, height: image_height).should eq false
    end

    it "returns false if the image dimensions are within the specified ratio but less than 951px wide" do
      image_width = 300
      image_height = 400
      helper.below_standard_ratio(width: image_width, height: image_height).should eq false
    end
  end

  #------------------------

  describe "modal" do
    it "renders the modal shell partial" do
      helper.modal("anything") { "content" }.should_not be_blank
    end

    it "raises an error if no style is passed in" do
      expect { helper.modal() { "content" } }.to raise_error ArgumentError
    end

    it "raises an error if a block is not given" do
      expect { helper.modal("anything") }.to raise_error
    end

    it "passes in the style" do
      helper.modal("awesome-modal") { "content" }.should match /awesome\-modal/
    end

    it "makes content_for :modal_content" do
      helper.modal("anything") { "Hello!" }
      helper.content_for?(:modal_content).should eq true
    end

    it "renders the modal_content block" do
      helper.modal("anything") { "Hello!" }.should match /Hello!/
    end
  end

  #------------------------

  describe "split_collection" do
    it "returns an array" do
      helper.split_collection([], 5).should be_a Array
    end

    it "sets the first slice to the first `num` elements" do
      arr = (1..10).to_a
      helper.split_collection(arr, 5)[0].should eq (1..5).to_a
    end

    it "sets the last slice to the rest of the array" do
      arr = (1..10).to_a
      helper.split_collection(arr, 5)[1].should eq (6..10).to_a
    end

    it "returns an empty array for the last portion if collection is smaller `num`" do
      arr = (1..5).to_a
      split = helper.split_collection(arr, 10)
      split[0].should eq (1..5).to_a
      split[1].should eq []
    end
  end

  #------------------------

  context "widgets" do
    let(:object) { create :blog_entry }

    describe "content_widget" do
      it "looks in /shared/cwidgets if just the name of the partial is given" do
        helper.content_widget("social_tools", object).should match /Share this\:/
      end
    end

    #------------------------

    describe "#comment_count_for" do
      it "renders a link to the comments" do
        comment_count_for(object).should match "href"
        comment_count_for(object).should match object.public_path(anchor: "comments")
      end

      it "uses the class passed in and preserves the hard-coded classes" do
        comment_count = comment_count_for(object, class: "other")
        comment_count.should match /comment_link/
        comment_count.should match /social_disq/
        comment_count.should match /other/
      end

      it "doesn't render anything if it doesn't respond to disqus_identifier" do
        comment_count_for(create :blog).should be_nil
      end
    end

    #------------------------

    describe "#comment_widget_for" do
      it "renders the comment_count partial" do
        comment_widget = comment_widget_for(object)
        comment_widget.should_not be_nil
        comment_widget.should match /comment-count/
      end

      it "has a link to the comments" do
        comment_widget_for(object).should match object.public_path(anchor: "comments")
      end

      it "doesn't render anything if it doesn't respond to disqus_identifier" do
        comment_widget_for(create :blog).should be_nil
      end

      it "passes in the cssClass" do
        comment_widget_for(object, cssClass: "someclass").should match /someclass/
      end
    end

    #------------------------

    describe '#twitter_profile_url' do
      it 'returns the full twitter url with the handle added' do
        url = helper.twitter_profile_url('kpcc')
        url.should match /twitter\.com/
        url.should match /kpcc\z/
      end

      it 'parameterizes the handle' do
        helper.twitter_profile_url('@KPCC').should_not match /@/
      end
    end

    #------------------------

    describe '#timestamp' do
      it "renders tag if datetime responds to strftime" do
        helper.timestamp(Time.now).should match /\<time/
      end

      it "doesn't render anything if datetime isn't a date/time" do
        helper.timestamp(nil).should eq nil
        helper.timestamp("nothing").should eq nil
      end
    end

    #------------------------

    describe '#format_clip_duration' do
      it "formats the audio duration with only minutes if the duration is less than an hour" do
        helper.format_clip_duration(240).should match /4:00/
      end
      it "formats the audio duration with hours and minutes if the duration is an hour or more" do
        helper.format_clip_duration(3660).should match /1:01:00/
      end
    end

    #------------------------

    describe "#comments_for" do
      it "renders the comments partial" do
        comments_for(object).should match 'comments'
      end

      it "passes along the cssClass" do
        comments_for(object, cssClass: "special_class").should match "special_class"
      end
    end
  end

  describe '#pij_source' do
    it 'renders the notice if is_from_pij? is true' do
      Object.any_instance.stub(:is_from_pij?) { true }
      helper.pij_source(Object.new).should match /Become a source/
    end

    it 'can have a custom message' do
      Object.any_instance.stub(:is_from_pij?) { true }
      helper.pij_source(Object.new, message: "Okedoke").should match /Okedoke/
    end

    it 'is nil if is_from_pij? is false' do
      Object.any_instance.stub(:is_from_pij?) { false }
      helper.pij_source(Object.new).should eq nil
    end
  end

  describe '#random_headshot' do
    it 'returns an img tag' do
      helper.random_headshot.should match /<img /
    end
  end

  describe '#add_ga_tracking_to' do
    context 'given a url containing scpr.org' do
      url = 'www.scpr.org'
      it 'renders a link with google analytics params if the given url contains scpr.org' do
        helper.add_ga_tracking_to(url).should eq 'www.scpr.org?utm_source=kpcc&utm_medium=email&utm_campaign=short-list'
      end
    end
    context 'given a url that does not contain scpr.org' do
      url = 'www.npr.org'
      it 'renders the original link' do
        helper.add_ga_tracking_to(url).should_not eq 'www.npr.org?utm_source=kpcc&utm_medium=email&utm_campaign=short-list'
        helper.add_ga_tracking_to(url).should eq 'www.npr.org'
      end
    end
  end


  describe '#url_with_params' do
    it "adds params if there aren't any" do
      url = helper.url_with_params("http://google.com", context: "kpcc")
      url.should eq "http://google.com?context=kpcc"
    end

    it "apprends to params if they already exist" do
      url = helper.url_with_params("http://google.com?from=kpcc", context: "podcast")
      url.should eq "http://google.com?from=kpcc&context=podcast"
    end

    it "ignores params if the value is falsey" do
      url = helper.url_with_params("http://google.com", from: 'kpcc', context: nil)
      url.should eq "http://google.com?from=kpcc"
    end

    it "doesn't leave a trailing ? if there are no params" do
      url = helper.url_with_params("http://google.com")
      url.should_not match /\?/
    end

    it "Returns the url if it's an invalid URI" do
      url = helper.url_with_params("nope nope nope")
      url.should eq "nope nope nope"
    end
  end
end
