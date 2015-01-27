##
# PublishedScope
#
# Select only published records (status = self.status_id(:live),
# and order by 'published_at desc'
#
# Required attributes: [:status, :published_at]
# Also requires a status :live defined on the class.
#
module Concern
  module Scopes
    module PublishedScope
      extend ActiveSupport::Concern

      included do
        scope :published, -> {
          where(status: self.status_id(:live))
          .order("#{self.table_name}.published_at desc")
        }
      end
    end # PublishedScope
  end # Scopes
end # Concern
