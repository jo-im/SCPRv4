##
# CategoryAssociation
#
# Defines category association
#
module Concern
  module Associations
    module CategoryAssociation
      extend ActiveSupport::Concern

      included do
        belongs_to :category, touch: true
      end
    end # CategoryAssociation
  end # Associations
end # Concern
