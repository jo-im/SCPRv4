##
#Quotes
#
FactoryGirl.define do

  #---------------------------

  factory :quote do
    category  { |f| f.association :category }
    content { |mic| mic.association(:content_shell) }

    sequence(:source_name) { |i| "jhoffing#{i}" }
    source_context "Shark Hunting Specialist"
    quote   "This is an excerpt of the quote"

    trait :published do
      status 5
    end

    trait :draft do
      status 0
    end
  end
end

