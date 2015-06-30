module Concern::Sanitizers::Content
  extend ActiveSupport::Concern

  included do
    before_save :remove_bad_characters
  end

  def remove_bad_characters
    [:name, :title, :short_title, :headline, :slug, :teaser, :body, :byline].each do |attrib|
      try(attrib).try(:gsub!, Regexp.new("\u2028|\u2029"), "")
    end
  end
end