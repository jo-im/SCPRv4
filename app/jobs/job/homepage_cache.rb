##
# HomepageCache
#
# This needs to be on the sphinx queue
# run after sphinx is indexed... otherwise
# it could run before and have out of date objects.
module Job
  class HomepageCache < Base
    # This job needs to be on the sphinx queue so
    # that it runs *after* a sphinx index has
    # occurred, because the homepage caching relies
    # on an up-to-date index.
    @queue = "#{namespace}:sphinx"

    def self.perform
      homepage = ::Homepage.published.first
      return if !homepage

      previews = homepage.category_previews
      self.cache(previews, "/home/cached/sections", "home/sections")
    end
  end
end
