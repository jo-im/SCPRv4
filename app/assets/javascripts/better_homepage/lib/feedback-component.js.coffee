Framework = require('framework')
module.exports = class extends Framework.Component
  name: 'feedback-component'
  init: ->
    @insertTracking()
    @adaptVisibility()
  adaptVisibility: ->
    # This seems to work fine for now, though maybe something
    # based on scrollStop would be preferable.  This at least
    # takes care of onLoad.
    if $('footer.footer').isOnScreen()
      @$el.addClass 'hidden'
    else
      @$el.removeClass 'hidden'
    setTimeout =>
      @adaptVisibility()
    , 500
  insertTracking: ->
    link = @$el.find('a.beta-opt-out')
    link.addClass('track-event')
    link.attr('data-ga-category', "@currentCategory")
    link.attr('data-ga-action', "Opt-Out")
    link.attr('data-ga-label', "@scrollDepth")