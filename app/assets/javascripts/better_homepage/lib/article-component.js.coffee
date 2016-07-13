Framework = require('framework')
SmarterTime = require('better_homepage/smarter-time')

module.exports = class ArticleComponent extends Framework.Component
  name: 'article-component'
  events:
    "click a" : "markAsRead"
  init: (options)->
    @insertTracking()
    @render()
    $(window).scroll =>
      # this is set up to prevent needless re-rendering
      # upon every scroll event firing.
      if @isScrolledIntoView()
        @markAsSeen()

    @smarterTime = new SmarterTime
      prefix: ''
      finder: @$el.find('.media__meta time')
      relativeTimeStrings:
        future: 'in %s'
        past: '%s ago'
        s: 'seconds'
        m: '1ms'
        mm: '%dm'
        h: '1h'
        hh: '%dh'
        d: '1d'
        dd: '%dd'
        M: '1m'
        MM: '%dm'
        y: '1y'
        yy: '%dy'

    # If no timestamp is present(which can change on conditions),
    # display the feature type.
    if @$el.find('time').text().length
      label = @$el.find(".media__meta .media__label")
      label.addClass 'hidden'

  insertTracking: ->
    # I'd prefer to do this here because it's a pain
    # to edit these attributes in all the templages
    # if we ever have to change anything.  Since this
    # is behavior, I think this should be handled in
    # the component instead of the templates.
    headline = @$el.find('.headline a')
    headline.addClass('track-event')
    headline.attr('data-ga-category', "@currentCategory")
    headline.attr('data-ga-action', "Article")
    headline.attr('data-ga-label', "@scrollDepth")

    related = @$el.find('.related-content a')
    related.addClass('track-event')
    related.attr('data-ga-category', "@currentCategory")
    related.attr('data-ga-action', "Related Content")
    related.attr('data-ga-label', "@scrollDepth")

    callToAction = @$el.find('a.call-to-action')
    callToAction.addClass('track-event')
    callToAction.attr('data-ga-category', "@currentCategory")
    callToAction.attr('data-ga-action', "Call To Action")
    callToAction.attr('data-ga-label', "@scrollDepth")

  stateToMediaClass: ->
    @stateTranslation[@model.get('state')] or ''

  stateTranslation:
    new: 'media--new-and-unread'
    seen: 'media--seen-and-unread'
    read: 'media--visited-and-read'

  markAsSeen: ->
    unless @model.get('state') is 'read'
      @model.set 'state', 'seen'

  markAsRead: (e) ->
    @model.set 'state', 'read'

  isScrolledIntoView: ->
    headline         = @$el.find('.headline')
    view             = if @model.isLastArticle() then 1 else 0.2
    headlinePosition = headline.offset().top
    wind             = $(window)
    winTop           = wind.scrollTop()
    winBottom        = winTop + (wind.height() * view)
    (headlinePosition < winBottom) and (headlinePosition > winTop)

  render: ->
    # @$el.removeClass (klass for state, klass of @stateTranslation).join(' ')
    @$el.addClass @stateToMediaClass()