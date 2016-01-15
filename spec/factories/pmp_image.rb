FactoryGirl.define do
  factory :pmp_image do

    trait :published do
      guid {Faker::Internet.ip_v6_address.gsub(":", "-")}
    end

  end
end
