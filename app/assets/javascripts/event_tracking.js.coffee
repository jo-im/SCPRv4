class scpr.EventTracking
    chooser: ".track-event"
    constructor: (@options={})->
        @parseOptions(@options)
        new scpr.EventTrackingLink($(link), @options) for link in $(@chooser)
        
    parseOptions: (opts)->
        for option of opts
            @options[option] = opts[option]

        if @options.trackScrollDepth
            new scpr.ScrollTracker(@options)

    @Helpers:
        scrollDepth: ->
            $.scrollDepth.calculateScrollPercentageFromMarks()

        currentCategory: ->
            @options.currentCategory

    class scpr.EventTrackingLink
        attributes:
            category: "data-ga-category"
            action:   "data-ga-action"
            label:    "data-ga-label"
            nonInteraction: "data-non-interaction"

        defaults:
            nonInteraction: 0

        constructor: (@el, @options={}) ->
            @nonInteraction = parseInt(@el.attr(@attributes.nonInteraction)) || @defaults.nonInteraction

            # Setup click event
            if @nonInteraction == 1
              @_gapush()
            else
              @el.on click: =>
                @_gapush()

        category: ->
            @_evalString @el.attr(@attributes.category)

        action: ->
            @_evalString @el.attr(@attributes.action)

        label: ->
            @_evalString @el.attr(@attributes.label)

        _gapush: ->
            category = @category() 
            action   = @action()
            label    = @label()
            # Don't send event unless we have all 3 pieces of data (which could happen if no current category is set)
            if category && action && label
                ga('send', 'event', category, action, label, {'nonInteraction': @nonInteraction});
                console.log([@category(), @action(), @label()]) if @options.verbose

        _evalString: (str) ->
            # If the string begins with an @ symbol, use it to call a helper function
            if @_shouldEvalAttribute(str)
                attr = scpr.EventTracking.Helpers["#{str.replace(/^@/, '')}"]
                if (typeof attr) == "function"
                    return attr.bind(this).call()
                else
                    return attr
            else
                return str

        _shouldEvalAttribute: (str) ->
            str[0] == "@"

    class scpr.ScrollTracker
        constructor: (@options={})->
            @enable()
            # Register the scroll depth position the page loads at.
            $(window).trigger("scroll.scrollDepth") 
        enable: ->
            # Only track if we have a category we can use
            if @options.currentCategory
                $.scrollDepth
                    gtmOverride: true
                    elements: [@chooser]
                    userTiming: false
                    pixelDepth: false
                    percentage: true
                    eventHandler: (data)=>
                        ga('send', 'event', @options.currentCategory, 'Scroll Depth', data.eventLabel, {'nonInteraction': 1});
                        console.log([@options.currentCategory, 'Scroll Depth', data.eventLabel]) if @options.verbose
                    nonInteraction: 1
                    container: @options.scrollDepthContainer

        disable: ->
            $.scrollDepth.reset()


if typeof module != 'undefined' and module.exports # if node.js/browserify
  module.exports = scpr.EventTracking