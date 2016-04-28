#= require framework

class outpost.HomepageEditor extends scpr.Framework

  constructor: (json)->
    super()
    collection = window.aggregator.baseView.collection
    component  = new ContentsComponent
      model: collection
      el: $('#homepage-content')
    component.render()

  class ContentComponent extends @Component
    className: 'media'
    events:
      "click": "toggleAssetDisplay"
    initialize: ->
      super()
      @components =
        asset: AssetComponent
      # @Handlebars.registerHelper 'asset', (context, options) =>
      #   component = new AssetComponent(options)
      #   new Handlebars.SafeString component.toHTML()

    toggleAssetDisplay: (e) ->
      display = @model.get('asset_display')
      if display == 'large'
        @model.set 'asset_display', 'medium'
      else if display == 'medium'
        @model.set 'asset_display', 'none'
      else if display == 'none'
        @model.set 'asset_display', 'large'

  class ContentsComponent extends @Component
    initialize: ->
      super()
      @components = 
        content: ContentComponent

    render: ->
      # Render our base element.
      super()
      # Take each of our models, render them, and append to our UL
      el = @$el#?.find('ul')
      if el and el.length
        for model in (_.sortBy @model.toArray(), (m) => m.attributes.position)
          modelComponent = new ContentComponent
            model: model
          el.append modelComponent.render().$el

  class AssetComponent extends @Component
    initialize: (attributes, display='medium') ->
      @display = display
      super
      @Handlebars.registerHelper 'ifMedium', (context, options) ->
        if @component.display is 'medium' and @model.get('asset_display') is 'medium'
          arguments[arguments.length - 1]?.fn?.call(@)
        else
          ''

      @Handlebars.registerHelper 'ifLarge', (context, options) ->
        if @component.display is 'large' and @model.get('asset_display') is 'large'
          arguments[arguments.length - 1]?.fn?.call(@)
        else
          ''