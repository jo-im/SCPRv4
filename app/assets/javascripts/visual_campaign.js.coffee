class scpr.VisualCampaign
    @ENDPOINT       = "http://audiobox.scprdev.org/api/v1/visual_campaigns"
    @HIDE_SELECTOR  = ".campaign-hide"

    @queue = {}

    # Enqueue a visual campaign to be included in a batch-fetch
    @enqueue: (key, element) ->
        @queue[key] = element

    # Fetch all campaigns in the queue.
    @fetchQueue: ->
        # No need to do anything if nothing is in the queue
        return if _.isEmpty(@queue)

        $.ajax
            type    : "GET"
            url     : @ENDPOINT
            data:
                keys: _.keys(@queue).join(",")

            success: (data, textStatus, jqXHR) =>
                for key, element of @queue
                    attributes = data["visual_campaigns"][key]
                    continue unless attributes

                    cookie_key = attributes['cookie_key']
                    continue if cookie_key and scpr.Cookie.get(cookie_key)

                    campaign = new scpr.VisualCampaign(attributes, element)
                    campaign.loadMarkup()
                    $(@HIDE_SELECTOR, element).on "click", -> campaign.hide()



    constructor: (attributes={}, @element) ->
        @key                = attributes['key']
        @markup             = attributes['markup']
        @cookie_key         = attributes['cookie_key']
        @cookie_ttl_hours   = attributes['cookie_ttl_hours']


    # Load the campaign's markup into the element
    loadMarkup: ->
        @element.append(@markup)


    # Hide the element and set a cookie for the campaign
    hide: ->
        @element.hide()

        scpr.Cookie.set
            key           : @cookie_key,
            value         : "1"
            expireSeconds : @cookie_ttl_hours*60*60
