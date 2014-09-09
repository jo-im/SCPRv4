require "spec_helper"

describe Concern::Associations::ProgramArticleAssociation do
  subject { build :test_class_story }
  it { should have_many(:program_articles) }

  describe 'destroying on unpublish' do
    it 'destroys the program_articles when unpublishing' do
      story = create :news_story, :published
      program = create :kpcc_program

      program.program_articles.create(article: story)

      program.program_articles.count.should eq 1
      story.update_attributes(status: story.class.status_id(:draft))
      program.program_articles.count.should eq 0
    end
  end
end
