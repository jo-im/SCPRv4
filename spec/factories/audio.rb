##
# Audio
#
FactoryGirl.define do
  factory :audio do
    trait :awaiting do
      status Audio.status_id(:waiting)
    end

    trait :live do
      status Audio.status_id(:live)
    end


    trait :uploaded do
      mp3 File.open(File.join(Rails.application.config.scpr.audio_root, "point1sec.mp3"))
    end

    trait :enco do
      enco_number 1488
      enco_date { Date.today }
    end

    trait :direct do
      url "http://media.scpr.org/audio/events/2012/10/02/SomeCoolEvent.mp3"
    end


    trait :for_episode do
      content { |a| a.association :show_episode }
    end

    trait :for_segment do
      content { |a| a.association :show_segment }
    end
  end
end
