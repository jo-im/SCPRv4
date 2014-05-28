##
# Quotes
#
FactoryGirl.define do
  factory :quote do
    content { |mic| mic.association(:content_shell) }

    sequence(:source_name) { |i| "jhoffing#{i}" }
    source_context "Shark Hunting Specialist"
    text "This is an excerpt of the quote"
  end
end
