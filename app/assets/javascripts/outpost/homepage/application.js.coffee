#= require outpost/base
#= require outpost/asset_host/assethostbase
#= require shared
class outpost.App
  Handlebars = require 'handlebars/dist/handlebars'

  safeEval: (code) ->
    eval("try{\n#{code};\n}catch(err){};")   

  class @Model extends Backbone.Model

  class @Collection extends Backbone.Collection

  class @Component extends Backbone.View
    tagName: 'div'

    initialize: ->
      @name     = this.constructor.name
      @template = Handlebars.compile $("##{@name}Template").text()
      @listenTo @model, "change", @render

    toHTML: (locals={}) ->
      @template
        model: (@model or @attributes)

    render: ->
      @$el?.html @toHTML()
      @

  constructor: ->
    Handlebars.registerHelper 'component', (context, options) =>
      component = new @components?[context]?(options)
      new Handlebars.SafeString component?.toHTML()


class outpost.HomepageEditor extends outpost.App

  constructor: (json)->
    super()
    json = JSON.parse("[{\"homepage_content\":{\"id\":66086,\"homepage_id\":387,\"content_id\":1858,\"position\":1,\"content_type\":\"Event\",\"homepage_type\":\"Homepage\",\"asset_scheme\":null}},{\"homepage_content\":{\"id\":66087,\"homepage_id\":387,\"content_id\":57796,\"position\":2,\"content_type\":\"NewsStory\",\"homepage_type\":\"Homepage\",\"asset_scheme\":null}},{\"homepage_content\":{\"id\":66088,\"homepage_id\":387,\"content_id\":57798,\"position\":3,\"content_type\":\"NewsStory\",\"homepage_type\":\"Homepage\",\"asset_scheme\":null}},{\"homepage_content\":{\"id\":66089,\"homepage_id\":387,\"content_id\":57789,\"position\":4,\"content_type\":\"NewsStory\",\"homepage_type\":\"Homepage\",\"asset_scheme\":null}},{\"homepage_content\":{\"id\":66090,\"homepage_id\":387,\"content_id\":57786,\"position\":5,\"content_type\":\"NewsStory\",\"homepage_type\":\"Homepage\",\"asset_scheme\":null}}]")
    json = (obj['homepage_content'] for obj in json)
    collection = new ContentCollection(json)
    component  = new ContentsComponent
      model: collection
      el: $('#homepage-content')
    component.render()

  class ContentComponent extends @Component
    tagName: 'li'
    events:
      "click": "_downcaseLi"
    _downcaseLi: (e) ->
      title = @model.get('content_type')
      @model.set 'content_type', title.toLowerCase()


  class ContentsComponent extends @Component
    tagName: 'ul'

    render: ->
      super()
      # Take each of our models, render them, and append to our UL
      el = @$el?.find('ul')
      if el and el.length
        for model in @model.toArray()
          modelComponent = new ContentComponent
            model: model
          # debugger
          el.append modelComponent.render().$el


  class Content extends @Model

  class ContentCollection extends @Collection
    model: Content