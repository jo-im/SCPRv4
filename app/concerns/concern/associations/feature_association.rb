# Features
# Required:
# * feature_id
# * AssetAssociation
module Concern
  module Associations
    module FeatureAssociation
      # Returns a Feature object
      def feature
        Feature.find_by_id(self.feature_id)
      end

      # Set the feature_id.
      # Accepts a symbol
      def feature=(value)
        case value
        when ArticleFeature
          self.feature_id = value.id
        when Symbol, String
          self.feature_id = Feature.find_by_key(value.to_sym).try(:id)
        when Integer
          self.feature_id = value
        end
      end
    end
  end
end
