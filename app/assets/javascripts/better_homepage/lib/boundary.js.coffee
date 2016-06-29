module.exports = class
  constructor: (el) ->
    @el = el
    @scrollUp = @el.attr('data-scroll-up')
    @scrollDown = @el.attr('data-scroll-down')
    @offset = parseInt(@el.attr('data-offset')) or 0
    @el.css 'margin-top', @offset
    @wasInView = @isInView()
  top: ->
    @el.offset().top
  isInView: ->
    position  = @el.position()
    top       = position.top + @offset
    wind      = $(window)
    winTop    = wind.scrollTop()
    winBottom = (wind.scrollTop() + wind.height())
    top > winTop and top < winBottom
  isOutOfView: ->
    !@isInView()
  hasCrossed: ->
    @wasInView isnt @isInView()
  isAbove: ->
    position  = @el.position()
    top       = position.top + @offset
    wind      = $(window)
    top < (wind.scrollTop() + wind.height())
  isBelow: ->
    !@isAbove()