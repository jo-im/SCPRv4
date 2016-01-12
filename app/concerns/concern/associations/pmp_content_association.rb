module Concern
  module Associations
    module PmpContentAssociation
      extend ActiveSupport::Concern

      included do
        attr_writer :publish_to_pmp
        has_one :pmp_content, as: :content, dependent: :destroy
        ## this should probably be only made to happen
        ## for 'story' content and not things like 
        ## audio or image assets
        before_save :save_pmp_content
      end

      def publish_to_pmp
        if @publish_to_pmp.nil?
          pmp_content ? true : false
        else
          [true, "true", 1, "1", "yes"].include? @publish_to_pmp
        end
      end

      def published_to_pmp?
        if pmp_content && pmp_content.published?
          true
        else
          false
        end
      end

      def pmp_permission_groups
        groups = []
        if respond_to?(:tags) && tags.where(slug: "california-counts").any?
          groups.concat [
            PMP::Link.new(href: "https://api-sandbox.pmp.io/docs/724d1c1e-0ab6-4067-8bfb-af72e47ba6fb", operation: "read")
          ]
        end
        groups
      end

      alias_method :publish_to_pmp?, :publish_to_pmp

      def save_pmp_content
        if valid? # can we do better than this?
          if publish_to_pmp? && !pmp_content
            content = create_pmp_content profile: self.class::PMP_PROFILE
            content.async_publish
          elsif !publish_to_pmp? && pmp_content
            pmp_content.destroy
            reload
          end
        end
      end

    end
  end
end
