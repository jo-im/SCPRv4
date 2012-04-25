def content_base_associations(object, evaluator)
  FactoryGirl.create_list(:asset, evaluator.asset_count.to_i, content: object)
  FactoryGirl.create_list(:link, evaluator.link_count.to_i, content: object)
  FactoryGirl.create_list(:brel, evaluator.brel_count.to_i, content: object)
  FactoryGirl.create_list(:frel, evaluator.frel_count.to_i, related: object)
  FactoryGirl.create_list(:byline, evaluator.byline_count.to_i, content: object)
  FactoryGirl.create(:content_category, content: object, category: FactoryGirl.create(evaluator.category_type)) if evaluator.category_type.present? && evaluator.with_category
end

FactoryGirl.define do

# Schedule #########################################################
  factory :schedule do # Requires us to pass in kpcc_proram_id or other_program_id and program. There must be a better way to do this.
    sequence(:day) { |n| (Time.now + 60*60*24*n).day }
    start_time "00:00:00" # arbitrary
    end_time "02:00:00" # aribtrary
    sequence(:program) { |n| "Cool Program #{n}" } 
    url { "/programs/#{program.parameterize}" }
    kpcc_program_id 1
  end
  

# User #########################################################
  factory :user, class: "Bio", aliases: [:author] do
    bio "This is a bio"
    short_bio "Short!"
    email "email@kpcc.org"
    is_public true
    last_name "Ricker"
    name "Bryan Ricker"
    slugged_name "bryan-ricker"
    title "Rails Developer"
    twitter "@kpcc"
    sequence(:user_id) 
  end


# KpccProgram #########################################################
  factory :kpcc_program, aliases: [:show] do
    sequence(:title) { |n| "Show #{n}" }
    slug { title.parameterize }
    teaser "AirTalk, short teaser, etc."
    description "This is the description for AirTalk!"
    host "Larry Mantle"
    airtime "Weekdays 10 a.m.-12 p.m."
    air_status "onair"
    podcast_url "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewPodcast?id=73329334&uo=6"
    rss_url "http://feeds.scpr.org/kpccAirTalk"
    sidebar "Sidebar Content"    
    twitter_url "airtalk"
    facebook_url "http://www.facebook.com/KPCC.AirTalk"
    display_segments 1
    display_episodes 1
    
    ignore { segment Hash.new } # Ensures that `merge` has something to do in the after_create block
    ignore { episode Hash.new } # Ensures that `merge` has something to do in the after_create block
    ignore { missed_it_bucket Hash.new }
    ignore { episode_count 0 }
    ignore { segment_count 0 }
    
    after_create do |kpcc_program, evaluator|
      FactoryGirl.create_list(:show_segment, evaluator.segment_count.to_i, evaluator.segment.merge!(show: kpcc_program))
      FactoryGirl.create_list(:show_episode, evaluator.episode_count.to_i, evaluator.episode.merge!(show: kpcc_program))
      
      # TODO Figure out a cleaner way to do this
      if evaluator.missed_it_bucket_id.blank?
        kpcc_program.missed_it_bucket = FactoryGirl.create(:missed_it_bucket, evaluator.missed_it_bucket.reverse_merge!(title: kpcc_program.title))
        kpcc_program.save!
      end
    end
  end
  

# OtherProgram #########################################################
  factory :other_program do
    sequence(:title) { |n| "Other Program #{n}" }
    slug { title.parameterize }
    teaser "Outside Program"
    description "This is the description for the outside program!"
    host "Larry Mantle"
    airtime "Weekdays 10 a.m.-12 p.m."
    air_status "onair"
    podcast_url "http://www.npr.org/rss/podcast.php?id=510294"
    rss_url "http://oncentral.org/rss/latest" # This column cannot be null?
    sidebar "Sidebar Content"
    web_url "http://www.bbc.co.uk/worldservice/"
    produced_by "BBC"
  end
  

# ShowRundown #########################################################
  factory :show_rundown do
    episode
    segment
  end
  

# Blog #########################################################
  factory :blog do
    sequence(:name) { |n| "Blog #{n}" }
    slug { name.parameterize }
    _teaser { "This is the teaser for #{name}!" }
    description "This is a description for this blog."
    head_image "http://media.scpr.org/assets/images/heads/larry_transparent.png"
    is_active true
    is_remote false
    is_news true
    feed_url "http://oncentral.org/rss/latest"
    custom_url "http://scpr.org" # it's a required field?
    
    factory :news_blog do
      is_news true
    end
    
    factory :non_news_blog do
      is_news false
    end
    
    factory :remote_blog do
      is_remote true
      feed_url "http://oncentral.org/rss/latest"
    end
  end
  

