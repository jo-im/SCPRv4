module Job
  class PublishPmpContent < Base

    @priority = :low

    class << self
      def perform profile, id
        ## The convention here is to assume that the name of the class begins with "Pmp"
        ## and is followed by the profile name. (e.g. 'story', 'image', 'audio')
        record = "Pmp#{profile.capitalize}".constantize.find(id)
        record.publish
      end
    end
  end
end