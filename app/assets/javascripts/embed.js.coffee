class scpr.Embed
    @placeholderFinder = "embed-placeholder"

    @embedHandlers =
        'youtube'       : 'Embedly'
        'vimeo'         : 'Embedly'
        'vine'          : 'Embedly'
        'brightcove'    : 'Embedly'
        'ustream'       : 'Embedly'
        'twitter'       : 'Embedly'
        'instagram'     : 'Embedly'
        'facebook'      : 'Embedly'
        'googlemaps'    : 'Embedly'
        'polldaddy'     : 'Embedly'
        'scribd'        : 'Embedly'
        'storify'       : 'Embedly'
        'soundcloud'    : 'Embedly'
        'spotify'       : 'Embedly'
        'other'         : 'Embedly'


    constructor: ->
        @placeholders = []
        @links = $(@_classify Embed.placeholderFinder)
        @findEmbeds()


    swap: ->
        placeholder.swap() for placeholder in @placeholders


    findEmbeds: ->
        for link in @links
            link = $(link)

            service = link.data('service') || 'other'
            handler = Embed.embedHandlers[service]

            placeholder = new scpr.Embed[handler](link)
            @placeholders.push(placeholder)


    _classify: (str) ->
        "." + str
