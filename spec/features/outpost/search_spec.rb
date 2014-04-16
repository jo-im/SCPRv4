require "spec_helper"

describe "Search" do
  it "shows the search results" do
    story = create :news_story, headline: "Mary Poppins"
    story2 = create :news_story, headline: "Not Interesting"
    index_sphinx

    login
    visit outpost_news_stories_path

    page.should have_content story.headline
    page.should have_content story2.headline

    within 'form.form-search' do
      fill_in "query", with: "Poppins"
      find('button').click
    end

    page.should have_content story.headline
    page.should_not have_content story2.headline
  end

  it "Allows special characters" do
    story = create :news_story, headline: "$800 dollars"
    story2 = create :news_story, headline: "Not Interesting"
    index_sphinx

    login
    visit outpost_news_stories_path

    page.should have_content story.headline
    page.should have_content story2.headline

    within 'form.form-search' do
      fill_in "query", with: "$800"
      find('button').click
    end

    page.should have_content story.headline
    page.should_not have_content story2.headline
  end
end