# Event #########################################################
  factory :event do
    sequence(:id, 1) # Not auto-incrementing in database?
    sequence(:title) { |n| "A Very Special Event #{n}" }
    slug { title.parameterize }
    description "This is a very special event."
    etype "comm" # This is actually "type" in mercer
    sponsor "Patt Morrison"
    sponsor_link "http://oncentral.org"
    sequence(:starts_at) { |n| Time.now + 60*60*24*n }
    ends_at { starts_at + 60*60*1 }
    is_all_day 0
    location_name "The Crawford Family Forum"
    location_link "http://www.scpr.org/crawfordfamilyforum"
    rsvp_link "http://kpcc.ticketleap.com/connie-rice/"
    show_map 1
    address_1 "474 South Raymond Avenue"
    address_2 "Second Level" # required column?
    city "Pasadena"
    state "CA"
    zip_code "91105"
    created_at Time.now
    modified_at Time.now
    for_program "airtalk"
    audio "audio/events/2011/05/23/Father_Boyle.mp3"
    archive_description "This is the description that shows after the event has happened"
    is_published 1
    show_comments 1
    _teaser "This is a short teaser"
    
    ignore { asset_count 0 }
    after_create do |event, evaluator|
      FactoryGirl.create_list(:asset, evaluator.asset_count.to_i, content: event)
    end
  end
  

# ContentAsset#########################################################
  factory :asset, class: ContentAsset do
    sequence(:id, 1)
    asset_order 1
    asset_id 33585 # This is an actual BrightCove asset on AssetHost. This is not the best way to test this but it'll do for now.
    sequence(:caption) { |n| "Caption #{n}" } 
  end


# ContentByline #########################################################
  factory :byline, class: "ContentByline" do # Requires we pass in "content"
    role 0
    user
    name "Dan Jones"
  end
  
  
# Category #########################################################
  factory :category do
    trait :is_news do 
      sequence(:category) { |n| "Local #{n}" }
      is_news true
    end

    trait :is_not_news do
      sequence(:category) { |n| "Culture #{n}" }
      is_news false
    end

    slug { category.parameterize }
    sequence(:comment_bucket_id)

    factory :category_news, traits: [:is_news]
    factory :category_not_news, traits: [:is_not_news]
  end
  

# ContentCategory #########################################################
  factory :content_category do
    # Empty, forcing us to pass content and category every time we create one
  end

# Related #########################################################
factory :related_content, class: Related do
  factory :brel do # "brels" - needs content
    flag 0
    related { |brel| brel.association(:content_shell) } #TODO Need to be able to pass in any type of factory here
  end

  factory :frel do # "frels" - needs related
    flag 0
    content { |frel| frel.association(:content_shell) } #TODO Need to be able to pass in any type of factory here
  end
end
  
# Link #########################################################
  factory :link do
    title "A Related Link"
    link "http://oncentral.org"
    link_type "website"
  end
  
# MissedItBucket #########################################################
  factory :missed_it_bucket do
    title "Airtalk"
    ignore { contents_count 0 }
    after_create do |object, evaluator|
      FactoryGirl.create_list(:missed_it_content, evaluator.contents_count.to_i, missed_it_bucket: object)
    end
  end

# MissedItContent #########################################################
  factory :missed_it_content do
    missed_it_bucket
    content { |mic| mic.association(:content_shell) }
  end
  
##########################################################
### ContentBase Classes
##### *NOTE:* The name of the factory should eq `ClassName.to_s.underscore.to_sym`, i.e. NewsStory = :news_story
##### This is to please `#make_content` in /spec/support/content_base_helpers.rb
##########################################################

# ContentBase - Common attributes ##########################################################
  trait :content_base do
    ignore { asset_count 0 }
    ignore { link_count 0 }
    ignore { brel_count 0 }
    ignore { frel_count 0 }
    ignore { with_category false }
    ignore { byline_count 0 }
    status 5
  end
  
  trait :sequenced_published_at do
    sequence(:published_at) { |n| Time.now + 60*60*n }
  end
  

