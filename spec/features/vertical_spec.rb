require 'spec_helper'

describe "Vertical page" do
  describe "rendering featured articles" do
    sphinx_spec

    it "does not return the top story in the reverse chronological article sections" do
      category = create :category, is_active: true
      articles = create_list :news_story, 6, :published, category: category
      other_articles = create_list :news_story, 10, :published, category: category

      articles.each do |article|
        # Featured articles
        category.category_articles.create(article: article)
      end

      index_sphinx

      ts_retry(2) do
        visit category.public_path

        # Make sure the top article only shows up once on the page
        page.should have_content category.featured_articles.first.short_title, count: 1
      end
    end

    # This spec is here becase an error occurred when a content shell
    # without issues was the lead article, since content shells don't have
    # related content.
    it "can have a content shell as the lead article with no issues" do
      category = create :category, is_active: true
      shell = create :content_shell, :published

      category.category_articles.create(article: shell)

      visit category.public_path
      page.should have_content shell.headline
      page.should_not have_content "More from Related Content"
    end
  end

  describe 'rendering events' do
    it "renders each event once" do
      category = create :category, is_active: true
      events = create_list :event, 4, :published, category: category

      visit category.public_path

      events.each do |event|
        page.should have_content event.headline, count: 1
      end
    end
  end

  describe 'rendering quote' do
    it 'renders the latest published quote' do
      category = create :category, is_active: true

      quote1 = create :quote, :published, category: category
      quote2 = create :quote, :published, category: category, text: "COOL QUOTE!!!"
      quote3 = create :quote, :draft, category: category

      quote1.update_column(:created_at, 1.month.ago)
      quote2.update_column(:created_at, 1.week.ago)
      quote3.update_column(:created_at, 1.day.ago)

      visit category.public_path

      page.should have_content "COOL QUOTE!!!"
    end
  end
end
