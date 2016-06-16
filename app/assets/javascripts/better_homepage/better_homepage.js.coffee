scpr.Framework = require 'framework'

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
    @collection.reset ({'id': $(el).attr('data-obj-key'), title: $(el).find('a.headline__link').text()} for el in articleEls)
    @collection.toArray().forEach (m) => 
      m.set 'state', 'new'
      m.save()

    # make our article components
    @articlesComponent = new ArticlesComponent
      el: @$el
      collection: @collection

    # pass the same collection to a 'whats next' component
    @whatsNext = new WhatsNextComponent
      el: $('#whats-next')
      collection: @collection

    # feedback element
    @feedback  = new FeedbackComponent
      el: $('#feedback-block')

  class FeedbackComponent extends @Component
    name: 'feedback-component'
    events:
      'click a.beta-opt-out': 'optOut'
    init: ->
      @adaptVisibility()
    optOut: ->
      document.cookie = 'beta_opt_in' + '=;expires=Thu, 01 Jan 1970 00:00:01 GMT;'
      location.reload()
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

  class WhatsNextHeadlineComponent extends @Component
    tagName: 'li'
    name: 'whats-next-headline-component'
    beforeDestroy: (callback) ->
      if this.model.get('state') isnt 'new'
        @reloadEl()
        @$el.fadeOut 400, callback
      else
        super(callback)

  class WhatsNextComponent extends @Component
    name: 'whats-next-component'
    collectionEvents: "add remove reset change"
    className: 'hidden'
    init: (options)->
      # we handle showing and hiding
      # with the scroll event because
      # render doesn't get fired that
      # often
      $(window).scroll => @renderify()
      @collection = new ArticleCollection options.collection.whatsNext()
      @components = 
        headline: WhatsNextHeadlineComponent
      
      $(window).one 'scroll', =>
        @continuousRender()
    renderify: ->
      # can't think of a better name. LOL
      unless @hasNone()
        @hideIfBlocked()
        @render() unless @isVisible()
      else
        @$el.addClass 'hidden'
    hasNone: ->
      @collection.where({state: 'new'}).length is 0
    continuousRender: ->
      @renderify()
      setTimeout => 
        @continuousRender
      , 500      
    hideIfBlocked: ->
      if @isBlocked()
        @$el.addClass 'hidden'
      else
        @$el.removeClass 'hidden'
    isVisible: ->
      !@$el.hasClass('hidden') and @$el.is(':visible')
    isBlocked: ->
      # tells us whether or not an ad or a huge
      # story image is in the way(i.e. visible on screen)
      docViewTop    = $(window).scrollTop()
      docViewBottom = docViewTop + $(window).height()
      for element in $('.b-ad, .c-ad, .media--hp-large .media__figure--widescreen, .hidden-gem, footer')
        el = $(element)
        if el.isOnScreen()
          return true
      false
    properties: ->
      stories: @collection.where({state: 'new'})
    helpers: 
      hasNone: (array) ->
        array.length <= 0

  class Article extends @Model.mixin(@Persistent)
    name: 'article'
    states: ['new', 'seen', 'read']
    defaults:
      state: 'new'
    init: ->
      @load() # get saved attributes from localstorage, if any
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
      [fc[firstIndex], fc[secondIndex], fc[thirdIndex]]

  class ArticleComponent extends @Component
    name: 'article-component'
    events:
      "click a" : "markAsRead"
    init: (options)->
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