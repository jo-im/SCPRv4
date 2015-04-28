class scpr.EventTracking
    chooser: ".track-event"
    constructor: ->
        new scpr.EventTrackingLink($ link) for link in $(@chooser)

class scpr.EventTrackingLink
    attributes:
        category: "data-ga-category"
        action:   "data-ga-action"
        label:    "data-ga-label"
        nonInteraction: "data-non-interaction"

    defaults:
        nonInteraction: 0

    constructor: (@el) ->
        @category = @el.attr(@attributes.category)
        @action   = @el.attr(@attributes.action)
        @label    = @el.attr(@attributes.label)

        @nonInteraction = parseInt(@el.attr(@attributes.nonInteraction)) || @defaults.nonInteraction

        # Setup click event
        if @nonInteraction == 1
          @_gapush()
        else
          @el.on click: =>
            @_gapush()


    _gapush: ->
        ga('send', 'event', @category, @action, @label, {'nonInteraction': @nonInteraction});
