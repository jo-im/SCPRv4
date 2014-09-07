module FeatureCandidate
  class Base
    attr_reader \
      :category,
      :content,
      :score


    def initialize(category, options={})
      @category = category
      @excludes = Array(options[:exclude])

      if @content = find_content
        @score = calculate_score
      end
    end


    private

    def decay(time, decay_length)
      Math.exp(-(decay_length.to_f/100) * ((Time.zone.now - time) / 1.hour.to_i))
    end
  end
end
