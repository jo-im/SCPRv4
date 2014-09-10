##
# Programs
#
FactoryGirl.define do
  factory :kpcc_program, aliases: [:show] do
    sequence(:title) { |n| "Show #{n}" }
    slug { title.parameterize }
    air_status "onair"

    audio_dir "airtalk" # lazy

    trait :episodic do
      is_episodic 1
    end

  end

  factory :program_article do
    kpcc_program
    article { |f| f.association(:news_story) }
    position 0
  end

  factory :program_reporter do
    kpcc_program
    bio
  end

end
