module Concern
  module Associations
    module TagsAssociation
      extend ActiveSupport::Concern

      included do
        has_many :taggings, as: :taggable, dependent: :destroy
        has_many :tags, through: :taggings

        if self.has_secretary?
          tracks_association :tags
        end
      end
    end
  end
end
