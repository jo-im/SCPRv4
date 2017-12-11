scpr.Framework      = require 'framework'
SmarterTime         = require './smarter-time'

class scpr.BetterHomepage extends scpr.Framework

  init: (options={}) ->
    $.fn.isOnScreen = ->
      win = $(window)
      viewport =
        top: win.scrollTop()
        left: win.scrollLeft()
      viewport.right = viewport.left + win.width()
      viewport.bottom = viewport.top + win.height()
      bounds = @offset() or {left: -99999, top: -99999}
      bounds.right = bounds.left + @outerWidth()
      bounds.bottom = bounds.top + @outerHeight()
      !(viewport.right < bounds.left or viewport.left > bounds.right or viewport.bottom < bounds.top or viewport.top > bounds.bottom)

    @smarterTime = new SmarterTime
      prefix: "Today's Top Stories <span class='divider'>|</span> Last Updated "
      finder: ['#homepage-timestamp time']
      wrapText: true

    # create a collection based on the articles in the DOM
    @collection = new (require('./lib/article-collection'))()
    articleEls = @$el.find('article.hp-story > .story[data-obj-key]')
    @collection.reset ({'id': $(el).attr('data-obj-key'), title: $.trim($(el).find('> .headline').text())} for el in articleEls)

    # reset stories to 'new' if development is set to true.
    # I'm sure there's a better way to apply properties
    # to all models in a collection.

    if options.development or @params('dev')
      @collection.toArray().forEach (m) =>
        m.set 'state', 'new'
        m.save()

    @components =
      # make our article components
      articles: new (require('./lib/articles-component'))
        el: @$el
        collection: @collection

      # feedback element
      feedback: new (require('./lib/feedback-component'))
        el: $('#feedback-block')
