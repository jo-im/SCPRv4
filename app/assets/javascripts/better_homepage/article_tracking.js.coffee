scpr.Framework = require 'frameworkv2'

class scpr.ArticleTracking extends scpr.Framework

  init: (selector) ->
    new ArticlesComponent
      el: $(selector).first()

  class WhatsNextComponent extends @Component
    name: 'whats-next-component'
    init: ->
      @render()
    properties: ->
      # take a cue from the css and only
      # do the work if our component is
      # visible(i.e. display: block;)
      stories: (=> if @$el.is(':visible') then @model.whatsNext() else [])()

    helpers: 
      hasNone: (array) ->
        array.length <= 0

  class Article extends @Model.mixin(@Persistent)
    self = @
    name: 'article'
    states: ['new', 'seen', 'read']
    defaults:
      state: 'new'
    init: ->
      @load() # get saved attributes from localstorage, if any
      @listenTo @, 'change', =>
        @save()
    whatsNext: ->
      collection         = (@collection or new ArticleCollection)
      thisIndex          = collection.indexOf @
      filteredCollection = collection.filter (model, index) => (index > 2) and (index > thisIndex) and (model isnt @)
      limitedCollection  = _.last _.shuffle(filteredCollection), 3
      _.sortBy limitedCollection, (model) => model.cid

  class ArticleCollection extends @Collection
    name: 'article-collection'
    model: Article

  class ArticleComponent extends @Component
    name: 'article-component'
    events:
      "click a" : "markAsRead"
    inView: false
    init: ->
      @addActiveComponent new WhatsNextComponent
        el: $('#whats-next')
        model: @model
      @render()
      $(window).scroll =>
        # this is set up to prevent needless re-rendering
        # upon every scroll event firing.
        if @isScrolledIntoView()
          @markAsSeen()
          @renderActiveComponents() unless @inView
          @inView = true
        else
          @inView = false

      # If no timestamp is present(which can change on conditions),
      # display the feature type.
      unless @$el.find('time').text().length
        label = @$el.find(".media__meta .media__label")
        if label.attr('data-media-label')
          label.append label.attr('data-media-label')
          label.find('use').attr('xlink:href', "#icon_line-audio")

    updateWhatsNext: ->


    stateToMediaClass: ->
      @stateTranslation[@model.get('state')] or ''

    stateTranslation:
      new: 'media--new-and-unread'
      read: 'media--visited-and-read'

    markAsSeen: ->
      unless @model.get('state') is 'read'
        @model.set 'state', 'seen'

    markAsRead: (e) ->
      @model.set 'state', 'read'

    isScrolledIntoView: ->
      docViewTop    = $(window).scrollTop()
      docViewBottom = docViewTop + $(window).height()
      headline      = @$el.find('.media__headline')
      elemTop       = headline.offset().top
      elemBottom    = elemTop + headline.height()
      elemBottom <= docViewBottom and elemTop >= docViewTop

    render: ->
      @$el.removeClass (klass for state, klass of @stateTranslation).join(' ')
      @$el.addClass @stateToMediaClass()


  class ArticlesComponent extends @Component
    name: 'articles-component'
    components:
      article: ArticleComponent
    init: (options={}) ->
      @options.headless = true
      @collection = new ArticleCollection()
      articleEls = @$el.find('[data-obj-key]')
      @collection.reset ({'id': $(el).attr('data-obj-key'), title: $(el).find('a.headline__link').text()} for el in articleEls)

      for model in @collection.models
        objKey = model.get('id')

        new ArticleComponent
          model: model
          el: @$el.find("[data-obj-key='#{objKey}']")