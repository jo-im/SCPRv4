class scpr.Embedder
    placeholderFinder : "embed-placeholder"


    constructor: ->
        @placeholders = []
        @links = $(@_classify @placeholderFinder)
        @findEmbeds()


    swap: ->
        placeholder.swap() for placeholder in @placeholders


    findEmbeds: ->
        for link in @links
            link = $(link)
            placeholder = new scpr.EmbedPlaceholder(link)
            @placeholders.push(placeholder)


    _classify: (str) ->
        "." + str
