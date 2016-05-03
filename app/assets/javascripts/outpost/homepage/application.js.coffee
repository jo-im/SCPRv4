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
      "click": "toggleAssetDisplay"
    @componentName: 'content-component'

    init: ->
      @defineComponents
        asset: new AssetComponent model: @model

    toggleAssetDisplay: (e) ->
      display = @model.get('asset_display')
      if display == 'large'
        @model.set 'asset_display', 'medium'
      else if display == 'medium'
        @model.set 'asset_display', 'none'
      else if display == 'none'
        @model.set 'asset_display', 'large'
      else
        # Some models seem to be coming in with 
        # asset_display names like 'photo'. 
        # Maybe we have a naming conflict, so we
        # have to do this for now.
        @model.set 'asset_display', 'medium'
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
        if options?.data?.root?.component?.options?.context is context and this.model.get('asset_display') is context
          options.fn?(this) # run block if true
        else
          ''

    properties: ->
      url: $(@model.get('thumbnail')).attr('src') or 'http://placehold.it/640x480'