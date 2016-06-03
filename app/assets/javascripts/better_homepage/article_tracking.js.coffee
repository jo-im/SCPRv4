scpr.Framework = require 'framework'

class scpr.ArticleTracking extends scpr.Framework

  init: (selector) ->
    new ArticlesComponent
      el: $(selector).first()

  class Article extends @Model.mixin(@Persistent)
    @_name = 'article'
    states: ['new', 'seen', 'read']
    defaults:
      state: 'new'
    init: ->
      @load() # get saved attributes from localstorage, if any
      @listenTo @, 'change', =>
        @save()        

  class ArticleCollection extends @Collection
    @_name = 'article-collection'
    model: Article
    init: ->
      window.coll = @

  class ArticleComponent extends @Component
    @_name: 'article-component'
    events:
      "click a" : "markAsRead"
    init: ->
      @render()
      $(window).scroll => @markAsSeen() if @isScrolledIntoView()
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

    markAsSeen: ->
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
    @_name: 'articles-component'
    init: (options={}) ->
      @options.headless = true
      @collection = new ArticleCollection()
      @defineComponents
        article: ArticleComponent
      articleEls = @$el.find('[data-obj-key]')
      @collection.reset ({'id': $(el).attr('data-obj-key')} for el in articleEls)

      for model in @collection.models
        objKey = model.get('id')

        new ArticleComponent
          model: model
          el: @$el.find("[data-obj-key='#{objKey}']")