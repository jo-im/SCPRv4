# Features
# Required:
# * feature_type_id
# * AssetAssociation
module Concern
  module Associations
    module FeatureAssociation
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
        end
      end
    end
  end
end
