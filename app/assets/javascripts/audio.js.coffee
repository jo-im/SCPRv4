class scpr.Audio
    DefaultOptions:
        playEl:         "#jquery_jplayer_1"
        titleEl:        "#jplayer1_title"
        widgetClass:    ".story-audio"
        playBtn:        ".audio-toggler"
        audioBar:       "#audio-bar"
        downloadEl:     ".download"
    constructor: (options={}) ->
        @options = _.defaults options, @DefaultOptions

        # instantiate jPlayer on playEl
        @player = $(@options.playEl).jPlayer
            swfPath:  "/assets-flash"
            supplied: "mp3"
            wmode:    "window"

        @audiobar = $(@options.audioBar)
        @widgets = []
        @playing = false
        @active = null

        # find our audio widgets
        $(@options.widgetClass).each (idx,el) =>
            # find a play button
            btn = $(@options.playBtn,el)
            if btn
                # get the audio file path from the href
                mp3      = $(btn).attr("href")
                title    = $(btn).attr("title")
                duration = Number($(btn).attr("data-duration"))
                @widget = $(btn).closest(".audio-actuator")

                # take the URL out of the href
                $(btn).attr "href", "javascript:void(0);"

                widget = new Audio.PlayWidget
                    player:     @
                    widget:     el
                    playBtn:    btn
                    mp3:        mp3
                    title:      title
                    duration:   duration

                @widgets.push widget

        # register listener to close audio bar
        $("#{@options.audioBar} .jp-stop, #opaque-cover").click => @closeAndStop()

        # Hide the modal if the Esc key is pressed
        $(document).keyup (event) =>
          @closeAndStop() if event.keyCode is 27 and @audiobar.is(":visible")

        # register listener to toggle the active widget from the audio bar
        _.each ["play", "pause"], (event) =>
            $("#{@options.audioBar} .jp-#{event}").on "click", (e) =>
                @active?[event]()
                return false

        @player.find("audio").on "ended", =>
            @active?.end()

    #----------

    closeAndStop: ->
        @widget.removeClass("activated")
        @audiobar.animate { bottom: @audiobar.height() * -1 }, 300, =>
            @audiobar.removeClass('active')
            $("body").removeClass("with-audio-bar") # which also hides the opaque-cover
        @player.jPlayer "stop"
        @playing = false
        @active = null

        false

    play: (widget) ->
        if @playing && @active == widget
            if @playing == 1
                @player.jPlayer "pause"
                @playing = 2
                @active?.pause()
            else
                @player.jPlayer "play"
                @playing = 1
                @active?.play()

            return true

        @stop() if @playing

        # set our new mp3
        @player.jPlayer "setMedia", mp3:widget.options.mp3
        $(@options.titleEl).text widget.options.title
        $(@options.downloadEl).attr('href', widget.options.mp3)
        # should we enable hours?
        $.jPlayer.timeFormat.showHour =
            if widget.options.duration && widget.options.duration > 60*60
                true
            else
                false

        # animate the bar
        @widget.addClass("activated")
        @audiobar.addClass("active")
        $("body").addClass("with-audio-bar")
        @audiobar.animate { bottom: 0 }, 1000
        # and hit play
        @player.jPlayer "play", 0
        @player.jPlayer "play" # Need the second one for IE 9...

        @playing = 1

        widget.play()
        @active = widget

    #----------

    stop: () ->
        @player.jPlayer "stop"
        @active?.stop()
        @playing = false

    #----------

    class @PlayWidget
        constructor: (options) ->
            @options = options
            @player = @options.player
            @audioElement = @player.player.find("audio")[0]
            # register click handler on play button
            @options.playBtn.on "click", (e) =>
                @player.play @
                return false

            @started = @quartile1 = @quartile2 = @quartile3 = @ended = @stopped = false

            $(@audioElement).on "timeupdate", =>
                if @ is @player.active
                    duration = @audioElement.duration
                    currentTime = @audioElement.currentTime

                    _.each [1,2,3], (i) =>
                        if (currentTime > (duration * i/4)) and !@["quartile#{i}"]
                            @["quartile#{i}"] = true
                            @sendEvent
                                action: "Quartile#{i}"
                                nonInteraction: true
                                value: @currentTime()
                            console.log "quartile#{i}"     


        currentTime: () => @audioElement.currentTime

        sendEvent: (options) ->
            ga 'send',
                hitType: 'event'
                eventCategory: 'AudioPlayer'
                eventAction: options.action
                eventLabel: @options.mp3
                nonInteraction: options.nonInteraction or true
                eventValue: options.value or undefined

        start: () ->
            @sendEvent
                action: 'start'
                nonInteraction: true
            @started = true

        play: () ->
            if @started is not true
                @start()
            else
                @resume()

        stop: () ->
            @stopped = true
            @sendEvent
                action: 'stop'
                label:  @options.mp3
                nonInteraction: true
                value: @currentTime()

        pause: () ->
            # ->

        resume: () ->
            if !@stopped
                # ->
            else
                @stopped = false

        end: () ->
            if @ended is not true
                @sendEvent
                    action: 'complete'
                    nonInteraction: true
                    value: @currentTime()