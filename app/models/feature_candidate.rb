module FeatureCandidate
  class Base
    attr_reader \
      :category,
      :content,
      :score

    def initialize(category, options={})
      @category = category
      @exclude = Array(options[:exclude])

      if @content = find_content
        @score = calculate_score
      end
    end


    private

    def decay(time, decay_rate)
      # lower decay decays more slowly. eg. rate of -0.01 
      # will have a lower score after 3 days than -0.05
      Math.exp(decay_rate * (Time.now - time) / 1.hour.to_i)
    end
  end
end
