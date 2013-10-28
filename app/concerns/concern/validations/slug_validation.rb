##
# SlugValidation
# Basic validation for slug field
#
# Required fields: [:slug]
# Also requires object to respond to :should_validate?
#
module Concern
  module Validations
    module SlugValidation
      extend ActiveSupport::Concern

      FORMAT         = %r{\A[\w-]+\z}
      FORMAT_MESSAGE = "Only letters, numbers, underscores, and hyphens allowed"

      MAX_LENGTH     = 50

      included do
        validates :slug,
          presence: true,
          format: { with: FORMAT, message: FORMAT_MESSAGE },
          length: { maximum: MAX_LENGTH },
          if: :should_validate?
      end
    end # SlugValidation
  end # Validations
end # Concern
