require "spec_helper"

describe "topics/_topic_preface_header.html.erb" do
  topic = nil
  articles = nil
  before :each do
    topic = create :tag
    article = stub(:article)
    topic.articles << article
    articles = topic.articles
  end
  it "shows the date range if the topic has both dates" do
    topic.update began_at: Date.parse('2015-01-01'), most_recent_at: Date.parse('2015-02-01')
    render "topic_preface_header", topic: topic, articles: articles
    expect(rendered).to match /COVERAGE BEGAN/i
    expect(rendered).to match /LATEST COVERAGE/i
  end
  it "omits the date range if either of the topic's timestamps is missing" do
    topic.update began_at: Date.parse('2015-01-01'), most_recent_at: nil
    render "topic_preface_header", topic: topic, articles: articles
    expect(rendered).to_not match /COVERAGE BEGAN/i
    expect(rendered).to_not match /LATEST COVERAGE/i
  end  
end