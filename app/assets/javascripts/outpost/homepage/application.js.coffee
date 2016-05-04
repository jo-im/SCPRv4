#= require framework

class outpost.HomepageEditor extends scpr.Framework

  init: (json)->
    collection = window.aggregator.baseView.collection
    component  = new ContentsComponent
      collection: collection
      el: $('#homepage-editor')
      empty: true
    component.render()

  class ContentsComponent extends @Component
    @componentName: 'contents-component'
    init: ->
      @defineComponents
        content: ContentComponent

        @listenTo @collection, "change:position", =>
          @collection.comparator = 'position'
          @collection.sort()
          @render()

    render: (locals={}, options={}) ->
      super(locals, options)
      @reloadComponents()
      
    helpers: 
      firstDown: (index, options) ->
        options.fn?(this) if index is 0
      seventhDown: (index, options) ->
        options.fn?(this) if index is 6


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

  class ContentComponent extends @Component
    className: 'media'
    events:
      "click": "toggleAssetScheme"
    @componentName: 'content-component'

    init: ->
      # If the content comes in without an asset scheme,
      # which it will if it just came from the aggregator,
      # give it a default value of 'medium'.
      if ['medium', 'none', 'large'].indexOf(@model.get('asset_scheme')) is -1
        @model.set 'asset_scheme', 'medium' 
      @defineComponents
        asset: new AssetComponent model: @model

    toggleAssetScheme: (e) ->
      display = @model.get('asset_scheme')
      if display == 'large'
        @model.set 'asset_scheme', 'medium'
      else if display == 'medium'
        @model.set 'asset_scheme', 'none'
      else if display == 'none'
        @model.set 'asset_scheme', 'large'
      else
        @model.set 'asset_scheme', 'medium'
      window.aggregator.baseView.dropZone.updateInput()

    properties: ->
      title: @model.get('title')
      teaser: @model.get('teaser')

  class AssetComponent extends @Component
    tagName: 'a'
    className: 'media__image-parent'
    @componentName: 'asset-component'
    attributes:
      target: '_blank'

    init: ->
      @display ||= 'medium' #options.context or 'medium'
      @model.url = $(@model.get('thumbnail')).attr('src')

    helpers:
      displayIf: (context, options) ->
        if options?.data?.root?.component?.options?.context is context and this.model.get('asset_scheme') is context
          options.fn?(this) # run block if true
        else
          ''

    properties: ->
      url: $(@model.get('thumbnail')).attr('src') or 'http://placehold.it/640x480'