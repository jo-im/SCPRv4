class scpr.VisualCampaign
    constructor: (@options={}) ->
        return

    fetch: ->
        return if scpr.Cookie.get("adClosed") == "1"

        $.ajax
            type        : "GET"
            url         : @options.endpoint + "/" + @options.key
            dataType    : "json"

            success: (data, textStatus, jqXHR) =>
                @options.success(data['visual_campaign']['markup'])
