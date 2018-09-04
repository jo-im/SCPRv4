namespace :scprv4 do

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

  desc "Index all articles to Elasticsearch"
  task :index_all_articles => [:environment] do
    log "Indexing all articles to Elasticsearch..."
    Article._index_all_articles
  end

  desc "Index all models to Elasticsearch"
  task :index_all_models => [:environment] do
    log "Indexing all outpost models to Elasticsearch..."
    Outpost.config.registered_models.map(&:safe_constantize).compact.each { |m| m.try(:import) }
  end

  desc "Index articles and models"
  task :index_all => [:index_all_articles,:index_all_models]

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

    desc "Cache marketplace articles"
    task :marketplace => [:environment] do
      log "Caching marketplace stories..."
      perform_or_enqueue(Job::FetchMarketplaceArticles)
    end
  end

  desc "Archive Versions Table"
  task :archive_versions => [:environment] do
    require "#{Rails.root}/lib/version_table_archiver"
    begin
      log "Archiving old versions..."
      if VersionTableArchiver.archive! == true
        log "Archiving finished successfully."
      else
        log "Archiving failed because request failed."
      end
    rescue => err
      log "Archiving failed because an error was encountered."
      puts err.message
      puts err.backtrace
      NewRelic.log_error(err)
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
