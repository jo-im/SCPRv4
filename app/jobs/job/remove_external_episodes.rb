module Job
  class RemoveExternalEpisodes < Base
    @priority = :mid

    class << self
      def perform
				ExternalProgram.where('days_to_expiry IS NOT NULL').each do |program|
					program.expired_episodes.destroy_all
				end
      end
    end
  end
end
