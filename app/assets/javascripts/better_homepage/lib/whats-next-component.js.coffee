Framework = require('framework')
Boundary  = require('./boundary')
bowser   = require('bowser')

module.exports = class extends Framework.Component
  name: 'whats-next-component'
  collectionEvents: "add remove reset change"
  className: 'hidden'
  attributes:
    id: 'whats-next'
  init: (options)->
    initialBoundary = new Boundary($('#whats-next-initial.boundary'))
    pos      = $(window).height() * 0.50 # try to figure out vertical center
    top      = initialBoundary.top() - pos
    # @$el.css 'top', top # creates an offset that prevents "bounce"
    $('section#content').prepend @$el
    # debugger
    # if $(window).scrollTop() > top
    #   @show()
    #   @unfreeze()
    # we handle showing and hiding
    # with the scroll event because
    # render doesn't get fired that
    # often
    @collection = new (require('./article-collection'))(options.collection.whatsNext())
    @components = 
      headline: require('./whats-next-headline-component')
  afterInit: ->
    # This has to happen here because our
    # components don't get registered until
    # after init.
    @render()
    @findBoundaries()

    callback = (e) => @detectCollision(e) unless @hasCompleted #or not @isVisible()# so that we don't do extra work when we don't need to
    interval = =>
      callback()
      setTimeout interval, 100

    # Safari has this bizarre issue with scroll events
    # not getting fired in the same way that Chrome 
    # fires them.  This workaround isn't exactly the
    # most performant thing in the world, but I'd rather
    # see this problem go away in production before I
    # figure out a better way to polyfill scrolling.
    if bowser.safari
      interval()
    else
      $(window).on 'DOMMouseScroll mousewheel resize', callback
    

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

  detectCollision: (e) ->
    # delta     = (e.originalEvent.detail or e.originalEvent.wheelDelta)
    for boundary in (@boundaries or [])
      if boundary.hasCrossed()
        if boundary.isInView() and boundary.lastDirection isnt 'scrollDown'
          direction = 'scrollDown'
        else if boundary.isBelow() #and boundary.lastDirection isnt 'scrollDown'
          direction = 'scrollUp'
        if direction
          boundary.lastDirection = direction
          for action in (boundary[direction] or '').split(' ')
            @[action]?(boundary, e)
      boundary.wasInView = boundary.isInView()
    
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

  findBoundaries: ->
    @boundaries = []
    for el in $('.boundary')
      el = $(el)
      @boundaries.push new Boundary $(el)