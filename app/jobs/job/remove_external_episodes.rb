module Job
  class RemoveExternalEpisodes < Base
    @priority = :mid

    class << self
      def perform
        logger.info "Sweeping expired episodes form external programs. - #{Time.now}"
        ExternalProgram.where('days_to_expiry IS NOT NULL').each do |program|
          program.expired_episodes.destroy_all
        end
        logger.info "Finished sweeping expired external episodes. - #{Time.now}"
      end
    end
  end
end