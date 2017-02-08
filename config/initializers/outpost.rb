require 'zlib'

# We need to register models somewhere, because theoretically
# someone could visit the admin page before a class is loaded.
# The other option is to eager load all classes, which breaks
# some cool Rails functionality.
# Use strings here so the classes aren't loaded yet.

Outpost::Config.configure do |config|
  config.registered_models = [
    "Abstract",
    "AdminUser",
    "Bio",
    "Blog",
    "BlogEntry",
    "BreakingNewsAlert",
    "Category",
    "ContentShell",
    "DataPoint",
    "Edition",
    "Event",
    "ExternalProgram",
    "FeaturedComment",
    "FeaturedCommentBucket",
    "Flatpage",
    "Homepage",
    "LandingPage",
    "KpccProgram",
    "MissedItBucket",
    "NewsStory",
    "PijQuery",
    "Podcast",
    "PressRelease",
    "RecurringScheduleRule",
    "RemoteArticle",
    "ScheduleOccurrence",
    "ShowEpisode",
    "ShowSegment",
    "Tag",
    "Vertical"
  ]

  config.user_class                   = "AdminUser"
  config.authentication_attribute     = :username
  config.title_attributes             = [:name, :headline, :short_headline, :title]
  config.excluded_list_columns        = ["body"]
end


module Outpost
  module Controller
    module CustomErrors
      # Should this be built-in to outpost?
      # I don't know and I don't feel like thinking about it right now.
      def report_error(e)
        ::NewRelic.log_error(e)
      end
    end
  end

  module Model
    module Identifier
      def obj_key_crc32
        @obj_key_crc32 ||= Zlib.crc32(obj_key)
      end
    end
  end
end
