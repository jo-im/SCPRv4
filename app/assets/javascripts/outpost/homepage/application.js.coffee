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

    constructor: (model, options={}) ->
      @model = model
      @className = this.constructor.name
      Handlebars.registerHelper 'action', (context, options) =>
        new Handlebars.SafeString "data-action-click=#{context} data-component=#{@className} data-component-id=#{@cid}"
      super()

    initialize: ->
      @template = Handlebars.compile $("##{@className}Template").text()
      $(document).on 'click', "[data-action-click][data-component=#{@className}][data-component-id=#{@cid}]", (e) =>
        target = $(e.target)
        className = target.attr('data-component')
        if actionName = target.attr('data-action-click')
          @actions?[actionName]?(e, @)
      @listenTo @model, "change", @render

    toHTML: (locals={}) ->
      @template
        model: @model

    render: (container) ->
      element = $ @toHTML()
      container?.html?(element)
      externalElement = $("[data-action-click][data-component=#{@className}][data-component-id=#{@cid}]")
      if externalElement.length
        externalElement.replaceWith element
      element

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
    component  = new ContentsComponent(collection)
    component.render($('#homepage-content'))

  class ContentComponent extends @Component
    actions:
      shutmeup: (e, component) =>
        # target = $(e.target) 
        # target.text target.text()?.toLowerCase()
        title = component.model.get('content_type')
        component.model.set 'content_type', title.toLowerCase()
        # debugger

  class ContentsComponent extends @Component


  components:
    ContentComponent: ContentComponent
    ContentsComponent: ContentsComponent

  class Content extends @Model

  class ContentCollection extends @Collection
    model: Content