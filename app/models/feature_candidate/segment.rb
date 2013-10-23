module FeatureCandidate
  class Segment < Base
    LIMIT           = 1
    DECAY_RATE      = -0.02
    INITIAL_SCORE   = 10


    private

    def find_content
      ContentBase.search({
        :classes    => [ShowSegment],
        :limit      => LIMIT,
        :with       => { category: @category.id },
        :without    => { obj_key: @exclude.map(&:obj_key_crc32) }
      }).first.try(&:to_article)
    end

    def calculate_score
      INITIAL_SCORE * decay(@content.public_datetime, DECAY_RATE)
    end
  end
end
