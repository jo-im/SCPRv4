##
# Featured Comments
#
FactoryGirl.define do
  factory :featured_comment_bucket, aliases: [:comment_bucket] do
    sequence(:title) { |n| "Comment Bucket #{n}" }
  end

  #---------------------------

  factory :featured_comment do
    bucket  { |f| f.association :featured_comment_bucket }
    content { |mic| mic.association(:content_shell) }

    username  "bryanricker"
    excerpt   "This is an excerpt of the featured comment"

    status FeaturedComment::STATUS_LIVE

    trait :draft do
      status FeaturedComment::STATUS_DRAFT
    end
  end
end
