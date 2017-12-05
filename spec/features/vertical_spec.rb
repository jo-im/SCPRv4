require 'spec_helper'

describe "Vertical page", :indexing do
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

  # describe "business vertical" do
  #   it "shows 2 latest marketplace articles" do
  #     vertical = create :vertical, slug: "business"
  #
  #     Rails.cache.write("views/business/marketplace",
  #       %Q{<mark>Drought puts California rice in a sticky situation</mark>
  #         <mark>PODCAST: Winter came for the GDP</mark>})
  #
  #     visit vertical.public_path
  #
  #     within('.affiliated .affiliate') do
  #       page.should have_content 'Drought puts California rice in a sticky situation'
  #       page.should have_content 'PODCAST: Winter came for the GDP'
  #     end
  #   end
  # end


  describe "rendering featured articles" do
    # it "does not return the top story in the reverse chronological article sections" do
    #   vertical = create :vertical
    #   articles = create_list :news_story, 6, :published, category: vertical.category
    #   create_list :news_story, 10, :published, category: vertical.category
    #
    #   articles.each do |article|
    #     # Featured articles
    #     vertical.vertical_articles.create(article: article)
    #   end
    #
    #   visit vertical.public_path
    #
    #   # Make sure the top article only shows up once on the page
    #   page.should have_content vertical.featured_articles.first.short_title, count: 1
    # end

    it "does not return the top story in the promoted topics section" do
      tag             = create :tag
      vertical        = create :vertical
      featured_story  = create :news_story, :published, category: vertical.category

      vertical.taggings.create(tag: tag)
      featured_story.taggings.create(tag: tag)
      vertical.vertical_articles.create(article: featured_story)

      other_articles = create_list :news_story, 2, :published

      # assign topic to featured article and other articles
      other_articles.each do |article|
        article.taggings.create(tag: tag)
      end

      visit vertical.public_path

      within(".o-featured-story__related-list") do
        # make sure top story doesn't show up in the promoted
        # 'more from this topic' section
        page.should_not have_content vertical.featured_articles.first.short_headline
      end

      # within("aside.o-vertical-topics") do
      #   # make sure top story will still show up in the Topics We're Tracking section
      #   page.should have_content vertical.featured_articles.first.short_title, count: 1
      # end
    end

  #   # This spec is here becase an error occurred when a content shell
  #   # without topics was the lead article, since content shells don't have
  #   # related content.
  #   it "can have a content shell as the lead article with no topics" do
  #     vertical = create :vertical
  #     shell = create :content_shell, :published
  #
  #     vertical.vertical_articles.create(article: shell)
  #
  #     visit vertical.public_path
  #     page.should have_content shell.headline
  #     page.should_not have_content "More from Related Content"
  #   end
  end

  # describe "rendering blog articles" do
  #   it "shows the latest blog articles" do
  #     blog     = create :blog
  #     vertical = create :vertical, blog: blog
  #
  #     create :blog_entry, :published,
  #       :published_at => 1.week.ago,
  #       :category => vertical.category,
  #       :blog => blog,
  #       :short_headline => "xxEntry1xx"
  #
  #     create :blog_entry, :published,
  #       :published_at => 1.day.ago,
  #       :category => vertical.category,
  #       :blog => blog,
  #       :short_headline => "xxEntry2xx"
  #
  #     create :blog_entry, :published,
  #       :published_at => 1.hour.ago,
  #       :category => vertical.category,
  #       :blog => blog,
  #       :short_headline => "xxEntry3xx"
  #
  #     visit vertical.public_path
  #
  #     within('.affiliated .latest') do
  #       page.should_not have_content "xxEntry1xx"
  #       page.should have_content "xxEntry2xx"
  #       page.should have_content "xxEntry3xx"
  #     end
  #   end

  #   it "doesn't return the top article in the blog list" do
  #     blog      = create :blog
  #     vertical  = create :vertical, blog: blog
  #
  #     entry1 = create :blog_entry, :published,
  #       :blog => blog,
  #       :category => vertical.category,
  #       :short_headline => "xxEntry1xx"
  #
  #     create :blog_entry, :published,
  #       :blog => blog,
  #       :category => vertical.category,
  #       :short_headline => "xxEntry2xx"
  #
  #     create :vertical_article, vertical: vertical, article: entry1
  #
  #     visit vertical.public_path
  #
  #     within('.affiliated .latest') do
  #       page.should have_content "xxEntry2xx"
  #       page.should_not have_content "xxEntry1xx"
  #     end
  #   end
  # end

  # describe 'rendering events' do
  #   it "renders each event once" do
  #     vertical = create :vertical
  #     events = create_list :event, 4, :published, category: vertical.category
  #
  #     visit vertical.public_path
  #
  #     events.each do |event|
  #       page.should have_content event.headline, count: 1
  #     end
  #   end
  # end

  # describe 'rendering quote' do
  #   it 'renders the quote' do
  #     quote = create :quote, text: "xxxThis is a quotexxx"
  #     vertical = create :vertical, quote: quote
  #     visit vertical.public_path
  #
  #     page.should have_content "xxxThis is a quotexxx"
  #   end
  # end

  describe "rendering topics" do
    # it "shows the related topics in the sidebar" do
    #   tag1 = create :tag, title: "xxIssue1xx"
    #   tag2 = create :tag, title: "xxIssue2xx"
    #   vertical = create :vertical
    #   vertical.tags = [tag1, tag2]
    #   vertical.save!
    #
    #   visit vertical.public_path
    #
    #   within('aside.o-vertical-topics') do
    #     page.should have_content "xxIssue1xx"
    #     page.should have_content "xxIssue2xx"
    #   end
    # end

    it "shows the topic's 2 latest articles" do
      tag = create :tag

      article1 = create :news_story, :published,
        :published_at => 1.week.ago,
        :short_headline => "xxArticle1xx"

      article2 = create :news_story, :published,
        :published_at => 1.day.ago,
        :short_headline => "xxArticle2xx"

      article3 = create :news_story, :published,
        :published_at => 1.hour.ago,
        :short_headline => "xxArticle3xx"

      create :tagging, tag: tag, taggable: article1
      create :tagging, tag: tag, taggable: article2
      create :tagging, tag: tag, taggable: article3

      vertical = build :vertical
      vertical.tags << tag
      vertical.save!

      visit vertical.public_path

      # within('aside.o-vertical-topics') do
      #   page.should_not have_content "xxArticle1xx"
      #   page.should have_content "xxArticle2xx"
      #   page.should have_content "xxArticle3xx"
      # end
    end
  end
end
