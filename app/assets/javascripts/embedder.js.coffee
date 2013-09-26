class scpr.Embedder
    embedlyDefaults :
        key         : "0cb3651dde4740db8fcb147850c6b555"
        method      : "before"
        className   : "embed-wrapper"
        endpoint    : 'oembed'

    displayDefaults :
        placeholderFinder   : "embed-placeholder"
        wrapperClass        : "embed-wrapper"


    constructor: (@options={}) ->
        @displayOptions     = _.defaults(@options['display'] || {}, @displayDefaults)
        @embedlyOptions     = _.defaults(@options['embedly'] || {}, @embedlyDefaults)

        @embeds = $(@_classify(@displayOptions.placeholderFinder))
        @swapEmbeds()


    swapEmbeds: ->
        for placeholder in @embeds
            placeholder = $(placeholder)

            params         = _.defaults({}, @embedlyOptions)
            params.query   = _.defaults(placeholder.data(), params.query)

            console.log(params)
            placeholder.embedly(params)


    _classify: (str) ->
        "." + str
