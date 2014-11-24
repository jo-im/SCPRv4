module FeatureCandidate
  class Slideshow < Base
    LIMIT           = 1
    DECAY_LENGTH    = 1
    INITIAL_SCORE   = 5 # slideshow initial scores are 5 * number of slides


    private

    def find_content
      ContentBase.search({
        :classes     => [NewsStory, BlogEntry, ShowSegment],
        :limit       => LIMIT,
        :with        => {
          "category.id"   => @category.id,
          "feature"       => "slideshow"
        },
        :without => { obj_key: @excludes.map(&:obj_key) }
      }).first
    end

    def calculate_score
      (INITIAL_SCORE + @content.assets.count) *
      decay(@content.public_datetime, DECAY_LENGTH)
    end
  end
end
