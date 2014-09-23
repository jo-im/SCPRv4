# Add parse! to match the Time.parse() API which raises ArgumentError when
# the date is unparseable. Time.zone.parse just returns nil.
module ActiveSupport
  class TimeZone
    def parse!(*args)
      parse(*args) or raise ArgumentError
    end
  end
end
