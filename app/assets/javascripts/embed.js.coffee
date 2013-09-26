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

    @defaultHandler = 'Embedly'
    @defaultService = 'other'

    constructor: ->
        @placeholders = []
        @links = $(@_classify Embed.placeholderFinder)
        @findEmbeds()


    swap: ->
        placeholder.swap() for placeholder in @placeholders


    findEmbeds: ->
        for link in @links
            link = $(link)

            # If "service" is blank in the CKEditor dialog, then it will
            # omit that data-attribute from the tag, and therefore
            # be undefined. In this scenario, we want to use the default
            # service as a fallback.
            #
            # If "service" is present but has no match in the Handlers object,
            # then we want to use the default handler as a fallback.
            service = link.data('service') || Embed.defaultService
            handler = Embed.embedHandlers[service] || Embed.defaultHandler

            placeholder = new scpr.Embed[handler](link)
            @placeholders.push(placeholder)


    _classify: (str) ->
        "." + str
