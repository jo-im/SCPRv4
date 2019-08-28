require "spec_helper"

describe "Search", :indexing do
  xit "shows the search results" do
    story = create :news_story, headline: "Mary Poppins"
    story2 = create :news_story, headline: "Not Interesting"

    login
    visit outpost_news_stories_path

    page.should have_content story.headline
    page.should have_content story2.headline

    within '.index-header .form-search' do
      fill_in "query", with: "Poppins"
      find('button').click
    end

    page.should have_content story.headline
    page.should_not have_content story2.headline
  end

  xit "Allows special characters" do
    story = create :news_story, headline: "$800 dollars"
    story2 = create :news_story, headline: "Not Interesting"

    login
    visit outpost_news_stories_path

    page.should have_content story.headline
    page.should have_content story2.headline

    within '.index-header .form-search' do
      fill_in "query", with: "$800"
      find('button').click
    end

    page.should have_content story.headline
    page.should_not have_content story2.headline
  end

  describe 'global search' do
    xit 'shows the search results' do
      ns = create :news_story, headline: "Obama"
      be = create :blog_entry, headline: "President Obama"
      pq = create :pij_query, headline: "Something about Obama"

      login

      within ".form-search" do
        fill_in "gquery", with: "Obama"
        find('button').click
      end

      expect(page).to have_content ns.headline
      expect(page).to have_content be.headline
      expect(page).to have_content pq.headline
    end

    it 'shows a message if no results are found' do
      login

      within ".form-search" do
        fill_in "gquery", with: "Supercalifragilisticexpialidocious"
        find('button').click
      end

      expect(page).to have_content "No Results"
    end

    it "doesn't show records that can't be edited" do
      ra = create :remote_article, headline: "xxObama Remote Article Headline--"

      login

      within ".form-search" do
        fill_in "gquery", with: "Obama"
        find('button').click
      end

      expect(page).not_to have_content ra.headline
    end
  end
end
