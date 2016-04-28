# This is a simple framework based on Backbone and Handlebars
# with the intention to reduce the friction in writing frontend
# code while still remaining light-weight.

class scpr.Framework

  safeEval: (code) ->
    eval("try{\n#{code};\n}catch(err){};")   

  class @Model extends Backbone.Model

  class @Collection extends Backbone.Collection

  class @Component extends Backbone.View
    # A component is basically a Backbone View that
    # makes an assumption about which template to 
    # use.  For example, if this component is called
    # 'StoryComponent', it will look for a script tag
    # with the id 'StoryComponentTemplate' and render
    # the Handlebars markup in that tag.  However, a
    # template isn't required.
    #
    # It's also set to automatically re-render whenever
    # the model has changed.

    tagName: 'div'

    initialize: ->
      # Either inject components as dependencies after
      # initialize or override your inherited initialize
      # function.
      @components = {}
      @Handlebars = require 'handlebars/dist/handlebars'
      @_registerHelpers(@Handlebars)
      @name       = this.constructor.name
      templateEl = $("script##{@name}[type='text/x-handlebars-template']")
      if templateEl.length
        @template = @Handlebars.compile templateEl.text()
      @listenTo @model, "change", @render

    toHTML: (locals={}) ->
      # This generates HTML from the template
      # but does not actually render it to
      # the component's element. 
      if @template
        @template
          model: (@model or @attributes)
          component: @
      else
        ""

    render: ->
      @$el?.html @toHTML()
      @

    # private

    _registerHelpers: (Handlebars) ->
      ## One caveat here: the component gets "rendered", but its events
      ## will not fire, so if you want to use the component helper
      ## to render a component that has behavior, that behavior has to 
      ## be assigned to a parent component that wasn't rendered with the
      ## same helper.  Hopefull, this will be fixed later on.
      Handlebars.registerHelper 'component', (context, options) ->
        # parentComponent = options?.data?.root?.component
        # component = new parentComponent?.components?[context]?(options.data.root)
        parentComponent = this.component
        component = new parentComponent?.components?[context]?(this, options)
        if component
          new Handlebars.SafeString component.toHTML()