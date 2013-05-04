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
  
  desc "Sync NPR Stories with NPR API"
  task :npr_fetch => [:environment] do
    puts "*** [#{Time.now}] Enqueueing sync of NPR Stories..."
    
    if Rails.env == "development"
      Job::NprFetch.perform
    else
      NprStory.async_sync_with_api
    end

    puts "Finished."
  end
  
  #----------
  
  desc "Clear events cache"
  task :clear_events => [ :environment ] do 
    Rails.cache.expire_obj("events/event:new")
  end

  #----------
  
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
  task :syncaudio => [:environment] do
    puts "*** [#{Time.now}] Enqueueing audio sync tasks into Resque..."
    Audio.enqueue_all
    puts "Finished."
  end




  #----------
  


  desc "Cache everything"
  task :cache => [:environment] do
    Rake::Task["scprv4:cache:remote_blogs"].invoke
    Rake::Task["scprv4:cache:programs"].invoke
    Rake::Task["scprv4:cache:homepage"].invoke
    Rake::Task["scprv4:cache:most_viewed"].invoke
    Rake::Task["scprv4:cache:most_commented"].invoke
    Rake::Task["scprv4:cache:twitter"].invoke
  end
  
  #----------
  
  namespace :cache do
    desc "Cache Remote Blog Entries"
    task :remote_blogs => [:environment] do
      puts "Caching remote blogs..."

      NewRelic.with_manual_agent do
        Blog.cache_remote_entries
      end

      puts "Finished.\n"
    end
    
    #----------
    
    desc "Cache Most Viewed"
    task :most_viewed => [:environment] do
      puts "*** [#{Time.now}] Enqueing most viewed..."
      
      if Rails.env == "development"
        Job::MostViewed.perform
      else
        Resque.enqueue(Job::MostViewed)
      end

      puts "Finished.\n"
    end

    #----------
    
    desc "Cache Most Commented"
    task :most_commented => [:environment] do
      puts "*** [#{Time.now}] Enqueing most commented..."

      if Rails.env == "development"
        Job::MostCommented.perform
      else
        Resque.enqueue(Job::MostCommented)
      end

      puts "Finished.\n"
    end

    #----------
    
    desc "Cache KPCCForum tweets"
    task :twitter => [:environment] do
      puts "*** [#{Time.now}] Caching KPCCForum tweets...."

      NewRelic.with_manual_agent do
        task = CacheTasks::Twitter.new("KPCCForum")
        task.verbose = true
        task.run
      end

      puts "Finished.\n"
    end
    
    #----------
    
    desc "Cache external programs"
    task :programs => [ :environment ] do
      puts "Caching remote programs..."

      NewRelic.with_manual_agent do
        OtherProgram.active.each { |p| p.cache }
      end

      puts "Finished.\n"
    end
    
    #----------
    
    desc "Cache homepage one time"
    task :homepage => [ :environment ] do
      puts "*** [#{Time.now}] Caching homepage..."

      task = CacheTasks::Homepage.new
      task.verbose = true
      task.run

      puts "Finished.\n"
    end
  end
end
