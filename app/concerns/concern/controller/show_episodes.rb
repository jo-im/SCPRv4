module Concern
  module Controller
    module ShowEpisodes
      extend ActiveSupport::Concern
      def render_kpcc_episode
        @content = @episode.published_content.map(&:to_article)
        @featured_programs = KpccProgram.where.not(id: @program.id, is_featured: false).first(4)
        if @program.is_segmented?
          @episodes = @program.episodes.published.order("air_date").first(4)
          render 'programs/standard_program_episode', layout: 'application' and return
        else
          render 'programs/kpcc/old/episode_standalone'
        end
      end
      def render_standard_episode
        @segments = @episode.segments
        render 'programs/standard_program_episode', layout: 'application' and return
      end
      def render_external_episode
        @segments = @episode.segments
        render 'programs/external_program_episode', layout: 'application' and return
      end
    end
  end
end