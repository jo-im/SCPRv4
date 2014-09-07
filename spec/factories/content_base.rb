# This made more sense when all the Article models were
# referencing the same status definition.
# Now it's just *likely* that they're all going to be
# the same, but any of them could change at any time.
FactoryGirl.define do
  trait :pending do
    status 3 # possibly
  end

  trait :published do
    status 5 # perhaps
    sequence(:published_at) { |n| Time.zone.now - n.hours }
  end

  trait :draft do
    status 0 # probably
  end
end
