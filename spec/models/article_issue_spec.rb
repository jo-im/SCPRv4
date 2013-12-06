require 'spec_helper'

describe ArticleIssue do
  subject { build :article_issue }

  it { should belong_to :issue }
  it { should belong_to :article }

  describe '#article' do
    it "only gets published articles" do
      story = create :news_story, :draft

      article_issue = create :article_issue, article: story

      article_issue.article(true).should be_nil
    end
  end
end
