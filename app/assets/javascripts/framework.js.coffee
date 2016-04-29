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
#   init: ->
#     picture = new Picture
#       el: "#picture"
#     picture.render()
# ```

class scpr.Framework

  Handlebars = require 'handlebars/dist/handlebars'

  # class JavaScriptCompiler extends Handlebars.JavaScriptCompiler
  #   invokeHelper: (paramSize, name, isSimple) ->
  #     super()
  #     console.log('hello world')

  # Handlebars.JavaScriptCompiler = JavaScriptCompiler

  safeEval: (code) ->
    eval("try{\n#{code};\n}catch(err){};")

  constructor: (options={}) ->
    # Call init function, to stay uniform with
    # the rest of the framework.
    @init?(options)

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

    @isComponentClass = true

    tagName: 'div'

    initialize: ->
      # @uuid = @_generateUUID()
      # Either inject components as dependencies after
      # initialize or override your inherited initialize
      # function.
      @components ||= {}
      @options    ||= {}
      # Components that are currently being used, including
      # any that were generated from a constructor.
      @activeComponents = []
      # Stores current renderings by UUID to be referenced
      # when the component elements are inserted into the DOM.
      @activeRenderings = {}
      # Scope Handlebars ENV to this component.
      @Handlebars = Handlebars.create()
      # Goes through the `helpers` hash registers the
      # functions with Handlebars.
      @_registerHelpers()
      @name       = this.constructor.name
      # Find designated template in the DOM, if it exists.
      # This would be a Handlebars template in a script tag.
      templateEl = $("script##{@name}[type='text/x-handlebars-template']")
      if templateEl.length
        @template = @Handlebars.compile templateEl.text()
      # Set element attributes
      for name, value of (@tagAttributes or {})
        @$el?.attr name, value
      # A component also makes the assumption that you
      # want it to re-render when its model changes.
      if @model
        @listenTo @model, "add change destroy", @render
      if @collection
        @listenTo @collection, "reset update sort change", @render
      # Call `init` function, which allows for a similar
      # initialization without having to call `super` 
      # every time you extend Component.
      @init?()




    defineComponents: (components={}) ->
      ## Add child components to the current component
      ## and automatically create helpers for them.
      for name, component of components
        @components[name] = component
        helper = (context, options={}) ->
          parentComponent = this.component or context?.data?.root?.component
          componentName   = '{{name}}'
          options.context = context
          if component = parentComponent?.components?[componentName]
            ## A component can take either a component constructor
            ## or a component instance.  If we get a constructor,
            ## we initialize a new one.  This is for cases where
            ## the number of child components is unpredictable.
            if component.isComponentClass
              component  = new component model: @
            renderId = component.render(this, options)
            parentComponent.activeComponents?.push component
            new component.Handlebars.SafeString component.placeholder(renderId)
        ## This is a workaround for the helper to have access to its own name.
        ## Not sure why this isn't already possible in Handlebars.
        @Handlebars.registerHelper name, eval @Handlebars.compile('(' + helper.toString() + ')')({name: name})


    renderHTML: (locals={}, options={}) ->
      # This generates HTML from the template
      # but does not actually render it to
      # the component's element.
      #
      # For internal use only.
      @options = options # store the options passed from the caller
      if @template
        @template @_params() # pass our properties to the template
        # Think of it as telling the template what local variables
        # to have, vs the options we set above, which is changing
        # the state of our component.
      else
        ""

    renderComponents: (locals={}, options={})->
      @clearActiveComponents()
      html = @renderHTML(locals, options) # generating the HTML will run the helpers that will re-populate the active components
      @$el?.html html
      for component in @activeComponents
        for id, rendering of component.activeRenderings
          placeholder = @$el.find("script##{id}[type='text/x-framework-component-placeholder']")
          if id is placeholder.attr('id')
            # Replace the placeholder tag with a new node
            # that has the designated event handlers copied
            # with it so that component-defined behavior
            # remains.
            placeholder.replaceWith component.$el.clone(true).html(rendering)
        component.activeRenderings = {} # Okay, child.  You don't need your renderings anymore. :)
      @$el.find("script[type='text/x-framework-component-placeholder']").remove() # clear any dead-end placeholders
      @

    render: (locals={}, options={}) ->
      # Here, we render the component and store the output with an ID.
      id = @_generateUUID()
      @activeRenderings[id] = @renderComponents(locals, options)?.$el?.html() # spit out the markup, but not the element
      id

    placeholder: (id) ->
      new @Handlebars.SafeString "<script id='#{id}' type='text/x-framework-component-placeholder'></script>"

    remove: ->
      @trigger 'clean_up'
      super()

    clearActiveComponents: ->
      for i of @activeComponents
        component = @activeComponents.pop()
        component.clearActiveComponents()
        component.remove()
      @trigger 'clean_up'

    # private

    _registerHelpers: ->
      for name, helper of (@helpers or {})
        @Handlebars.registerHelper name, helper

    _params: (externalParams={})->
      ## This is what gets passed on to templates
      ## and child components.  Include an 'properties'
      ## method on the component to add more parameters.
      params =
        model: (@model or @properties)
        collection: @collection
        component: @
      for name, attr of (@properties?() or {})
        params[name] = attr
      for name, attr of externalParams
        params[name] = attr
      params

    _generateUUID: ->
      d = (new Date).getTime()
      uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
        r = (d + Math.random() * 16) % 16 | 0
        d = Math.floor(d / 16)
        (if c == 'x' then r else r & 0x3 | 0x8).toString 16
      )
      uuid