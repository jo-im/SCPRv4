##
# RelatedContentAssociation
#
# Defines forward and backwards relations between two pieces of content.
module Concern
  module Associations
    module RelatedContentAssociation
      extend ActiveSupport::Concern

      included do
        # This should be "referrer" and "referee"
        has_many :outgoing_references,
          -> { order('position') },
          :as           => :content,
          :class_name   => "Related",
          :dependent    => :destroy

        has_many :incoming_references,
          -> { order('position').where.not(content_type: ["Tag", "BroadcastContent"]) },
          :as           => :related,
          :class_name   => "Related",
          :dependent    => :destroy
        # ^^^
        # Sometimes we use the related content association to relate
        # content to non-content, like Tags and BroadcastContent.  However,
        # since we need to convert our references to articles here, and
        # since said non-content does not convert to an article, we need to
        # only include objects that are of content models.
        #
        # I'd like to find a better way to relate content to non-content but,
        # for now, I see no reason why content would need to be aware of
        # its related non-content.  Usually, we only need non-content to
        # be able to have a list of content it can reference.

        after_save :_destroy_incoming_references,
          :if => -> { respond_to?(:unpublishing?) ? self.unpublishing? : true }

        accepts_json_input_for :outgoing_references

        if self.has_secretary?
          tracks_association :outgoing_references
        end

        before_save :outgoing_references_only
      end

      def outgoing_references_only
        incoming_reference_ids = incoming_references.map(&:content_id)
        bad_outgoing_references = outgoing_references.where(related_id: incoming_reference_ids)
        if bad_outgoing_references.any?
          bad_outgoing_references.destroy_all
          clear_association_cache
        end
      end

      #-------------------------
      # Return any content which this content references,
      # or which is referencing this content
      def related_content
        @related_content ||= begin
          content = []

          # Outgoing references: Where `content` is this object
          # So we want to grab `related`
          self.outgoing_references.includes(:related).each do |reference|
            content.push reference.related
          end

          # Incoming references: Where `related` is this object
          # So we want to grab `content`
          self.incoming_references.includes(:content).each do |reference|
            content.push reference.content
          end

          # Compact to make sure no nil records get through - those would
          # be unpublished content.
          content.compact.uniq
            .sort { |a, b|
              if b.try(:public_datetime) && a.try(:public_datetime)
                b.public_datetime <=> a.public_datetime
              elsif b.try(:published_at) && a.try(:published_at)
                b.published_at  <=> a.published_at
              end
            }
        end
      end


      private

      def build_outgoing_reference_association(outgoing_reference_hash, content)
        if content.published?
          Related.new(
            :position => outgoing_reference_hash["position"].to_i,
            :related  => content,
            :content  => self
          )
        end
      end

      def _destroy_incoming_references
        self.incoming_references.clear
      end
    end # RelatedContentAssociation
  end # Associations
end # Concern
