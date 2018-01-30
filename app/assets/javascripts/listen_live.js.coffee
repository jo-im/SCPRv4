#= require x2js/xml2json.min

class scpr.ListenLive

    class @CurrentGen
        DefaultOptions:
            url:                "https://live.scpr.org/kpcclive?ua=SCPRWEB&preskip=true"
            player:             "#jquery_jplayer_1"
            swf_path:           "/assets-flash"
            pause_timeout:      300
            schedule_finder:    "#llschedule"
            schedule_template:  JST["t_listen/currentgen_schedule"]
            solution:           "flash, html"
            ad_element:         "#live_ad"
            skip_preroll:       false
            nielsen_enabled:    false

        constructor: (opts) ->
            @options        = _.defaults opts, @DefaultOptions

            @x2js           = new X2JS()

            @player         = $(@options.player)

            @_pause_timeout = null

            @_live_ad       = $(@options.ad_element)

            @_shouldTryAd   = true

            @_inPreroll     = false

            @_on_now        = null

            @_playerReady   = false

            @nielsen        = if @options.nielsen_enabled then new Nielsen() else undefined

            # -- set up our player -- #

            @player.jPlayer
                swfPath: @options.swf_path
                supplied: "mp3"
                noVolume:
                  ipad: null
                  iphone: null
                  ipod: null
                  android_pad: null
                  android_phone: null
                  blackberry: null
                  windows_ce: null
                  iemobile: null
                  webos: null
                  playbook: null
                ready: =>
                    @_playerReady = true

            # -- Ad Code -- #

            if @_playerReady
                @_play()
            else
                @player.one $.jPlayer.event.ready, (evt) => @_play()

            # -- register play / pause handlers -- #
            @player.on $.jPlayer.event.play, (evt) =>
                if @_pause_timeout
                    clearTimeout @_pause_timeout
                    @_pause_timeout = null

                @nielsen?.play() if !@_inPreroll
                @_addToDataLayer('play', @options.url) if !@_inPreroll

            @player.on $.jPlayer.event.pause, (evt) =>
                # set a timer to convert this pause to a stop in one minute
                @_pause_timeout = setTimeout =>
                    @player.jPlayer("clearMedia")
                    @_shouldTryAd = true
                , @options.pause_timeout * 1000
                @nielsen?.stop() if !@_inPreroll
                @_addToDataLayer('pause', @options.url) if !@_inPreroll

            @player.on $.jPlayer.event.error, (evt) =>
                if evt.jPlayer.error.type == "e_url_not_set"
                    @_play()

            @player.on $.jPlayer.event.ended, (evt) =>
                @adResponse?.touchImpressions() if @_inPreroll
                @_shouldTryAd = false
                @_inPreroll   = false
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
            _playStream = _.once =>
                @player.jPlayer("clearMedia")
                @player.jPlayer("setMedia",mp3:@options.url).jPlayer("play")

            if !@_shouldTryAd || @options.skip_preroll
                _playStream()
            else
                @_shouldTryAd = false
                # set a timeout so that we make sure the stream starts playing
                # regardless of whether our preroll works
                _timedOut = false
                _errorTimeout = setTimeout =>
                    _timedOut = true
                    @_inPreroll = false
                    console.log "timed out waiting for ad response"
                    _playStream()
                , 3000

                # hit our ad endpoint and see if there is something to play
                $.ajax
                    type:       "GET"
                    url:        "https://adserver.adtechus.com/?adrawdata/3.0/5511.1/3590535/0/0/header=yes;adct=text/xml;cors=yes"
                    dataType:   "xml"
                    xhrFields:
                        withCredentials: true
                    error: (err) =>
                        console.log "ajax error ", err
                    success:    (xml) =>
                        console.log "xml is ", xml
                        clearTimeout _errorTimeout if _errorTimeout
                        response_xml = @x2js.xml2json(xml)
                        @adResponse = new AdResponse(response_xml)
                        # is there an ad there for us?
                        if @adResponse.ad()
                            # is there a preroll?
                            if @adResponse.preroll() && !_timedOut
                                # yes... play it
                                @_inPreroll = true
                                @adResponse.playPreroll(@player)
                            else
                                _playStream()
                            # display a visual if there is one
                            @adResponse.renderVisual(@_live_ad)
                        else
                            _playStream()

        #----------

        _buildSchedule: ->
            on_now = @schedule.on_now()
            on_next = @schedule.on_at( on_now.end.toDate() ) if on_now

            @_on_now = on_now

            if on_now
                $(@options.schedule_finder).html(
                    @options.schedule_template?(
                        on_now:  on_now.toJSON()
                        on_next: on_next.toJSON()
                    )
                )

                show_link_array = @_on_now.toJSON().link.split( '/' )
                show_slug = show_link_array[4]
                show_splash_img = 'http://media.scpr.org/assets/images/programs/' + show_slug + '_splash@2x.jpg'

                $('.wrapper, .wrapper-backdrop').css('background-image', 'url(' + show_splash_img + ')')

        _addToDataLayer: (eventAction, eventLabel) ->
            # push to the dataLayer for general reporting purposes (e.g. NPR)
            dataLayer.push
                event: 'LiveStream'
                eventCategory: 'LiveStream'
                eventAction: eventAction
                eventLabel: eventLabel

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

    class AdResponse
        constructor: (xml)->
            @xml = xml
            @obj = xml.DAAST or xml.VAST or undefined
        preroll: ->
            @ad().Creatives?.Creative?[0]?.Linear
        ad: ->
            @obj?.Ad?.InLine
        renderVisual: (el)->
            companions = @companions()
            resources = {}
            # ordered by precedence
            resourceTypes = [
              {
                name: 'HTMLResource'
                render: (c) ->
                    el?.html(c.HTMLResource.toString())
                    el.css(margin:"0 auto").width(c._width)
              }
              {
                name: 'IFrameResource'
                render: (c) ->
                    el?.html $("<iframe>",src:c.IFrameResource.toString(),width:c._width,height:c._height)
                    @_submitViewEvent(c)
              }
            ]

            for r in resourceTypes
                break if _(companions).find (c) =>
                    if c[r.name]?
                        r.render(c)
                        return true
                    else
                        return false

        impressions: ->
            # Always return an array, even if there is one or no impressions
            impressions = _.flatten [@ad().Impression or []]
            _.map impressions, (i) ->
                return i.toString()
        companions: ->
            if @xml.DAAST
                @ad().Creatives?.Creative?[1]?.CompanionAds or []
            else if @xml.VAST
                @ad().Creatives?.Creative?[1]?.CompanionAds?.Companion or []
            else
                []
        playPreroll: (player)->
            if preroll = @preroll()
                media = preroll.MediaFiles.MediaFile.toString()
                player.jPlayer("setMedia",mp3:media).jPlayer("play")
        _submitViewEvent: (companion) ->
            trackingEvents = _.flatten([companion.TrackingEvents.Tracking])
            # only use the creativeView tracking event
            _.find trackingEvents, (e) ->
                if e._event == "creativeView"
                    url = e.toString()
                    $.get("#{url};cors=yes")
                    return true
                else
                    return false
        touchImpressions: ->
            impressions = @impressions()
            _.each impressions, (url) =>
                # create an img and append it to our DOM
                img = $("<img src='#{url}'>").css("display:none")
                $('body').append(img)

    #----------

    class Nielsen
        constructor: ->
            @_queued = []
            $.getScript "http://secure-drm.imrworldwide.com/novms/js/2/ggcmb400.js"
                .done (script,status) =>
                    @nolcmb = new NOLCMB?.ggInitialize
                        sfcode: "drm"
                        apid  : "P4FA39C01-1BC0-41C3-A309-06ED295D84D2"
                        apn   : "kpcc-live-stream-browser"

                    @nolcmb.ggPM e... for e in @_queued
                    true

                .fail (xhr,settings,exception) =>
                    console.log "Failed to load Nielsen SDK: #{exception}"

        _send: (event,data) ->
            if @nolcmb
                @nolcmb.ggPM event, data
            else
                @_queued.push [event,data]

        play: ->
            @_send "loadMetadata",
                stationType: 2
                dataSrc    : "cms"
                type       : "radio"
                assetid    : "KPCC-FM"
                provider   : "Southern California Public Radio"

            @_send "play", Math.floor(Date.now() / 1000)

            # send setPlayheadPosition every 2 seconds, as specified by Nielsen
            @_setPlayheadPosition = setInterval(=>
                @_send "setPlayheadPosition", Math.floor(Date.now() / 1000)
            , 2000)

        stop: ->
            @_send "stop", Math.floor(Date.now() / 1000)
            clearInterval(@_setPlayheadPosition)
