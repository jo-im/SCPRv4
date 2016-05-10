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
      @$el.addClass @model.get('state')
      $(window).scroll => @markAsSeen() if @isScrolledIntoView()

    markAsSeen: ->
      @model.set 'state', 'seen'
      @$el.find('.unread').fadeOut 1500
      @$el.find('.status').removeClass 'notify'

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
      @$el.removeClass 'new seen read'
      @$el.addClass @model.get('state')

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