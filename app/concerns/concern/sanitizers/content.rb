module Concern::Sanitizers::Content
  extend ActiveSupport::Concern

  included do
    before_save :remove_bad_characters
  end

  def remove_bad_characters
    attribute_names.each do |k|
      v = send(k)
      if v.is_a?(String)
        send "#{k}=", v.gsub(Regexp.new("\u2028|\u2029"), "")
      end
    end
  end
end