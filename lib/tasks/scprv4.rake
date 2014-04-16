namespace :scprv4 do
  task :test_error => [:environment] do
    puts "*** [#{Time.now}] Testing Error..."

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
    puts "*** [#{Time.now}] Enqueueing sphinx index into Resque..."
    Indexer.enqueue
    puts "Finished."
  end

  #----------

  desc "Sync Remote Articles with the remote sources"
  task :sync_remote_articles => [:environment] do
    puts "*** [#{Time.now}] Syncing remote articles..."

    if Rails.env.development?
      Job::SyncRemoteArticles.perform
      puts "Finished.\n"
    else
      Job::SyncRemoteArticles.enqueue
      puts "Job was placed in queue.\n"
    end
  end


  desc "Sync external programs"
  task :sync_external_programs => [:environment] do
    puts "*** [#{Time.now}] Syncing remote programs..."

    if Rails.env.development?
      Job::SyncExternalPrograms.perform
      puts "Finished.\n"
    else
      Job::SyncExternalPrograms.enqueue
      puts "Job was placed in queue.\n"
    end
  end



  desc "Clear events cache"
  task :clear_events => [ :environment ] do
    puts "*** [#{Time.now}] Clearing Event Cache..."
    Rails.cache.expire_obj(Event.new_obj_key)
    puts "Finished."
  end



  desc "Fire pending content alarms"
  task :fire_content_alarms => [:environment] do
    puts "*** [#{Time.now}] Firing pending content alarms..."

    NewRelic.with_manual_agent do
      ContentAlarm.fire_pending
    end

    puts "Finished."
  end

  #----------

  desc "Sync all Audio types"
  task :sync_audio => [:environment] do
    puts "*** [#{Time.now}] Syncing Audio..."
    args = ["AudioSync::Pending", "AudioSync::Program"]

    if Rails.env.development?
      Job::SyncAudio.perform(args)
      puts "Finished.\n"
    else
      Job::SyncAudio.enqueue(args)
      puts "Job was placed in queue.\n"
    end
  end


  namespace :schedule do
    desc "Build the recurring schedule occurrences"
    task :build => [:environment] do
      puts "*** [#{Time.now}] Building recurring schedule..."

      if Rails.env.development?
        Job::BuildRecurringSchedule.perform
        puts "Finished.\n"
      else
        Job::BuildRecurringSchedule.enqueue
        puts "Job was placed in queue.\n"
      end
    end
  end



  desc "Cache everything"
  task :cache => [:environment] do
    Rake::Task["scprv4:cache:homepage"].invoke
    Rake::Task["scprv4:cache:most_viewed"].invoke
    Rake::Task["scprv4:cache:most_commented"].invoke
    Rake::Task["scprv4:cache:audiovision"].invoke
    Rake::Task["scprv4:cache:twitter"].invoke
  end

  #----------

  namespace :cache do
    desc "Cache Audiovision Homepage Module"
    task :audiovision => [:environment] do
      puts "*** [#{Time.now}] Caching AudioVision for homepage..."

      if Rails.env.development?
        Job::AudioVisionCache.perform
        puts "Finished.\n"
      else
        Job::AudioVisionCache.enqueue
        puts "Job was placed in queue.\n"
      end
    end

    #----------

    desc "Cache Most Viewed"
    task :most_viewed => [:environment] do
      puts "*** [#{Time.now}] Caching most viewed..."

      if Rails.env.development?
        Job::MostViewed.perform
        puts "Finished.\n"
      else
        Job::MostViewed.enqueue
        puts "Job was placed in queue.\n"
      end
    end

    #----------

    desc "Cache Most Commented"
    task :most_commented => [:environment] do
      puts "*** [#{Time.now}] Caching most commented..."

      if Rails.env.development?
        Job::MostCommented.perform
        puts "Finished.\n"
      else
        Job::MostCommented.enqueue
        puts "Job was placed in queue.\n"
      end

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
          "twitter:kpcc"
        ]
      ]

      NewRelic.with_manual_agent do
        feeds.each do |feed|
          puts "*** [#{Time.now}] Caching #{args.first} twitter feed..."

          if Rails.env.development?
            Job::TwitterCache.perform(*feed)
            puts "Finished.\n"
          else
            Job::TwitterCache.enqueue(*feed)
            puts "Job was placed in queue.\n"
          end
        end
      end

      puts "*** [#{Time.now}] Caching Vertical twtiter feeds..."

      if Rails.env.development?
        Job::VerticalsTwitterCache.perform
        puts "Finished.\n"
      else
        Job::VerticalsTwitterCache.enqueue
        puts "Job was placed in queue.\n"
      end
    end


    desc "Cache homepage sections"
    task :homepage => [ :environment ] do
      puts "*** [#{Time.now}] Caching homepage..."

      if Rails.env.development?
        Job::HomepageCache.perform
        puts "Finished.\n"
      else
        Job::HomepageCache.enqueue
        puts "Job was placed in queue.\n"
      end
    end
  end
end
