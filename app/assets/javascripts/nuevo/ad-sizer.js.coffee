# Hack to get DFP ads in iframes to be responsive
$ = require('jquery')

module.exports = class
    constructor: ->
        $(document).ready =>
            # 7 times. If the ad hasn't loaded after that,
            # then we're giving up.
            for i in [1..7]
                @sizedCheck(i)

    sizedCheck: (i) ->
        setTimeout () =>
            if $(".dfp:not(.adSized)").length
                @resizeIframes()
        , 500*i

    resizeIframes: ->
        $.each $(".dfp:not(.adSized) iframe"), (i, iframe) =>
            $(iframe.contentWindow.document).ready () =>
                ad = $(iframe.contentWindow.document).find(
                        "img, object, embed")[0]
                if $(ad).length

                    $(ad).css
                        "width": "100%"
                        "height": "100%"

                    @removeFixedDimensions(ad)

                    widthPx  = parseFloat($(iframe).attr('width'))
                    heightPx = parseFloat($(iframe).attr('height'))

                    wrapper = $(iframe).closest(".ad .dfp, .c-ad .dfp")

                    $(iframe).css
                        "width": "100%"
                        "height": "100%"
                        "top": "0"
                        "left": "0"
                        "position": "absolute"

                    @removeFixedDimensions(iframe)

                    wrapper.css
                        "position": "relative"
                        "padding-bottom": ((heightPx / widthPx) * 100) + "%"
                        "height": "0px"
                        "padding-top": "0px"
                        "overflow": "hidden"

 
                    wrapper.addClass("adSized")


    removeFixedDimensions: (element) ->
        $(element).removeAttr("width").removeAttr("height")