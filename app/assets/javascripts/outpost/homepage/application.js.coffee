#= require framework

class outpost.HomepageEditor extends scpr.Framework

  scroll = require 'jquery.scrollto'

  constructor: (json)->
    super()
    collection = window.aggregator.baseView.collection
    component  = new ContentsComponent
      model: collection
      el: $('#homepage-editor')
    component.render()

  class ContentComponent extends @Component
    className: 'media'
    events:
      "click": "toggleAssetDisplay"
    initialize: ->
      super()
      @defineComponents
        asset: AssetComponent

    toggleAssetDisplay: (e) ->
      display = @model.get('asset_display')
      if display == 'large'
        @model.set 'asset_display', 'medium'
      else if display == 'medium'
        @model.set 'asset_display', 'none'
      else if display == 'none'
        @model.set 'asset_display', 'large'
      window.aggregator.baseView.dropZone.updateInput()

    attributes: ->
      {
        title: @model.get('title')
        teaser: @model.get('teaser')
      }

  class ContentsComponent extends @Component
    initialize: ->
      super()
      @components = 
        content: ContentComponent
      @_fixPageScroll()

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

    # private

    _fixPageScroll: ->
      ## This prevents the annoyance of having the page scroll
      ## once you have scrolled beyond the top or bottom of
      ## the editor.
      @$el.on 'wheel', (e) ->
        $this = $(this)
        if e.originalEvent.deltaY < 0
          $this.scrollTop() > 0
        else
          $this.scrollTop() + $this.innerHeight() < $this[0].scrollHeight

  class AssetComponent extends @Component
    initialize: (attributes, options) ->
      @display = options.context or 'medium'
      super
      @model.url = $(@model.get('thumbnail')).attr('src')
      @Handlebars.registerHelper 'ifMedium', (context, options) ->
        if @component.display is 'medium' and @model.get('asset_display') is 'medium'
          arguments[arguments.length - 1]?.fn?(@)
        else
          ''
      @Handlebars.registerHelper 'ifLarge', (context, options) ->
        if @component.display is 'large' and @model.get('asset_display') is 'large'
          arguments[arguments.length - 1]?.fn?(@)
        else
          ''

    attributes: ->
      {
        url: $(@model.get('thumbnail')).attr('src')
      }