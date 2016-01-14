module Concern
  module Associations
    module PmpContentAssociation

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

      def destroy_pmp_content
        if !publish_to_pmp?
          pmp_content.try(:destroy)
          reload
        end
      end

      def build_pmp_content
        if valid? && publish_to_pmp? && !pmp_content
          content = create_pmp_content profile: self.class::PMP_PROFILE
        end
      end

      def publish_pmp_content
        if valid?
          content = pmp_content
          if publish_to_pmp && content && (try(:published?) || try(:publishing?))
            async_publish_pmp_content
          end
        end
      end

      def async_publish_pmp_content
        content = pmp_content
        if (published_to_pmp? && changed?) || !published_to_pmp?
          content.async_publish
        end
      end

      ["story", "audio", "image"].each do |profile_name|
        mod = Module.new do
          extend ActiveSupport::Concern
          included do
            attr_writer :publish_to_pmp
            has_one :pmp_content, as: :content, dependent: :destroy
            has_one "pmp_#{profile_name}".to_sym, as: :content, foreign_key: :content_id
            after_save :destroy_pmp_content, :build_pmp_content, :publish_pmp_content
          end
          include PmpContentAssociation
          self.const_set "PMP_PROFILE", profile_name
        end
        self.const_set "#{profile_name.capitalize}Profile", mod
      end

    end
  end
end
