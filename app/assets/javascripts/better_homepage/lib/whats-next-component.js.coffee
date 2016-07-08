Framework = require('framework')

module.exports = class extends Framework.Component
  name: 'whats-next-component'
  collectionEvents: "add remove reset change"
  className: 'hidden'
  attributes:
    id: 'whats-next'
  init: (options)->
    $('section#content').prepend @$el
    @collection = new (require('./article-collection'))(options.collection.whatsNext())
    @components = 
      headline: require('./whats-next-headline-component')

  afterInit: ->
    @render()

  render: ->
    unless @hasNone()
      super()
    else
      @$el.removeClass 'visible'
      @$el.addClass 'hidden'
      @hasCompleted = true

  hasNone: ->
    @collection.where({state: 'new'}).length is 0   

  isVisible: ->
    # !@$el.hasClass('hidden') and @$el.is(':visible')
    @$el.hasClass('visible')

  properties: ->
    stories: @collection.where({state: 'new'})

  show: ->
    unless @hasNone()
      @$el.removeClass('invisible')
      @$el.removeClass('hidden')
      @$el.addClass('visible')
    else
      @$el.removeClass('visible')
      @$el.addClass('hidden')

  hide: ->
    @$el.removeClass('visible')
    @$el.addClass('hidden')

  hideQuickly: ->
    @$el.removeClass('visible')
    @$el.addClass('invisible')

  freeze: (boundary) ->
    if !@$el.hasClass('frozen')
      offset = @$el.offset()
      # percent = (offset.top / $(document).height()) * 100
      # @$el.css 'top', "#{percent}%"
      @$el.css 'top', offset.top
      @$el.css 'left', offset.left
      @$el.addClass 'frozen'

  unfreeze: (boundary, e={}) ->
    delta     = (e.originalEvent?.detail or e.originalEvent?.wheelDelta) or 0
    if @$el.hasClass('frozen')
      @$el.css 'top', (@$el.css('top') - delta)
      setTimeout =>
        @$el.css 'top', ''
        @$el.css 'left', ''
        @$el.removeClass 'frozen'
      , 0

  rollup: (callback) ->
    @$el.one 'webkitAnimationEnd oanimationend msAnimationEnd animationend',  (e) =>
      @$el.removeClass 'rollup'
      callback?(e)
    @$el.addClass 'rollup'

  rolldown: (callback) ->
    @$el.one 'webkitAnimationEnd oanimationend msAnimationEnd animationend',  (e) =>
      @$el.removeClass 'rolldown'
      callback?(e)
    @$el.addClass 'rolldown'