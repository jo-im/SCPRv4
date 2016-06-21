scpr.Framework = require 'framework'

class outpost.HomepageEditor extends scpr.Framework

  init: (json)->
    collection = window.aggregator.baseView.collection
    component  = new ContentsComponent
      collection: collection
      el: $('#homepage-editor')
      empty: true
    component.render()

  class ContentsComponent extends @Component
    name: 'contents-component'
    collectionEvents: "add remove reset change:position"
    init: ->
      @components =
        content: ContentComponent

    beforeRender: (callback)->
      @collection.comparator = 'position'
      @collection.sort()
      callback()

    afterRender: ->
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
    name: 'content-component'
    className: 'media'
    events:
      "click": "toggleAssetScheme"
    init: ->
      # # If the content comes in without an asset scheme,
      # # which it will if it just came from the aggregator,
      # # give it a default value of 'medium'.
      # if ['medium', 'none', 'large'].indexOf(@model.get('asset_scheme')) is -1
      #   @model.set 'asset_scheme', 'medium' 
      @defineComponents
        largeAsset: new AssetComponent model: @model, scheme: 'large'
        mediumAsset: new AssetComponent model: @model, scheme: 'medium'

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
    name: 'asset-component'
    tagName: 'a'
    className: 'media__image-parent'
    attributes:
      target: '_blank'

    init: (options)->
      @scheme = options.scheme
      @display ||= 'medium' #options.context or 'medium'
      @model.url = $(@model.get('thumbnail')).attr('src')

    helpers:
      largeScheme: (context, options) ->
        # yeah, I know, I've gotta figure out why this has to be complicated
        scheme = context?.data?.root?.scheme or options?.data?.root?.scheme
        (this.model.get('asset_scheme') is 'large') and (scheme is 'large')
      mediumScheme: (context, options) ->
        scheme = context?.data?.root?.scheme or options?.data?.root?.scheme
        (this.model.get('asset_scheme') is 'medium') and (scheme is 'medium')

    properties: ->
      url: $(@model.get('thumbnail')).attr('src') or 'http://placehold.it/640x480'
      scheme: @scheme