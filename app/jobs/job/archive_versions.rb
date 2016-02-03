require 'rake'
module Job
  class ArchiveVersions < Base
    @priority = :low

    class << self
      def perform
        Rake::Task.clear
        Scprv4::Application.load_tasks
        Rake::Task['scprv4:archive_versions'].invoke
      end
    end
  end
end
