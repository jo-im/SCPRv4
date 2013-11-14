FactoryGirl.define do
  factory :issue do
    sequence(:title) { |n| "Important Issue #{n}" }

    slug                { title.parameterize }
    description          "This is a very important issue."
    is_active           1

  end

end
