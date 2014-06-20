require 'spec_helper'

describe "DFP configuration" do
  let(:category) { create :category, slug: "cool-slug" }

  describe "category" do
    it "doesn't do anything if there is no category" do
      article = create :news_story
      visit article.public_path
      page.html.should_not include 'DFP_CATEGORY = '
    end

    context "news story" do
      it "sets the DFP category if the article has a category" do
        article = create :news_story, category: category
        visit article.public_path
        page.html.should include 'DFP_CATEGORY = "cool-slug"'
      end
    end

    context "show segment" do
      it "sets the DFP category if the article has a category" do
        article = create :show_segment, category: category
        visit article.public_path
        page.html.should include 'DFP_CATEGORY = "cool-slug"'
      end
    end

    context "blog entry" do
      it "sets the DFP category if the article has a category" do
        article = create :blog_entry, category: category
        visit article.public_path
        page.html.should include 'DFP_CATEGORY = "cool-slug"'
      end
    end

    context "event" do
      it "sets the DFP category if the article has a category" do
        article = create :event, :published, category: category
        visit article.public_path
        page.html.should include 'DFP_CATEGORY = "cool-slug"'
      end
    end
  end

  describe "key suffix override" do
    it "sets a special key for the homepage" do
      visit "/"
      page.html.should include 'DFP_KEY_SUFFIX_OVERRIDE = "homepage"'
    end

    it "sets a special key for flatpages" do
      flatpage = create :flatpage
      visit flatpage.public_path
      page.html.should include 'DFP_KEY_SUFFIX_OVERRIDE = ""'
    end
  end
end
