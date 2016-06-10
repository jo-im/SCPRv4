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
    @beforeInit?()
    @init?(options)
    @afterInit?()

  class @Collection extends Backbone.Collection
    initialize: ->
      @beforeInit?()
      @init?()
      @afterInit?()

  class @Model extends Backbone.Model
    name: 'model'
    initialize: ->
      @beforeInit?() # before and after are hooks mainly for mixins
      @init?()
      @afterInit?()

    # @Collection: ->
    #   self = @
    #   class extends Backbone.Collection
    #     model: self
    #     name: self + '-collection'
    #     initialize: ->
    #       @beforeInit?()
    #       @init?()
    #       @afterInit?()

  class @Component extends Backbone.View
    # A component is basically a Backbone View that
    # uses Handlebars templates and can contain other
    # components that maintain their own scoped behavior.
    # use.  Components are meant to be 'safe' in the sense
    # that they will properly manage their child components
    # to prevent memory leakage.  A template is not
    # necessarily required.  For example, a component
    # can use an element that is already in the DOM.
    #
    # Unlike a Backbone View, a component attempts to render 
    # by default, and assumes that we want to render whenever
    # the model has changed.  This, of course, can be overridden.

    # Since we need to support rendering both
    # pre-instantiated components and classes of components,
    # we need the following attribute to tell us whether
    # or not we are dealing with a class or an instance.
    # Yeah, I know.  It's JS.  They aren't *really* instances.
    @isComponentClass = true

    # I think Backbone already does this, so I'm not sure 
    # why I included it.
    tagName: 'div'
    # Every component should be assigned a name, under 
    # a prototype attribute called 'name'.  The below
    # simply defaults the name to 'component'.  This name
    # is mostly used to reference a corresponding template.
    name   : 'component'

    initialize: (context={}, options={}) ->
      @beforeInit?()
      @uuid       = @_generateUUID()
      @insertFrameworkAttributes()
      # By default, if the component's element has no content,
      # the element will render blank.  Set the attribute 
      # `empty` to true if the element should be rendered,
      # despite having no child nodes.
      @empty      = false
      # Either inject components as dependencies after
      # initialize or override your inherited initialize
      # function.  The latter is not recommended.
      @components ||= {}
      @options    ||= {}
      # Components that are currently being used, including
      # any that were generated from a constructor.  This 
      # helps us garbage collect components we stop using.
      @activeComponents = []
      # Scope Handlebars ENV to this component.
      @Handlebars = Handlebars.create()
      # Goes through the `helpers` hash registers the
      # functions with Handlebars.
      @_registerHelpers()
      if @templatePath
        # If a path to an HBS template has been provided, load
        # that.  Else, search for a script tag under the 
        # assumed name.
        ## NOTE: Unfortunately, there seems to be no way
        ## to require text files that I can get working.
        ## all the solutions, which are Browserify transforms,
        ## appear to do nothing.  I don't know why.
        #
        # Basically, ignore this case for now.
      else
        # Find designated template in the DOM, if it exists.
        # This would be a Handlebars template in a script tag.
        #
        # The currently preferred way for creating a template
        # for your component is to write it in an .hbs file
        # inside a directory in `app/views`, then use the
        # ApplicationHelper#include_handlebars_template helper
        # in your Rails templates.  See that helper for more
        # details on how to use it.
        templateEl = $("script##{@name}[type='text/x-handlebars-template']")
        if templateEl.length
          templateMarkup = templateEl.text()
      # Compile the template to JS for later use.
      if templateMarkup
        # Having no template markup is equivalent
        # to the 'headless' option.
        @template = @Handlebars.compile templateMarkup
      # Set element attributes
      for name, value of (@tagAttributes or {})
        @$el?.attr name, value
      # Call `init` function, which allows for a similar
      # initialization without having to call `super` 
      # every time you extend Component.
      @init?(options)
      # Automatically register components
      @defineComponents @components
      #
      # A component also makes the assumption that you
      # want it to re-render when its model changes.
      @_listen()
      @afterInit?()

    insertFrameworkAttributes: ->
      # This add a unique identifier to the element, which
      # allows deeply-nested components to scope behavior.
      @$el.attr('data-framework-component-id', @uuid)
      @$el.attr('data-framework-component-name', @name)

    defineComponents: (components={}) ->
      ## Add child components to the current component
      ## and automatically create helpers for them.
      #
      ## The point of this is partly so that you can 
      ## technically use the same component twice,
      ## but in different ways and be able to reference
      ## them with different helper names.  Any component
      ## you use will still expect a template named
      ## after itself and not the name given to its helper.
      ## Maybe that will change in the future?
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
            parentComponent.addActiveComponent component
            new component.Handlebars.SafeString component.html()
        ## This is a workaround for the helper to have access to its own name.
        ## Not sure why this isn't already possible in Handlebars.
        @Handlebars.registerHelper name, eval @Handlebars.compile('(' + helper.toString() + ')')({name: name})

    addActiveComponent: (component) ->
      # This is just a canonical way to add an active component
      # to the list of active components.  This is used by the
      # defineComponents method, but can also be called when 
      # instantiating components that aren't pre-defined
      # with a Handlebars helper.
      (@activeComponents ?= []).push component

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
        @insertFrameworkAttributes()
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

    renderActiveComponents: ->
      # If you are instantiating components outside
      # of the normal templating pipeline, this can be
      # useful for triggering all your active components
      # to render.
      component.render() for component in @activeComponents

    clearActiveComponents: (comp)->
      # Effectively 'garbage collects' components in the
      # case that we are no longer using them.  This is to
      # make it easy for us to not have a bunch of components
      # build up on the heap.
      for component in @activeComponents
        # If a component object is provided as an argument,
        # only clear that specific one.
        continue if comp and (component != comp)
        component.clearActiveComponents()
        component.unbind()
        # I've heard some people say that the delete operator
        # should be avoided.  However, it's a part of future
        # ECMAScript editions, and is a clear way of expressing
        # what is intended to happen here.
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
      #
      # You probably don't want to meddle with this.
      params =
        model: (@model or @properties)
        collection: @collection
        component: @
      for name, attr of (@model or {attributes: {}}).attributes
        params[name] = attr
      # Properties set on the component override
      # those that come from the model, 
      # so be careful.
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
        "#{@name}-#{@id}"
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
          results.push(value) if key.match("#{@prototype.name}-") and filter(key, JSON.parse(value))
        if collection
          collection.reset results
          collection
        else
          results
      itemKey: (id) ->
        "#{@prototype.name}-#{id}"

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