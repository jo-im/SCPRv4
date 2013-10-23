module FeatureCandidate
  class Slideshow < Base
    LIMIT           = 1
    DECAY_RATE      = -0.01
    INITIAL_SCORE   = 5 # slideshow initial scores are 5 * number of slides


    private

    def find_content
      ContentBase.search({
        :classes     => [NewsStory, BlogEntry, ShowSegment],
        :limit       => LIMIT,
        :with        => {
          :category     => @category.id,
          :is_slideshow => true
        },
        :without => { obj_key: @exclude.map(&:obj_key_crc32) }
      }).first.try(&:to_article)
    end

    def calculate_score
      (INITIAL_SCORE + @content.assets.size) *
      decay(@content.public_datetime, DECAY_RATE)
    end
  end
end
