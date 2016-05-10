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

class Framework
  Handlebars            = require 'handlebars/dist/handlebars'

  constructor: (options={}) ->
    # Call init function, to stay uniform with
    # the rest of the framework.
    @init?(options)

  class @Model extends Backbone.Model
    initialize: ->
      @beforeInit?() # before and after are hooks mainly for mixins
      @init?()
      @afterInit?()

  class @Collection extends Backbone.Collection
    initialize: ->
      @beforeInit?()
      @init?()
      @afterInit?()

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

    initialize: (context={}, options={}) ->
      @uuid       = @_generateUUID()
      @name       = @constructor._name
      @$el.attr('data-framework-component-id', @uuid)
      @$el.attr('data-framework-component-name', @name)
      # By default, if the component's element has no content,
      # the element will render blank.  Set the attribute 
      # `empty` to true if the element should be rendered,
      # despite having no child nodes.
      @empty      = false
      # Either inject components as dependencies after
      # initialize or override your inherited initialize
      # function.
      @components ||= {}
      @options    ||= {}
      # Components that are currently being used, including
      # any that were generated from a constructor.
      @activeComponents = []
      # Scope Handlebars ENV to this component.
      @Handlebars = Handlebars.create()
      # Goes through the `helpers` hash registers the
      # functions with Handlebars.
      @_registerHelpers()
      # Find designated template in the DOM, if it exists.
      # This would be a Handlebars template in a script tag.
      templateEl = $("script##{@name}[type='text/x-handlebars-template']")
      if templateEl.length
        @template = @Handlebars.compile templateEl.text()
      # Set element attributes
      for name, value of (@tagAttributes or {})
        @$el?.attr name, value
      # Call `init` function, which allows for a similar
      # initialization without having to call `super` 
      # every time you extend Component.
      @init?(options)
      # A component also makes the assumption that you
      # want it to re-render when its model changes.
      @_listen()


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
              component  = new component({model: @}, context.hash)
            component.render(this, options)
            parentComponent.activeComponents?.push component
            new component.Handlebars.SafeString component.html()
        ## This is a workaround for the helper to have access to its own name.
        ## Not sure why this isn't already possible in Handlebars.
        @Handlebars.registerHelper name, eval @Handlebars.compile('(' + helper.toString() + ')')({name: name})

    html: ->
      # outerHTML representation of the current element
      # irrespective of rendering.  This is what finally
      # gets inserted into the DOM if the component is a
      # child of another component.
      return '' if !@empty and !@$el.html().trim().length
      @$el?.prop('outerHTML')

    renderHTML: (locals={}, options={}) ->
      # This generates HTML from the template
      # but does not actually render it to
      # the component's element.
      #
      # For internal use only.
      if @template
        @options = options # store the options passed from the caller
        output = @template @_params() # pass our properties to the template
        @options = undefined # get rid of options
        output
        # Think of it as telling the template what local variables
        # to have, vs the options we set above, which is changing
        # the state of our component.
      else
        ""

    render: (locals={}, options={}) ->
      # Inserts generated HTML into its element.
      @clearActiveComponents()
      # Set headless to true in global component
      # options to prevent rendering out, or 
      # simply overwrite the render function to
      # do your own thing.
      unless @options?.headless
        @$el?.html @renderHTML(locals, options)

    reloadComponents: ->
      for component in @activeComponents
        newElement = @$el.find("[data-framework-component-name='#{component.name}'][data-framework-component-id='#{component.uuid}']").first()
        if newElement.length
          component.setElement newElement
          component.reloadComponents()

    remove: ->
      @trigger 'clean_up'
      super()

    clearActiveComponents: ->
      for component in @activeComponents
        component.clearActiveComponents()
        component.unbind()
        delete (component.model or component.collection or {}).options #= undefined
        delete component.components
        component.remove()
      @activeComponents = []
      @trigger 'clean_up'

    # private

    _unlisten: ->
      @stopListening (@model or @collection)

    _listen: ->
      @_unlisten()
      if @model
        @listenTo @model, "change destroy", @render
      if @collection
        @listenTo @collection, "add remove reset", @render

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


  @Persistent =
    # Extend your model or collection off this if
    # you want to persist to localStorage.
    _instance: 
      beforeInit: ->
        @storage = @constructor.storage
      save: ->
        @storage?.setItem @itemKey(), @stringify()
      stringify: ->
        JSON.stringify @toJSON()
      load: ->
        # Uses the current object and retrieves any
        # data that is in localStorage
        if json = @storage?.getItem(@itemKey()) 
          if props = JSON.parse(json)
            @set(props) # tries for a collection and then a model
      itemKey: ->
        "#{@constructor._name}-#{@id}"
    _class:
      storage: window.localStorage or window.sessionStorage
      find: (id) ->
        if json = @storage?.getItem(@itemKey(id))
          new @ json
      findAll: (ids) ->
        @select (k, v) ->
          v.id is id
      saveAll: ->
        # If this is a collection, save all the models
        # individually instead of one stringified
        # collection.
        for model in (@models or [])
          @save model
      select: (filter, collection) ->
        results = []
        for key, value of @storage
          results.push(value) if key.match("#{@_name}-") and filter(key, JSON.parse(value))
        if collection
          collection.reset results
          collection
        else
          results
      itemKey: (id) ->
        "#{@_name}-#{id}"

  # Implements a mixin pattern for our entities.
  # It's useful for when you need to inherit properties
  # and behavior from multiple sources.
  #
  # For example, if you need to create a model that also
  # has behavior from the Persistence mixin, you'd use
  # the follwing syntax:
  #
  # `class Thing extends @Model.mixin(@Persistent)
  @Model.mixin        =
    @Collection.mixin =
    @Component.mixin  = (props) -> @extend(props._instance, props._class)


if typeof module != 'undefined' and module.exports # if node.js/browserify
  module.exports = Framework
else if typeof define == 'function' and define.amd # if AMD
  define -> Framework
else
  window.scpr.Framework = Framework