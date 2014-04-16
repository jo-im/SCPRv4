require 'spec_helper'

describe "Vertical page" do
  describe "rendering featured articles" do
    sphinx_spec

    it "does not return the top story in the reverse chronological article sections" do
      vertical = create :vertical
      articles = create_list :news_story, 6, :published, category: vertical.category
      other_articles = create_list :news_story, 10, :published, category: vertical.category

      articles.each do |article|
        # Featured articles
        vertical.vertical_articles.create(article: article)
      end

      index_sphinx
      ts_retry(2) do
        visit vertical.public_path

        # Make sure the top article only shows up once on the page
        page.should have_content vertical.featured_articles.first.short_title, count: 1
      end
    end

    it "does not return the top story in the promoted issues section" do
      issue           = create :active_issue
      vertical        = create :vertical
      featured_story  = create :news_story, :published, category: vertical.category

      vertical.vertical_issues.create(issue: issue)
      featured_story.article_issues.create(issue: issue)
      vertical.vertical_articles.create(article: featured_story)

      other_articles = create_list :news_story, 2, :published

      # assign issue to featured article and other articles
      other_articles.each do |article|
        article.article_issues.create(issue: issue)
      end

      index_sphinx

      ts_retry(2) do
        visit vertical.public_path

        within(".supportive aside.more") do
          # make sure top story doesn't show up in the promoted
          # 'more from this issue' section
          page.should_not have_content vertical.featured_articles.first.short_title
        end

        within("section.issues") do
          # make sure top story will still show up in the Issues We're Tracking section
          page.should have_content vertical.featured_articles.first.short_title, count: 1
        end
      end
    end

    # This spec is here becase an error occurred when a content shell
    # without issues was the lead article, since content shells don't have
    # related content.
    it "can have a content shell as the lead article with no issues" do
      vertical = create :vertical
      shell = create :content_shell, :published

      vertical.vertical_articles.create(article: shell)

      visit vertical.public_path
      page.should have_content shell.headline
      page.should_not have_content "More from Related Content"
    end
  end

  describe 'rendering events' do
    it "renders each event once" do
      vertical = create :vertical
      events = create_list :event, 4, :published, category: vertical.category

      visit vertical.public_path

      events.each do |event|
        page.should have_content event.headline, count: 1
      end
    end
  end

  describe 'rendering quote' do
    it 'renders the quote' do
      quote = create :quote, text: "xxxThis is a quotexxx"
      vertical = create :vertical, quote: quote
      visit vertical.public_path

      page.should have_content "xxxThis is a quotexxx"
    end
  end
end
