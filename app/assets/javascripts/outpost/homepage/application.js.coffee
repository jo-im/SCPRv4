#= require framework

class outpost.HomepageEditor extends scpr.Framework

  init: (json)->
    collection = window.aggregator.baseView.collection
    component  = new ContentsComponent
      collection: collection
      el: $('#homepage-editor')
    component.render()

  class ContentsComponent extends @Component
    init: ->
      @defineComponents
        content: ContentComponent
      if @collection
        @collection.comparator = 'position'
        @listenTo @collection, "reset update change", =>
          @collection.sort()

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

    init: ->
      # @$el.on 'click', => @toggleAssetDisplay()
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
      {
        title: @model.get('title')
        teaser: @model.get('teaser')
      }

  class AssetComponent extends @Component
    tagName: 'a'
    className: 'media__image-parent'
    attributes:
      target: '_blank'

    init: ->
      @display ||= 'medium' #options.context or 'medium'
      @model.url = $(@model.get('thumbnail')).attr('src')

    helpers:
      displayIf: (context, options) ->
        debugger
        if this.model.get('asset_display') is context
          debugger
          options.fn?(this) # run block if true
        else
          ''
      ifMedium: (context, options) ->
        if context?.data?.root?.component?.options?.context is 'medium' and this.model.get('asset_display') is 'medium'
          arguments[arguments.length - 1]?.fn?(this) # run block if true
        else
          ''
      ifLarge: (context, options) ->
        if context?.data?.root?.component?.options?.context is 'large' and this.model.get('asset_display') is 'large'
          arguments[arguments.length - 1]?.fn?(this) # run block if true
        else
          ''

    properties: ->
      {
        url: $(@model.get('thumbnail')).attr('src') or 'http://placehold.it/640x480'
      }