module Concern
  module Associations
    module PmpContentAssociation

      def publish_to_pmp
        if @publish_to_pmp.nil?
          pmp_content ? true : false
        else
          is_true? @publish_to_pmp
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
        # If we need different behavior for other tags,
        # we should change this to ask the tags for these permissions
        if respond_to?(:tags) && tags.where(slug: "california-counts").any?
          groups.concat PmpGroup.where(title: "California Counts").map(&:link).to_a
        end
        groups
      end

      alias_method :publish_to_pmp?, :publish_to_pmp

      def destroy_pmp_content
        if !publish_to_pmp?
          pmp_content.try(:destroy)
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
          if publish_to_pmp && content && pmp_publishable?
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

      def plaintext_body
        ContentRenderer.new(self).render_plaintext
      end

      def rendered_body
        ContentRenderer.new(self).render_with_assets
      end

      def templated_body
        # Returns the straight body
        # except without specific tags
        ContentRenderer.new(self).render_templated
      end

      def __versioned_changes
        old_value = pmp_content.present?
        new_value = is_true?(@publish_to_pmp)
        if new_value != old_value
          super.merge({'publish_to_pmp' => [old_value.to_s, new_value.to_s]})
        else
          super
        end
      end

      ["story", "audio", "image", "episode", "broadcast"].each do |profile_name|
        mod = Module.new do
          extend ActiveSupport::Concern
          included do
            attr_writer :publish_to_pmp
            has_one :pmp_content, as: :content, dependent: :destroy
            has_one "pmp_#{profile_name}".to_sym, as: :content, foreign_key: :content_id
            after_save :destroy_pmp_content, :build_pmp_content, :publish_pmp_content
            if profile_name == 'broadcast'
              has_many :broadcast_contents, through: :incoming_references, source: :content, source_type: "BroadcastContent"
            end
          end
          include PmpContentAssociation
          self.const_set "PMP_PROFILE", profile_name
        end
        self.const_set "#{profile_name.capitalize}Profile", mod
      end



      private

      def is_true? value
        # in the context of how we are treating a value we 
        # are getting from a form
        [true, "true", 1, "1", "yes"].include? value
      end

      def pmp_publishable?
        ## This just tells us whether or not we have the right status to publish.
        try(:pending?) || try(:published?) || try(:publishing?)
      end

      class ContentRenderer < ActionView::Base
        include ApplicationHelper
        def initialize content
          content.reload
          @content = content
          @pmp_content = content.pmp_content
          super ActionController::Base.view_paths, {}, ActionController::Base.new
        end
        def render_with_assets
          render(template: "pmp/#{@pmp_content.profile}", layout: false, locals: {content: @content})
        end
        def render_plaintext
          Nokogiri::HTML(@content.body).xpath("//text()").to_s
        end
        def render_templated
          banned_tags = "iframe,script"
          doc = Nokogiri::HTML::DocumentFragment.parse(@content.body)
          doc.css(banned_tags).each{|t| t.replace(Nokogiri::HTML::DocumentFragment.parse(''))}
          doc.to_s.html_safe
        end
        def params
          {} # ActionView expects this, but obviously it isn't useful in this context.
        end
      end

    end
  end
end
