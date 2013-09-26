class scpr.EmbedPlaceholder
    # This object should hold any keys that we want to
    # send to the API. Any key not in this object will
    # be ignored as a data attribute.
    @queryDefaults =
        maxheight: 450

    @embedlyDefaults =
        key         : "0cb3651dde4740db8fcb147850c6b555"
        method      : "before"
        className   : "embed-wrapper"
        endpoint    : 'oembed'


    buildEmbedlyParams: (queryParams) ->
        if @embedlyParams
            return @embedlyParams

        @embedlyParams = _.extend(
            EmbedPlaceholder.embedlyDefaults,
            query : queryParams)


    constructor: (@element) ->
        data = {}

        for key,val of @element.data()
            # Make sure we care about this attribute
            if EmbedPlaceholder.queryDefaults[key]
                data[key] = val

        @queryParams = _.defaults data, EmbedPlaceholder.queryDefaults


    swap: ->
        params = @buildEmbedlyParams(@queryParams)
        @element.embedly(params)

