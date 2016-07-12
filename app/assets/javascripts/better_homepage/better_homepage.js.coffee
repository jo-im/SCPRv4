scpr.Framework      = require 'framework'
scpr.EventTracking  = require 'event_tracking'
Boundary            = require './lib/boundary'

class scpr.BetterHomepage extends scpr.Framework

  init: (options={}) ->
    $.fn.isOnScreen = ->
      win = $(window)
      viewport = 
        top: win.scrollTop()
        left: win.scrollLeft()
      viewport.right = viewport.left + win.width()
      viewport.bottom = viewport.top + win.height()
      bounds = @offset()
      bounds.right = bounds.left + @outerWidth()
      bounds.bottom = bounds.top + @outerHeight()
      !(viewport.right < bounds.left or viewport.left > bounds.right or viewport.bottom < bounds.top or viewport.top > bounds.bottom)

    $.timeago.settings.strings =
      suffixAgo: ' ago'
      minute: 'about a minute'
      minutes: '%dm'
      hour: 'about 1h'
      hours: '%dh'
      day: '1d'
      days: '%dd'
      month: '1mo'
      months: '%dmo'

    @$el.find('#homepage-timestamp time.timeago').timeago()
    @smartTime = new (scpr.SmartTime)
      prefix: "Today's Top Stories <span class='divider'>|</span> Last Updated "
      finder: ['#homepage-timestamp time']
      wrapText: true

    # create a collection based on the articles in the DOM
    @collection = new (require('./lib/article-collection'))()
    articleEls = @$el.find('[data-obj-key]')
    @collection.reset ({'id': $(el).attr('data-obj-key'), title: $.trim($(el).find('.headline').text())} for el in articleEls)

    # reset stories to 'new' if development is set to true.
    # I'm sure there's a better way to apply properties
    # to all models in a collection.
    console.log @params('dev')

    if options.development or @params('dev')
      @collection.toArray().forEach (m) => 
        m.set 'state', 'new'
        m.save()

    @components =
      # make our article components
      articles: new (require('./lib/articles-component'))
        el: @$el
        collection: @collection

      # pass the same collection to a 'whats next' component
      'whats-next': new (require('./lib/whats-next-component'))
        collection: @collection

      # feedback element
      feedback: new (require('./lib/feedback-component'))
        el: $('#feedback-block')

    @eventTracking     = new scpr.EventTracking
      trackScrollDepth: true
      currentCategory: 'Homepage'
      scrollDepthContainer: @$el

    checkItOut = @$el.find('#check-it-out a')
    checkItOut.addClass('track-event')
    checkItOut.attr('data-ga-category', "@currentCategory")
    checkItOut.attr('data-ga-action', "Check It Out")
    checkItOut.attr('data-ga-label', "Link")

    @findBoundaries()
    @detectCollision()

  detectCollision: (e) ->
    boundaryCount = @boundaries.length
    i = 0
    while i < boundaryCount
      ((i) =>
        boundary = @boundaries[i]
        setTimeout =>
          if boundary.hasCrossed()
            if boundary.isInView() and boundary.lastDirection isnt 'scrollDown'
              direction = 'scrollDown'
            else if boundary.isBelow() #and boundary.lastDirection isnt 'scrollDown'
              direction = 'scrollUp'
            if direction
              boundary.lastDirection = direction
              for action in (boundary[direction] or '').split(' ')
                for cname in boundary.components
                  @components[cname]?[action]?(boundary, e)
          if i is (boundaryCount - 1)
            setTimeout =>
              @detectCollision()
            , 0
          boundary.wasInView = boundary.isInView()
        , 0
      )(i)
      i++

  findBoundaries: ->
    @boundaries = []
    for el in $('.boundary')
      el = $(el)
      @boundaries.push new Boundary $(el)
      , 0