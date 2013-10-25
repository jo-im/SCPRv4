module FeatureCandidate
  class FeaturedComment < Base
    DECAY_LENGTH    = 4
    INITIAL_SCORE   = 20


    private

    def find_public_datetime
      @content.created_at
    end

    def find_content
      bucket = @category.comment_bucket
      return nil if !bucket

      bucket.comments.published.first
    end

    def calculate_score
      INITIAL_SCORE * decay(@content.created_at, DECAY_LENGTH)
    end
  end
end
