class outpost.Autosave
  Handlebars   = require 'handlebars/dist/handlebars'
  moment       = require 'moment-strftime'
  PouchDB.plugin require 'pouchdb-upsert'
  safeEval     = (code) ->
    eval("try{\n#{code};\n}catch(err){};")   

  constructor: (options={}) ->
    @options = 
      _id           : 'new'
      id            : undefined  # this is the ID 
      type          : 'document'
      databaseName  : 'scprv4_outpost'
      autoCompaction: true
      revsLimit     : 100
      exclude       : []
    for option of options
      @options[option] = options[option]
    @db           = new PouchDB(@options.databaseName, {auto_compaction: @options.autoCompaction, revs_limit: @options.revsLimit})
    @document     = $(document)
    @elementNames = [
      'input'
      'textarea'
      'select'
    ]
    @doc         = undefined
    @form        = $('form.simple_form[id]')
    # Populate elements we are tracking for DOM changes.
    @elements    = new outpost.Autosave.Elements
    for selector in (@options.elements or [])
      @elements.push new outpost.Autosave.Element(selector)
    # Populate inputs & textareas that we are going to track changes for.
    @fields      = new outpost.Autosave.Elements
      find: [("#main #{elName}[id]" for elName in @elementNames).join(", ")]
      not: [':button', '[type=hidden]', '.datetime:hidden']
    @events      = {}
    @_watchCollections()
    @_initializeWarning()
    @_checkForChangesThenListen()

  listen: ->
    # Listens for changes to our form.
    changeCallback = (e) =>
      console.log 'change made'
      @shouldWarn = true
      @_cancelTimeout()
      @_waitAndSave()
    domChangeCallback = (e) =>
      console.log 'dom change callback'
      @fields.reload()
      @fields.off 'change'
      @fields.one 'change', changeCallback
    @fields.reload().one 'change', changeCallback
    @on 'elementReflect', domChangeCallback
    @elements.on 'mutate', domChangeCallback

  unlisten: ->
    # Stops listening to form changes.
    @_cancelTimeout()
    @off 'elementReflect'
    @fields.reload().off 'change'
    @elements.off 'mutate'

  getDoc: (options={}, callback) ->
    ## This retrieves a document from PouchDB
    ## and returns it to a callback, if provided.
    ## It also assigns the returned document to
    ## our @doc variable.  The @doc is considered
    ## the "current" document, as there really is
    ## no case where we need to deal with multiple
    ## live documents.
    if typeof options is 'function'
      callback = options
      options  = {}
    options.revs ||= true
    @db.get @options._id, options, (error, doc)=>
      unless error
        @doc = doc
        callback(error, doc) if callback
      else
        callback(error) if callback
        throw error

  saveDoc: (options={}, callback) ->
    ## Retrieve the document, in case it already exists from PouchDB.
    ## If it doesn't exist, create a new one so that we have a doc
    ## with an ID that we can continually write to.  Then write our
    ## serialized form data to it.
    ## Essentially, this is an "upsert".
    if typeof options is 'function'
      callback = options
      options  = {}
    options.revs     ||= true
    @getDoc options, (error, doc) =>
      if error?.status is 404
        doc  = @_newDoc()
      else if error
        throw error 
      mdoc = @_mergeDocs @_serialize(), (doc or {})
      mdoc.updatedAt = new Date()
      @db.put mdoc, options, (error, doc) =>
        unless error
          @options._id = doc.id
          @getDoc()
          callback(error, doc) if callback
        else
          if error.status is 409
            @db.upsert @options._id, -> doc
          else
            callback(error) if callback
            throw error

  removeDoc: (options={}, callback) ->
    # Destroy the document in PouchDB and
    # execute a callback, fi there is one.
    if typeof options is 'function'
      callback = options
      options  = {}
    options.revs     ||= true
    @db.remove @doc, options, (error, doc) =>
      unless error
        @doc = undefined
        console.log 'doc removed'
        callback(error, doc) if callback
      else
        callback(error) if callback
        throw error if error

  on: (name, callback) ->
    ## Adds callbacks to our event stack, kinda like jQuery.@
    @events[name] ||= []
    @events[name].push callback

  # private

  _checkForChangesThenListen: ->
    ## Checks to see if the form values differ
    ## from those in the autosave snapshot. 
    ## Then we start listening for changes to
    ## the form once we are done.

    mapToIds = (collection) ->
      ids = $.map collection, (model) ->
        model.id
      ids.sort()

    @getDoc (error, doc) =>
      unless error
        docA = @_serialize()
        docB = doc
        for key of docA.fields
          ## Blank fields are serialized as blank strings, but this is
          ## equivalent to an undefined field in an autosaved doc, so
          ## we had might as well consider a blank string the default 
          ## for a non-value.
          if (docA?.fields?[key] or '').toString() isnt (docB?.fields?[key] or '').toString()
            @_changesHaveBeenMade()
            return true
        for key of docA.collections
          if mapToIds(docA?.collections?[key]).toString() isnt mapToIds(docB?.collections?[key]).toString()
            @_changesHaveBeenMade()
            return true
      # Start listening to changes if autosave isn't different.
      @listen()
    false

  _newDoc: ->
    ## Just an empty "doc" that we can populate when
    ## we serialize.
    {
      _id: @options._id
      id: @options.id
      type: @options.type
      fields: {}
      collections: {}
      elements: {}
    }

  _watchCollections: ->
    # Observes changes to collections so
    # we can know when to serialize them.
    $(document).ready =>
      for collectionName in (@options.collections or [])
        if collection = safeEval("window.#{collectionName}")?.collection 
          collection.on 'change', =>
            @shouldWarn = true
            @_waitAndSave()

  _initializeWarning: ->
    # This displays a warning window if a user tries to leave
    # the page while they have unsaved changes.  The warning
    # should not display if they have clicked 'Save', or if
    # no changes have occurred.
    @shouldWarn  = false
    $("form.simple_form").on 'submit', =>
      @shouldWarn = false
      true
    $(window).one 'beforeunload', =>
      if @shouldWarn
        return 'This content has unsaved changes.  If you want to keep these changes, you can stay on the page and click \'Save\'.'

  _waitAndSave: ->
    ## Will save the document after 1 second unless
    ## the timeout is cancelled by more typing.
    callback = => @saveDoc()
    @timeout = setTimeout callback, 1000

  _cancelTimeout: ->
    clearTimeout(@timeout) if @timeout

  _mergeDocs: (a, b) ->
    # changes from a merge into b
    # not destructive
    mergedDoc = {}
    for key of b
      mergedDoc[key] = b[key]
    for key of a
      mergedDoc[key] = a[key]
    mergedDoc

  _changesHaveBeenMade: ->
    # Displays modal if changes are detected
    # in the autosaved document on page load.
    @shouldWarn = true
    modalHTML = @_render
      template: '#autosave-recovery-modal-body-template'
      locals: 
        timestamp: moment(@doc.updatedAt).strftime('%m/%d/%y %I:%M %p')
    @_createModal 'You have some unsaved changes.', modalHTML

  _createModal: (title, body) ->
    # Method for displaying our recovery modal.
    html = @_render
      template: '#autosave-modal-template'
      locals:
        title: title
        body: body
    $('body').append html
    modal         = $('#autosave-modal')
    modal.one 'click', 'button', (e) =>
      if e.target.id is 'yes'
        @_reflect()
      else if e.target.id is 'no'
        @shouldWarn = false
        @removeDoc()
      modal.remove()
      @listen()
    modal.modal({show: true, background: true})

  _render: (options={}) ->
    ## Renders a Handlebars template.
    ## Pass in a tag ID through the `template` option.
    ## Pass variables through the `locals` option.
    options.locals ||= {}
    if options.template
      source   = $(options.template).html()
      template = Handlebars.compile(source)
      template(options.locals)

  _trigger: (name, doc) ->
    @events[name] ||= []
    for f in @events[name]
      f(doc)

  _reflect: ->
    # Take an autosaved document, if it exists,
    # and display the values of its fields
    # in the form on the page.
    @getDoc (error, doc) =>
      unless error
        @_trigger('reflect', doc)
        # elements  
        # NOTE: This should happen before field reflection.
        for selector of (doc.elements ||= {})
          el = $(selector)
          if el.length > 0
            @DefaultReflectors["elementReflector"]?(el, doc.elements[selector])
            @_trigger('elementReflect', el, doc.elements[selector])
        # fields
        ## Not sure of a better way to do this.
        $("select").not('[data-disable-select2="true"]').select2
          placeholder: " "
          allowClear: true
        for key of (doc.fields ||= {})
          el    = $("#main ##{key}")
          if el.length > 0
            type  = el.attr('type') or el.prop("tagName")?.toLowerCase()
            value = doc.fields[key]
            @DefaultReflectors["#{type}Reflector"]?(el, value)
            @_trigger('fieldReflect', el, value)
        # collections
        for name of (doc.collections ||= {})
          if collectionView = safeEval("window.#{name}")
            collection = collectionView.collection
            @DefaultReflectors["collectionReflector"]?(name, collection, doc.collections[name])
            @_trigger('collectionReflect', name, collection, doc.collections[name])

  _serialize: ->
    # Convert the form fields on the page to a JSON
    # document that can be used to save to PouchDB.
    doc = 
      fields:      {}
      collections: {}
      elements:    {}
    # fields
    for field in @fields
      field         = field.$
      if field.length > 0
        fieldId       = field.attr('id')
        type          = field.attr('type') or field.prop("tagName")?.toLowerCase()
        doc.fields[fieldId]  = @DefaultSerializers["#{type}Serializer"]?(field)
        # debugger if field.attr('id') is 'news_story_bylines_attributes_0_name'
        @_trigger('fieldSerialize', field)
    # collections (e.g. asset manager, content aggregator)
    for name in (@options.collections or [])
      if collectionView = safeEval("window.#{name}")
        doc.collections[name] = @DefaultSerializers["collectionSerializer"]?(name, collectionView.collection)
        @_trigger('collectionSerialize', name, collectionView.collection)
    # elements (e.g. stuff like bylines where fields might be dynamically appended)
    for selector in (@options.elements or [])
      el = $(selector)
      if el.length > 0
        doc.elements[selector] = @DefaultSerializers["elementSerializer"]?(el)
        @_trigger('elementSerialize', el)
    @_trigger('serialize', doc)
    doc

  _writeDialog: (text) ->
    # Writes a snippet of text to the submit-row.
    # Could be useful to display status.
    $(".submit-row span#dialog").text text

  DefaultSerializers: 
    ## Serializers are used to convert a field element
    ## to a value in a PouchDB document.
    ## The return value is assigned to the field.
    checkboxSerializer: (el) ->
      el.prop('checked')
    textSerializer: (el) ->
      el.val()
    textareaSerializer: (el) ->
      el.val()
    selectSerializer: (el) ->
      el.val()
    collectionSerializer: (name, collection) ->
      collection.toJSON()
    urlSerializer: (el) ->
      el.val()
    elementSerializer: (el) ->
      shadowCopy = el.clone()
      shadowCopy.find('.select2-container').remove() # strip select2 elements
      shadowCopy.find('select.select2-offscreen').removeClass('select2-offscreen')
      shadowCopy.find('script').remove() # remove script tags
      shadowCopy.html()

  DefaultReflectors:
    ## Reflectors are used to take values stored in a
    ## document and display them properly in the DOM.
    ## Assign the value to the element according to type.
    checkboxReflector: (el, value) ->
      el.prop 'checked', value
    textReflector: (el, value) ->
      el.prop 'value', value
    urlReflector: (el, value) ->
      el.prop 'value', value
    textareaReflector: (el, value) ->
      el.val value
    selectReflector: (el, value) ->
      el.select2('val', value)
    collectionReflector: (name, collection, json) ->
      collection.update json
      if collectionView = safeEval("window.#{name}")
        collectionView.render()
    elementReflector: (el, value) =>
      recursiveDestroy = (el) ->
        while el.firstChild
          recursiveDestroy el.firstChild
          el.removeChild el.firstChild
      recursiveDestroy el[0]
      el = $(el[0])
      el.html value

  class @Elements extends Array
    ## This is a collection for our own Element class.
    constructor: (selector) ->
      @selector = selector
      @refresh()
      
    refresh: ->
      @off()
      @.length = 0 # clear
      for el in (new outpost.Autosave.Element(e) for e in @_query())
        @push(el)
      @

    reload: ->
      for el in (new outpost.Autosave.Element(e) for e in @_query())
        if i = @_exists(el)
          @[i].$ = el.$
        else
          @push el
      @

    on: (event, callback) ->
      for element in @
        element.on(event, callback)

    one: (event, callback) ->
      for element in @
        element.one(event, callback)

    off: (event, callback) ->
      for element in @
        element.off(event, callback)

    _exists: (element) ->
      # Returns array index if exists, else false.
      i = 0
      for el in @
        if element.guid is el.guid
          return i
        i++
      false

    _isFunction: (object) ->
      typeof object is 'function'

    _query: ->
      selection = $(document)
      for key of @selector
        for val in @selector[key]
          selection = selection[key](val)
      selection


  class @Element
    ## This is here to make event tracking uniform
    ## across different DOM elements.  For example,
    ## a custom onchange 'observer' is added to 
    ## textarea so that, even if its own oninput/onchage
    ## events aren't triggered because of CKEDITOR, we
    ## can still track its value changes.  This also
    ## provides a 'mutate' event which adds a MutationObserver
    ## to a DOM element so we can track whether it has had
    ## any children inserted or removed.
    constructor: (selector) ->
      @$ = $(selector)
      @guid = @$.prop('tagName') + @$.prop('id') + @$.prop('name') + @$.prop('type')
      @value  = @getVal()
      @callbacks = {}
      @observers = {}
      @_shim()

    on: (event, callback) ->
      callbacks = (@callbacks[event] ||= [])
      callbacks.push callback
      @_shim event
      true

    one: (event, callback) ->
      # This only adds an event to the stack if no
      # others exist under that name.  Kind of crufty
      # but it works for our particular need.
      callbacks = (@callbacks[event] ||= [])
      callbacks.pop()
      callbacks.push callback
      @_shim event
      true

    getVal: ->
      type = @$.prop('type')
      if type is 'checkbox'
        @$.prop('checked')
      else
        @$.val()

    off: (event, callback) ->
      # Passing a callback here doesn't actually
      # schedule it to perform; if you have an 
      # existing callback, you can pass it here
      # and turn it off specifically.  Otherwise,
      # all callbacks for the event are removed.
      clearInterval(@changeObserver) if event is 'change'
      @mutationObserver?.disconnect() if event is 'mutate'
      if !event
        for e of @callbacks
          @off e
        return true

      callbacks = (@callbacks[event] ||= [])
      unless callback
        callbacks.pop() while callbacks.length > 0
      else
        i = 0
        for cb in callbacks
          if cb is callback
            callbacks.splice(i, 1)
          i++
      @$.off event
      true

    trigger: (event) ->
      callbacks = (@callbacks[event] ||= [])
      for callback in callbacks
        setTimeout => 
          callback({event: event, target: @})
        , 0
      true

    _needsOnChangeShim: ->
      # Text areas have an oninput event, but this is not triggered
      # because CKEDITOR dynamically inserts edits to the textarea that
      # it keeps in the background.  Time pickers have a similar issue.
      @$.prop("tagName").match('TEXTAREA') or @$.hasClass('timestamp-el')

    _needsOnChangeAsInput: ->
      @$.prop("type").match('checkbox') or @$.prop("tagName").match('SELECT')

    _shimOnChange: (event='change')->
      @changeObserver = setInterval =>
        a = @getVal()
        b = @value
        if Array.isArray(a) and Array.isArray(b)
          isntEqual = !@_arrayCompare(a, b)
        else
          isntEqual = a isnt b
        if isntEqual 
          @trigger(event)
          @value = a # the new current value
      , 1000

    _shim: (event) ->
      # Shim specific events, or pass the event on to jQuery.
      if event?.match(/change|input/)
        if @_needsOnChangeShim()
          @_shimOnChange()
        else
          @$.on 'change input', => @trigger(event)
      else if event?.match(/mutate/)
        callback = => @trigger(event)
        if element  = @$[0]
          (@mutationObserver ||= new(window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver)(callback))?.observe element,
            attributes: true
            childList: true
            characterData: true
      else
        @$.on event, => @trigger(event)

    _arrayCompare: (a, b) ->
      (a.length == b.length) and a.every (element, index) -> element is b[index]