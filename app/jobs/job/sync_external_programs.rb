##
# SyncExternalPrograms
#
# Import all external programs.
#
module Job
  class SyncExternalPrograms < Base
    @priority = :low

    class << self
      def perform(source=nil)
        ExternalProgram.sync(source)
      end
    end
  end
end
