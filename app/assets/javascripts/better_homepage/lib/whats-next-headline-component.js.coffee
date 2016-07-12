Framework = require('framework')
module.exports = class extends Framework.Component
  tagName: 'li'
  name: 'whats-next-headline-component'
  events:
    click: 'scrollToStory'
  beforeDestroy: (callback) ->
    # only destroy if we actually want to destroy
    if this.model.get('state') isnt 'new'
      @reloadEl()
      @$el.one "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", (e) => 
        # if we finished the last transition
        if e.originalEvent.propertyName is 'margin-bottom'
          callback()
      @$el.addClass 'read' # this class creates an animated transition

  scrollToStory: ->
    objKey = @model.get('id')
    if position = $("[data-obj-key='#{objKey}']").offset()?.top
      $('html, body').animate
        scrollTop: position
      , 2000