# VideoShell ##########################################################
  factory :video_shell do
    content_base
    sequence(:headline) { |n| "This is a video #{n}" }
    slug { headline.parameterize }
    body "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque a enim a leo auctor lobortis. Etiam aliquam metus sit amet nulla blandit molestie. Cras lobortis odio non turpis laoreet non congue libero commodo. Vestibulum dolor nibh, eleifend eu suscipit eget, egestas sed diam. Proin cursus rutrum nibh eget consequat. Donec viverra augue sed nisl ultrices venenatis id eget quam. Cras id dui a magna tristique fermentum in sit amet lacus. Curabitur urna metus, mattis vel mollis quis, placerat vitae turpis.
    Phasellus et tortor eget mauris imperdiet fermentum. Mauris a rutrum augue. Quisque at fringilla libero. Phasellus vitae nisl turpis, at sodales erat. Duis et risus orci, at placerat quam. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Etiam sed nibh non odio pretium rhoncus et nec ipsum. Nam sed dignissim velit."
    sequenced_published_at
    
    ignore { related_factory "content_shell" }
    ignore { category_type :category_not_news }
    
    after_create do |object, evaluator|
      content_base_associations(object, evaluator)
    end
  end
  

# NewsStory #########################################################
  factory :news_story do
    content_base
    primary_reporter_id 7
    sequence(:headline) { |n| "This is news story ##{n}" }
    slug { headline.parameterize }
    news_agency "KPCC"
    _teaser "This is a teaser"
    body "This is a big block of text for the news story"
    locale "local"
    editing_status 2
    is_published 1 # required field by db but not used anymore
    byline "Local Byline"
    comment_count 1
    
    sequenced_published_at
    ignore { related_factory "content_shell" }
    ignore { category_type :category_news }
    
    after_create do |object, evaluator|
      content_base_associations(object, evaluator)
    end
  end


# ShowEpisode #########################################################
  factory :show_episode, aliases: [:episode] do
    content_base
    show
    sequence(:air_date) { |n| (Time.now + 60*60*24*n).strftime("%Y-%m-%d") }
    title "AirTalk for May 22, 2009"
    _teaser "This is a short summary of the show"
    comment_count 0

    sequenced_published_at
    
    ignore { segment_count 0 }
    ignore { related_factory "content_shell" }
    ignore { category_type nil }
    
    after_create do |object, evaluator|
      content_base_associations(object, evaluator)
      segments = FactoryGirl.create_list(:show_segment, evaluator.segment_count.to_i, show: object.show)
      segments.each { |segment| segment.episodes << object }
    end
  end


# ShowSegment #########################################################
  factory :show_segment, aliases: [:segment] do
    content_base
    show
    sequence(:title) { |n| "Show Segment #{n}" }
    slug { title.parameterize }
    _teaser "This is a teaser for the show segment"
    body "This is a description of the show segment"
    locale "local"
    comment_count 1
    _short_headline "Short Headline"
    audio_date { Time.now }
    enco_number 999

    sequenced_published_at
    ignore { related_factory "content_shell" }
    ignore { category_type :category_news }
    
    after_create do |object, evaluator|
      content_base_associations(object, evaluator)
    end
  end


# BlogEntry #########################################################
  factory :blog_entry do
    content_base
    sequence(:title) { |n| "Blog Entry #{n}" }
    slug { title.parameterize }
    content "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque a enim a leo auctor lobortis. Etiam aliquam metus sit amet nulla blandit molestie. Cras lobortis odio non turpis laoreet non congue libero commodo. Vestibulum dolor nibh, eleifend eu suscipit eget, egestas sed diam. Proin cursus rutrum nibh eget consequat. Donec viverra augue sed nisl ultrices venenatis id eget quam. Cras id dui a magna tristique fermentum in sit amet lacus. Curabitur urna metus, mattis vel mollis quis, placerat vitae turpis.
    Phasellus et tortor eget mauris imperdiet fermentum. Mauris a rutrum augue. Quisque at fringilla libero. Phasellus vitae nisl turpis, at sodales erat. Duis et risus orci, at placerat quam. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Etiam sed nibh non odio pretium rhoncus et nec ipsum. Nam sed dignissim velit."
    author
    blog
    blog_slug { slug }
    is_published 1 # required field by db but not used anymore
    comment_count 1

    sequenced_published_at
    ignore { related_factory "content_shell" }
    ignore { category_type :category_not_news }
    
    after_create do |object, evaluator|
      content_base_associations(object, evaluator)
    end
  end


# ContentShell #########################################################
  factory :content_shell do
    content_base
    comment_count 2
    sequence(:headline) { |n| "This is some outside Content #{n}" }
    site "blogdowntown"
    sequence(:_teaser) { |n| "This is a teaser for the content #{n}" }
    url "http://blogdowntown.com/2011/11/6494-green-paint-welcomes-cyclists-to-a-reprioritized"
    
    sequence(:pub_at) { |n| Time.now + 60*60*n }
    ignore { related_factory "video_shell" }
    ignore { category_type :category_news }

    after_create do |object, evaluator|
      content_base_associations(object, evaluator)
    end
  end
end