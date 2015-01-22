module Job
  class PublishNotification < Base
    @priority = :low

    class << self
      def perform(message, room)
        config = Rails.application.config.api['campfire']

        campfire = Tinder::Campfire.new(config['domain'],
          token: config['token'])

        room = campfire.find_room_by_id(config['rooms'][room])
        room.speak(message)
      end
    end
  end
end
