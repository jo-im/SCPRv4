scpr.Framework      = require 'framework'
scpr.EventTracking  = require 'event_tracking'

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

    # create a collection based on the articles in the DOM
    @collection = new (require('./lib/article-collection'))()
    articleEls = @$el.find('[data-obj-key]')
    @collection.reset ({'id': $(el).attr('data-obj-key'), title: $.trim($(el).find('.headline').text())} for el in articleEls)

    # reset stories to 'new' if development is set to true.
    # I'm sure there's a better way to apply properties
    # to all models in a collection.
    if options.development
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

    # @render()