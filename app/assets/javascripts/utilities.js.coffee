class scpr.CompactNav
    constructor: ->
        @nav = $("#footer-nav")
        @viewPort = $(".viewport")

        $("#condensed-nav-link").on
            click: => @slideRight()

        $("#compact-nav-head .in-btn").on
            click: => @slideLeft()

    slideRight: ->
        $("html").addClass "compactNav"
        @nav.addClass("active")
        @viewPort.css(height: @nav.height())

        $("body").addClass("navIn").css
            height: @nav.height()

        @viewPort.animate(left: @nav.width(), "fast")

    slideLeft: ->
        @viewPort.animate(left: 0, "fast", =>
            @viewPort.css(height: "auto")
            $("body").removeClass("navIn").css
                height: "auto"
            @nav.removeClass("active")
        )

#----------
# Hack to get DFP ads in iframes to be responsive
class scpr.adSizer
    constructor: ->
        $(document).ready =>
            # 7 times. If the ad hasn't loaded after that,
            # then we're giving up.
            for i in [1..7]
                @sizedCheck(i)

    setPositionRelative: (element) ->
        $(element).css
            "position": "relative"

    resize: (element) ->
        $(element).css
            "max-width": "100%",
            "height": "auto"
        @removeFixedDimensions(element)

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

                googleAdContainer = $(iframe.contentWindow.document).find(
                        "#google_image_div")[0]

                if $(ad).length
                    @setPositionRelative(googleAdContainer)
                    @resize(ad)
                    $(iframe).closest(".ad .dfp, .c-ad .dfp").addClass("adSized")

    removeFixedDimensions: (element) ->
        $(element).removeAttr("width").removeAttr("height")

#----------

class scpr.TweetRotator
    defaults:
        el:          "#election-tweets"
        fadeSpeed:   '400' # milliseconds
        rotateSpeed: 15 # seconds
        activeClass: 'active'

    constructor: (options={}) ->
        @options    = _.defaults options, @defaults
        @el         = $(@options.el)

        @_firstChild = $(@el.children()[0])
        @active      = @_firstChild

        setInterval =>
            @rotate()
        , @options.rotateSpeed * 1000

    rotate: ->
        next = @getNext()
        @active.fadeOut @options.fadeSpeed, =>
            @deactivate @active
            @activate next

    activate: (el) ->
        el.fadeIn @options.fadeSpeed, =>
            el.addClass(@options.activeClass)
            @active = el

    deactivate: (el) ->
        el.removeClass(@options.activeClass)

    getNext: ->
        next = @active.next()
        if next.length then next else @_firstChild


#----------
class scpr.PromoteFacebook
    constructor: ->
        $(document).ready =>
            # Show callout to Like KPCC on Facebook if user
            # came to scpr.org from Facebook.
            unless document.referrer.search("facebook") is -1
                $(".fb-callout").addClass "show"

class scpr.SocialTools
    DefaultOptions:
        fbfinder        : ".social_fb"
        twitfinder      : ".social_twit"
        gplusfinder     : ".social_gplus"
        emailfinder     : ".social_email"
        disqfinder      : ".social_disq"
        count           : ".count"
        gaq             : "_gaq"
        disqurl         : "https://disqus.com/api/3.0/threads/set.jsonp"
        disq_api_key    : 'EAlRB1x2Coj262YxEGbmvecZufapzC8IJ8aqKgtG0ILS4L1EMucA66Jq9MlY270b'
        disq_short_name : 'kpcc'
        no_comments     : "Add your comments"
        comments        : "<%= count %>"

    constructor: (options) ->
        @options = _.defaults options||{}, @DefaultOptions

        # look for facebook elements so that
        # we can add functionality
        @fbelements = ($ el for el in $ @options.fbfinder)
        @fbTimeout = null

        # look for twitter elements
        @twit_elements = ($ el for el in $ @options.twitfinder)
        @twitTimeout = null

        # look for disqus elements
        @disq_elements = ($ el for el in $ @options.disqfinder)
        @disqPending = false
        @disqTimeout = null

        # -- look for google analytics -- #
        @gaq = null
        if window[@options.gaq]
            @gaq = window[@options.gaq]

        if @disq_elements.length > 0
            @disqCache = []
            @_getDisqusCounts()

        # add share functionality on facebook
        $(@options.fbfinder).on "click", (evt) =>
            if url = $(@options.fbfinder).attr("data-url")
                fburl = "http://www.facebook.com/sharer.php?u=#{url}"
                window.open fburl, 'pop_up',
                    'height=350,width=556,'+
                    'resizable,left=10,top=10,scrollbars=no,toolbar=no'
            false

        # add share functionality on google plus
        $(@options.gplusfinder).on "click", (evt) =>
            if url = $(evt.target).attr("data-url")
                gpurl = "https://plus.google.com/share?url=#{url}"
                window.open gpurl, 'pop_up',
                    'height=400,width=500,' +
                    'resizable,left=10,top=10,scrollbars=no,toolbar=no'

        # add share functionality for twitter
        $(@options.twitfinder).on "click", (evt) =>
            if url = $(@options.twitfinder).attr("data-url")
                headline = $(@options.twitfinder).attr("data-text")
                twurl = "https://twitter.com/intent/tweet?" +
                        "url=#{url}&text=#{headline}&via=kpcc"
                window.open twurl, 'pop_up',
                    'height=350,width=556,' +
                    'resizable,left=10,top=10,scrollbars=no,toolbar=no'
            false

        # add share functionality for email
        $(@options.emailfinder).each (index, el) =>
          $(el).on "click", (evt) =>
              if key = $(el).attr("data-key")
                  emurl = "/content/share?obj_key=#{key}"
                  debugger
                  window.open emurl, 'pop_up',
                      'height=830,width=545,' +
                      'resizable,left=10,top=10,scrollbars=no,toolbar=no'
              false

    #----------

    _getDisqusCounts: ->
        # fire off a request to disqus
        urls = []
        @disqCache = {}

        _(@disq_elements).each (el,idx) =>
            if url = el.attr('href')
                @disqCache[el.attr('data-objkey')] = el
                urls.push "link:http://www.scpr.org" + url.split("#")[0]

        ajax = $.ajax(
            url: @options.disqurl
            type: 'GET'
            dataType: "jsonp"
            data:
                api_key: @options.disq_api_key,
                forum: @options.disq_short_name,
                thread: urls
            success: (data) =>
                @_displayDisqusCounts(data)
            error: (jqxhr, status, error) =>
                @_signalDisqusLoadFailure()
        )

        @disqPending = Number(new Date)
        true

    _displayDisqusCounts: (data) ->
        # how long did the load take?
        loadtime = Number(new Date) - @disqPending
        @gaq?.push ['_trackEvent','SocialTools','Disqus Load','',loadtime,true]

        # handle comment counts on the page
        for thread in data.response
            count = thread.posts
            continue if count < 1

            el = @disqCache[thread.identifiers[0]]
            parent = el.parents("div.comments")

            # will not display comment count if it has the class 'non-zero' and the count is zero
            if el[0] && !((/non-zero/.test(parent.className)) && count == 0)
                c = $(@options.count, el)
                if c.length
                    c.text(count)
                else
                    el.text _.template(@options.comments, count: count)

                parent.removeClass("non-zero")

            # note our pending request as finished
            @disqPending = false

            true

    _signalDisqusLoadFailure: ->
        console.log "failed to load disqus counts in 5 seconds."
        @gaq?.push([
            '_trackEvent',
            'SocialTools',
            'Disqus Failure',
            String(new Date),
            0,
            true
        ])