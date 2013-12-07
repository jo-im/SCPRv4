FEATURES = [
    {
      :id               => 1,
      :key              => :slideshow,
      :name             => "Slideshow",
      :asset_display    => "slideshow"
    },
    {
      :id               => 2,
      :key              => :video,
      :name             => "Video",
      :asset_display    => "video"
    },
    {
      :id               => 3,
      :key              => :poll,
      :name             => "Poll",
      :asset_display    => "photo"
    },
    {
      :id               => 4,
      :key              => :map,
      :name             => "Map",
      :asset_display    => "photo"
    },
    {
      :id               => 5,
      :key              => :infographic,
      :name             => "Infographic",
      :asset_display    => "photo"
    },
    {
      :id               => 6,
      :key              => :audio,
      :name             => "Audio",
      :asset_display    => "photo"
    },
    {
      :id               => 7,
      :key              => :taketwo,
      :name             => "Take Two",
      :asset_display    => "photo"
    },
    {
      :id               => 8,
      :key              => :airtalk,
      :name             => "AirTalk",
      :asset_display    => "photo"
    },
    {
      :id               => 9,
      :key              => :offramp,
      :name             => "Off-Ramp",
      :asset_display    => "photo"
    }
  ].map { |attributes| ArticleFeature.new(attributes) }.freeze
