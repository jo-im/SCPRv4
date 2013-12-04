require 'spec_helper'

describe Issue do
  describe '::active' do
    it 'only selects active issues' do
      active_issue = create :issue, :is_active
      inactive_issue = create :issue, :is_not_active

      Issue.active.to_a.should eq [active_issue]
    end
  end

  describe '#articles' do
    it 'gets associated articles' do
      issue = create :issue, :is_active

      article1 = create :news_story
      article2 = create :blog_entry

      issue.article_issues.create(article: article1)

      issue.articles.should eq [article1].map(&:to_article)
    end
  end
end
