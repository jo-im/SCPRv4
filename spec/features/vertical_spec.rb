require 'spec_helper'

describe "Vertical page" do
  describe "politics vertical" do
    it "renders" do
      vertical = create :vertical, slug: "politics"
      visit vertical.public_path
    end
  end

  describe "education vertical" do
    it "renders" do
      vertical = create :vertical, slug: "education"
      visit vertical.public_path
    end
  end

  describe "business vertical" do
    it "shows 2 latest marketplace articles" do
      vertical = create :vertical, slug: "business"

      story1 = create :news_story, :published,
        :source => "marketplace",
        :published_at => 1.week.ago,
        :short_headline => "xxMarketplace1xx"

      story2 = create :news_story, :published,
        :source => "marketplace",
        :published_at => 1.day.ago,
        :short_headline => "xxMarketplace2xx"

      story3 = create :news_story, :published,
        :source => "marketplace",
        :published_at => 1.hour.ago,
        :short_headline => "xxMarketplace3xx"

      story4 = create :news_story, :published,
        :source => "npr",
        :published_at => 1.minute.ago,
        :short_headline => "xxMarketplace4xx"

      visit vertical.public_path

      within('.affiliated .affiliate') do
        page.should_not have_content 'xxMarketplace1xx'
        page.should_not have_content 'xxMarketplace4xx'
        page.should have_content 'xxMarketplace2xx'
        page.should have_content 'xxMarketplace3xx'
      end
    end
  end


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

  describe "rendering blog articles" do
    sphinx_spec

    it "shows the latest blog articles" do
      blog     = create :blog
      vertical = create :vertical, blog: blog

      blog_entry1 = create :blog_entry, :published,
        :published_at => 1.week.ago,
        :category => vertical.category,
        :blog => blog,
        :short_headline => "xxEntry1xx"

      blog_entry2 = create :blog_entry, :published,
        :published_at => 1.day.ago,
        :category => vertical.category,
        :blog => blog,
        :short_headline => "xxEntry2xx"

      blog_entry3 = create :blog_entry, :published,
        :published_at => 1.hour.ago,
        :category => vertical.category,
        :blog => blog,
        :short_headline => "xxEntry3xx"

      index_sphinx

      ts_retry do
        visit vertical.public_path

        within('.affiliated .latest') do
          page.should_not have_content "xxEntry1xx"
          page.should have_content "xxEntry2xx"
          page.should have_content "xxEntry3xx"
        end
      end
    end

    it "doesn't return the top article in the blog list" do
      blog      = create :blog
      vertical  = create :vertical, blog: blog

      entry1 = create :blog_entry, :published,
        :blog => blog,
        :category => vertical.category,
        :short_headline => "xxEntry1xx"

      entry2 = create :blog_entry, :published,
        :blog => blog,
        :category => vertical.category,
        :short_headline => "xxEntry2xx"

      create :vertical_article, vertical: vertical, article: entry1

      index_sphinx

      ts_retry do
        visit vertical.public_path

        within('.affiliated .latest') do
          page.should have_content "xxEntry2xx"
          page.should_not have_content "xxEntry1xx"
        end
      end
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

  describe "rendering issues" do
    it "shows the related issues in the sidebar" do
      issue1 = create :issue, title: "xxIssue1xx"
      issue2 = create :issue, title: "xxIssue2xx"
      vertical = create :vertical
      vertical.issues = [issue1, issue2]
      vertical.save!

      visit vertical.public_path

      within('section.issues') do
        page.should have_content "xxIssue1xx"
        page.should have_content "xxIssue2xx"
      end
    end

    it "shows the issue's 2 latest articles" do
      issue = create :issue

      article1 = create :news_story, :published,
        :published_at => 1.week.ago,
        :short_headline => "xxArticle1xx"

      article2 = create :news_story, :published,
        :published_at => 1.day.ago,
        :short_headline => "xxArticle2xx"

      article3 = create :news_story, :published,
        :published_at => 1.hour.ago,
        :short_headline => "xxArticle3xx"

      create :article_issue, issue: issue, article: article1
      create :article_issue, issue: issue, article: article2
      create :article_issue, issue: issue, article: article3

      vertical = build :vertical
      vertical.issues << issue
      vertical.save!

      visit vertical.public_path

      within('section.issues') do
        page.should_not have_content "xxArticle1xx"
        page.should have_content "xxArticle2xx"
        page.should have_content "xxArticle3xx"
      end
    end
  end
end
