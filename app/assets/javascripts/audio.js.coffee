class scpr.Audio
    DefaultOptions:
        playEl:         "#jquery_jplayer_1"
        titleEl:        "#jplayer1_title"
        widgetClass:    ".c-audio-widget"
        playBtn:        ".c-play__button"
        audioBar:       "#audio-bar"
        downloadEl:     ".o-audio-bar__download"
    constructor: (options={}) ->
        @options = _.defaults options, @DefaultOptions

        # instantiate jPlayer on playEl
        @player = $(@options.playEl).jPlayer
            swfPath:  "/assets-flash"
            supplied: "mp3"
            wmode:    "window"
            play: (e) =>
                # add a play event to the data layer for each play
                @addToDataLayer
                    action: 'play'
                    nonInteraction: false
                    value: 1

                # if no audio element has played yet, send a start event to GA
                if @state.started != true
                    @state = {}
                    @sendEvent
                        action: 'start'
                        nonInteraction: false
                        value: 1
                    @state.started = true
            pause: (e) =>
                # add a pause event to the data layer for each pause
                @addToDataLayer
                    action: 'pause'
                    nonInteraction: false
                    value: 1
            timeupdate: (e) =>
                time = e.jPlayer.status.currentTime
                @state ?= {}
                _.each [1,2,3], (i) =>
                    if (time > (@duration() * i/4)) and !@state["quartile#{i}"]
                        @state["quartile#{i}"] = true
                        @sendEvent
                            action: "Quartile#{i}"
                            nonInteraction: true
                            value: 1
            ended: () =>
                @playing = false
                @state ?= {}
                if @state.started == true
                    @sendEvent
                        action: 'complete'
                        nonInteraction: true
                        value: 1
                    @state.started = false
            loadstart: (e) =>
                # initialize the state object if it doesn't already exist
                @state ?= {}
                @state.started ?= true

                # initialize the previous audio source as the current source if it doesn't already exist
                @previousSource ?= e.jPlayer.status.src

                # if an audio is starting to load and the current source is different from the previous source 
                # add a change event to the dataLayer
                if @previousSource != e.jPlayer.status.src
                    @previousSource = e.jPlayer.status.src
                    @addToDataLayer
                        action: 'change'
                        nonInteraction: false
                        value: 1


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
                actuator = $(btn).closest(".audio-actuator, .story-audio")
                @widget = actuator if actuator.length

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

    #----------

    closeAndStop: ->
        if @widget
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
            else
                @player.jPlayer "play"
                @playing = 1

            return true

        if @playing
            # tell the player to stop
            @player.jPlayer "stop"

            # and tell the widget that it stopped
            @active?.stop()

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
        if @widget
          @widget.addClass("activated")
        @audiobar.addClass("active")
        $("body").addClass("with-audio-bar")
        @audiobar.animate { bottom: -1 }, 750
        # and hit play
        @player.jPlayer "play", 0
        @player.jPlayer "play" # Need the second one for IE 9...

        @playing = 1

        widget.play()
        @active = widget

    #----------

    stop: () ->
        if @playing
            @player.jPlayer "stop"
            @active?.stop()
            @playing = false

    #----------

    status: () ->
        @player.data("jPlayer").status

    #----------

    currentTime: () ->
        @status().currentTime

    #----------

    duration: () ->
        @status().duration

    #----------

    src: () ->
        @status().src

    #----------

    sendEvent: (options) ->
        options.nonInteraction ?= true

        # send an audio event to GA
        ga 'send',
            hitType: 'event'
            eventCategory: 'AudioPlayer'
            eventAction: options.action
            eventLabel: @src()
            nonInteraction: options.nonInteraction
            eventValue: options.value or 0

    #----------

    addToDataLayer: (options) ->
        options.nonInteraction ?= true

        # push to the dataLayer for general reporting purposes (e.g. NPR)
        dataLayer.push
            event: 'AudioPlayer'
            eventCategory: 'AudioPlayer'
            eventAction: options.action
            eventLabel: @src()
            nonInteraction: options.nonInteraction
            eventValue: options.value or 0

    class @PlayWidget
        constructor: (options) ->
            @options = options
            @player = @options.player
            # register click handler on play button
            @options.playBtn.on "click", (e) =>
                @player.play @
                return false

        play: () ->
            # ...

        stop: () ->
            # ...
