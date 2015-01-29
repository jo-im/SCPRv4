#= require xml2json

class scpr.ListenLive
    constructor: (options) ->
        # This was old code for a StreamMachine PoC. It is no longer used.

    #----------

    class @CurrentGen
        DefaultOptions:
            url:                "http://205.144.162.143/kpcclive?ua=SCPRWEB&preskip=true"
            player:             "#jquery_jplayer_1"
            swf_path:           "/assets-flash"
            pause_timeout:      300
            schedule_finder:    "#llschedule"
            schedule_template:  JST["t_listen/currentgen_schedule"]
            solution:           "flash, html"
            ad_element:         "#live_ad"

        constructor: (opts) ->
            @options = _.defaults opts, @DefaultOptions

            @x2js = new X2JS()

            @player = $(@options.player)
            @_pause_timeout = null

            @_live_ad = $(@options.ad_element)

            @_shouldTryAd = true

            @_on_now = null

            @_playerReady = false

            # -- set up our player -- #

            @player.jPlayer
                swfPath: @options.swf_path
                supplied: "mp3"
                ready: =>
                    @_playerReady = true

            # -- Triton Ad Code -- #

            # ping the idSync service
            $.getScript "http://playerservices.live.streamtheworld.com/api/idsync.js?station=KPCCFM", =>
                if @_playerReady
                    @_play()
                else
                    @player.one $.jPlayer.event.ready, (evt) => @_play()

                # -- register play / pause handlers -- #
                @player.on $.jPlayer.event.play, (evt) =>
                    if @_pause_timeout
                        clearTimeout @_pause_timeout
                        @_pause_timeout = null

                    if url = @_impressionURL
                        @_impressionURL = null
                        $.ajax type:"GET", url:url, success:(resp) =>
                            # nothing right now

                @player.on $.jPlayer.event.pause, (evt) =>

                    # set a timer to convert this pause to a stop in one minute
                    @_pause_timeout = setTimeout =>
                        @player.jPlayer("clearMedia")
                        @_shouldTryAd = true
                    , @options.pause_timeout * 1000

                @player.on $.jPlayer.event.error, (evt) =>
                    if evt.jPlayer.error.type == "e_url_not_set"
                        @_play()

                @player.on $.jPlayer.event.ended, (evt) =>
                    @_play()

                $.jPlayer.timeFormat.showHour = true;

                # -- build our schedule -- #

                if @options.schedule
                    @schedule = new ListenLive.Schedule @options.schedule
                    @_buildSchedule()

                    setTimeout =>
                        @_buildSchedule() unless @_on_now == @schedule.on_now()
                    , 60*1000

        #----------

        _play: ->
            _playStream = =>
                @player.jPlayer("clearMedia")
                @player.jPlayer("setMedia",mp3:@options.url).jPlayer("play")

            if !@_shouldTryAd
                _playStream()

            else
                @_shouldTryAd = false

                # hit our ad endpoint and see if there is something to play
                $.ajax
                    type:       "GET"
                    url:        "http://cmod.live.streamtheworld.com/ondemand/ars?type=preroll&stid=83153&fmt=vast-jsonp"
                    jsonp:      "jscb"
                    dataType:   "jsonp"
                    success:    (xml) =>
                        obj = @x2js.xml_str2json(xml)

                        @_triton = obj

                        # is there an ad there for us?
                        if ad = obj?.VAST?.Ad?.InLine
                            # is there a preroll?
                            if preroll = ad.Creatives?.Creative?[0]?.Linear
                                # yes... play it
                                media = preroll.MediaFiles.MediaFile.toString()
                                @player.jPlayer("setMedia",mp3:media).jPlayer("play")

                                @_impressionURL = ad.Impression.toString()

                            else
                                _playStream()

                            # is there a visual?
                            if companions = ad.Creatives?.Creative?[1]?.CompanionAds?.Companion
                                # find the first html or iframe
                                _(companions).find (c) =>
                                    switch
                                        when c.HTMLResource?
                                            @_live_ad?.html(c.HTMLResource.toString())
                                            @_live_ad.css(margin:"0 auto").width(c._width)
                                            true
                                        when c.IFrameResource?
                                            @_live_ad?.html $("<iframe>",src:c.IFrameResource.toString(),width:c._width,height:c._height)

                                            true
                                        else
                                            false

                        else
                            _playStream()


                    error:      (err) =>
                        # just play the stream
                        _playStream()



        #----------

        _buildSchedule: ->
            on_now = @schedule.on_now()
            on_next = @schedule.on_at( on_now.end.toDate() )

            $(@options.schedule_finder).html(
                @options.schedule_template?(
                    on_now:  on_now.toJSON()
                    on_next: on_next.toJSON()
                )
            )

            @_on_now = on_now

            show_link_array = @_on_now.toJSON().link.split( '/' )
            show_slug = show_link_array[4]
            show_splash_img = 'http://media.scpr.org/assets/images/programs/' + show_slug + '_splash@2x.jpg'

            $('.wrapper, .wrapper-backdrop').css('background-image', 'url(' + show_splash_img + ')')



    #----------

    @ScheduleShow: Backbone.Model.extend
        urlRoot: '/api/programs'
        initialize: ->
            # parse start and end times
            @start  = moment 1000 * Number(@attributes['start'])
            @end    = moment 1000 * Number(@attributes['end'])

            # Check if the show starts or ends between hours and choose format
            if @start.format("mm") is "00" and @end.format("mm") is "00"
                time_format = "ha"
            else
                time_format = "h:mma"

            @set
                start:      @start
                end:        @end
                start_time: @start.format(time_format)
                end_time:   @end.format(time_format)

        isWhatsPlayingAt: (time) ->
            @start.toDate() <= time < @end.toDate()

        isPlaying: (state) ->
            @set isPlaying:state

    @Schedule: Backbone.Collection.extend
        model: ListenLive.ScheduleShow

        on_at: (time) ->
            # iterate through models until we get a true result from isWhatsPlayingAt
            @find (m) ->
                m.isWhatsPlayingAt time

        #----------

        on_now: -> @on_at (new Date)

    #----------