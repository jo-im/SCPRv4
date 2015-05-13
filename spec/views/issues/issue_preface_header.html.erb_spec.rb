require "spec_helper"

describe "issues/_issue_preface_header.html.erb" do
  issue = nil
  articles = nil
  before :each do
    issue = create :tag
    article = stub(:article)
    issue.articles << article
    articles = issue.articles
  end
  it "shows the date range if the issue has both dates" do
    issue.update began_at: Date.parse('2015-01-01'), most_recent_at: Date.parse('2015-02-01')
    render "issue_preface_header", issue: issue, articles: articles
    expect(rendered).to match /COVERAGE BEGAN/i
    expect(rendered).to match /LATEST COVERAGE/i
  end
  it "omits the date range if either of the issue's timestamps is missing" do
    issue.update began_at: Date.parse('2015-01-01'), most_recent_at: nil
    render "issue_preface_header", issue: issue, articles: articles
    expect(rendered).to_not match /COVERAGE BEGAN/i
    expect(rendered).to_not match /LATEST COVERAGE/i
  end  
end