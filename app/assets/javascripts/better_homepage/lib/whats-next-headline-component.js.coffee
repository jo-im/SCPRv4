Framework = require('framework')
module.exports = class extends Framework.Component
  tagName: 'li'
  name: 'whats-next-headline-component'
  beforeDestroy: (callback) ->
    if this.model.get('state') isnt 'new'
      @reloadEl()
      @$el.one "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", (e) => 
        # if we finished the last transition
        if e.originalEvent.propertyName is 'margin-bottom'
          callback()
      @$el.addClass 'read' # this class creates an animated transition
    else
      super(callback)