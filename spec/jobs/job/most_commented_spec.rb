require 'spec_helper'

describe Job::MostCommented do
  subject { described_class }
  it { subject.queue.should eq Job::QUEUES[:low_priority] }

  describe "::perform" do
    it "fetches, parses, and caches the popular articles" do
      stub_request(:get, %r|disqus|).to_return({
        :body => JSON.parse(load_fixture("api/disqus/listPopular.json")).to_json,
        :headers => {
          :content_type   => "application/json"
        }
      })

      story = create :news_story

      Concern::Methods::CommentMethods.should_receive(:obj_by_disqus_identifier)
      .and_return(story)

      Job::MostCommented.perform

      Rails.cache.read("popular/commented").should eq [story].map(&:to_article)
    end
  end
end
