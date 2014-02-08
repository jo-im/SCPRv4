##
# SyncExternalPrograms
#
# Import all external programs.
#
module Job
  class SyncExternalPrograms < Base
    @priority = :low

    class << self
      def perform
        ExternalProgram.sync
      end
    end
  end
end
