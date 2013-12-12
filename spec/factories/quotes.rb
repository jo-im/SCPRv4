##
# Quotes
#
FactoryGirl.define do
  factory :quote do
    category  { |f| f.association :category }
    content { |mic| mic.association(:content_shell) }

    sequence(:source_name) { |i| "jhoffing#{i}" }
    source_context "Shark Hunting Specialist"
    text "This is an excerpt of the quote"

    trait :published do
      status Quote::STATUS_LIVE
    end

    trait :draft do
      status Quote::STATUS_DRAFT
    end
  end
end

