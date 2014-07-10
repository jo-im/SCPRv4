require "spec_helper"

describe ArticlePresenter do
  describe "#related_links" do
    it "returns html_safe list of related links and related content with a header if present" do
      story = create :news_story, :published
      related_story  = create :news_story, :published, headline: "Test Headline", short_headline: "Test Short Headline"
      related_content  = create :related_content, content: related_story, related: story
      story.related_links.build(title: "Website", url: "http://www.scpr.org/airtalk", link_type: "website")
      p = presenter(story.to_article)
      p.related_links.should eq "<aside class=\"related\"><header><h1>Related Links</h1></header><nav><ul><li><a href=\"#{related_story.public_path}\"><mark>Test Short Headline</mark><span>Article</span></a></li><li><a href=\"http://www.scpr.org/airtalk\"><mark>Website</mark><span>Article</span></a></li></ul></nav></aside>".html_safe
    end

    it "returns html_safe related links with a header if present and related_content is absent" do
      story = create :news_story, :published
      story.related_links.build(title: "Website", url: "http://www.scpr.org/airtalk", link_type: "website")
      p = presenter(story.to_article)
      p.related_links.should eq "<aside class=\"related\"><header><h1>Related Links</h1></header><nav><ul><li><a href=\"http://www.scpr.org/airtalk\"><mark>Website</mark><span>Article</span></a></li></ul></nav></aside>".html_safe
    end

    it "returns html_safe list of related content with a header if present and related links are absent" do
      story = create :news_story, :published
      related_story  = create :news_story, :published, headline: "Test Headline", short_headline: "Test Short Headline"
      related_content  = create :related_content, content: related_story, related: story
      p = presenter(story.to_article)
      p.related_links.should eq "<aside class=\"related\"><header><h1>Related Links</h1></header><nav><ul><li><a href=\"#{related_story.public_path}\"><mark>Test Short Headline</mark><span>Article</span></a></li></ul></nav></aside>".html_safe
    end
  end
end
