FactoryGirl.define do
  trait :pending do
    status ContentBase::STATUS_PENDING
  end

  trait :published do
    status ContentBase::STATUS_LIVE
    sequence(:published_at) { |n| Time.now - n.hours }
  end

  trait :draft do
    status ContentBase::STATUS_DRAFT
  end
end
