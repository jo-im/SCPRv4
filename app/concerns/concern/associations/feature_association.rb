# Features
# Required:
# * feature_type_id
# * AssetAssociation
module Concern
  module Associations
    module FeatureAssociation
      
      extend ActiveSupport::Concern

      included do
        before_save :autoselect_feature_type, if: :should_autoselect_feature_type?
      end

      # Returns a Feature object
      def feature
        ArticleFeature.find_by_id(self.feature_type_id)
      end

      # Set the feature_type_id.
      # Accepts a symbol
      def feature=(value)
        case value
        when ArticleFeature
          self.feature_type_id = value.id
        when Symbol, String
          self.feature_type_id =
            ArticleFeature.find_by_key(value.to_sym).try(:id)
        when Integer
          self.feature_type_id = value
        when NilClass
          self.feature_type_id = nil
        end
      end

      def autoselect_feature_type
        if try(:audio).try(:any?)
          self.feature = :audio
        elsif try(:asset_display) == :slideshow
          self.feature = :slideshow
        end
      end

      private
      
      def should_autoselect_feature_type?
        feature_type_id.nil? && (publishing? || published?)
      end
    end
  end
end
