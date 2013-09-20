class scpr.Embedder
    embedlyOptions:
        key         : "0cb3651dde4740db8fcb147850c6b555"
        method      : "before"
        className   : "embed-wrapper"
        endpoint    : 'oembed'
        query       :
            maxHeight : 450

    defaults:
        placeholderFinder   : "embed-placeholder"
        wrapperClass        : "embed-wrapper"

    constructor: (options={}) ->
        @options = _.defaults options, @defaults
        @embeds = $(@classify(@options.placeholderFinder))
        @swapEmbeds()

    swapEmbeds: ->
        for placeholder in @embeds
            $(placeholder).embedly(@embedlyOptions)

    classify: (str) ->
        "." + str
