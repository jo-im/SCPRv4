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
end
