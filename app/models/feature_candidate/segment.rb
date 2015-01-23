module FeatureCandidate
  class Segment < Base
    LIMIT           = 1
    DECAY_LENGTH    = 2
    INITIAL_SCORE   = 10


    private

    def find_content
      ContentBase.search({
        :classes    => [ShowSegment],
        :limit      => LIMIT,
        :with       => { "category.id" => @category.id },
        :without    => { obj_key: @excludes.map(&:obj_key) }
      }).first
    end

    def calculate_score
      INITIAL_SCORE * decay(@content.public_datetime, DECAY_LENGTH)
    end
  end
end
