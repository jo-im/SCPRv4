# This is a simple "framework" based on Backbone and Handlebars
# with the intention to reduce the friction in writing frontend
# code while still remaining light-weight.
# 
# To create a new app based on the framework, you simply create
# a new object(or class in coffeescript) and extend from the
# framework.
#
# Example:
#
# ```
# class App extends scpr.Framework
#   class Picture extends @Component
#
#   constructor: ->
#     super()
#     picture = new Picture
#       el: "#picture"
#     picture.render()
# ```

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
    # with the id 'StoryComponent' and render
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
      @components ||= {}
      @options    ||= {}
      @Handlebars = require 'handlebars/dist/handlebars'
      @_registerHelpers(@Handlebars)
      @name       = this.constructor.name
      templateEl = $("script##{@name}[type='text/x-handlebars-template']")
      if templateEl.length
        @template = @Handlebars.compile templateEl.text()
      # A component also makes the assumption that you
      # want it to re-render when its model changes.
      @listenTo @model, "change", @render

    defineComponents: (components={}) ->
      ## Add child components to the current component
      ## and automatically create helpers for them.
      for name, component of components
        @components[name] = component
        helper = (context, options={}) ->
          parentComponent = this.component
          componentName   = '{{name}}'
          options.context = context
          if component = parentComponent?.components?[componentName]
            new component.Handlebars.SafeString component.toHTML(this, options)
        ## This is a workaround for the helper to have access to its own name.
        ## Not sure why this isn't already possible in Handlebars.
        @Handlebars.registerHelper name, eval("(" + helper.toString().replace(/{{name}}/, name) + ")")


    toHTML: (locals={}, options={}) ->
      # This generates HTML from the template
      # but does not actually render it to
      # the component's element.
      @options = options # store the options passed from the caller
      if @template
        @template @_params() # pass our attributes to the template
        # Think of it as telling the template what local variables
        # to have, vs the options we set above, which is changing
        # the state of our component.
      else
        ""

    render: ->
      @$el?.html @toHTML()
      @

    # private

    _params: (externalParams={})->
      ## This is what gets passed on to templates
      ## and child components.  Include an 'attributes'
      ## method on the component to add more parameters.
      params =
        model: (@model or @attributes)
        component: @
      for name, attr of (@attributes?() or {})
        params[name] = attr
      for name, attr of externalParams
        params[name] = attr
      params

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