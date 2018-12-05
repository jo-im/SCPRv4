SCPRv4
======

[![Build Status](https://circleci.com/gh/SCPR/SCPRv4.png)](https://circleci.com/gh/SCPR/SCPRv4)

SCPRv4 is the code that runs [SCPR.org](http://www.scpr.org). It is the fourth generation of the software for the site.

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

## Getting Started

### Prerequisites

You will need to have Ruby 2.x, MySQL(~>5.6), Elasticsearch(1.7.x), Redis, and Memcached installed on the host machine.

They can be installed natively, or you can use Docker Compose to run them as containers.

It's as easy as running `docker-compose up -d mysql elasticsearch redis memcached`.

### Installation

Copy `config/templates/secrets.yml.template` to `config/secrets.yml`.

And install dependencies:

`bundle install & npm install`

Note: `bundle install` will try to use a specific native MySQL installation to compile the mysql gem, so you'll need to install that first. The latest MySQL version won't work, so the easiest method would be to `brew install mysql@5.6` and add `mysql` to `PATH` (i.e. `echo 'export PATH="/usr/local/opt/mysql@5.6/bin:$PATH"' >> ~/.bash_profile`).

After that finishes, initialize your database:

`bundle exec rake db:setup`

`bundle exec rake db:seed`

To run the development server, run `rails s`.

### Using Production Database Backups

In the chance that you need to get a backup of the production database and use that for development/debugging, you can use the [scpr/restore-percona-backup](https://github.com/scpr/restore-percona-backup) Docker image in place of the MySQL service defined in `docker-compose.yml`.  The repo for restore-percona-backup includes instructions on how to do this.

## Quick Tour

SCPRv4 basically integrates a CMS and frontend. CMS conventions are provided
through [Outpost](https://github.com/scpr/outpost), but all data models are
here inside the SCPRv4 project.

And speaking of data models... there is a lot of them, and some of them might
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

If you ran `bundle exec rake db:seed`, database will be seeded with an AdminUser called `admin` with `password` as the password.  You can log in as this user in Outpost under the `/outpost` route.

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

