##
#Quotes
#
FactoryGirl.define do

  #---------------------------

  factory :quote do
    category  { |f| f.association :category }
    article { |mic| mic.association(:content_shell) }

    source_name  "jhoffing"
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

