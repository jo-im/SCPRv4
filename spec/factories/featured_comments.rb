##
# Featured Comments
#
FactoryGirl.define do
  factory :featured_comment_bucket, aliases: [:comment_bucket] do
    sequence(:title) { |n| "Comment Bucket #{n}" }
  end

  #---------------------------

  factory :featured_comment do
    bucket { |f| f.association :featured_comment_bucket }
    content { |f| f.association(:content_shell) }

    username "bryanricker"
    excerpt "This is an excerpt of the featured comment"

    status FeaturedComment.status_id(:live)

    # Since it's a required field, we need to populate the content_json
    # field for request specs in Outpost.
    content_json { [content.simple_json].to_json }

    trait :published do
      status FeaturedComment.status_id(:live)
    end

    trait :draft do
      status FeaturedComment.status_id(:hidden)
    end
  end
end
