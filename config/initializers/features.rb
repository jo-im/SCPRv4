[
    {
      :id               => 0,
      :key              => :slideshow,
      :name             => "Slideshow",
      :asset_display    => "slideshow"
    },
    {
      :id               => 1,
      :key              => :video,
      :name             => "Video",
      :asset_display    => "video"
    },
    {
      :id               => 2,
      :key              => :poll,
      :name             => "Poll",
      :asset_display    => "photo"
    },
    {
      :id               => 3,
      :key              => :map,
      :name             => "Map",
      :asset_display    => "photo"
    },
    {
      :id               => 4,
      :key              => :infographic,
      :name             => "Infographic",
      :asset_display    => "photo"
    },
    {
      :id               => 5,
      :key              => :audio,
      :name             => "Audio",
      :asset_display    => "photo"
    },
    {
      :id               => 6,
      :key              => :taketwo,
      :name             => "Take Two",
      :asset_display    => "photo"
    },
    {
      :id               => 7,
      :key              => :airtalk,
      :name             => "AirTalk",
      :asset_display    => "photo"
    },
    {
      :id               => 8,
      :key              => :offramp,
      :name             => "Off-Ramp",
      :asset_display    => "photo"
    }
  ].map { |attributes| ArticleFeature.new(attributes) }
