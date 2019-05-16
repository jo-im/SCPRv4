task :scheduler => [:environment] do
  scheduler = Rufus::Scheduler.new

  # -- Content -- #

  scheduler.every '1m' do |job|
    Job::MastheadCache.enqueue()
  end

  scheduler.every '1m' do |job|
    ContentAlarm.fire_pending
  end

  scheduler.every '10m' do |job|
    Job::SyncAudio.enqueue ["AudioSync::Pending", "AudioSync::Program"]
  end

  scheduler.every '1d' do |job|
    Job::BuildRecurringSchedule.enqueue()
    Job::ReportScheduleProblems.enqueue
  end

  scheduler.cron '0 0 1 * *' do |job|
    Job::ArchiveVersions.enqueue
  end

  # -- Caches -- #

  # most whatevers...
  scheduler.every '30m' do |job|
    Job::MostViewed.enqueue()
    Job::MostViewedBlogEntries.enqueue()
    Job::MostCommented.enqueue()
  end

  # -- Externals -- #

  # external NPR programs every hour
  scheduler.cron "0 * * * *" do |job|
    Job::SyncExternalPrograms.enqueue("npr-api")
  end

  # external RSS programs every hour
  scheduler.cron "0 * * * *" do |job|
    Job::SyncExternalPrograms.enqueue("rss")
  end

  # remove external RSS episodes that have expired
  scheduler.cron "0 1 * * * " do |job|
    Job::RemoveExternalEpisodes.enqueue
  end

  # marketplace every hour
  scheduler.cron "0 * * * *" do |job|
    Job::FetchMarketplaceArticles.enqueue()
  end

  # remote articles every 20 minutes
  scheduler.cron "*/20 * * * *" do |job|
    Job::SyncRemoteArticles.enqueue()
  end

  scheduler.every '60m' do |job|
    Job::ImportLaistArticles.enqueue()
  end

  # Go!
  puts "Scheduler running."
  scheduler.join
end