require "spec_helper"

describe KpccProgram do
  describe "::scopes" do
    describe "can sync audio" do
      it "returns records with onair and audio_dir" do
        onair_and_dir = create :kpcc_program, air_status: "onair", audio_dir: "coolprogram"
        online        = create :kpcc_program, air_status: "online", audio_dir: "coolprogram"
        no_dir        = create :kpcc_program, air_status: "onair", audio_dir: ""
        offair_no_dir = create :kpcc_program, air_status: "online", audio_dir: ""

        KpccProgram.can_sync_audio.should eq [onair_and_dir]
      end
    end
  end

  describe 'slug uniqueness validation' do
    it 'validates that the slug is unique across the program models' do
      external_program = create :external_program, slug: "same"
      kpcc_program = build :kpcc_program, slug: "same"
      kpcc_program.should_not be_valid
      kpcc_program.errors[:slug].first.should match /be unique between/
    end
  end

  describe '#program_articles' do
    it 'orders by position' do
      program = build :kpcc_program
      program.program_articles.to_sql.should match /order by position/i
    end
  end

  describe '#featured_articles' do
    it 'turns all of the items into articles' do
      program = create :kpcc_program
      story = create :news_story
      program_article = create :program_article, kpcc_program: program, article: story

      program.featured_articles.map(&:class).uniq.should eq [Article]
    end

    it "only gets published articles" do
      program = create :kpcc_program
      story_published = create :news_story, :published
      story_unpublished = create :news_story, :draft

      program.program_articles.create(article: story_published)
      program.program_articles.create(article: story_unpublished)

      program.featured_articles.should eq [story_published].map(&:to_article)
    end
  end

end
