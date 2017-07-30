# SCPRv4

[![Build Status](https://circleci.com/gh/SCPR/SCPRv4.png)](https://circleci.com/gh/SCPR/SCPRv4)

SCPRv4 is the code that runs [SCPR.org](http://www.scpr.org). It is
approximately the fourth generation of the software for the site.

## Requirements

SCPRv4 is a Rails app, and runs in production on Ruby 2.1.

It connects to the following services:

* __MySQL__ is used as the primary datastore for CMS data.
* __Elasticsearch__ powers article search and display.
* __Redis__ is used by Resque, the queuing system used for async jobs.
* __Memcached__ is used in production for caching, but isn't required
    for development.
* __[Newsroom](https://github.com/scpr/newsroom)__ is a small Node.js app
    that is used to communicate editing status inside the CMS, including
    the completion of import jobs inside Outpost.
* __NFS__ is used to make uploaded audio files available on all SCPRv4
    servers.
* __[Assethost](http://github.com/scpr/Assethost)__ is used to manage all
    photo and video assets for content.

## Quick Tour

SCPRv4 basically integrates a CMS and frontend. CMS conventions are provided
through [Outpost](https://github.com/scpr/outpost), but all data models are
here inside the SCPRv4 project.

And speaking of data models... there are a lot of them, and some of them might
seem like they overlap.

### Content Models

Before SCPRv4, there was Mercer. In Mercer, there were different models for
blog entries, show segments, events and news stories, and each had very
defined rules about where they could exist.

_ContentBase_ was our effort to first make all of those content types
available on the home page, and then secondly to make them far more
interchangable.

Since then, _ContentBase_ loosely evolved into the `Article` model. It would
be fair to say that in SCPRv4, "content" is any model that can be cast as an
`Article`.

Currently, that list includes `Abstract`, `BlogEntry`, `ContentShell`, `Event`,
`ExternalEpisode`, `ExternalSegment`, `NewsStory`, `PijQuery`, `ShowEpisode`,
and `ShowSegment`.

Each of these models includes a `to_article` function, which is used to shape
the content into the standardized form that `Article` needs. `Article` objects
are stored in Elasticsearch, and are used directly in various index contexts
around the site.

### CMS Login

User accounts for the CMS are in the `AdminUser` model.

### Caching

SCPRv4 uses two kinds of caching:

* __As-Needed Partial Caching:__ These are normal Rails partial caches,
    generated and stored on-demand when content views are generated.
* __Periodic Caches:__ A handful of expensive caches are computed out-of-band
    and updated periodically rather than on-demand. The most important is the
    cache for homepage content, which requires loading up all homepage content
    objects, sorting them by section, etc.

### Rake Tasks

There are some backend tasks that are worth knowing:

* __`scprv4:index_all`:__ Index all articles and models to Elasticsearch. During
    normal operation these are generated as content is updated, but this task
    can be necessary when importing data into a new deployment.
* __`scprv4:sync_remote_articles`:__ Trigger a `SyncRemoteArticles` job.
* __`scprv4:sync_external_programs`:__ Trigger a `SyncExternalPrograms` job.
* __`scprv4:fire_content_alarms`:__ Call `ContentAlarm.fire_pending` to publish
    all pending content with a current alarm.
* __`scprv4:sync_audio`:__ Trigger `AudioSync::Pending` and `AudioSync::Program`
    jobs.
* __`scprv4:schedule:build`:__ Trigger a `BuildRecurringSchedule` job.
* __`scprv4:cache`:__ Trigger jobs to build all of the periodic caches.

### Scheduler

SCPRv4 uses [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler) to
manage periodic job execution. You can find that schedule defined in
[lib/tasks/scheduler.rake](lib/tasks/scheduler.rake).

In production, scheduler runs on a worker instance.

### Asset Sync

[AssetSync](lib/asset_sync.rb) (run via [this rake task](lib/tasks/asset_sync.rake))
listens to a Redis server for AssetHost to send PUB/SUB notifications that
an asset has been updated. When an asset is updated externally, we need to
delete our cache of it so that the newest version is picked up.

In production, assetsync runs on a worker instance.

## Getting Started

### Docker Setup (recommended)

This is by far the easiest way of getting the application up and running.  All you need is to have [Docker](https://www.docker.com/) with [docker-compose](https://docs.docker.com/compose/) installed.

Obtain a Deploybot key for a database backup and provide that to a new MySQL container.

      docker-compose run -d mysql <DEPLOYBOT TOKEN>

This will pull a database backup, which will take a few minutes to do.  Unfortunately, there's currently no way to run the command without daemon mode and be able to exit the container with CTRL+C until we can modify `scpr/restore-percona-backup` to optionally pull a backup without starting the MySQL server.  You can check if your MySQL server is up and running by executing `curl localhost:3306` and seeing if you get a response.

Then run the rest of the services.

      docker-compose up -d redis elasticsearch

If you have Rails installed on your host, running the web server is simple as:

      rails s

Optionally, you can also run the Rails application in a Docker container.  The disadvantages to this approach are that you will have to first build a Docker image and that the application will also run slower, but the advantage is the application environment is self-contained as the rest of the servies are(i.e. no having to maintain version of Ruby, RVM/Rbenv, Node.js, etc. on the host machine).

After acquring `config/secrets.yml` from the wiki, you can run the Rails server:
      
      docker-compose run --rm scpr

On first run, `bundle install` and `npm install` will pull in dependencies.  This will take a few minutes but will be much shorter in the future because the dependencies get saved in volumes.

To use the Rails console:

      docker-compose run --rm scpr rails c

The application will be available at http://localhost:3000.  If you are using [docker-machine](https://docs.docker.com/machine/), it will be available at the IP of your virtual machine, which you can find by executing `echo $DOCKER_HOST`.

### Native Setup

* Install Ruby 2.1.x
* Install Node.js 5.x
* Install MySQL (5.6.x should be fine) / Elasticsearch (1.5.x) / Redis
* Acquire a `secrets.yml` file via the wiki
* `bundle install` and `npm install`
* `rake scprv4:index_all` to index articles and models into Elasticsearch
* `rake scprv4:cache` to cache homepage, tweets, etc

