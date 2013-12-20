module AudioSync
  class Base
    attr_reader :audio

    def initialize(audio)
      @audio = audio
    end
  end
end
