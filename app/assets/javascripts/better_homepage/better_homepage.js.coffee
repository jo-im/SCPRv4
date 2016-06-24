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
    @collection = new ArticleCollection()
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
      articles: new ArticlesComponent
        el: @$el
        collection: @collection

      # pass the same collection to a 'whats next' component
      'whats-next': new WhatsNextComponent
        collection: @collection

      # feedback element
      feedback: new FeedbackComponent
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

  class FeedbackComponent extends @Component
    name: 'feedback-component'
    init: ->
      @insertTracking()
      @adaptVisibility()
    adaptVisibility: ->
      # This seems to work fine for now, though maybe something
      # based on scrollStop would be preferable.  This at least
      # takes care of onLoad.
      if $('footer.footer').isOnScreen()
        @$el.addClass 'hidden'
      else
        @$el.removeClass 'hidden'
      setTimeout =>
        @adaptVisibility()
      , 500
    insertTracking: ->
      link = @$el.find('a.beta-opt-out')
      link.addClass('track-event')
      link.attr('data-ga-category', "@currentCategory")
      link.attr('data-ga-action', "Opt-Out")
      link.attr('data-ga-label', "@scrollDepth")

  class WhatsNextHeadlineComponent extends @Component
    tagName: 'li'
    name: 'whats-next-headline-component'
    beforeDestroy: (callback) ->
      if this.model.get('state') isnt 'new'
        @reloadEl()
        @$el.one "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", (e) => 
          # if we finished the last transition
          if e.originalEvent.propertyName is 'margin-bottom'
            callback()
        @$el.addClass 'read' # this class creates an animated transition
      else
        super(callback)

  class Boundary
    constructor: (el) ->
      @el = el
      @scrollUp = @el.attr('data-scroll-up')
      @scrollDown = @el.attr('data-scroll-down')
      @offset = parseInt(@el.attr('data-offset')) or 0
      @el.css 'margin-top', @offset
      @wasInView = @isInView()
    top: ->
      @el.position().top
    isInView: ->
      position  = @el.position()
      top       = position.top + @offset
      wind      = $(window)
      winTop    = wind.scrollTop()
      winBottom = (wind.scrollTop() + wind.height())
      top > winTop and top < winBottom
    isOutOfView: ->
      !@isInView()
    hasCrossed: ->
      @wasInView isnt @isInView()
    isAbove: ->
      position  = @el.position()
      top       = position.top + @offset
      wind      = $(window)
      top < (wind.scrollTop() + wind.height())
    isBelow: ->
      !@isAbove()

  class WhatsNextComponent extends @Component
    name: 'whats-next-component'
    collectionEvents: "add remove reset change"
    className: 'hidden frozen visible'
    attributes:
      id: 'whats-next'
    init: (options)->
      initialBoundary = new Boundary($('#whats-next-initial.boundary'))
      @$el.css 'top', initialBoundary.top() - 400 # creates an offset that prevents "bounce"
      $('section#content').prepend @$el
      # we handle showing and hiding
      # with the scroll event because
      # render doesn't get fired that
      # often
      @collection = new ArticleCollection options.collection.whatsNext()
      @components = 
        headline: WhatsNextHeadlineComponent
    afterInit: ->
      # This has to happen here because our
      # components don't get registered until
      # after init.
      @render()
      @findBoundaries()
      $(window).on 'DOMMouseScroll mousewheel resize', (e) => 
        @detectCollision(e) unless @hasCompleted or not @isVisible()# so that we don't do extra work when we don't need to
    render: ->
      unless @hasNone()
        super()
      else
        @$el.removeClass 'visible'
        @$el.addClass 'hidden'
        @hasCompleted = true
    hasNone: ->
      @collection.where({state: 'new'}).length is 0   

    isVisible: ->
      # !@$el.hasClass('hidden') and @$el.is(':visible')
      @$el.hasClass('visible')

    properties: ->
      stories: @collection.where({state: 'new'})

    detectCollision: (e) ->
      # delta     = (e.originalEvent.detail or e.originalEvent.wheelDelta)
      for boundary in (@boundaries or [])
        if boundary.hasCrossed()
          if boundary.isInView() and boundary.lastDirection isnt 'scrollDown'
            direction = 'scrollDown'
          else if boundary.isBelow() #and boundary.lastDirection isnt 'scrollDown'
            direction = 'scrollUp'
          if direction
            boundary.lastDirection = direction
            for action in (boundary[direction] or '').split(' ')
              @[action]?(boundary)
        boundary.wasInView = boundary.isInView()
      
    show: ->
      unless @hasNone()
        @$el.removeClass('invisible')
        @$el.removeClass('hidden')
        @$el.addClass('visible')
      else
        @$el.removeClass('visible')
        @$el.addClass('hidden')

    hide: ->
      @$el.removeClass('visible')
      @$el.addClass('hidden')

    hideQuickly: ->
      @$el.removeClass('visible')
      @$el.addClass('invisible')

    freeze: (boundary) ->
      if !@$el.hasClass('frozen')
        offset = @$el.offset()
        @$el.css 'top', offset.top
        @$el.css 'left', offset.left
        @$el.addClass 'frozen'

    unfreeze: (boundary) ->
      if @$el.hasClass('frozen')
        @$el.css 'top', ''
        @$el.css 'left', ''
        @$el.removeClass 'frozen'

    rollup: ->
      @$el.one 'webkitAnimationEnd oanimationend msAnimationEnd animationend',  (e) =>
        @$el.removeClass 'rollup'
      @$el.addClass 'rollup'

    rolldown: ->
      @$el.one 'webkitAnimationEnd oanimationend msAnimationEnd animationend',  (e) =>
        @$el.removeClass 'rolldown'
      @$el.addClass 'rolldown'

    findBoundaries: ->
      @boundaries = []
      for el in $('.boundary')
        el = $(el)
        @boundaries.push new Boundary $(el)


  class Article extends @Model.mixin(@Persistent)
    name: 'article'
    states: ['new', 'seen', 'read']
    defaults:
      state: 'new'
    init: ->
      @load(['state']) # get saved attributes from localstorage, if any
      @listenTo @, 'change', => @save()
    whatsNext: ->
      (@collection or new ArticleCollection).whatsNext()

  class ArticleCollection extends @Collection
    name: 'article-collection'
    model: Article
    whatsNext: ->
      fc = @filter (model, index) => model.get('state') == 'new' # is below the top 3 stories
      firstIndex  = Math.round(fc.length * 0.5) - 1
      secondIndex = Math.round(fc.length * 0.75) - 1
      thirdIndex  = fc.length - 1
      _.reject [fc[firstIndex], fc[secondIndex], fc[thirdIndex]], (m) => m is undefined 

  class ArticleComponent extends @Component
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

      # If no timestamp is present(which can change on conditions),
      # display the feature type.
      unless @$el.find('time').text().length
        label = @$el.find(".media__meta .media__label")
        if label.attr('data-media-label')
          label.append label.attr('data-media-label')
          label.find('use').attr('xlink:href', "#icon_line-audio")

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
      @$el.find('.headline').isOnScreen()

    render: ->
      # @$el.removeClass (klass for state, klass of @stateTranslation).join(' ')
      @$el.addClass @stateToMediaClass()


  class ArticlesComponent extends @Component
    name: 'articles-component'
    components:
      article: ArticleComponent
    init: (options={}) ->
      @options.headless = true
      for model in @collection.models
        objKey = model.get('id')
        new ArticleComponent
          model: model
          el: @$el.find("[data-obj-key='#{objKey}']")