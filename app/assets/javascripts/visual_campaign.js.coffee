class scpr.VisualCampaign
    constructor: (@options={}) ->
        return

    fetch: ->
        $.ajax
            type        : "GET"
            url         : @options.endpoint + "/" + @options.key
            dataType    : "json"

            complete: (xhr, status) ->
                console.log "got it: ", status
