module Concern::Sanitizers::Content
  extend ActiveSupport::Concern

  included do
    before_save :remove_bad_characters
  end

  def remove_bad_characters
    body.gsub!(Regexp.new("\u2028|\u2029"), "")
  end
end