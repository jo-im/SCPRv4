require "resque/server"

Scprv4::Application.routes.draw do
  # Homepage
  # get '/' => 'home#index', constraints: lambda { |request| !request.cookie_jar[:beta_opt_in]}, as: :root
  # get '/' => 'better_homepage#index', constraints: lambda { |request| request.cookie_jar[:beta_opt_in]}
  get '/' => 'better_homepage#index', as: :root
  get '/beta-homepage', to: redirect("/"), as: :beta_homepage
  get '/homepage/:id/missed-it-content/' => 'home#missed_it_content', as: :homepage_missed_it_content

  # Listen Live
  get '/listen_live/' => 'listen#index', as: :listen
  get '/listen_live/pledge-free' => 'listen#pledge_free_stream', as: :listen_pledge_free
  get '/listen_live/pledge-free/off-air' => 'listen#pledge_free_off_air', as: :listen_pledge_free_off_air
  get '/listen_live/pledge-free/error' => 'listen#pledge_free_error', as: :listen_pledge_free_error
  get '/listen-live' => redirect('/listen_live')
  get '/listenlive'  => redirect('/listen_live')

  # Sections
  get '/category/carousel-content/:object_class/:id' => 'category#carousel_content',  as: :category_carousel, defaults: { format: :js }
  get '/news/'                                       => 'category#news',              as: :latest_news

  # RSS
  get '/feeds/all_news'        => 'feeds#all_news',    as: :all_news_feed
  get '/feeds/take_two'        => 'feeds#take_two',    as: :take_two_feed # Deprecated, delete once replaced with npr_ingest
  get '/feeds/npr_ingest'      => 'feeds#npr_ingest',  as: :npr_ingest_feed
  get '/feeds/flash_briefing'  => 'feeds#flash_briefing'
  get '/feeds/flash_briefing/:category' => 'feeds#flash_briefing'
  get '/feeds/*feed_path', to: redirect { |params, request| "/#{params[:feed_path]}.xml" }



  # Podcasts
  get '/podcasts/mash-up-americans', to: redirect('https://rss.art19.com/the-mash-up-americans', status: 301)
  get '/podcasts/:slug/' => 'podcasts#podcast', as: :podcast, defaults: { format: :xml }
  get '/podcasts/'       => 'podcasts#index',   as: :podcasts


  # Blogs / Entries
  get '/blogs/:blog/archive/:year/:month/'             => "blogs#archive",                as: :blog_archive,         constraints: { year: /\d{4}/, month: /\d{2}/ }
  post '/blogs/:blog/process_archive_select'           => "blogs#process_archive_select", as: :blog_process_archive_select
  get '/blogs/:blog/:year/:month/:day/:id/:slug/'      => "blogs#entry",                  as: :blog_entry,           constraints: { year: /\d{4}/, month: /\d{2}/, day: /\d{2}/, id: /\d+/, slug: /[\w-]+/ }
  get '/blogs/:blog/'                                  => 'blogs#show',                   as: :blog
  get '/blogs/'                                        => 'blogs#index',                  as: :blogs

  # News Stories
  get '/news/:year/:month/:day/:id/:slug/'  => 'news#story',      as: :news_story,  constraints: { year: /\d{4}/, month: /\d{2}/, day: /\d{2}/, id: /\d+/, slug: /[\w_-]+/}


  # Programs / Segments
  get '/programs/:show' => "programs#show"
  get '/programs/:show/featured' => "programs#list", as: :list
  # This route is for displaying a clone of the old layout for featured programs for an index of episodes and segments
  # Legacy route for old Episode URLs
  get '/programs/:show/:year/:month/:day/' => "programs#episode", constraints: { year: /\d{4}/, month: /\d{2}/, day: /\d{2}/ }

  get '/programs/:show/archive/'                      => redirect("/programs/%{show}/#archive")
  post '/programs/:show/archive/'                     => "programs#archive",    as: :program_archive
  get '/programs/:show/:year/:month/:day/:id/'        => "programs#episode",    as: :episode,           constraints: { year: /\d{4}/, month: /\d{2}/, day: /\d{2}/, id: /\d+/ }
  get '/programs/:show/:year/:month/:day/:id/:slug/'  => "programs#segment",    as: :segment,           constraints: { year: /\d{4}/, month: /\d{2}/, day: /\d{2}/, id: /\d+/, slug: /[\w_-]+/}
  get '/programs/:show'                               => 'programs#show',       as: :program
  get '/programs/'                                    => 'programs#index',      as: :programs
  get '/schedule(/:year/:month/:day)'                 => 'programs#schedule',   as: :schedule,          constraints: { year: /\d{4}/, month: /\d{2}/, day: /\d{2}/ }


  # Events
  get '/events/2015/12/05/1766/scpr-gala/' => redirect('/events/2017/03/18/2192/Gala/')
  get '/events/forum/archive/'             => redirect('/events/kpcc-in-person/archive')
  get '/events/forum/'                     => redirect("/events/kpcc-in-person")
  get '/forum'                             => redirect('/events/kpcc-in-person')

  get '/events/kpcc-in-person/archive/'            => 'events#archive',    as: :kpcc_in_person_events_archive
  get '/events/kpcc-in-person/unheard-la'          => 'root_path#unheard_la'
  get '/events/kpcc-in-person/:subtype'            => 'events#kpcc_in_person'
  get '/events/kpcc-in-person/'                    => 'events#kpcc_in_person',      as: :kpcc_in_person_events

  get '/events/sponsored/'                => redirect('/events/kpcc-in-person/sponsored/')
  get '/events/:year/:month/:day/:id/:slug/'  => 'events#show',   as: :event,                 constraints: { year: /\d{4}/, month: /\d{2}/, day: /\d{2}/, id: /\d+/, slug: /[\w_-]+/ }
  get '/events/(list/:list)'              => redirect('/events/kpcc-in-person/list/')
  # Short List
  post '/short-list/archive'                     => "editions#archive"
  get '/short-list/:year/:month/:day'            => "editions#latest", constraints: { year: /\d{4}/, month: /\d{2}/, day: /\d{2}/ }
  get '/short-list/:year/:month/:day/:id/:slug/' => "editions#short_list", as: :short_list, constraints: { year: /\d{4}/, month: /\d{2}/, day: /\d{2}/, id: /\d+/, slug: /[\w-]+/ }
  get '/short-list/latest'                       => "editions#latest"
  get '/short-list/'                             => redirect("/short-list/latest")

  # Legacy route
  get '/events/:year/:month/:day/:slug/'  => 'events#show', constraints: { year: /\d{4}/, month: /\d{2}/, day: /\d{2}/, slug: /[\w_-]+/}


  # Topics
  get '/topics/:slug' => 'topics#show', as: :topic
  get '/topics' => redirect("/")


  # Search
  get '/search/' => 'search#index', as: :search


  # PIJ Queries
  get '/network/questions/:slug/' => "pij_queries#show",  as: :pij_query
  get '/network/'                 => "pij_queries#index", as: :pij_queries


  # About / Bios / Press
  get '/about/press/:slug'        => "press_releases#show",  as: :press_release
  get '/about/press/'             => "press_releases#index", as: :press_releases
  get '/about/people/staff/'      => 'people#index',         as: :staff_index
  get '/about/people/staff/:slug' => 'people#bio',           as: :bio
  get '/about'                    => "home#about_us",        as: :about


  # Article Email Sharing
  get   '/content/share' => 'content_email#new',    :as => :new_content_email
  post  '/content/share' => 'content_email#create', :as => :content_email


  # Archive
  post  '/archive/process/'             => "archive#process_form",  as: :archive_process_form
  get '/archive(/:year/:month/:day)/'   => "archive#show",          as: :archive,                 constraints: { year: /\d{4}/, month: /\d{2}/, day: /\d{2}/ }


  # Sitemaps
  get '/sitemap' => "sitemaps#index", as: :sitemaps,  defaults: { format: :xml }
  get '/sitemap/:action',             as: :sitemap,   defaults: { format: :xml }, controller: "sitemaps"


  #------------------

  namespace :api, defaults: { format: "json" } do
    # PUBLIC
    scope module: "public" do
      # V2
      namespace :v2 do
        match '/' => "articles#options", via: :options, constraints: { method: 'OPTIONS' }

        # Old paths
        get '/content'                  => 'articles#index'
        get '/content/by_url'           => 'articles#by_url'
        get '/content/most_viewed'      => 'articles#most_viewed'
        get '/content/most_commented'   => 'articles#most_commented'
        get '/content/:obj_key'         => 'articles#show'

        resources :articles, only: [:index] do
          collection do
            # These need to be in "collection", otherwise
            # Rails would expect an  :id parameter in
            # the URL.
            get 'most_viewed'      => 'articles#most_viewed'
            get 'most_commented'   => 'articles#most_commented'
            get 'by_url'           => 'articles#by_url'
            get ':obj_key'         => 'articles#show'
          end
        end

        resources :alerts, only: [:index, :show]
        resources :audio, only: [:index, :show]
        resources :editions, only: [:index, :show]
        resources :categories, only: [:index, :show]
        resources :events, only: [:index, :show]
        resources :programs, only: [:index, :show]
        resources :buckets, only: [:index, :show]
        resources :episodes, only: [:index, :show]
        resources :blogs, only: [:index, :show]

        resources :schedule, controller: 'schedule_occurrences',only: [:index] do
          collection do
            get :at,      to: "schedule_occurrences#show"
            get :current, to: "schedule_occurrences#show"
          end
        end
      end # V2


      # V3
      namespace :v3 do
        match '/' => "articles#options", via: :options, constraints: { method: 'OPTIONS' }

        resources :articles, only: [:index] do
          collection do
            # These need to be in "collection", otherwise
            # Rails would expect an  :id parameter in
            # the URL.
            get 'most_viewed'      => 'articles#most_viewed'
            get 'most_commented'   => 'articles#most_commented'
            get 'by_url'           => 'articles#by_url'
            get ':obj_key'         => 'articles#show'
          end
        end

        resources :alerts, only: [:index, :show]
        resources :audio, only: [:index, :show]
        resources :editions, only: [:index, :show]
        resources :categories, only: [:index, :show]
        resources :events, only: [:index, :show]
        resources :members, only: [:show]
        resources :programs, only: [:index, :show]
        resources :buckets, only: [:index, :show]
        resources :episodes, only: [:index, :show]
        resources :blogs, only: [:index, :show]
        resources :data_points, only: [:index, :show]
        resources :tags, only: [:index, :show]
        resources :lists, only: [:index, :show]

        get "settings" => "settings#index"
        get "settings/:context" => "settings#index"

        get "programs/:id/episodes/archive/:year/:month" => "archive_browser#index"
        get "programs/:id/histogram"                => "programs#histogram"

        resources :schedule, controller: 'schedule_occurrences',only: [:index] do
          collection do
            get :at,      to: "schedule_occurrences#show"
            get :current, to: "schedule_occurrences#show"
          end
        end
      end # V3
    end


    # PRIVATE
    namespace :private do
      # V2
      namespace :v2 do
        match '/' => "articles#options", via: :options, constraints: { method: 'OPTIONS' }

        resources :articles, only: [:index] do
          collection do
            # These need to be in "collection", otherwise
            # Rails would expect an  :id parameter in
            # the URL.
            get 'by_url'   => 'articles#by_url'
            get ':obj_key' => 'articles#show'
          end
        end
      end
    end
  end

  #------------------

  mount Outpost::Secretary::Engine => '/outpost', as: 'secretary'
  mount Outpost::Engine => '/outpost', as: 'outpost'

  namespace :outpost do
    resque_constraint = ->(request) do
      user_id = request.session.to_hash["user_id"]

      if user_id && u = AdminUser.find_by(:id => user_id)
        u.is_superuser?
      else
        false
      end
    end

    constraints resque_constraint do
      mount Resque::Server.new, :at => "resque"
    end

    concern :preview do
      put "preview", on: :member
      patch "preview", on: :member
      post "preview", on: :collection
    end

    concern :search do
      get "search", on: :collection, as: :search
    end

    # This is an annoying hack. This route needs to be above the
    # Secretary mounted routes. We need to figure out a way to
    # inject routes into the middle of a namespace. We can't mount
    # the routes at the bottom because of the catch-all for error
    # handling.
    resources :admin_users, concerns: [:search] do
      get "activity", on: :member, as: :activity
    end

    get 'search', to: 'home#search', as: :search

  end

  namespace :outpost do
    resources :recurring_schedule_rules, concerns: [:preview, :search]
    resources :schedule_occurrences, concerns: [:search]
    resources :podcasts, concerns: [:search]
    resources :breaking_news_alerts, concerns: [:search] do
      member do
        get 'bodies', as: :bodies
      end
    end
    resources :featured_comment_buckets, concerns: [:search]
    resources :categories, concerns: [:search]
    resources :topics, concerns: [:search]
    resources :missed_it_buckets, concerns: [:search]
    resources :external_programs, concerns: [:search]
    resources :kpcc_programs, concerns: [:search]
    resources :blogs, concerns: [:search]
    resources :content_shells, concerns: [:search]
    resources :featured_comments, concerns: [:search]
    resources :quotes, concerns: [:search]
    resources :data_points, concerns: [:search]
    resources :bios, concerns: [:search]
    resources :press_releases, concerns: [:search]
    resources :abstracts, concerns: [:search]
    resources :editions, concerns: [:search] do
      member do
        get 'bodies', as: :bodies
      end
    end

    resources :verticals
    resources :landing_pages
    resources :tags, concerns: [:search]

    resources :homepages, concerns: [:preview, :search]
    resources :pij_queries, concerns: [:preview, :search]
    resources :flatpages, concerns: [:preview, :search]
    resources :show_episodes, concerns: [:preview, :search]
    resources :show_segments, concerns: [:preview, :search]
    resources :news_stories, concerns: [:preview, :search]
    resources :blog_entries, concerns: [:preview, :search]
    resources :events, concerns: [:preview, :search]
    resources :pledge_drives, concerns: [:search]
    resources :broadcast_contents, concerns: [:search]

    resources :better_homepages, concerns: [:preview, :search]

    resources :lists, concerns: [:search]

    resources :remote_articles, only: [:index], concerns: [:search] do
      member do
        post "import", as: :import
        put "skip", as: :skip
      end

      collection do
        post "sync", as: :sync
      end
    end

    get "trigger_error" => 'home#trigger_error'
    get "*path" => 'errors#not_found'
  end

  get "trigger_error" => 'home#trigger_error'
  get "*path" => 'root_path#handle_path', as: :root_slug
end
