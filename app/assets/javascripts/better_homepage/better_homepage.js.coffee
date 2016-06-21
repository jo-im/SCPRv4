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

    # make our article components
    @articlesComponent = new ArticlesComponent
      el: @$el
      collection: @collection

    # pass the same collection to a 'whats next' component
    @whatsNext         = new WhatsNextComponent
      collection: @collection

    # feedback element
    @feedback          = new FeedbackComponent
      el: $('#feedback-block')

    @eventTracking     = new scpr.EventTracking
      trackScrollDepth: true
      currentCategory: 'Homepage'
      scrollDepthContainer: @$el

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

  class WhatsNextComponent extends @Component
    name: 'whats-next-component'
    collectionEvents: "add remove reset change"
    className: 'hidden'
    attributes:
      id: 'whats-next'
    init: (options)->
      $('section#content').prepend @$el
      # we handle showing and hiding
      # with the scroll event because
      # render doesn't get fired that
      # often
      $(window).scroll => @hideIfBlocked()
      @collection = new ArticleCollection options.collection.whatsNext()
      @components = 
        headline: WhatsNextHeadlineComponent
    afterInit: ->
      # This has to happen here because our
      # components don't get registered until
      # after init.
      @render()
    render: ->
      unless @hasNone()
        super()
      else
        @$el.addClass 'hidden'
    hasNone: ->
      @collection.where({state: 'new'}).length is 0   
    hideIfBlocked: ->
      if @isBlocked() or !@isBelowPositionB()
        @$el.removeClass 'visible'
        @$el.addClass 'hidden'
      else
        unless @hasNone()
          @$el.removeClass 'hidden'
          @$el.addClass 'visible'
    isVisible: ->
      # !@$el.hasClass('hidden') and @$el.is(':visible')
      @$el.hasClass('visible')
    isBlocked: ->
      # tells us whether or not an ad or a huge
      # story image is in the way(i.e. visible on screen)
      docViewTop    = $(window).scrollTop()
      docViewBottom = docViewTop + $(window).height()
      for element in $('.hidden-gem, footer')
        el = $(element)
        if el.isOnScreen()
          return true
      false
    isBelowPositionB: ->
      positionB = $('#ad-position-b').first()
      $(window).scrollTop() > (positionB?.position()?.top + positionB?.height())
    properties: ->
      stories: @collection.where({state: 'new'})

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
      @$el.find('.media__headline').isOnScreen()

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