FactoryGirl.define do
  factory :pmp_story do

    content {create(:news_story)}

    trait :published do
      guid {Faker::Internet.ip_v6_address.gsub(":", "-")}
    end

  end
end
