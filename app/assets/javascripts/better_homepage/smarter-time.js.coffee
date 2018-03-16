(->
    class SmarterTime

        moment = require('moment')

        DefaultOptions:
            finder:             ".smarttime, .smartertime"
            time_format:        "%I:%M %p"
            date_format:        "%B %d"
            prefix:             ""
            relative:           "8h"
            timecut:            "36h"
            window:             null
            class:              "sttime"
            wrapText:           false

        constructor: (options) ->
            @options = _.defaults options||{}, @DefaultOptions

            # build some defaults
            for opt in ['relative','timecut','window']
                if @options[opt]
                    @options[opt] = ( @options[opt].match /(\d+)\s?(\w+)/)?[1..2].reverse()
                    @options[opt][1] = parseInt(@options[opt][1])

            # now find our elements
            @elements = _.compact( new SmarterTime.Instance(el,@options) for el in $ @options.finder )

        #----------

        class SmarterTime.Instance

            constructor: (el,options) ->
                @$el = $(el)
                @options = options

                @time       = null
                @window     = @options.window
                @relative   = @options.relative
                @timecut    = @options.timecut

                # -- find our time -- #

                if @$el.attr("data-unixtime")
                    # if there's a data-unixtime attribute, that's our preferred choice
                    # for grabbing a time
                    @time = moment Number(@$el.attr("data-unixtime")) * 1000

                else if $(el).attr("datetime")
                    # a datetime value is our next fallback. for now, we'll just let
                    # moment try to figure it out
                    @time = moment @$el.attr("datetime")


                # Allows for custom relative time strings.  For example:
                  # future: 'in %s'
                  # past: '%s ago'
                  # s: 'seconds'
                  # m: 'a minute'
                  # mm: '%d minutes'
                  # h: 'an hour'
                  # hh: '%d hours'
                  # d: 'a day'
                  # dd: '%d days'
                  # M: 'a month'
                  # MM: '%d months'
                  # y: 'a year'
                  # yy: '%d years'

                if @time and @options.relativeTimeStrings
                    for key, value of @options.relativeTimeStrings
                        @time._locale._relativeTime[key] = value

                # -- look for display limits -- #
                for opt in ['relative','timecut','window']
                    if @$el.attr("data-#{opt}")
                        @[opt] = (@$el.attr("data-#{opt}").match /(\d+)\s?(\w+)/)?[1..2].reverse()
                        @[opt][1] = parseInt(@[opt][1])
                # -- now figure out our display -- #

                @update()

            #----------

            render: (text) ->
                if (text and text.length)
                    if @options.wrapText
                        @$el.html "<span>#{text}</span>"
                    else
                        @$el.text text
                else
                    @$el.text ""

            #----------

            update: ->
                now = moment()
                # Dup the Moment object
                # All limits are Lower limits
                # "Outside" = Before
                # "Inside"  = After
                windowLimit   = moment(now).subtract(@window...)   if @window
                relativeLimit = moment(now).subtract(@relative...) if @relative
                timecutLimit  = moment(now).subtract(@timecut...)  if @timecut

                # if we have a window, are we inside of it?
                if @time < windowLimit
                    # @time is outside of the windowLimit
                    # eg:
                    #   now     = 8:00pm
                    #   @time   = 6:00am
                    #   @window = "10h"
                    #
                    #   windowLimit = (now - @window) = 10:00am
                    #
                    #   @time is outside (before) the windowLimit, so don't show anything
                    #
                    @render ''
                    @$el.removeClass @options.class if @options.class
                    return true

                # are we doing relative or absolute timing?
                if @time > relativeLimit
                    # @time is inside of the relativeLimit
                    # Show a relative time
                    # eg:
                    #   now       = 1:00pm
                    #   @time     = 12:00pm
                    #   @relative = "2h"
                    #
                    #   relativeLimit = (now - @relative) = 11:00am
                    #
                    #   @time is inside (after) relativeLimit, so show Relative time
                    #
                    # If (now - @time) is negative (i.e., @time is AFTER now),
                    # then display "Just Now". This can happen just because of slight
                    # discrepancies between server and client times.
                    if now.diff(@time, "seconds") < 0
                        @render 'Just Now'
                    else
                        # relative formatting
                        @render "" + @options.prefix + @time.fromNow()


                @$el.addClass @options.class if @options.class

    module.exports = SmarterTime

)(module or ({}).__defineSetter__ 'exports', (x)-> window.scpr ?= {}; window.scpr.SmarterTime = x; return x;)