namespace :scprv4 do

  task :election_feed => :environment do
    log "Caching election results..."
    perform_or_enqueue(Job::CacheElectionResults)
  end

  task :test_rake => [:environment] do
    tasks = %w{
      scprv4:enqueue_index
      scprv4:sync_remote_articles
      scprv4:sync_external_programs
      scprv4:clear_events
      scprv4:fire_content_alarms
      scprv4:sync_audio
      scprv4:schedule:build
      scprv4:enqueue_index
      scprv4:enqueue_index
      scprv4:cache
    }

    tasks.each do |t|
      begin
        Rake::Task[t].invoke
      rescue => e
        warn "Task #{t} raised an error: #{e}"
      end
    end
  end


  task :test_error => [:environment] do
    log "Testing Error..."

    # Now test these errors. This Rake task will fail (that's the point)
    Resque.enqueue(ErrorTestJob)

    NewRelic.with_manual_agent do
      test = ErrorTest.new
      test.test_error
    end

    puts "Finished."
  end

  #----------

  desc "Place a full sphinx index into the queue"
  task :enqueue_index => [:environment] do
    log "Enqueueing sphinx index into Resque..."
    Indexer.enqueue
    puts "Finished."
  end

  #----------

  desc "Sync Remote Articles with the remote sources"
  task :sync_remote_articles => [:environment] do
    log "Syncing remote articles..."
    perform_or_enqueue(Job::SyncRemoteArticles)
  end


  desc "Sync external programs"
  task :sync_external_programs => [:environment] do
    log "Syncing remote programs..."
    perform_or_enqueue(Job::SyncExternalPrograms)
  end



  desc "Clear events cache"
  task :clear_events => [ :environment ] do
    log "Clearing Event Cache..."
    Rails.cache.expire_obj(Event.new_obj_key)
    puts "Finished."
  end



  desc "Fire pending content alarms"
  task :fire_content_alarms => [:environment] do
    log "Firing pending content alarms..."

    NewRelic.with_manual_agent do
      ContentAlarm.fire_pending
    end

    puts "Finished."
  end

  #----------

  desc "Sync all Audio types"
  task :sync_audio => [:environment] do
    log "Syncing Audio..."

    perform_or_enqueue(Job::SyncAudio,
      ["AudioSync::Pending", "AudioSync::Program"])
  end


  namespace :schedule do
    desc "Build the recurring schedule occurrences"
    task :build => [:environment] do
      log "Building recurring schedule..."
      perform_or_enqueue(Job::BuildRecurringSchedule)
    end
  end



  desc "Cache everything"
  task :cache => [:environment] do
    %w[
      homepage
      most_viewed
      most_viewed_blog_entries
      most_commented
      twitter
      marketplace
    ].each do |task|
      Rake::Task["scprv4:cache:#{task}"].invoke
    end
  end

  #----------

  namespace :cache do
    desc "Cache Most Viewed"
    task :most_viewed => [:environment] do
      log "Caching most viewed..."
      perform_or_enqueue(Job::MostViewed)
    end

    #----------

    desc "Cache Most Viewed Blog Entries"
    task :most_viewed_blog_entries => [:environment] do
      log "Caching most viewed blog entries..."
      perform_or_enqueue(Job::MostViewedBlogEntries)
    end

    #----------

    desc "Cache Most Commented"
    task :most_commented => [:environment] do
      log "Caching most commented..."
      perform_or_enqueue(Job::MostCommented)
    end

    #----------

    desc "Cache twitter feeds"
    task :twitter => [:environment] do
      feeds = [
        [
          "KPCCForum",
          "/shared/widgets/cached/tweets",
          "twitter:KPCCForum"
        ],
        [
          "kpcc",
          "/shared/widgets/cached/sidebar_tweets",
          "twitter:kpcc",
          { count: 4 }
        ]
      ]

      NewRelic.with_manual_agent do
        feeds.each do |feed|
          log "Caching #{feed.first} twitter feed..."
          perform_or_enqueue(Job::TwitterCache, *feed)
        end
      end

      log "Caching Vertical twitter feeds..."
      perform_or_enqueue(Job::VerticalsTwitterCache)
    end


    desc "Cache homepage sections"
    task :homepage => [:environment] do
      log "Caching homepage..."
      perform_or_enqueue(Job::HomepageCache)
    end

    desc "Cache marketplace articles"
    task :marketplace => [:environment] do
      log "Caching marketplace stories..."
      perform_or_enqueue(Job::FetchMarketplaceArticles)
    end
  end


  def log(msg)
    puts "*** [#{Time.zone.now}] #{msg}"
  end

  def perform_or_enqueue(klass, *args)
    if run_jobs?
      klass.perform(*args)
      puts "Finished.\n"
    else
      klass.enqueue(*args)
      puts "Job was placed in queue.\n"
    end
  end

  def run_jobs?
    if !ENV['RUN_JOBS'].nil?
      %w{true 1}.include? ENV['RUN_JOBS']
    else
      Rails.env.development?
    end
  end
end
