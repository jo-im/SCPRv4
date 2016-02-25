module Concern
  module Associations
    module EpisodeRundownAssociation
      extend ActiveSupport::Concern

      included do
        has_many :rundowns,
          :class_name     => "ShowRundown",
          :foreign_key    => "content_id",
          :as             => "content",
          :dependent      => :destroy,
          :before_add     => :set_rundown_position

        has_many :episodes,
          -> { order('status desc,air_date desc') },
          :through    => :rundowns,
          :source     => :episode,
          :autosave   => true

        before_save ->{episodes.update_all(updated_at: Time.now) if changed?}
      end

      def set_rundown_position(rundown)
        if !rundown.position
          rundown.position = self.rundowns.length + 1
        end
      end

    end
  end
end