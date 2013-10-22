module FeatureCandidate
  class FeaturedComment < Base
    DECAY_RATE      = -0.04
    INITIAL_SCORE   = 20


    private

    def find_content
      bucket = @category.comment_bucket
      return nil if !bucket

      bucket.comments.published.first
    end

    def calculate_score
      INITIAL_SCORE * decay(@content.created_at, DECAY_RATE)
    end
  end
end
