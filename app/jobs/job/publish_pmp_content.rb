module Job
  class PublishPmpContent < Base

    @priority = :low

    class << self
      def perform profile, id
        record = "Pmp#{profile.capitalize}".constantize.find(id)
        record.publish
      end
    end
  end
end